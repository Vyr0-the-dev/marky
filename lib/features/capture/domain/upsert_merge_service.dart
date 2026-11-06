import 'package:marky/features/bookmarks/domain/bookmark.dart';

/// Merges incoming metadata into an existing [Bookmark] when the
/// capture pipeline detects a duplicate.
///
/// Policy: **fill gaps, don't overwrite user edits.**
///
/// - Null → non-null: populate the field (e.g. scraper found a title
///   that a quick-save didn't have).
/// - Non-null → non-null: keep the existing value. The user may have
///   hand-edited it — overwriting silently is a worse UX than stale
///   metadata.
/// - List fields (tagIds, collectionIds): union without duplicates.
/// - Flags (isFavorite, isPinned, etc.): keep the existing value.
/// - Timestamps: updatedAt is bumped; createdAt is never changed.
abstract interface class UpsertMergeService {
  /// Returns a merged [Bookmark] combining [existing] with any new
  /// data from [incoming]. The returned bookmark has the same [id]
  /// as [existing].
  Bookmark merge(Bookmark existing, Bookmark incoming);
}
