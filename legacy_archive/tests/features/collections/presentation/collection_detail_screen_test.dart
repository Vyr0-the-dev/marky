import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/collections/presentation/screens/collection_detail_screen.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';

// ─── Fake Collection Repository ────────────────────────────────────────

class FakeCollectionRepository implements CollectionRepository {
  final List<BookmarkCollection> _collections = <BookmarkCollection>[];

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
  Future<void> clear() async => _collections.clear();
}

// ─── Fake Bookmark Repository ──────────────────────────────────────────

class FakeBookmarkRepo implements BookmarkItemRepository {
  final List<BookmarkItem> _items = <BookmarkItem>[];

  void setItems(List<BookmarkItem> items) {
    _items
      ..clear()
      ..addAll(items);
  }

  @override
  Future<BookmarkItem?> getById(int id) async => null;
  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async =>
      List<BookmarkItem>.unmodifiable(_items);
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
  Future<List<BookmarkItem>> getByCollectionId(int collectionId, {int? offset, int? limit}) async {
    return _items
        .where((BookmarkItem b) => b.collectionIds?.contains(collectionId) ?? false)
        .toList();
  }

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
}) {
  return BookmarkCollection(
    title: title,
    slug: title.toLowerCase().replaceAll(' ', '-'),
    accentColor: accentColor,
    icon: icon,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  )..id = id;
}

BookmarkItem _makeBookmark({
  required int id,
  required String url,
  String? title,
  List<int>? collectionIds,
}) {
  final DateTime now = DateTime(2025, 1, 15);
  return BookmarkItem(
    originalUrl: url,
    title: title,
    collectionIds: collectionIds,
    createdAt: now,
    updatedAt: now,
  )..id = id;
}

Widget buildCollectionDetailScreen(
  FakeCollectionRepository collectionRepo,
  FakeBookmarkRepo bookmarkRepo,
  int id,
) {
  return ProviderScope(
    overrides: <Override>[
      collectionRepositoryProvider.overrideWithValue(collectionRepo),
      bookmarkRepositoryProvider.overrideWithValue(bookmarkRepo),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: CollectionDetailScreen(id: id),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('CollectionDetailScreen', () {
    late FakeCollectionRepository fakeCollectionRepo;
    late FakeBookmarkRepo fakeBookmarkRepo;

    setUp(() {
      fakeCollectionRepo = FakeCollectionRepository();
      fakeBookmarkRepo = FakeBookmarkRepo();
    });

    testWidgets('renders loading state initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildCollectionDetailScreen(fakeCollectionRepo, fakeBookmarkRepo, 1),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders collection name in app bar when loaded', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Research', accentColor: '#7C5CFF'),
      ]);

      await tester.pumpWidget(
        buildCollectionDetailScreen(fakeCollectionRepo, fakeBookmarkRepo, 1),
      );
      await tester.pumpAndSettle();

      expect(find.text('Research'), findsOneWidget);
    });

    testWidgets('renders "Collection not found" for missing collection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildCollectionDetailScreen(fakeCollectionRepo, fakeBookmarkRepo, 999),
      );
      await tester.pumpAndSettle();

      expect(find.text('Collection not found'), findsOneWidget);
    });

    testWidgets('renders bookmarks in the collection', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Research'),
      ]);
      fakeBookmarkRepo.setItems(<BookmarkItem>[
        _makeBookmark(
          id: 1,
          url: 'https://example.com',
          title: 'Example Article',
          collectionIds: <int>[1],
        ),
      ]);

      await tester.pumpWidget(
        buildCollectionDetailScreen(fakeCollectionRepo, fakeBookmarkRepo, 1),
      );
      await tester.pumpAndSettle();

      expect(find.text('Example Article'), findsOneWidget);
    });

    testWidgets('renders empty state when no bookmarks in collection', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Empty Collection'),
      ]);

      await tester.pumpWidget(
        buildCollectionDetailScreen(fakeCollectionRepo, fakeBookmarkRepo, 1),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No bookmarks in this collection yet'),
        findsOneWidget,
      );
    });

    testWidgets('renders edit button in app bar for existing collection', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Research'),
      ]);

      await tester.pumpWidget(
        buildCollectionDetailScreen(fakeCollectionRepo, fakeBookmarkRepo, 1),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('renders error state when collection load fails', (
      WidgetTester tester,
    ) async {
      final ErrorCollectionRepository errorRepo = ErrorCollectionRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            collectionRepositoryProvider.overrideWithValue(errorRepo),
            bookmarkRepositoryProvider.overrideWithValue(fakeBookmarkRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const CollectionDetailScreen(id: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load collection'), findsOneWidget);
    });
  });
}

// ─── Error-throwing repository for negative tests ──────────────────────

class ErrorCollectionRepository implements CollectionRepository {
  @override
  Future<List<BookmarkCollection>> getAll() async =>
      throw Exception('Simulated load failure');

  @override
  Future<BookmarkCollection?> getById(int id) async =>
      throw Exception('Simulated load failure');

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
