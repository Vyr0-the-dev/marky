import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/collections/presentation/widgets/collection_assignment_sheet.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';

// ─── Fake Collection Repository ────────────────────────────────────────

/// In-memory fake implementation of [CollectionRepository] for testing.
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

/// Minimal fake bookmark repository for assignment sheet tests.
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
  Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

// ─── Test Helpers ──────────────────────────────────────────────────────

BookmarkCollection _makeCollection({
  required int id,
  required String title,
  String? accentColor,
  String? icon,
  int itemCount = 0,
}) {
  return BookmarkCollection(
    title: title,
    slug: title.toLowerCase().replaceAll(' ', '-'),
    accentColor: accentColor,
    icon: icon,
    itemCount: itemCount,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  )..id = id;
}

Widget buildAssignmentSheet(
  FakeCollectionRepository collectionRepo, {
  List<int> initialCollectionIds = const <int>[],
}) {
  return ProviderScope(
    overrides: <Override>[
      collectionRepositoryProvider.overrideWithValue(collectionRepo),
      bookmarkRepositoryProvider.overrideWithValue(FakeBookmarkRepo()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: CollectionAssignmentSheet(
          bookmarkId: 1,
          initialCollectionIds: <int>[],
        ),
      ),
    ),
  );
}

Widget buildAssignmentSheetWithSelection(
  FakeCollectionRepository collectionRepo, {
  required List<int> initialCollectionIds,
}) {
  return ProviderScope(
    overrides: <Override>[
      collectionRepositoryProvider.overrideWithValue(collectionRepo),
      bookmarkRepositoryProvider.overrideWithValue(FakeBookmarkRepo()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: CollectionAssignmentSheet(
          bookmarkId: 1,
          initialCollectionIds: initialCollectionIds,
        ),
      ),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('CollectionAssignmentSheet', () {
    late FakeCollectionRepository fakeCollectionRepo;

    setUp(() {
      fakeCollectionRepo = FakeCollectionRepository();
    });

    testWidgets('renders loading state initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no collections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('No collections yet'), findsOneWidget);
      expect(
        find.text('Create your first collection to get started'),
        findsOneWidget,
      );
    });

    testWidgets('renders collection titles and item counts', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Flutter', itemCount: 3),
        _makeCollection(id: 2, title: 'Dart', itemCount: 1),
      ]);

      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('3 items'), findsOneWidget);
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('renders checkboxes for each collection', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Flutter'),
        _makeCollection(id: 2, title: 'Dart'),
      ]);

      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsNWidgets(2));
    });

    testWidgets('initially selected collections are checked', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Flutter'),
        _makeCollection(id: 2, title: 'Dart'),
      ]);

      await tester.pumpWidget(
        buildAssignmentSheetWithSelection(
          fakeCollectionRepo,
          initialCollectionIds: <int>[1],
        ),
      );
      await tester.pumpAndSettle();

      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      expect(checkboxes.length, 2);
      expect(checkboxes.first.value, isTrue);
      expect(checkboxes.last.value, isFalse);
    });

    testWidgets('tapping a collection toggles its checkbox', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Flutter'),
      ]);

      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      // Initially unchecked.
      Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);

      // Tap the collection row.
      await tester.tap(find.text('Flutter'));
      await tester.pumpAndSettle();

      // Should be checked after tap.
      checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('tapping checkbox toggles selection', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Flutter'),
      ]);

      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      // Tap directly on the checkbox.
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('shows Create New Collection button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Create New Collection'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders collection with custom accent color', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Flutter', accentColor: '#FF5722'),
      ]);

      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
      // The sheet renders without error for custom colors.
    });

    testWidgets('renders collection with custom icon', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(
          id: 1,
          title: 'Flutter',
          icon: Icons.folder.codePoint.toString(),
        ),
      ]);

      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('renders title and subtitle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Assign Collections'), findsOneWidget);
      expect(
        find.text('Select collections to organize this bookmark'),
        findsOneWidget,
      );
    });

    testWidgets('renders singular item count correctly', (
      WidgetTester tester,
    ) async {
      fakeCollectionRepo.setCollections(<BookmarkCollection>[
        _makeCollection(id: 1, title: 'Solo', itemCount: 1),
      ]);

      await tester.pumpWidget(buildAssignmentSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('1 item'), findsOneWidget);
      expect(find.text('1 items'), findsNothing);
    });
  });
}
