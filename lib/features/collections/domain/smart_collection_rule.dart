import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';

@immutable
class SmartCollectionRule {
  const SmartCollectionRule({
    this.filter = BookmarkFeedFilter.all,
    this.tagId,
    this.host,
    this.contentType,
    this.addedWithinDays,
  });

  final BookmarkFeedFilter filter;
  final int? tagId;
  final String? host;
  final BookmarkContentType? contentType;
  final int? addedWithinDays;

  BookmarkFeedQuery toFeedQuery({DateTime? now}) {
    final DateTime? createdAfter = addedWithinDays == null
        ? null
        : (now ?? DateTime.now()).subtract(Duration(days: addedWithinDays!));
    return BookmarkFeedQuery(
      filter: filter,
      tagId: tagId,
      host: host,
      contentType: contentType,
      createdAfter: createdAfter,
    );
  }

  bool matches(Bookmark bookmark, {DateTime? now}) {
    switch (filter) {
      case BookmarkFeedFilter.all:
        if (bookmark.isArchived) return false;
      case BookmarkFeedFilter.favorites:
        if (bookmark.isArchived || !bookmark.isFavorite) return false;
      case BookmarkFeedFilter.unread:
        if (bookmark.isArchived || bookmark.isRead) return false;
      case BookmarkFeedFilter.archived:
        if (!bookmark.isArchived) return false;
    }

    if (tagId != null && !bookmark.tagIds.contains(tagId)) return false;
    if (host != null && bookmark.normalizedHost != host) return false;
    if (contentType != null && bookmark.contentType != contentType) {
      return false;
    }
    if (addedWithinDays != null) {
      final DateTime cutoff =
          (now ?? DateTime.now()).subtract(Duration(days: addedWithinDays!));
      if (bookmark.createdAt.isBefore(cutoff)) return false;
    }
    return true;
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'filter': filter.name,
        'tagId': tagId,
        'host': host,
        'contentType': contentType?.name,
        'addedWithinDays': addedWithinDays,
      };

  String encode() => jsonEncode(toJson());

  static SmartCollectionRule decode(String json) {
    final Object? decoded = jsonDecode(json);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException(
          'Smart collection rule must be a JSON object');
    }
    return fromJson(decoded);
  }

  static SmartCollectionRule fromJson(Map<String, Object?> json) {
    return SmartCollectionRule(
      filter: BookmarkFeedFilter.values.firstWhere(
        (BookmarkFeedFilter f) => f.name == json['filter'],
        orElse: () => BookmarkFeedFilter.all,
      ),
      tagId: json['tagId'] as int?,
      host: json['host'] as String?,
      contentType: json['contentType'] == null
          ? null
          : BookmarkContentType.values.firstWhere(
              (BookmarkContentType t) => t.name == json['contentType'],
              orElse: () => BookmarkContentType.unknown,
            ),
      addedWithinDays: json['addedWithinDays'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartCollectionRule &&
        other.filter == filter &&
        other.tagId == tagId &&
        other.host == host &&
        other.contentType == contentType &&
        other.addedWithinDays == addedWithinDays;
  }

  @override
  int get hashCode => Object.hash(
        filter,
        tagId,
        host,
        contentType,
        addedWithinDays,
      );
}
