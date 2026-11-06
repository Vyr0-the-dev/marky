import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/note_entity.dart';
import 'package:marky/features/notes/data/note_mapper.dart';
import 'package:marky/features/notes/domain/note.dart';
import 'package:marky/features/notes/domain/note_repository.dart';

/// Isar-backed [NoteRepository].
///
/// Touchstones:
/// - All writes are wrapped in `writeTxn` so the watcher stream
///   delivers consistent snapshots.
/// - List queries are sorted `createdAt DESC` — the timeline view
///   reads top-down (newest first), matching how users review notes.
/// - `deleteByBookmarkId` is bulk and atomic; the use case for
///   bookmark deletion runs it inside the same transaction as the
///   bookmark removal so we never leak orphan notes.
class IsarNoteRepository implements NoteRepository {
  IsarNoteRepository(this._isar);

  final Isar _isar;

  @override
  Future<Note> save(Note note) async {
    final Note stamped = note.copyWith(updatedAt: DateTime.now());
    final NoteEntity entity = NoteMapper.toEntity(stamped);

    final int id = await _isar.writeTxn<int>(() => _isar.notes.put(entity));
    return stamped.copyWith(id: id);
  }

  @override
  Future<Note> createForBookmark(int bookmarkId, String content) async {
    final String trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
          content, 'content', 'Note content must not be blank');
    }

    final DateTime now = DateTime.now();
    final Note note = Note(
      bookmarkId: bookmarkId,
      content: trimmed,
      createdAt: now,
      updatedAt: now,
    );
    return save(note);
  }

  @override
  Future<Note?> getById(int id) async {
    final NoteEntity? e = await _isar.notes.get(id);
    return e == null ? null : NoteMapper.toDomain(e);
  }

  @override
  Future<bool> delete(int id) {
    return _isar.writeTxn<bool>(() async => _isar.notes.delete(id));
  }

  @override
  Future<int> deleteByBookmarkId(int bookmarkId) async {
    return _isar.writeTxn<int>(() async {
      return _isar.notes.where().bookmarkIdEqualTo(bookmarkId).deleteAll();
    });
  }

  @override
  Future<List<Note>> getByBookmarkId(int bookmarkId) async {
    final List<NoteEntity> rows = await _isar.notes
        .where()
        .bookmarkIdEqualTo(bookmarkId)
        .sortByCreatedAtDesc()
        .findAll();
    return rows.map(NoteMapper.toDomain).toList(growable: false);
  }

  @override
  Future<int> count() {
    return _isar.notes.where().count();
  }

  @override
  Stream<List<Note>> watchByBookmarkId(int bookmarkId) {
    final Query<NoteEntity> q = _isar.notes
        .where()
        .bookmarkIdEqualTo(bookmarkId)
        .sortByCreatedAtDesc()
        .build();
    return q.watch(fireImmediately: true).map(
          (List<NoteEntity> rows) =>
              rows.map(NoteMapper.toDomain).toList(growable: false),
        );
  }
}
