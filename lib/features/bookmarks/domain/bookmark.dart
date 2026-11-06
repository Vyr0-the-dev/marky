import 'package:flutter/foundation.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';

/// Immutable domain model for a saved link.
///
/// **Why this class exists separately from `BookmarkEntity`:**
/// the Isar entity is a *mutable*, *generated* class with framework-
/// specific concerns (`Id` type, `@Index` annotations, `g.dart`
/// codegen). Feature code should not depend on those — it should
/// see a plain Dart value type that's safe to compare with `==`,
/// pass through a Riverpod provider, and serialise for backup.
///
/// The mapper in `data/bookmark_mapper.dart` is the only file that
/// imports both — keep it that way.
@immutable
class Bookmark {
  const Bookmark({
    this.id,
    required this.originalUrl,
    this.canonicalUrl,
    this.normalizedHost,
    this.urlHash,
    this.externalContentId,
    this.title,
    this.description,
    this.snippet,
    this.author,
    this.siteName,
    this.publisher,
    this.publishDate,
    this.languageCode,
    this.contentType = BookmarkContentType.unknown,
    this.sourceType = BookmarkSourceType.manual,
    this.heroImageUrl,
    this.heroImageLocalPath,
    this.faviconUrl,
    this.localFaviconPath,
    this.dominantColorHex,
    this.tagIds = const <int>[],
    this.collectionIds = const <int>[],
    this.reminderIds = const <int>[],
    this.inlineNotes,
    this.isFavorite = false,
    this.isArchived = false,
    this.isRead = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastOpenedAt,
    this.lastInteractionAt,
    this.openCount = 0,
    this.readProgress,
    this.readingTimeMinutes,
    this.scrapingStatus = BookmarkScrapingStatus.pending,
    this.duplicateGroupId,
  });

  /// `null` when the bookmark hasn't been persisted yet. Save
  /// returns a copy with this populated.
  final int? id;

  final String originalUrl;
  final String? canonicalUrl;
  final String? normalizedHost;
  final String? urlHash;
  final String? externalContentId;

  final String? title;
  final String? description;
  final String? snippet;
  final String? author;
  final String? siteName;
  final String? publisher;
  final DateTime? publishDate;
  final String? languageCode;

  final BookmarkContentType contentType;
  final BookmarkSourceType sourceType;

  final String? heroImageUrl;
  final String? heroImageLocalPath;
  final String? faviconUrl;
  final String? localFaviconPath;
  final String? dominantColorHex;

  final List<int> tagIds;
  final List<int> collectionIds;
  final List<int> reminderIds;
  final String? inlineNotes;

  final bool isFavorite;
  final bool isArchived;
  final bool isRead;
  final bool isPinned;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;
  final DateTime? lastInteractionAt;

  final int openCount;
  final double? readProgress;
  final int? readingTimeMinutes;

  final BookmarkScrapingStatus scrapingStatus;
  final String? duplicateGroupId;

  /// Title most useful for display: explicit `title` if scraped,
  /// otherwise `canonicalUrl`, otherwise `originalUrl`. Never null,
  /// never empty.
  String get displayTitle {
    final String? t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    final String? c = canonicalUrl?.trim();
    if (c != null && c.isNotEmpty) return c;
    return originalUrl;
  }

  /// True when the user can act on the bookmark (i.e. not in any
  /// transient processing state). UI uses this to gate the "share"
  /// and "open in browser" affordances on the card.
  bool get isReady =>
      scrapingStatus == BookmarkScrapingStatus.done ||
      scrapingStatus == BookmarkScrapingStatus.failed;

