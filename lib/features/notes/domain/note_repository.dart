import 'package:marky/features/notes/domain/note.dart';

/// Persistence + query boundary for [Note].
///
/// The repository owns Isar reads/writes only — it does not enforce
/// cross-entity invariants (e.g. "bookmark exists for [bookmarkId]").
/// That's the use case's job, so storage stays trivial to swap.
abstract interface class NoteRepository {
  // ─── CRUD ───────────────────────────────────────────────────────

  /// Inserts or updates [note]. Stamps `updatedAt`.
  Future<Note> save(Note note);

  /// Convenience constructor for the create flow: builds a fresh
  /// [Note] for [bookmarkId] with the given [content], stamping
  /// `createdAt` and `updatedAt` to `now`. Returns the persisted row.
  ///
  /// Throws [ArgumentError] if [content] is blank after trimming —
  /// blank notes are never useful and prevent UI accidents.
  Future<Note> createForBookmark(int bookmarkId, String content);

  Future<Note?> getById(int id);

  /// Hard-delete. Returns `true` if the note existed.
  Future<bool> delete(int id);

  /// Hard-deletes every note belonging to [bookmarkId]. Used when
  /// the parent bookmark is deleted; returns the count removed so
  /// callers can log the cascade.
  Future<int> deleteByBookmarkId(int bookmarkId);

  // ─── Queries ────────────────────────────────────────────────────

  /// All notes for [bookmarkId], newest first by `createdAt`.
  Future<List<Note>> getByBookmarkId(int bookmarkId);

  /// Total count across all bookmarks. Used by Dashboard.
  Future<int> count();

  // ─── Streams ────────────────────────────────────────────────────

  /// Reactive list of notes for a single bookmark, newest first.
  /// Auto-refreshes when notes are added/edited/removed.
  Stream<List<Note>> watchByBookmarkId(int bookmarkId);
}
