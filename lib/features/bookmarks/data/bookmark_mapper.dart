import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/bookmark_entity.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';

/// Converts between the Isar [BookmarkEntity] and the domain
/// [Bookmark]. The only file that imports both halves of the boundary.
///
/// Both directions are deliberately field-by-field (no reflection /
/// codegen). Slower than a generated mapper at write time, but cheap
/// to inspect, easy to diff, and trivial to evolve when a new field
/// lands — the compiler tells you exactly where to update.
abstract final class BookmarkMapper {
  /// Entity → domain. Always succeeds (entity is presumed valid).
  static Bookmark toDomain(BookmarkEntity e) {
    return Bookmark(
      // `Isar.autoIncrement` is `Isar.minId` until the row is
      // persisted; treat that as "unsaved" for safety.
      id: e.id == Isar.autoIncrement ? null : e.id,
      originalUrl: e.originalUrl,
      canonicalUrl: e.canonicalUrl,
      normalizedHost: e.normalizedHost,
      urlHash: e.urlHash,
      externalContentId: e.externalContentId,
      title: e.title,
      description: e.description,
      snippet: e.snippet,
      author: e.author,
      siteName: e.siteName,
      publisher: e.publisher,
      publishDate: e.publishDate,
      languageCode: e.languageCode,
      contentType: e.contentType,
      sourceType: e.sourceType,
      heroImageUrl: e.heroImageUrl,
      heroImageLocalPath: e.heroImageLocalPath,
      faviconUrl: e.faviconUrl,
      localFaviconPath: e.localFaviconPath,
      dominantColorHex: e.dominantColorHex,
      // Defensive copy — entity lists are mutable, domain promises
      // immutability. `List.unmodifiable` would be ideal but List<int>
      // round-tripping through Isar drops that wrapper anyway, so
      // a fresh copy is the honest middle ground.
      tagIds: List<int>.from(e.tagIds),
      collectionIds: List<int>.from(e.collectionIds),
      reminderIds: List<int>.from(e.reminderIds),
      inlineNotes: e.inlineNotes,
      isFavorite: e.isFavorite,
      isArchived: e.isArchived,
      isRead: e.isRead,
      isPinned: e.isPinned,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      lastOpenedAt: e.lastOpenedAt,
      lastInteractionAt: e.lastInteractionAt,
      openCount: e.openCount,
      readProgress: e.readProgress,
      readingTimeMinutes: e.readingTimeMinutes,
      scrapingStatus: e.scrapingStatus,
      duplicateGroupId: e.duplicateGroupId,
    );
  }

  /// Domain → entity. The repository sets `updatedAt` itself before
  /// calling this, so the mapper just trusts the input.
  ///
  /// When [b.id] is null, leaves the entity's id at
  /// `Isar.autoIncrement` so Isar assigns one on insert.
  static BookmarkEntity toEntity(Bookmark b) {
    final BookmarkEntity entity = BookmarkEntity(
      originalUrl: b.originalUrl,
      canonicalUrl: b.canonicalUrl,
      normalizedHost: b.normalizedHost,
      urlHash: b.urlHash,
      externalContentId: b.externalContentId,
      title: b.title,
      description: b.description,
      snippet: b.snippet,
      author: b.author,
      siteName: b.siteName,
      publisher: b.publisher,
      publishDate: b.publishDate,
      languageCode: b.languageCode,
      contentType: b.contentType,
      sourceType: b.sourceType,
      heroImageUrl: b.heroImageUrl,
      heroImageLocalPath: b.heroImageLocalPath,
      faviconUrl: b.faviconUrl,
      localFaviconPath: b.localFaviconPath,
      dominantColorHex: b.dominantColorHex,
      tagIds: List<int>.from(b.tagIds),
      collectionIds: List<int>.from(b.collectionIds),
      reminderIds: List<int>.from(b.reminderIds),
      inlineNotes: b.inlineNotes,
      isFavorite: b.isFavorite,
      isArchived: b.isArchived,
      isRead: b.isRead,
      isPinned: b.isPinned,
      createdAt: b.createdAt,
      updatedAt: b.updatedAt,
      lastOpenedAt: b.lastOpenedAt,
      lastInteractionAt: b.lastInteractionAt,
      openCount: b.openCount,
      readProgress: b.readProgress,
      readingTimeMinutes: b.readingTimeMinutes,
      scrapingStatus: b.scrapingStatus,
      duplicateGroupId: b.duplicateGroupId,
    );
    if (b.id != null) {
      entity.id = b.id!;
    }
    return entity;
  }
}
