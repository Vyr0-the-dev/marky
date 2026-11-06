import 'package:isar/isar.dart';

part 'note_entity.g.dart';

/// A user-authored note attached to a single bookmark.
///
/// Distinct from `Bookmark.inlineNotes` (a single legacy string field
/// kept for backwards compatibility). The proper Notes feature in
/// Faz 9 is *multi-note per bookmark with timestamps* — each entry
/// has its own create/update time so the user can review their
/// thinking over weeks of revisits.
///
/// Notes are scoped: `bookmarkId` is indexed so listing notes for a
/// bookmark stays O(log n) regardless of total note count, and a
/// composite ordering by `createdAt` keeps the timeline view stable.
@Collection(accessor: 'notes')
class NoteEntity {
  NoteEntity({
    required this.bookmarkId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Id id = Isar.autoIncrement;

  /// Parent bookmark id. Indexed because the only common query is
  /// "give me all notes for bookmark X, newest first".
  ///
  /// We deliberately do **not** use Isar links here — the cross-Isar
  /// link cost outweighs the benefit when notes are read-heavy and
  /// the bookmark is already in memory.
  @Index()
  int bookmarkId;

  /// Free-form text content. No markup parsing in the MVP — UI
  /// renders plain text with line breaks preserved. AI summarization
  /// of notes is a Faz 17 concern; the storage layer stays oblivious.
  String content;

  DateTime createdAt;
  DateTime updatedAt;
}
