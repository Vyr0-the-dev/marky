import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/search/presentation/providers/search_providers.dart';
import 'package:marky/features/search/presentation/screens/search_screen.dart';
import 'package:marky/features/search/presentation/widgets/search_result_row.dart';
import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ─── Fakes ─────────────────────────────────────────────────────────────

class FakeBookmarkItemRepository implements BookmarkItemRepository {
  List<BookmarkItem> searchResults = <BookmarkItem>[];
  Exception? searchError;
  int searchCallCount = 0;

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async {
    searchCallCount++;
    if (searchError != null) {
      throw searchError!;
    }
    return searchResults;
  }

  @override
  Future<BookmarkItem?> getById(Id id) async => null;

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<Id> insert(BookmarkItem entity) async => 1;

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
}

class FakeAppSettingsRepository implements AppSettingsRepository {
  AppSettings? _saved;

  @override
  Future<AppSettings?> getSettings() async => _saved;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _saved = settings;
  }

  @override
  Future<void> deleteSettings() async {
    _saved = null;
  }
}

// ─── Test Helpers ──────────────────────────────────────────────────────

/// Creates a sample bookmark for test data.
BookmarkItem _makeBookmark({
  required int id,
  required String url,
  String? title,
  bool isFavorite = false,
}) {
  final DateTime now = DateTime.now();
  return BookmarkItem(
    originalUrl: url,
    title: title,
    isFavorite: isFavorite,
    createdAt: now,
    updatedAt: now,
  )..id = id;
}

/// Builds the [SearchScreen] inside a testable [MaterialApp] with
/// GoRouter and overridden providers.
Widget buildSearchScreen({
  required FakeBookmarkItemRepository fakeBookmarkRepo,
  required FakeAppSettingsRepository fakeSettingsRepo,
}) {
  final GoRouter router = GoRouter(
    initialLocation: Routes.search,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.search,
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: Routes.bookmarkDetail,
        builder: (BuildContext context, GoRouterState state) {
          return Scaffold(
            body: Center(
              child: Text('Detail ${state.pathParameters['id']}'),
            ),
          );
        },
      ),
    ],
  );

  return ProviderScope(
    overrides: <Override>[
      bookmarkRepositoryProvider.overrideWithValue(fakeBookmarkRepo),
      appSettingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
    ],
    child: MaterialApp.router(
      theme: AppTheme.dark(),
      routerConfig: router,
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('SearchScreen', () {
    late FakeBookmarkItemRepository fakeBookmarkRepo;
    late FakeAppSettingsRepository fakeSettingsRepo;

    setUp(() {
      fakeBookmarkRepo = FakeBookmarkItemRepository();
      fakeSettingsRepo = FakeAppSettingsRepository();
    });

    testWidgets('renders search bar with hint text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search bookmarks...'), findsOneWidget);
    });

    testWidgets('shows recent searches empty state when focused and query is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      // Tap the search field to focus it.
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('Start typing to search'), findsOneWidget);
    });

    testWidgets('typing triggers debounced search', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      // Enter text in the search field.
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      // Immediately after typing, no search should have fired yet.
      expect(fakeBookmarkRepo.searchCallCount, 0);

      // Wait for debounce (300ms + buffer).
      await tester.pump(const Duration(milliseconds: 400));

      // Search should have been triggered.
      expect(fakeBookmarkRepo.searchCallCount, greaterThanOrEqualTo(1));
    });

    testWidgets('shows empty state when no results', (
      WidgetTester tester,
    ) async {
      fakeBookmarkRepo.searchResults = <BookmarkItem>[];

      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      // Type a query and wait for debounce.
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('shows search results when bookmarks match', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter Docs',
      );
      fakeBookmarkRepo.searchResults = <BookmarkItem>[bm];

      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      // Type a query and wait for debounce.
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Docs'), findsOneWidget);
      expect(find.byType(SearchResultRow), findsOneWidget);
    });

    testWidgets('tapping a result row navigates to detail', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 42,
        url: 'https://example.com',
        title: 'Example',
      );
      fakeBookmarkRepo.searchResults = <BookmarkItem>[bm];

      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      // Type a query and wait for debounce.
      await tester.enterText(find.byType(TextField), 'example');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Tap the result row.
      await tester.tap(find.byType(SearchResultRow));
      await tester.pumpAndSettle();

      // Should navigate to detail screen.
      expect(find.text('Detail 42'), findsOneWidget);
    });

    testWidgets('filter chip toggles operator in search query', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(SearchScreen)),
      );

      // Initial state: no operators.
      expect(container.read(searchQueryProvider).operators, isEmpty);

      // Tap the Favorite chip.
      await tester.tap(find.text('Favorite'));
      await tester.pumpAndSettle();

      // Query should now have is:favorite.
      final SearchQuery query1 = container.read(searchQueryProvider);
      expect(query1.hasOperator('is'), isTrue);
      expect(query1.operatorValues('is'), contains('favorite'));

      // Tap the Favorite chip again to toggle off.
      await tester.tap(find.text('Favorite'));
      await tester.pumpAndSettle();

      final SearchQuery query2 = container.read(searchQueryProvider);
      expect(query2.hasOperator('is'), isFalse);
    });

    testWidgets('error state shows retry button', (
      WidgetTester tester,
    ) async {
      fakeBookmarkRepo.searchError = Exception('Database error');

      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      // Type a query and wait for debounce.
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    });

    testWidgets('clear button removes text from field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      // Enter text.
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pumpAndSettle();

      // Clear button should be visible and tapping it clears the field.
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('flutter'), findsNothing);
    });

    testWidgets('shows loading indicator while searching', (
      WidgetTester tester,
    ) async {
      // Use a delayed search to keep it in loading state.
      fakeBookmarkRepo.searchResults = <BookmarkItem>[
        _makeBookmark(id: 1, url: 'https://example.com'),
      ];

      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      // Type a query — before debounce completes, the provider is still
      // in its previous state. After debounce starts but before the future
      // resolves, we should see loading.
      await tester.enterText(find.byType(TextField), 'test');
      // Pump just past debounce but not long enough for settle.
      await tester.pump(const Duration(milliseconds: 350));

      // Should show loading.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('search field submit adds to recent searches', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSearchScreen(
        fakeBookmarkRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      ));
      await tester.pumpAndSettle();

      // Enter text and submit.
      await tester.enterText(find.byType(TextField), 'flutter tips');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(SearchScreen)),
      );

      // Recent searches should contain the submitted query.
      await tester.pump(const Duration(milliseconds: 100));
      final List<String> recent = container.read(recentSearchesProvider);
      expect(recent, contains('flutter tips'));
    });
  });
}