  /// Returns a new bookmark with the given fields replaced.
  ///
  /// Note: nullable fields cannot be *cleared* through copyWith — this
  /// is the standard immutable trade-off. Add explicit `clearX`
  /// helpers later if a feature needs to null a field; YAGNI for now.
  Bookmark copyWith({
    int? id,
    String? originalUrl,
    String? canonicalUrl,
    String? normalizedHost,
    String? urlHash,
    String? externalContentId,
    String? title,
    String? description,
    String? snippet,
    String? author,
    String? siteName,
    String? publisher,
    DateTime? publishDate,
    String? languageCode,
    BookmarkContentType? contentType,
    BookmarkSourceType? sourceType,
    String? heroImageUrl,
    String? heroImageLocalPath,
    String? faviconUrl,
    String? localFaviconPath,
    String? dominantColorHex,
    List<int>? tagIds,
    List<int>? collectionIds,
    List<int>? reminderIds,
    String? inlineNotes,
    bool? isFavorite,
    bool? isArchived,
    bool? isRead,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastOpenedAt,
    DateTime? lastInteractionAt,
    int? openCount,
    double? readProgress,
    int? readingTimeMinutes,
    BookmarkScrapingStatus? scrapingStatus,
    String? duplicateGroupId,
  }) {
    return Bookmark(
      id: id ?? this.id,
      originalUrl: originalUrl ?? this.originalUrl,
      canonicalUrl: canonicalUrl ?? this.canonicalUrl,
      normalizedHost: normalizedHost ?? this.normalizedHost,
      urlHash: urlHash ?? this.urlHash,
      externalContentId: externalContentId ?? this.externalContentId,
      title: title ?? this.title,
      description: description ?? this.description,
      snippet: snippet ?? this.snippet,
      author: author ?? this.author,
      siteName: siteName ?? this.siteName,
      publisher: publisher ?? this.publisher,
      publishDate: publishDate ?? this.publishDate,
      languageCode: languageCode ?? this.languageCode,
      contentType: contentType ?? this.contentType,
      sourceType: sourceType ?? this.sourceType,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      heroImageLocalPath: heroImageLocalPath ?? this.heroImageLocalPath,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      localFaviconPath: localFaviconPath ?? this.localFaviconPath,
      dominantColorHex: dominantColorHex ?? this.dominantColorHex,
      tagIds: tagIds ?? this.tagIds,
      collectionIds: collectionIds ?? this.collectionIds,
      reminderIds: reminderIds ?? this.reminderIds,
      inlineNotes: inlineNotes ?? this.inlineNotes,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isRead: isRead ?? this.isRead,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      openCount: openCount ?? this.openCount,
      readProgress: readProgress ?? this.readProgress,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      scrapingStatus: scrapingStatus ?? this.scrapingStatus,
      duplicateGroupId: duplicateGroupId ?? this.duplicateGroupId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark &&
        other.id == id &&
        other.originalUrl == originalUrl &&
        other.canonicalUrl == canonicalUrl &&
        other.normalizedHost == normalizedHost &&
        other.urlHash == urlHash &&
        other.externalContentId == externalContentId &&
        other.title == title &&
        other.description == description &&
        other.snippet == snippet &&
        other.author == author &&
        other.siteName == siteName &&
        other.publisher == publisher &&
        other.publishDate == publishDate &&
        other.languageCode == languageCode &&
        other.contentType == contentType &&
        other.sourceType == sourceType &&
        other.heroImageUrl == heroImageUrl &&
        other.heroImageLocalPath == heroImageLocalPath &&
        other.faviconUrl == faviconUrl &&
        other.localFaviconPath == localFaviconPath &&
        other.dominantColorHex == dominantColorHex &&
        listEquals(other.tagIds, tagIds) &&
        listEquals(other.collectionIds, collectionIds) &&
        listEquals(other.reminderIds, reminderIds) &&
        other.inlineNotes == inlineNotes &&
        other.isFavorite == isFavorite &&
        other.isArchived == isArchived &&
        other.isRead == isRead &&
        other.isPinned == isPinned &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastOpenedAt == lastOpenedAt &&
        other.lastInteractionAt == lastInteractionAt &&
        other.openCount == openCount &&
        other.readProgress == readProgress &&
        other.readingTimeMinutes == readingTimeMinutes &&
        other.scrapingStatus == scrapingStatus &&
        other.duplicateGroupId == duplicateGroupId;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        id,
        originalUrl,
        canonicalUrl,
        normalizedHost,
        urlHash,
        externalContentId,
        title,
        description,
        contentType,
        sourceType,
        Object.hashAll(tagIds),
        Object.hashAll(collectionIds),
        Object.hashAll(reminderIds),
        isFavorite,
        isArchived,
        isRead,
        isPinned,
        createdAt,
        updatedAt,
        scrapingStatus,
      ]);

  @override
  String toString() => 'Bookmark(id: $id, url: $originalUrl, title: $title, '
      'archived: $isArchived, fav: $isFavorite, '
      'status: $scrapingStatus)';
}
