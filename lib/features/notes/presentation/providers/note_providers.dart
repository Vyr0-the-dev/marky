import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/features/notes/domain/use_cases/manage_notes_use_case.dart';
import 'package:marky/shared/models/note.dart';

// ─── Simple future providers ───────────────────────────────────────────

/// Loads all notes from the repository.
final FutureProvider<List<Note>> noteListProvider =
    FutureProvider<List<Note>>((Ref ref) async {
  final NoteRepository repository = ref.watch(noteRepositoryProvider);
  return repository.getAll();
});

/// Looks up a single note by its ID.
final FutureProviderFamily<Note?, int> noteByIdProvider =
    FutureProvider.family<Note?, int>((Ref ref, int id) async {
  final NoteRepository repository = ref.watch(noteRepositoryProvider);
  return repository.getById(id);
});

/// Loads all notes attached to the bookmark with [bookmarkId].
final FutureProviderFamily<List<Note>, int> notesByBookmarkIdProvider =
    FutureProvider.family<List<Note>, int>((Ref ref, int bookmarkId) async {
  final NoteRepository repository = ref.watch(noteRepositoryProvider);
  return repository.getByBookmarkId(bookmarkId);
});

// ─── Use-case provider ─────────────────────────────────────────────────

/// Provider for [ManageNotesUseCase], wired to live repositories.
final Provider<ManageNotesUseCase> manageNotesUseCaseProvider =
    Provider<ManageNotesUseCase>((Ref ref) {
  final NoteRepository noteRepo = ref.watch(noteRepositoryProvider);
  final BookmarkItemRepository bookmarkRepo = ref.watch(bookmarkRepositoryProvider);
  return ManageNotesUseCase(
    noteRepository: noteRepo,
    bookmarkRepository: bookmarkRepo,
  );
});

// ─── State notifier ────────────────────────────────────────────────────

/// Notifier that manages the note list with CRUD operations.
class NoteManagerNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  /// Creates the notifier and immediately loads the note list.
  NoteManagerNotifier({required ManageNotesUseCase useCase})
      : _useCase = useCase,
        super(const AsyncValue<List<Note>>.loading()) {
    unawaited(load());
  }

  final ManageNotesUseCase _useCase;
  final Logger _logger = Logger();

  /// Reloads the full note list from the repository.
  Future<void> load() async {
    state = const AsyncValue<List<Note>>.loading();
    try {
      final List<Note> notes = await _useCase.getAll();
      state = AsyncValue<List<Note>>.data(notes);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to load notes', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Note>>.error(e, stackTrace);
    }
  }

  /// Creates a new note attached to [bookmarkId] and refreshes the list.
  Future<Id> create({
    required Id bookmarkId,
    required String content,
    String contentFormat = 'plain',
    bool isPinned = false,
    String? colorLabel,
  }) async {
    try {
      final Id noteId = await _useCase.create(
        bookmarkId: bookmarkId,
        content: content,
        contentFormat: contentFormat,
        isPinned: isPinned,
        colorLabel: colorLabel,
      );
      await load();
      return noteId;
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to create note', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Note>>.error(e, stackTrace);
      rethrow;
    }
  }

  /// Updates an existing [note] and refreshes the list.
  Future<Id> update(Note note) async {
    try {
      final Id noteId = await _useCase.update(note);
      await load();
      return noteId;
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to update note', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Note>>.error(e, stackTrace);
      rethrow;
    }
  }

  /// Deletes a note by [id] and refreshes the list.
  Future<void> delete(int id) async {
    try {
      await _useCase.delete(id);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to delete note', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Note>>.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Provider for [NoteManagerNotifier].
final StateNotifierProvider<NoteManagerNotifier, AsyncValue<List<Note>>>
    noteManagerNotifierProvider =
    StateNotifierProvider<NoteManagerNotifier, AsyncValue<List<Note>>>(
  (Ref ref) => NoteManagerNotifier(
    useCase: ref.watch(manageNotesUseCaseProvider),
  ),
);
