import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/core/database/database_providers.dart';
import 'package:marky/features/notes/data/isar_note_repository.dart';
import 'package:marky/features/notes/domain/note.dart';
import 'package:marky/features/notes/domain/note_repository.dart';

/// Live [NoteRepository] wired to the v2 Isar instance.
final Provider<NoteRepository> noteRepositoryProvider =
    Provider<NoteRepository>((Ref ref) {
  return IsarNoteRepository(ref.watch(markyIsarProvider));
});

/// Reactive list of notes for a single bookmark, newest first.
/// Auto-disposes — used by the Detail screen's notes section.
final AutoDisposeStreamProviderFamily<List<Note>, int> notesByBookmarkProvider =
    StreamProvider.autoDispose.family<List<Note>, int>((Ref ref, int id) {
  return ref.watch(noteRepositoryProvider).watchByBookmarkId(id);
});
