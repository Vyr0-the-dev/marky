import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/collections/presentation/widgets/create_collection_sheet.dart';
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

  List<BookmarkCollection> get collections => List<BookmarkCollection>.unmodifiable(_collections);

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

/// Minimal fake bookmark repository for collection sheet tests.
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
  String? description,
  int itemCount = 0,
}) {
  return BookmarkCollection(
    title: title,
    slug: title.toLowerCase().replaceAll(' ', '-'),
    accentColor: accentColor,
    icon: icon,
    description: description,
    itemCount: itemCount,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  )..id = id;
}

Widget buildCreateCollectionSheet(FakeCollectionRepository collectionRepo) {
  return ProviderScope(
    overrides: <Override>[
      collectionRepositoryProvider.overrideWithValue(collectionRepo),
      bookmarkRepositoryProvider.overrideWithValue(FakeBookmarkRepo()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: CreateCollectionSheet(),
      ),
    ),
  );
}

Widget buildEditCollectionSheet(
  FakeCollectionRepository collectionRepo,
  BookmarkCollection collection,
) {
  return ProviderScope(
    overrides: <Override>[
      collectionRepositoryProvider.overrideWithValue(collectionRepo),
      bookmarkRepositoryProvider.overrideWithValue(FakeBookmarkRepo()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: CreateCollectionSheet.edit(collection: collection),
      ),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('CreateCollectionSheet', () {
    late FakeCollectionRepository fakeCollectionRepo;

    setUp(() {
      fakeCollectionRepo = FakeCollectionRepository();
    });

    testWidgets('renders title and fields in creation mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCreateCollectionSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Create Collection'), findsNWidgets(2));
      expect(find.text('Collection title'), findsOneWidget);
      expect(find.text('Description (optional)'), findsOneWidget);
    });

    testWidgets('renders title and fields in edit mode', (
      WidgetTester tester,
    ) async {
      final collection = _makeCollection(id: 1, title: 'Research');
      await tester.pumpWidget(
        buildEditCollectionSheet(fakeCollectionRepo, collection),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Collection'), findsOneWidget);
    });

    testWidgets('pre-fills title in edit mode', (
      WidgetTester tester,
    ) async {
      final collection = _makeCollection(id: 1, title: 'Research Papers');
      await tester.pumpWidget(
        buildEditCollectionSheet(fakeCollectionRepo, collection),
      );
      await tester.pumpAndSettle();

      expect(find.text('Research Papers'), findsOneWidget);
    });

    testWidgets('pre-fills description in edit mode', (
      WidgetTester tester,
    ) async {
      final collection = _makeCollection(
        id: 1,
        title: 'Research',
        description: 'My research collection',
      );
      await tester.pumpWidget(
        buildEditCollectionSheet(fakeCollectionRepo, collection),
      );
      await tester.pumpAndSettle();

      expect(find.text('My research collection'), findsOneWidget);
    });

    testWidgets('save button is disabled when title is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCreateCollectionSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('save button is enabled when title is entered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCreateCollectionSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'New Collection');
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('creates collection when save is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCreateCollectionSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Flutter Tips');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // After creation + pop, sheet should be gone.
      expect(find.text('Create Collection'), findsNothing);
    });

    testWidgets('renders color picker options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCreateCollectionSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Accent Color'), findsOneWidget);
      // Color options are rendered as GestureDetector containers.
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('renders icon picker options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCreateCollectionSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Icon'), findsOneWidget);
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('renders cover mode toggle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCreateCollectionSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      expect(find.text('Cover Style'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Gradient'), findsOneWidget);
    });

    testWidgets('tapping color option selects it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCreateCollectionSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      // Tap the first color option (GestureDetector in the color section).
      final gestureDetectors = find.byType(GestureDetector);
      // There are many GestureDetectors; tap one in the color picker area.
      await tester.tap(gestureDetectors.at(1));
      await tester.pumpAndSettle();

      // Sheet should still be open; no crash.
      expect(find.text('Create Collection'), findsNWidgets(2));
    });

    testWidgets('tapping cover mode option changes selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildCreateCollectionSheet(fakeCollectionRepo));
      await tester.pumpAndSettle();

      // Tap the "Gradient" option.
      await tester.tap(find.text('Gradient'));
      await tester.pumpAndSettle();

      // Sheet should still be open; no crash.
      expect(find.text('Create Collection'), findsNWidgets(2));
    });

    testWidgets('edit mode shows Save Changes button', (
      WidgetTester tester,
    ) async {
      final collection = _makeCollection(id: 1, title: 'Research');
      await tester.pumpWidget(
        buildEditCollectionSheet(fakeCollectionRepo, collection),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save Changes'), findsOneWidget);
    });
  });
}
