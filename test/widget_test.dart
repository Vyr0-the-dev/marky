import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/main.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/widgets/marky_bottom_nav.dart';

import 'fakes/fake_app_settings_repository.dart';

// ─── Fake Collection Repository for smoke tests ────────────────────────

class _FakeCollectionRepository implements CollectionRepository {
  @override
  Future<BookmarkCollection?> getById(Id id) async => null;

  @override
  Future<List<BookmarkCollection>> getAll() async => <BookmarkCollection>[];

  @override
  Future<Id> insert(BookmarkCollection entity) async => entity.id;

  @override
  Future<Id> update(BookmarkCollection entity) async => entity.id;

  @override
  Future<void> delete(Id id) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<BookmarkCollection?> getBySlug(String slug) async => null;
}

// ─── Fake Bookmark Repository for smoke tests ──────────────────────────

class _FakeBookmarkRepository implements BookmarkItemRepository {
  @override
  Future<BookmarkItem?> getById(Id id) async => null;

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<Id> insert(BookmarkItem entity) async => entity.id;

  @override
  Future<Id> update(BookmarkItem entity) async => entity.id;

  @override
  Future<void> delete(Id id) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(
          String externalContentId) async =>
      null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId,
          {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId,
          {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query,
          {int? offset, int? limit}) async =>
      <BookmarkItem>[];
}

void main() {
  group('MarkyApp smoke tests', () {
    late FakeAppSettingsRepository fakeRepo;
    late _FakeBookmarkRepository fakeBookmarkRepo;
    late _FakeCollectionRepository fakeCollectionRepo;

    setUp(() {
      fakeRepo = FakeAppSettingsRepository();
      fakeBookmarkRepo = _FakeBookmarkRepository();
      fakeCollectionRepo = _FakeCollectionRepository();
    });

    Widget buildApp() {
      return ProviderScope(
        overrides: <Override>[
          appSettingsProvider.overrideWith(
            (Ref ref) => AppSettingsNotifier(repository: fakeRepo),
          ),
          bookmarkRepositoryProvider.overrideWithValue(fakeBookmarkRepo),
          collectionRepositoryProvider.overrideWithValue(fakeCollectionRepo),
        ],
        child: const MarkyApp(),
      );
    }

    testWidgets('renders and shows initial Feed route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('No bookmarks yet'), findsOneWidget);
      expect(find.byType(MarkyBottomNav), findsOneWidget);
    });

    testWidgets('tapping Search tab switches to Search route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('No bookmarks yet'), findsOneWidget);

      // Find the Search nav item and tap it
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // The new SearchScreen shows a hero search bar with this hint text
      expect(find.text('Search bookmarks...'), findsOneWidget);
      expect(find.text('No bookmarks yet'), findsNothing);
    });

    testWidgets('tapping Add tab switches to Capture route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // The Add button uses an Icon, not text — find it by icon
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Add Link'), findsOneWidget);
    });

    testWidgets('tapping Collections tab switches to Collections route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Collections'));
      await tester.pumpAndSettle();

      expect(find.text('No collections yet'), findsOneWidget);
    });

    testWidgets('tapping Profile tab switches to Settings route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.byIcon(Icons.person_outline),
        ),
      );
      await tester.pumpAndSettle();

      // Profile branch renders SettingsScreen — look for the app bar title
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('bottom navigation exposes semantic labels', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      try {
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(MarkyBottomNav),
            matching: find.bySemanticsLabel('Feed'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(MarkyBottomNav),
            matching: find.bySemanticsLabel('Search'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(MarkyBottomNav),
            matching: find.bySemanticsLabel('Add'),
          ),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('preserves inherited text scaling in app content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: buildApp(),
        ),
      );
      await tester.pumpAndSettle();

      final Iterable<MediaQuery> mediaQueries = tester.widgetList<MediaQuery>(
        find.descendant(
          of: find.byType(MaterialApp),
          matching: find.byType(MediaQuery),
        ),
      );

      expect(
        mediaQueries.any(
          (MediaQuery query) => query.data.textScaler.scale(10) == 20,
        ),
        isTrue,
      );
    });
  });
}
