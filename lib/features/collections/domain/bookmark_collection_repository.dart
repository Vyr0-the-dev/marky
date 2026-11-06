import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';

abstract interface class BookmarkCollectionRepository {
  Future<BookmarkCollection> save(BookmarkCollection collection);

  /// Convenience constructor: builds a collection from `title`,
  /// derives + dedupes slug, returns the persisted row.
  Future<BookmarkCollection> createFromTitle(
    String title, {
    int? accentColorArgb,
    String? icon,
  });

  /// Creates a rule-backed collection. Smart collections don't store
  /// membership in `Bookmark.collectionIds`; opening one applies the
  /// encoded [rule] as a live feed query instead.
  Future<BookmarkCollection> createSmartFromRule(
    String title,
    SmartCollectionRule rule, {
    int? accentColorArgb,
    String? icon,
  });

  Future<BookmarkCollection?> getById(int id);
  Future<BookmarkCollection?> findBySlug(String slug);

  /// Returns all non-archived collections by default; pass
  /// `includeArchived: true` to include archived too. Sorted
  /// pinned-first, then by orderIndex, then alphabetically.
  Future<List<BookmarkCollection>> getAll({bool includeArchived = false});

  Future<List<BookmarkCollection>> getByIds(List<int> ids);

  Future<bool> delete(int id);

  // ─── Item-count maintenance ─────────────────────────────────────

  Future<void> incrementItemCount(int collectionId);
  Future<void> decrementItemCount(int collectionId);
  Future<int> recomputeItemCount(int collectionId);
  Future<Map<int, int>> recomputeAllItemCounts();

  // ─── Streams ────────────────────────────────────────────────────

  Stream<List<BookmarkCollection>> watchAll({bool includeArchived = false});
  Stream<BookmarkCollection?> watchById(int id);
}
