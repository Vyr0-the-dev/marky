import 'package:marky/features/tags/domain/tag.dart';

/// Persistence + query boundary for [Tag].
abstract interface class TagRepository {
  // ─── CRUD ───────────────────────────────────────────────────────

  /// Inserts or updates [tag]. Stamps `updatedAt`. If [Tag.id] is
  /// null the slug must already be unique — slug-collision throws.
  Future<Tag> save(Tag tag);

  /// Convenience constructor for the create flow: builds a [Tag]
  /// from `name`, derives the slug, dedupes the slug if needed
  /// (`design`, `design-2`, `design-3`...). Returns the persisted
  /// row.
  Future<Tag> createFromName(String name, {int? colorArgb, String? icon});

  Future<Tag?> getById(int id);
  Future<Tag?> findBySlug(String slug);
  Future<List<Tag>> getAll();
  Future<List<Tag>> getByIds(List<int> ids);

  /// Hard-delete. Returns `true` if the tag existed.
  ///
  /// Note: this does *not* automatically remove the tag id from
  /// any bookmark's `tagIds` — orchestration of that fan-out is
  /// the responsibility of the use case that triggers the delete
  /// (so it can run inside a single Isar transaction with the
  /// bookmark updates).
  Future<bool> delete(int id);

  // ─── Usage-count maintenance ────────────────────────────────────

  /// Atomic +1 / -1. Used by feature code on the hot path of
  /// "user added/removed a tag from a bookmark". Both clamp at zero
  /// (decrement on a count of 0 is a no-op).
  Future<void> incrementUsageCount(int tagId);
  Future<void> decrementUsageCount(int tagId);

  /// Authoritative recompute by scanning all bookmarks for [tagId].
  /// Slower than incr/decr but guaranteed correct — useful after
  /// bulk imports / migrations / debug-time repair.
  Future<int> recomputeUsageCount(int tagId);

  /// Recomputes counts for every tag. Returns a map of {tagId:
  /// newCount} for caller-side logging.
  Future<Map<int, int>> recomputeAllUsageCounts();

  // ─── Streams ────────────────────────────────────────────────────

  /// Reactive list of all tags, sorted pinned-first then by
  /// orderIndex/name. Used by the Library tag panel.
  Stream<List<Tag>> watchAll();

  /// Reactive single tag — for the editor screen.
  Stream<Tag?> watchById(int id);
}
