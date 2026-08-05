import 'dart:developer' as developer;

import 'package:isar/isar.dart';

import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/shared/models/note.dart';

/// Use case for managing notes attached to bookmarks.
///
/// Handles CRUD operations and automatically synchronizes
/// [BookmarkItem.noteIds] so widgets never write to both tables directly.
class ManageNotesUseCase {
  ManageNotesUseCase({
    required NoteRepository noteRepository,
    required BookmarkItemRepository bookmarkRepository,
  })  : _noteRepository = noteRepository,
        _bookmarkRepository = bookmarkRepository;

  final NoteRepository _noteRepository;
  final BookmarkItemRepository _bookmarkRepository;

  // ─── Create ────────────────────────────────────────────────────────────

  /// Creates a new note attached to [bookmarkId] with the given [content].
  ///
  /// After insertion, appends the new note ID to the bookmark's [noteIds]
  /// (creating the list if absent), updates [updatedAt], and persists the
  /// bookmark.
  ///
  /// Returns the ID of the newly created note.
  Future<Id> create({
    required Id bookmarkId,
    required String content,
    String contentFormat = 'plain',
    bool isPinned = false,
    String? colorLabel,
  }) async {
    final DateTime now = DateTime.now();

    final Note note = Note(
      bookmarkId: bookmarkId,
      content: content,
      contentFormat: contentFormat,
      createdAt: now,
      updatedAt: now,
      isPinned: isPinned,
      colorLabel: colorLabel,
    );

    final Id noteId = await _noteRepository.insert(note);

    // Sync bookmark.noteIds
    final bookmark = await _bookmarkRepository.getById(bookmarkId);
    if (bookmark != null) {
      final List<int> ids = bookmark.noteIds?.toList() ?? <int>[];
      ids.add(noteId);
      bookmark.noteIds = ids;
      bookmark.updatedAt = DateTime.now();
      await _bookmarkRepository.update(bookmark);
    }

    return noteId;
  }

  // ─── Update ────────────────────────────────────────────────────────────

  /// Updates an existing [note] in place.
  ///
  /// Sets [updatedAt] to now before persisting.
  Future<Id> update(Note note) async {
    note.updatedAt = DateTime.now();
    return _noteRepository.update(note);
  }

  // ─── Delete ────────────────────────────────────────────────────────────

  /// Deletes the note with [id] and cleans up the bookmark reference.
  ///
  /// After deletion, finds the parent bookmark and removes the note ID from
  /// [noteIds]. Sets [noteIds] to `null` when the list becomes empty.
  Future<void> delete(Id id) async {
    final note = await _noteRepository.getById(id);
    if (note == null) {
      return;
    }

    await _noteRepository.delete(id);

    // Remove note reference from parent bookmark.
    final bookmark = await _bookmarkRepository.getById(note.bookmarkId);
    if (bookmark == null) {
      developer.log(
        'Bookmark not found during note delete cleanup',
        name: 'ManageNotesUseCase',
        error: 'bookmarkId=${note.bookmarkId}',
      );
      return;
    }

    final List<int>? noteIds = bookmark.noteIds;
    if (noteIds != null && noteIds.contains(id)) {
      noteIds.remove(id);
      bookmark.noteIds = noteIds.isEmpty ? null : noteIds;
      bookmark.updatedAt = DateTime.now();
      await _bookmarkRepository.update(bookmark);
    }
  }

  // ─── Read ──────────────────────────────────────────────────────────────

  /// Returns all notes.
  Future<List<Note>> getAll() => _noteRepository.getAll();

  /// Returns the note with [id], or `null` if not found.
  Future<Note?> getById(Id id) => _noteRepository.getById(id);

  /// Returns all notes attached to the bookmark with [bookmarkId].
  Future<List<Note>> getByBookmarkId(Id bookmarkId) =>
      _noteRepository.getByBookmarkId(bookmarkId);
}
