import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/features/notes/presentation/screens/note_edit_screen.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/note.dart';

// ─── Fake Note Repository ──────────────────────────────────────────────

/// In-memory fake implementation of [NoteRepository] for testing.
class FakeNoteRepository implements NoteRepository {
  final Map<Id, Note> _notes = <Id, Note>{};
  int _nextId = 1;
  int saveCount = 0;

  void seedNote(Note note) {
    _notes[note.id] = note;
    if (note.id >= _nextId) {
      _nextId = note.id + 1;
    }
  }

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
        .where((Note n) => n.bookmarkId == bookmarkId)
        .toList();
  }
}

// ─── Fake Bookmark Repository ──────────────────────────────────────────

/// Minimal fake bookmark repository for note screen tests.
class FakeBookmarkRepo implements BookmarkItemRepository {
  final Map<Id, BookmarkItem> _bookmarks = <Id, BookmarkItem>{};
  int _nextId = 1;

  void seedBookmark(BookmarkItem bookmark) {
    _bookmarks[bookmark.id] = bookmark;
    if (bookmark.id >= _nextId) {
      _nextId = bookmark.id + 1;
    }
  }

  @override
  Future<BookmarkItem?> getById(Id id) async => _bookmarks[id];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => _bookmarks.values.toList();

  @override
  Future<Id> insert(BookmarkItem entity) async {
    entity.id = _nextId++;
    _bookmarks[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    _bookmarks[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async => _bookmarks.remove(id);

  @override
  Future<void> clear() async {
    _bookmarks.clear();
    _nextId = 1;
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async => null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

// ─── Test Helpers ──────────────────────────────────────────────────────

Note _makeNote({
  required Id id,
  required Id bookmarkId,
  required String content,
}) {
  return Note(
    bookmarkId: bookmarkId,
    content: content,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  )..id = id;
}

BookmarkItem _makeBookmark({
  required Id id,
  String originalUrl = 'https://example.com',
}) {
  return BookmarkItem(
    originalUrl: originalUrl,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  )..id = id;
}

/// Builds the [NoteEditScreen] wrapped in a [ProviderScope] with fake
/// repositories and a [Navigator] so [context.pop] works.
Widget buildNoteEditScreen({
  required FakeNoteRepository noteRepo,
  required FakeBookmarkRepo bookmarkRepo,
  required int bookmarkId,
  int? noteId,
}) {
  return ProviderScope(
    overrides: <Override>[
      noteRepositoryProvider.overrideWithValue(noteRepo),
      bookmarkRepositoryProvider.overrideWithValue(bookmarkRepo),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (BuildContext context) => NoteEditScreen(
              bookmarkId: bookmarkId,
              noteId: noteId,
            ),
          );
        },
      ),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('NoteEditScreen', () {
    late FakeNoteRepository fakeNoteRepo;
    late FakeBookmarkRepo fakeBookmarkRepo;

    setUp(() {
      fakeNoteRepo = FakeNoteRepository();
      fakeBookmarkRepo = FakeBookmarkRepo();
    });

    // ─── Create mode ───────────────────────────────────────────────────

    testWidgets('renders New Note title in create mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('shows multiline text field in create mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      final TextField textField = tester.widget(find.byType(TextField));
      expect(textField.maxLines, isNull); // null = unlimited
      expect(textField.minLines, 8);
      expect(textField.keyboardType, TextInputType.multiline);
    });

    testWidgets('does not show delete button in create mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('save creates a new note and pops with true', (
      WidgetTester tester,
    ) async {
      fakeBookmarkRepo.seedBookmark(_makeBookmark(id: 1));

      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'My new note');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Should have popped — screen is gone.
      expect(find.byType(NoteEditScreen), findsNothing);
      // Note was created.
      expect(fakeNoteRepo.saveCount, greaterThan(0));
      final List<Note> notes = await fakeNoteRepo.getByBookmarkId(1);
      expect(notes.length, 1);
      expect(notes.first.content, 'My new note');
    });

    testWidgets('save does nothing when content is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
        ),
      );
      await tester.pumpAndSettle();

      // Leave text field empty and tap save.
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Screen still visible, no note created.
      expect(find.byType(NoteEditScreen), findsOneWidget);
      expect(fakeNoteRepo.saveCount, 0);
    });

    // ─── Edit mode ─────────────────────────────────────────────────────

    testWidgets('renders Edit Note title in edit mode', (
      WidgetTester tester,
    ) async {
      fakeNoteRepo.seedNote(_makeNote(id: 10, bookmarkId: 1, content: 'Existing'));

      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
          noteId: 10,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Note'), findsOneWidget);
    });

    testWidgets('loads existing note content in edit mode', (
      WidgetTester tester,
    ) async {
      fakeNoteRepo.seedNote(_makeNote(id: 10, bookmarkId: 1, content: 'Existing content'));

      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
          noteId: 10,
        ),
      );
      await tester.pumpAndSettle();

      final TextField textField = tester.widget(find.byType(TextField));
      expect(textField.controller!.text, 'Existing content');
    });

    testWidgets('shows delete button in edit mode', (
      WidgetTester tester,
    ) async {
      fakeNoteRepo.seedNote(_makeNote(id: 10, bookmarkId: 1, content: 'Existing'));

      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
          noteId: 10,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('save updates existing note and pops with true', (
      WidgetTester tester,
    ) async {
      fakeNoteRepo.seedNote(_makeNote(id: 10, bookmarkId: 1, content: 'Old'));
      fakeBookmarkRepo.seedBookmark(_makeBookmark(id: 1));

      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
          noteId: 10,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Updated content');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Should have popped.
      expect(find.byType(NoteEditScreen), findsNothing);
      // Note was updated.
      final Note? updated = await fakeNoteRepo.getById(10);
      expect(updated!.content, 'Updated content');
    });

    testWidgets('delete shows confirmation dialog and removes note', (
      WidgetTester tester,
    ) async {
      fakeNoteRepo.seedNote(_makeNote(id: 10, bookmarkId: 1, content: 'To delete'));
      fakeBookmarkRepo.seedBookmark(
        _makeBookmark(id: 1)..noteIds = [10],
      );

      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
          noteId: 10,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear.
      expect(find.text('Delete note?'), findsOneWidget);

      // Tap Delete.
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should have popped.
      expect(find.byType(NoteEditScreen), findsNothing);
      // Note was removed.
      expect(await fakeNoteRepo.getById(10), isNull);
    });

    testWidgets('delete dialog cancel keeps note', (
      WidgetTester tester,
    ) async {
      fakeNoteRepo.seedNote(_makeNote(id: 10, bookmarkId: 1, content: 'Keep me'));

      await tester.pumpWidget(
        buildNoteEditScreen(
          noteRepo: fakeNoteRepo,
          bookmarkRepo: fakeBookmarkRepo,
          bookmarkId: 1,
          noteId: 10,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Tap Cancel.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Still on screen, note intact.
      expect(find.byType(NoteEditScreen), findsOneWidget);
      expect(await fakeNoteRepo.getById(10), isNotNull);
    });

    // ─── Route constants ───────────────────────────────────────────────

    testWidgets('Routes.noteEdit is defined', (WidgetTester tester) async {
      expect(Routes.noteEdit, '/note/edit');
    });

    testWidgets('Routes.noteEditWithId is defined', (WidgetTester tester) async {
      expect(Routes.noteEditWithId, '/note/edit/:id');
    });
  });
}
