import 'package:isar/isar.dart';
import 'package:marky/core/database/base_repository.dart';
import 'package:marky/shared/models/note.dart';

/// Domain contract for [Note] persistence and querying.
///
/// Implementations provide CRUD via [BaseRepository] plus note-specific
/// lookups for bookmark relationship traversal.
abstract class NoteRepository implements BaseRepository<Note> {
  /// Returns all notes attached to the bookmark with [bookmarkId].
  Future<List<Note>> getByBookmarkId(Id bookmarkId);
}
