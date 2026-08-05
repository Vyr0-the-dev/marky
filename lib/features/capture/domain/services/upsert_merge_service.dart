import 'package:marky/features/capture/domain/models/save_bookmark_params.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Pure Dart service that merges incoming bookmark parameters into an
/// existing [BookmarkItem] according to Marky's upsert policy.
///
/// The service mutates [existing] in place and returns it so callers
/// can immediately persist the updated record.
///
/// Merge rules (explicit and deterministic):
///
/// | Field            | Rule                                         |
/// |------------------|----------------------------------------------|
/// | updatedAt        | Always set to `DateTime.now()`               |
/// | lastInteractionAt| Always set to `DateTime.now()`               |
/// | tagIds           | Set union (`existing ∪ incoming`); null = noop |
/// | collectionIds    | Set union; null = noop                       |
/// | sharedText       | Keep existing if non-null/non-empty; else accept incoming |
/// | resolvedUrl      | Keep existing if present; else accept incoming |
/// | sourceType       | Preserve original                            |
/// | createdAt        | Never touch                                  |
/// | isFavorite       | Preserve unconditionally                     |
/// | isArchived       | Preserve unconditionally                     |
/// | isRead           | Preserve unconditionally                     |
/// | isPinned         | Preserve unconditionally                     |
/// | title            | Preserve existing enriched metadata          |
/// | description      | Preserve existing enriched metadata          |
/// | thumbnailUrl     | Preserve existing enriched metadata          |
/// | duplicateGroupId | Do not touch (handled by S04)                |
class UpsertMergeService {
  UpsertMergeService._();

  static final UpsertMergeService instance = UpsertMergeService._();

  /// Merges [incoming] parameters into [existing] and returns [existing].
  BookmarkItem merge(BookmarkItem existing, SaveBookmarkParams incoming) {
    final DateTime now = DateTime.now();

    // ── Timestamps (always refresh) ──────────────────────────────────
    existing.updatedAt = now;
    existing.lastInteractionAt = now;

    // ── Tag union ────────────────────────────────────────────────────
    if (incoming.tagIds != null) {
      final List<int> incomingTagList = incoming.tagIds!;
      final Set<int> existingTags = <int>{...?existing.tagIds};
      final Set<int> incomingTags = <int>{...incomingTagList};
      existing.tagIds = existingTags.union(incomingTags).toList();
    }

    // ── Collection union ─────────────────────────────────────────────
    if (incoming.collectionIds != null) {
      final List<int> incomingCollectionList = incoming.collectionIds!;
      final Set<int> existingCollections = <int>{...?existing.collectionIds};
      final Set<int> incomingCollections = <int>{...incomingCollectionList};
      existing.collectionIds =
          existingCollections.union(incomingCollections).toList();
    }

    // ── sharedText (keep existing if already populated) ──────────────
    if (existing.sharedText == null || existing.sharedText!.isEmpty) {
      if (incoming.sharedText != null && incoming.sharedText!.isNotEmpty) {
        existing.sharedText = incoming.sharedText;
      }
    }

    // ── resolvedUrl (keep existing if already present) ───────────────
    if (existing.resolvedUrl == null || existing.resolvedUrl!.isEmpty) {
      if (incoming.rawUrl != null && incoming.rawUrl!.isNotEmpty) {
        existing.resolvedUrl = incoming.rawUrl;
      }
    }

    // sourceType, createdAt, user flags, enriched metadata, and
    // duplicateGroupId are intentionally left untouched.

    return existing;
  }
}
