import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/capture/domain/upsert_merge_service.dart';

/// Default implementation of [UpsertMergeService].
///
/// Strategy per field category:
///
/// | Category        | Behaviour                             |
/// |-----------------|---------------------------------------|
/// | String?         | Fill if existing is null               |
/// | DateTime?       | Fill if existing is null               |
/// | List<int>       | Union (preserve existing + add new)    |
/// | Enum            | Keep existing unless it's the default  |
/// | Bool flag       | Keep existing                          |
/// | Numeric counter | Keep existing (user interaction data)  |
/// | updatedAt       | Set to now                             |
/// | createdAt       | Never change                           |
class DefaultUpsertMergeService implements UpsertMergeService {
  const DefaultUpsertMergeService();

  @override
  Bookmark merge(Bookmark existing, Bookmark incoming) {
    return existing.copyWith(
      // ── URL fields ─────────────────────────────────────────────
      // originalUrl: never change — it's the historical capture URL.
      canonicalUrl: existing.canonicalUrl ?? incoming.canonicalUrl,
      normalizedHost: existing.normalizedHost ?? incoming.normalizedHost,
      urlHash: existing.urlHash ?? incoming.urlHash,
      externalContentId:
          existing.externalContentId ?? incoming.externalContentId,

      // ── Content metadata ───────────────────────────────────────
      title: existing.title ?? incoming.title,
      description: existing.description ?? incoming.description,
      snippet: existing.snippet ?? incoming.snippet,
      author: existing.author ?? incoming.author,
      siteName: existing.siteName ?? incoming.siteName,
      publisher: existing.publisher ?? incoming.publisher,
      publishDate: existing.publishDate ?? incoming.publishDate,
      languageCode: existing.languageCode ?? incoming.languageCode,

      // ── Content type ───────────────────────────────────────────
      // Upgrade from unknown to a detected type, but don't
      // downgrade a previously classified item.
      contentType: existing.contentType == BookmarkContentType.unknown
          ? incoming.contentType
          : existing.contentType,

      // ── Media ──────────────────────────────────────────────────
      heroImageUrl: existing.heroImageUrl ?? incoming.heroImageUrl,
      heroImageLocalPath:
          existing.heroImageLocalPath ?? incoming.heroImageLocalPath,
      faviconUrl: existing.faviconUrl ?? incoming.faviconUrl,
      localFaviconPath: existing.localFaviconPath ?? incoming.localFaviconPath,
      dominantColorHex: existing.dominantColorHex ?? incoming.dominantColorHex,

      // ── Relationships ──────────────────────────────────────────
      tagIds: _unionIds(existing.tagIds, incoming.tagIds),
      collectionIds: _unionIds(existing.collectionIds, incoming.collectionIds),
      reminderIds: _unionIds(existing.reminderIds, incoming.reminderIds),

      // ── Notes ──────────────────────────────────────────────────
      inlineNotes: existing.inlineNotes ?? incoming.inlineNotes,

      // ── Flags ──────────────────────────────────────────────────
      // Keep the user's existing preferences.

      // ── Timestamps ─────────────────────────────────────────────
      updatedAt: DateTime.now(),
      // createdAt: never change.

      // ── Reading state ──────────────────────────────────────────
      readingTimeMinutes:
          existing.readingTimeMinutes ?? incoming.readingTimeMinutes,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────

  /// Union two id-lists without duplicates, preserving existing order
  /// first, then appending new entries.
  static List<int> _unionIds(List<int> existing, List<int> incoming) {
    if (incoming.isEmpty) return existing;
    if (existing.isEmpty) return incoming;

    final Set<int> seen = existing.toSet();
    final List<int> merged = List<int>.of(existing);
    for (final int id in incoming) {
      if (seen.add(id)) merged.add(id);
    }
    return merged;
  }
}
