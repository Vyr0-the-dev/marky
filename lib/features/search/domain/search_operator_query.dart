import 'package:flutter/foundation.dart';

import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/tags/domain/tag.dart';

enum SearchStatusOperator {
  favorite,
  unread,
  read,
  archived,
}

@immutable
class SearchOperatorQuery {
  const SearchOperatorQuery({
    this.text = '',
    this.tagSlug,
    this.domain,
    this.status,
    this.createdBefore,
    this.createdAfter,
  });

  final String text;
  final String? tagSlug;
  final String? domain;
  final SearchStatusOperator? status;
  final DateTime? createdBefore;
  final DateTime? createdAfter;

  bool get hasText => text.trim().isNotEmpty;
  bool get hasOperators =>
      tagSlug != null ||
      domain != null ||
      status != null ||
      createdBefore != null ||
      createdAfter != null;

  BookmarkFeedQuery toFeedQuery({int? tagId, int limit = 50}) {
    return BookmarkFeedQuery(
      filter: switch (status) {
        SearchStatusOperator.favorite => BookmarkFeedFilter.favorites,
        SearchStatusOperator.unread => BookmarkFeedFilter.unread,
        SearchStatusOperator.archived => BookmarkFeedFilter.archived,
        SearchStatusOperator.read => BookmarkFeedFilter.all,
        null => BookmarkFeedFilter.all,
      },
      tagId: tagId,
      host: domain,
      createdBefore: createdBefore,
      createdAfter: createdAfter,
      limit: limit,
    );
  }

  bool matches(Bookmark bookmark, {int? tagId}) {
    if (tagId != null && !bookmark.tagIds.contains(tagId)) return false;
    if (domain != null && bookmark.normalizedHost != domain) return false;
    if (createdBefore != null && bookmark.createdAt.isAfter(createdBefore!)) {
      return false;
    }
    if (createdAfter != null && bookmark.createdAt.isBefore(createdAfter!)) {
      return false;
    }

    switch (status) {
      case SearchStatusOperator.favorite:
        return !bookmark.isArchived && bookmark.isFavorite;
      case SearchStatusOperator.unread:
        return !bookmark.isArchived && !bookmark.isRead;
      case SearchStatusOperator.read:
        return !bookmark.isArchived && bookmark.isRead;
      case SearchStatusOperator.archived:
        return bookmark.isArchived;
      case null:
        return !bookmark.isArchived;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchOperatorQuery &&
        other.text == text &&
        other.tagSlug == tagSlug &&
        other.domain == domain &&
        other.status == status &&
        other.createdBefore == createdBefore &&
        other.createdAfter == createdAfter;
  }

  @override
  int get hashCode => Object.hash(
        text,
        tagSlug,
        domain,
        status,
        createdBefore,
        createdAfter,
      );
}

class SearchOperatorParser {
  const SearchOperatorParser();

  static final RegExp _operatorPattern = RegExp(
    r'''(^|\s)(tag|domain|is|before|after):("[^"]+"|'[^']+'|\S+)''',
    caseSensitive: false,
  );

  SearchOperatorQuery parse(String rawQuery) {
    String? tagSlug;
    String? domain;
    SearchStatusOperator? status;
    DateTime? createdBefore;
    DateTime? createdAfter;
    final StringBuffer freeText = StringBuffer();
    int cursor = 0;

    for (final RegExpMatch match in _operatorPattern.allMatches(rawQuery)) {
      freeText.write(rawQuery.substring(cursor, match.start));
      cursor = match.end;

      final String operatorName = match.group(2)!.toLowerCase();
      final String value = _stripQuotes(match.group(3)!.trim());
      final bool consumed = switch (operatorName) {
        'tag' => () {
            final String slug = Tag.slugify(value);
            if (slug.isEmpty) return false;
            tagSlug = slug;
            return true;
          }(),
        'domain' => () {
            final String? normalized = _normalizeDomain(value);
            if (normalized == null) return false;
            domain = normalized;
            return true;
          }(),
        'is' => () {
            final SearchStatusOperator? parsed = _parseStatus(value);
            if (parsed == null) return false;
            status = parsed;
            return true;
          }(),
        'before' => () {
            final DateTime? parsed = _parseDate(value, endOfDay: true);
            if (parsed == null) return false;
            createdBefore = parsed;
            return true;
          }(),
        'after' => () {
            final DateTime? parsed = _parseDate(value, endOfDay: false);
            if (parsed == null) return false;
            createdAfter = parsed;
            return true;
          }(),
        _ => false,
      };

      if (!consumed) {
        freeText.write(rawQuery.substring(match.start, match.end));
      }
    }

    freeText.write(rawQuery.substring(cursor));
    return SearchOperatorQuery(
      text: _normalizeFreeText(freeText.toString()),
      tagSlug: tagSlug,
      domain: domain,
      status: status,
      createdBefore: createdBefore,
      createdAfter: createdAfter,
    );
  }

  static SearchStatusOperator? _parseStatus(String value) {
    return switch (value.trim().toLowerCase()) {
      'favorite' || 'favorites' || 'starred' => SearchStatusOperator.favorite,
      'unread' => SearchStatusOperator.unread,
      'read' => SearchStatusOperator.read,
      'archived' || 'archive' => SearchStatusOperator.archived,
      _ => null,
    };
  }

  static DateTime? _parseDate(String value, {required bool endOfDay}) {
    final String trimmed = value.trim();
    final RegExpMatch? dateOnly =
        RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(trimmed);
    if (dateOnly != null) {
      final int year = int.parse(dateOnly.group(1)!);
      final int month = int.parse(dateOnly.group(2)!);
      final int day = int.parse(dateOnly.group(3)!);
      if (endOfDay) {
        return DateTime(year, month, day, 23, 59, 59, 999, 999);
      }
      return DateTime(year, month, day);
    }
    return DateTime.tryParse(trimmed);
  }

  static String? _normalizeDomain(String value) {
    final String lower = value.trim().toLowerCase();
    if (lower.isEmpty) return null;
    final Uri? uri = Uri.tryParse(lower);
    final String candidate = uri != null && uri.hasScheme && uri.host.isNotEmpty
        ? uri.host
        : lower.split('/').first;
    final String host = candidate.trim();
    return host.isEmpty ? null : host;
  }

  static String _stripQuotes(String value) {
    if (value.length < 2) return value;
    final bool doubleQuoted = value.startsWith('"') && value.endsWith('"');
    final bool singleQuoted = value.startsWith("'") && value.endsWith("'");
    return doubleQuoted || singleQuoted
        ? value.substring(1, value.length - 1)
        : value;
  }

  static String _normalizeFreeText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
