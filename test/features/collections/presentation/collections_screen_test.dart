import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/collections/presentation/screens/collections_screen.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';

// ─── Fake Collection Repository ────────────────────────────────────────

/// In-memory fake implementation of [CollectionRepository] for testing.
class FakeCollectionRepository implements CollectionRepository {
  final List<BookmarkCollection> _collections = <BookmarkCollection>[];
  int _nextId = 1;

  void setCollections(List<BookmarkCollection> collections) {
    _collections
      ..clear()
      ..addAll(collections);
  }

  @override
  Future<List<BookmarkCollection>> getAll() async =>
      List<BookmarkCollection>.unmodifiable(_collections);

  @override
  Future<BookmarkCollection?> getById(int id) async {
    try {
      return _collections.firstWhere((BookmarkCollection c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BookmarkCollection?> getBySlug(String slug) async {
    try {
      return _collections.firstWhere((BookmarkCollection c) => c.slug == slug);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insert(BookmarkCollection entity) async {
    entity.id = _nextId++;
    _collections.add(entity);
    return entity.id;
  }

  @override
  Future<int> update(BookmarkCollection entity) async => entity.id;

  @override
  Future<void> delete(int id) async {
    _collections.removeWhere((BookmarkCollection c) => c.id == id);
  }

  @override
  Future<void> clear() async {
    _collections.clear();
    _nextId = 1;
  }
}

// ─── Fake Bookmark Repository ──────────────────────────────────────────

/// Minimal fake bookmark repository for collection screen tests.
class FakeBookmarkRepo implements BookmarkItemRepository {
  @override
  Future<BookmarkItem?> getById(int id) async => null;
  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => <BookmarkItem>[];
  @override
  Future<int> insert(BookmarkItem entity) async => 0;
  @override
  Future<int> update(BookmarkItem entity) async => 0;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> clear() async {}
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

// ─── Test Helpers ──────────────────────────────────────────────────────

BookmarkCollection _makeCollection({
  required int id,
  required String title,
  String? accentColor,
  String? icon,
  String? description,
  int itemCount = 0,
  bool isPinned = false,
}) {
  return BookmarkCollection(
    title: title,
    slug: title.toLowerCase().replaceAll(' ', '-'),
    accentColor: accentColor,
    icon: icon,
    description: description,
    itemCount: itemCount,
    isPinned: isPinned,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  )..id = id;
}

Widget buildCollectionsScreen(FakeCollectionRepository collectionRepo) {
  return ProviderScope(
    overrides: <Override>[
      collectionRepositoryProvider.overrideWithValue(collectionRepo),
      bookmarkRepositoryProvider.overrideWithValue(FakeBookmarkRepo()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: const CollectionsScreen(),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('CollectionsScreen', () {
    late FakeCollectionRepository fakeCollectionRepo;

    setUp(() {
      fakeCollectionRepo = FakeCollectionRepository();
    });

    testWidgets('renders loading state initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCollectionsScreen(fakeCollectionRepo));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no collections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCollectionsScreen(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('No collections yet'), findsOneWidget);
      expect(
        find.text('Create your first collection to organize bookmarks'),
        findsOneWidget,
      );
    });

    testWidgets('renders collection titles and item counts', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Research', itemCount: 5),
        _makeCollection(id: 2, title: 'Ideas', itemCount: 1),
      ]);

      await tester.pumpWidget(buildCollectionsScreen(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Research'), findsOneWidget);
      expect(find.text('Ideas'), findsOneWidget);
      expect(find.text('5 items'), findsOneWidget);
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('renders collection descriptions when present', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(
          id: 1,
          title: 'Research',
          description: 'Papers and articles',
        ),
      ]);

      await tester.pumpWidget(buildCollectionsScreen(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Papers and articles'), findsOneWidget);
    });

    testWidgets('filters collections by search query', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Flutter Dev'),
        _makeCollection(id: 2, title: 'Dart Tips'),
      ]);

      await tester.pumpWidget(buildCollectionsScreen(fakeCollectionRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Flu');
      await tester.pumpAndSettle();

      expect(find.text('Flutter Dev'), findsOneWidget);
      expect(find.text('Dart Tips'), findsNothing);
    });

    testWidgets('shows no results message when search has no matches', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Flutter'),
      ]);

      await tester.pumpWidget(buildCollectionsScreen(fakeCollectionRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();

      expect(find.text('No collections matching "xyz"'), findsOneWidget);
    });

    testWidgets('FAB is present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCollectionsScreen(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows pinned collections first', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Regular'),
        _makeCollection(id: 2, title: 'Pinned', isPinned: true),
      ]);

      await tester.pumpWidget(buildCollectionsScreen(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('renders grid with collection cards', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'A'),
        _makeCollection(id: 2, title: 'B'),
        _makeCollection(id: 3, title: 'C'),
      ]);

      await tester.pumpWidget(buildCollectionsScreen(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('renders error state on failure', (
      WidgetTester tester,
    ) async {
      // Create a repository that throws on getAll.
      final ErrorCollectionRepository errorRepo = ErrorCollectionRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            collectionRepositoryProvider.overrideWithValue(errorRepo),
            bookmarkRepositoryProvider.overrideWithValue(FakeBookmarkRepo()),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const CollectionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load collections'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

// ─── Error-throwing repository for negative tests ──────────────────────

class ErrorCollectionRepository implements CollectionRepository {
  @override
  Future<List<BookmarkCollection>> getAll() async =>
      throw Exception('Simulated load failure');

  @override
  Future<BookmarkCollection?> getById(int id) async => null;

  @override
  Future<BookmarkCollection?> getBySlug(String slug) async => null;

  @override
  Future<int> insert(BookmarkCollection entity) async => 0;

  @override
  Future<int> update(BookmarkCollection entity) async => 0;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> clear() async {}
}
