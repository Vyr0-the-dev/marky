import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/features/notes/domain/use_cases/manage_notes_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/note.dart';

/// Pure-Dart fake [NoteRepository] for fast, deterministic tests.
class FakeNoteRepository implements NoteRepository {
  final Map<Id, Note> _notes = <Id, Note>{};
  int _nextId = 1;
  int saveCount = 0;

  List<Note> get savedNotes => _notes.values.toList();

  @override
  Future<Note?> getById(Id id) async => _notes[id];

  @override
  Future<List<Note>> getAll() async => _notes.values.toList();

  @override
  Future<Id> insert(Note entity) async {
    entity.id = _nextId++;
    _notes[entity.id] = entity;
    saveCount++;
    return entity.id;
  }

  @override
  Future<Id> update(Note entity) async {
    _notes[entity.id] = entity;
    saveCount++;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _notes.remove(id);
    saveCount++;
  }

  @override
  Future<void> clear() async {
    _notes.clear();
    _nextId = 1;
    saveCount++;
  }

  @override
  Future<List<Note>> getByBookmarkId(Id bookmarkId) async {
    return _notes.values
        .where((n) => n.bookmarkId == bookmarkId)
        .toList();
  }
}

/// Pure-Dart fake [BookmarkItemRepository] for fast, deterministic tests.
class FakeBookmarkRepository implements BookmarkItemRepository {
  final Map<Id, BookmarkItem> _bookmarks = <Id, BookmarkItem>{};
  int _nextId = 1;
  int saveCount = 0;

  @override
  Future<BookmarkItem?> getById(Id id) async => _bookmarks[id];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => _bookmarks.values.toList();

  @override
  Future<Id> insert(BookmarkItem entity) async {
    entity.id = _nextId++;
    _bookmarks[entity.id] = entity;
    saveCount++;
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    _bookmarks[entity.id] = entity;
    saveCount++;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _bookmarks.remove(id);
    saveCount++;
  }

  @override
  Future<void> clear() async {
    _bookmarks.clear();
    _nextId = 1;
    saveCount++;
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async => null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => [];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async => [];
}

void main() {
  group('ManageNotesUseCase', () {
    late FakeNoteRepository noteRepo;
    late FakeBookmarkRepository bookmarkRepo;
    late ManageNotesUseCase useCase;

    setUp(() {
      noteRepo = FakeNoteRepository();
      bookmarkRepo = FakeBookmarkRepository();
      useCase = ManageNotesUseCase(
        noteRepository: noteRepo,
        bookmarkRepository: bookmarkRepo,
      );
    });

    // ─── create ──────────────────────────────────────────────────────────

    test('create inserts a note and returns its id', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      final noteId = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Test note content',
      );

      expect(noteId, greaterThan(0));

      final note = await noteRepo.getById(noteId);
      expect(note, isNotNull);
      expect(note!.content, 'Test note content');
      expect(note.bookmarkId, bookmark.id);
    });

    test('create syncs bookmark.noteIds when null', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);
      expect(bookmark.noteIds, isNull);

      final noteId = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'First note',
      );

