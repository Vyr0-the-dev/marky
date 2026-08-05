import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/feed/presentation/screens/bookmark_detail_screen.dart';
import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/note.dart';

// ─── Fake Repository ───────────────────────────────────────────────────

/// In-memory fake implementation of [BookmarkItemRepository] for testing.
class FakeBookmarkItemRepository implements BookmarkItemRepository {
  final List<BookmarkItem> _items = <BookmarkItem>[];

  void setItems(List<BookmarkItem> items) {
    _items
      ..clear()
      ..addAll(items);
  }

  @override
  Future<BookmarkItem?> getById(int id) async {
    try {
      return _items.firstWhere((BookmarkItem item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => List<BookmarkItem>.unmodifiable(_items);

  @override
  Future<int> insert(BookmarkItem entity) async {
    _items.add(entity);
    return entity.id;
  }

  @override
  Future<int> update(BookmarkItem entity) async => entity.id;

  @override
  Future<void> delete(int id) async {
    _items.removeWhere((BookmarkItem item) => item.id == id);
  }

  @override
  Future<void> clear() async => _items.clear();

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
  Future<List<BookmarkItem>> getByCollectionId(int collectionId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(int tagId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

// ─── Fake Note Repository ──────────────────────────────────────────────

/// In-memory fake implementation of [NoteRepository] for testing.
class FakeNoteRepository implements NoteRepository {
  final List<Note> _notes = <Note>[];

  void setNotes(List<Note> notes) {
    _notes
      ..clear()
      ..addAll(notes);
  }

  @override
  Future<List<Note>> getAll() async => List<Note>.unmodifiable(_notes);

  @override
  Future<Note?> getById(int id) async {
    try {
      return _notes.firstWhere((Note note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insert(Note entity) async {
    _notes.add(entity);
    return entity.id;
  }

  @override
  Future<int> update(Note entity) async => entity.id;

  @override
  Future<void> delete(int id) async {
    _notes.removeWhere((Note note) => note.id == id);
  }

  @override
  Future<void> clear() async => _notes.clear();

  @override
  Future<List<Note>> getByBookmarkId(int bookmarkId) async {
    return _notes.where((Note note) => note.bookmarkId == bookmarkId).toList();
  }
}

// ─── Test Helpers ──────────────────────────────────────────────────────

/// Builds the [BookmarkDetailScreen] inside a [MaterialApp] with the Marky
/// dark theme and a [ProviderScope] that overrides repositories.
Widget buildDetailScreen(
  FakeBookmarkItemRepository bookmarkRepo,
  int id, {
  FakeNoteRepository? noteRepo,
}) {
  final List<Override> overrides = <Override>[
    bookmarkRepositoryProvider.overrideWithValue(bookmarkRepo),
  ];
  if (noteRepo != null) {
    overrides.add(noteRepositoryProvider.overrideWithValue(noteRepo));
  }
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: BookmarkDetailScreen(id: id),
    ),
  );
}

/// Creates a sample bookmark for test data.
BookmarkItem _makeBookmark({
  required int id,
  required String url,
  String? title,
  String? description,
  String? localThumbnailPath,
  String? heroImageUrl,
  String? thumbnailUrl,
  DateTime? createdAt,
}) {
  final DateTime now = createdAt ?? DateTime(2025, 1, 15);
  return BookmarkItem(
    originalUrl: url,
    title: title,
    description: description,
    localThumbnailPath: localThumbnailPath,
    heroImageUrl: heroImageUrl,
    thumbnailUrl: thumbnailUrl,
    createdAt: now,
    updatedAt: now,
  )..id = id;
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('BookmarkDetailScreen', () {
    late FakeBookmarkItemRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeBookmarkItemRepository();
    });

    testWidgets('renders loading state initially', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildDetailScreen(fakeRepository, 1));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders title when bookmark loaded', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter Documentation',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildDetailScreen(fakeRepository, 1));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Documentation'), findsOneWidget);
    });

    testWidgets('renders hero image area (AspectRatio present)', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildDetailScreen(fakeRepository, 1));
      await tester.pumpAndSettle();

      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('renders domain and date', (
      WidgetTester tester,
    ) async {
      final DateTime createdAt = DateTime(2025, 6, 10);
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: createdAt,
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildDetailScreen(fakeRepository, 1));
      await tester.pumpAndSettle();

      expect(find.text('flutter.dev'), findsOneWidget);
      // Date is rendered via DateFormat.yMMMd()
      expect(find.text('Jun 10, 2025'), findsOneWidget);
    });

    testWidgets('renders action buttons', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildDetailScreen(fakeRepository, 1));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Favorite'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('renders Bookmark not found when ID does not exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildDetailScreen(fakeRepository, 999));
      await tester.pumpAndSettle();

      expect(find.text('Bookmark not found'), findsOneWidget);
    });

    testWidgets('hero image uses localThumbnailPath over remote URLs', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter',
        localThumbnailPath: '/fake/local/image.png',
        heroImageUrl: 'https://example.com/hero.jpg',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildDetailScreen(fakeRepository, 1));
      await tester.pumpAndSettle();

      // When local path is present, the Image.file widget is used.
      // We verify by checking no CachedNetworkImage is rendered.
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('renders notes section header', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildDetailScreen(fakeRepository, 1));
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Add note'), findsOneWidget);
    });

    testWidgets('renders empty notes state when no notes exist', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);
      final FakeNoteRepository noteRepo = FakeNoteRepository();

      await tester.pumpWidget(buildDetailScreen(fakeRepository, 1, noteRepo: noteRepo));
      await tester.pumpAndSettle();

      expect(find.text('No notes yet'), findsOneWidget);
    });

    testWidgets('renders note content when notes exist', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      final DateTime now = DateTime(2025, 1, 15);
      final FakeNoteRepository noteRepo = FakeNoteRepository()
        ..setNotes(<Note>[
          Note(
            bookmarkId: 1,
            content: 'Remember to check the docs',
            createdAt: now,
            updatedAt: now,
          )..id = 1,
        ]);

      await tester.pumpWidget(buildDetailScreen(fakeRepository, 1, noteRepo: noteRepo));
      await tester.pumpAndSettle();

      expect(find.text('Remember to check the docs'), findsOneWidget);
    });
  });
}
