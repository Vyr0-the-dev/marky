import 'package:isar/isar.dart';

import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/shared/models/note.dart';

/// Isar-backed implementation of [NoteRepository].
///
/// Expects [isar] to be an open database instance that includes
/// [NoteSchema].
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({required Isar isar}) : _isar = isar;

  final Isar _isar;

  // ─── BaseRepository<Note> ──────────────────────────────────────────────

  @override
  Future<Note?> getById(Id id) async {
    return _isar.notes.get(id);
  }

  @override
  Future<List<Note>> getAll() async {
    return _isar.notes.where().findAll();
  }

  @override
  Future<Id> insert(Note entity) async {
    return _isar.writeTxn(() async {
      return _isar.notes.put(entity);
    });
  }

  @override
  Future<Id> update(Note entity) async {
    return _isar.writeTxn(() async {
      return _isar.notes.put(entity);
    });
  }

  @override
  Future<void> delete(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.notes.delete(id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.notes.clear();
    });
  }

  // ─── NoteRepository queries ────────────────────────────────────────────

  @override
  Future<List<Note>> getByBookmarkId(Id bookmarkId) async {
    return _isar.notes
        .where()
        .bookmarkIdEqualTo(bookmarkId)
        .findAll();
  }
}