      final updatedBookmark = await bookmarkRepo.getById(bookmark.id);
      expect(updatedBookmark!.noteIds, [noteId]);
    });

    test('create appends to existing noteIds', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        noteIds: [99],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      final noteId = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Second note',
      );

      final updatedBookmark = await bookmarkRepo.getById(bookmark.id);
      expect(updatedBookmark!.noteIds, [99, noteId]);
    });

    test('create sets timestamps', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      final before = DateTime.now();
      final noteId = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Timed note',
      );
      final after = DateTime.now();

      final note = await noteRepo.getById(noteId);
      expect(
        note!.createdAt.isAfter(before) || note.createdAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        note.createdAt.isBefore(after) || note.createdAt.isAtSameMomentAs(after),
        isTrue,
      );
      expect(note.updatedAt, note.createdAt);
    });

    test('create stores optional fields', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      final noteId = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Rich note',
        contentFormat: 'markdown',
        isPinned: true,
        colorLabel: '#FF5722',
      );

      final note = await noteRepo.getById(noteId);
      expect(note!.contentFormat, 'markdown');
      expect(note.isPinned, true);
      expect(note.colorLabel, '#FF5722');
    });

    test('create updates bookmark updatedAt', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      await bookmarkRepo.insert(bookmark);
      final originalUpdatedAt = bookmark.updatedAt;

      await Future.delayed(const Duration(milliseconds: 10));

      await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Note',
      );

      final updatedBookmark = await bookmarkRepo.getById(bookmark.id);
      expect(updatedBookmark!.updatedAt.isAfter(originalUpdatedAt), isTrue);
    });

    // ─── update ──────────────────────────────────────────────────────────

    test('update persists changes and refreshes updatedAt', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      final noteId = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Old content',
      );
      final note = await noteRepo.getById(noteId);

      await Future.delayed(const Duration(milliseconds: 10));

      note!.content = 'Updated content';
      note.isPinned = true;
      await useCase.update(note);

      final updated = await noteRepo.getById(noteId);
      expect(updated!.content, 'Updated content');
      expect(updated.isPinned, true);
      expect(updated.updatedAt.isAfter(updated.createdAt), isTrue);
    });

    // ─── getById / getAll / getByBookmarkId ──────────────────────────────

    test('getById returns note or null', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      final noteId = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Test',
      );

      expect(await useCase.getById(noteId), isNotNull);
      expect(await useCase.getById(999), isNull);
    });

    test('getAll returns all notes', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      await useCase.create(bookmarkId: bookmark.id, content: 'A');
      await useCase.create(bookmarkId: bookmark.id, content: 'B');

      final all = await useCase.getAll();
      expect(all.length, 2);
    });

    test('getByBookmarkId returns notes for bookmark', () async {
      final b1 = BookmarkItem(
        originalUrl: 'https://a.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final b2 = BookmarkItem(
        originalUrl: 'https://b.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(b1);
      await bookmarkRepo.insert(b2);

      await useCase.create(bookmarkId: b1.id, content: 'Note 1');
      await useCase.create(bookmarkId: b1.id, content: 'Note 2');
      await useCase.create(bookmarkId: b2.id, content: 'Note 3');

      final results = await useCase.getByBookmarkId(b1.id);
      expect(results.length, 2);
      expect(results.map((n) => n.content).toSet(), {'Note 1', 'Note 2'});
    });

    // ─── delete ──────────────────────────────────────────────────────────

    test('delete removes the note', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      final noteId = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'ToDelete',
      );
      expect(await noteRepo.getById(noteId), isNotNull);

      await useCase.delete(noteId);

      expect(await noteRepo.getById(noteId), isNull);
    });

    test('delete is no-op for non-existent id', () async {
      await useCase.delete(999);
      expect(noteRepo.saveCount, 0);
    });

    test('delete removes noteId from bookmark.noteIds', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      final noteId1 = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Keep',
      );
      final noteId2 = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Delete',
      );

      await useCase.delete(noteId2);

      final updatedBookmark = await bookmarkRepo.getById(bookmark.id);
      expect(updatedBookmark!.noteIds, [noteId1]);
    });

    test('delete sets noteIds to null when last note removed', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      final noteId = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Only note',
      );

      await useCase.delete(noteId);

      final updatedBookmark = await bookmarkRepo.getById(bookmark.id);
      expect(updatedBookmark!.noteIds, isNull);
    });

    test('delete updates bookmark updatedAt', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      await bookmarkRepo.insert(bookmark);
      final originalUpdatedAt = bookmark.updatedAt;

      final noteId = await useCase.create(
        bookmarkId: bookmark.id,
        content: 'Note',
      );

      await Future.delayed(const Duration(milliseconds: 10));

      await useCase.delete(noteId);

      final updatedBookmark = await bookmarkRepo.getById(bookmark.id);
      expect(updatedBookmark!.updatedAt.isAfter(originalUpdatedAt), isTrue);
    });
  });
}
