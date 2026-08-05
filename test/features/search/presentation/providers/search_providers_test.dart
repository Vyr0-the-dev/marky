import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/search/domain/use_cases/search_bookmarks_use_case.dart';
import 'package:marky/features/search/presentation/providers/search_providers.dart';
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
  int saveCount = 0;

  AppSettings? get saved => _saved;

  @override
  Future<AppSettings?> getSettings() async => _saved;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _saved = settings;
    saveCount++;
  }

  @override
  Future<void> deleteSettings() async {
    _saved = null;
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────

ProviderContainer createContainer({
  required FakeBookmarkItemRepository fakeRepo,
  required FakeAppSettingsRepository fakeSettingsRepo,
}) {
  return ProviderContainer(
    overrides: <Override>[
      bookmarkRepositoryProvider.overrideWithValue(fakeRepo),
      appSettingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
    ],
  );
}

void main() {
  group('SearchBookmarksUseCase', () {
    late FakeBookmarkItemRepository fakeRepo;
    late SearchBookmarksUseCase useCase;

    setUp(() {
      fakeRepo = FakeBookmarkItemRepository();
      useCase = SearchBookmarksUseCase(repository: fakeRepo);
    });

    test('execute returns empty list for empty query', () async {
      const query = SearchQuery();
      final results = await useCase.execute(query);
      expect(results, isEmpty);
      expect(fakeRepo.searchCallCount, 0);
    });

    test('execute delegates to repository for non-empty query', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      fakeRepo.searchResults = <BookmarkItem>[bookmark];

      const query = SearchQuery(freeText: <String>['flutter']);
      final results = await useCase.execute(query);

      expect(results, hasLength(1));
      expect(fakeRepo.searchCallCount, 1);
    });

    test('execute propagates repository exceptions', () async {
      fakeRepo.searchError = Exception('Isar error');
      const query = SearchQuery(freeText: <String>['flutter']);

      expect(() => useCase.execute(query), throwsA(isA<Exception>()));
    });
  });

  group('SearchQueryNotifier', () {
    test('initial state is empty SearchQuery', () {
      final notifier = SearchQueryNotifier();
      expect(notifier.state, const SearchQuery());
    });

    test('setQuery debounces by default 300ms', () async {
      final notifier = SearchQueryNotifier();
      notifier.setQuery('flutter');

      // Immediately after calling, state should still be empty.
      expect(notifier.state, const SearchQuery());

      // After 250ms, still debouncing.
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(notifier.state, const SearchQuery());

      // After 350ms total, debounce should have fired.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(notifier.state.freeText, <String>['flutter']);

      notifier.dispose();
    });

    test('rapid sequential queries cancel prior timer', () async {
      final notifier = SearchQueryNotifier();

      notifier.setQuery('a');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      notifier.setQuery('ab');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      notifier.setQuery('abc');

      // Wait just past the first 300ms window.
      await Future<void>.delayed(const Duration(milliseconds: 250));
      // Should still be empty because the third query reset the timer.
      expect(notifier.state, const SearchQuery());

      // Wait for the third query's debounce to complete.
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(notifier.state.freeText, <String>['abc']);

      notifier.dispose();
    });

    test('setQuery with custom debounceMs', () async {
      final notifier = SearchQueryNotifier();
      notifier.setQuery('dart', debounceMs: 50);

      await Future<void>.delayed(Duration.zero);
      expect(notifier.state, const SearchQuery());

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(notifier.state.freeText, <String>['dart']);

      notifier.dispose();
    });

    test('cancelDebounce prevents pending update', () async {
      final notifier = SearchQueryNotifier();
      notifier.setQuery('flutter');
      notifier.cancelDebounce();

      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(notifier.state, const SearchQuery());

      notifier.dispose();
    });

    test('handles very long raw query gracefully', () async {
      final notifier = SearchQueryNotifier();
      final longQuery = 'a' * 2000;
      notifier.setQuery(longQuery, debounceMs: 0);

      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.freeText, hasLength(1));
      expect(notifier.state.freeText.first, longQuery);

      notifier.dispose();
    });

    test('handles empty and whitespace-only queries', () async {
      final notifier = SearchQueryNotifier();

      notifier.setQuery('', debounceMs: 0);
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.isEmpty, true);

      notifier.setQuery('   ', debounceMs: 0);
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.isEmpty, true);

      notifier.dispose();
    });
  });

  group('searchResultsProvider', () {
    late FakeBookmarkItemRepository fakeRepo;
    late FakeAppSettingsRepository fakeSettingsRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeBookmarkItemRepository();
      fakeSettingsRepo = FakeAppSettingsRepository();
      container = createContainer(
        fakeRepo: fakeRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      );
    });

    tearDown(() => container.dispose());

    test('emits loading then data for non-empty query', () async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://flutter.dev',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      fakeRepo.searchResults = <BookmarkItem>[bookmark];

      const query = SearchQuery(freeText: <String>['flutter']);
      final subscription = container.listen(
        searchResultsProvider(query),
        (_, __) {},
      );

      // Immediately after requesting, should be loading.
      expect(subscription.read(), isA<AsyncLoading<List<BookmarkItem>>>());

      // Wait for completion.
      await container.read(searchResultsProvider(query).future);
      final value = subscription.read();
      expect(value, isA<AsyncData<List<BookmarkItem>>>());
      expect(value.value, hasLength(1));

      subscription.close();
    });

    test('emits empty data for empty query', () async {
      const query = SearchQuery();
      final results = await container.read(searchResultsProvider(query).future);
      expect(results, isEmpty);
    });

    test('emits AsyncValue.error when repository throws', () async {
      fakeRepo.searchError = Exception('Database locked');
      const query = SearchQuery(freeText: <String>['flutter']);

      final subscription = container.listen(
        searchResultsProvider(query),
        (_, __) {},
      );

      // Wait for the future to complete with error.
      await expectLater(
        container.read(searchResultsProvider(query).future),
        throwsA(isA<Exception>()),
      );

      // After the future rejects, the AsyncValue should be error.
      final value = subscription.read();
      expect(value, isA<AsyncError<List<BookmarkItem>>>());

      subscription.close();
    });
  });

  group('RecentSearchesNotifier', () {
    late FakeAppSettingsRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeAppSettingsRepository();
    });

    test('initial state is empty', () async {
      final notifier = RecentSearchesNotifier(repository: fakeRepo);
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state, isEmpty);
      notifier.dispose();
    });

    test('loads persisted searches on init', () async {
      await fakeRepo.saveSettings(
        AppSettings(
          themeMode: 'dark',
          recentSearches: <String>['flutter', 'dart'],
        ),
      );

      final notifier = RecentSearchesNotifier(repository: fakeRepo);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, <String>['flutter', 'dart']);
      notifier.dispose();
    });

    test('addQuery prepends and dedupes', () async {
      final notifier = RecentSearchesNotifier(repository: fakeRepo);
      await Future<void>.delayed(Duration.zero);

      notifier.addQuery('flutter');
      expect(notifier.state, <String>['flutter']);

      notifier.addQuery('dart');
      expect(notifier.state, <String>['dart', 'flutter']);

      notifier.addQuery('flutter');
      expect(notifier.state, <String>['flutter', 'dart']);

      notifier.dispose();
    });

    test('addQuery ignores empty or whitespace-only queries', () async {
      final notifier = RecentSearchesNotifier(repository: fakeRepo);
      await Future<void>.delayed(Duration.zero);

      notifier.addQuery('');
      notifier.addQuery('   ');
      expect(notifier.state, isEmpty);

      notifier.dispose();
    });

    test('addQuery caps at 20 items', () async {
      final notifier = RecentSearchesNotifier(repository: fakeRepo);
      await Future<void>.delayed(Duration.zero);

      for (var i = 0; i < 25; i++) {
        notifier.addQuery('query_$i');
      }

      expect(notifier.state, hasLength(20));
      expect(notifier.state.first, 'query_24');
      expect(notifier.state.last, 'query_5');

      notifier.dispose();
    });

    test('clear empties the list', () async {
      final notifier = RecentSearchesNotifier(repository: fakeRepo);
      await Future<void>.delayed(Duration.zero);

      notifier.addQuery('flutter');
      notifier.clear();
      expect(notifier.state, isEmpty);

      notifier.dispose();
    });

    test('persists on add and clear', () async {
      final notifier = RecentSearchesNotifier(repository: fakeRepo);
      await Future<void>.delayed(Duration.zero);

      notifier.addQuery('flutter');
      await Future<void>.delayed(Duration.zero);
      expect(fakeRepo.saved?.recentSearches, <String>['flutter']);

      notifier.clear();
      await Future<void>.delayed(Duration.zero);
      expect(fakeRepo.saved?.recentSearches, isEmpty);

      notifier.dispose();
    });

    test('silently skips persistence failures', () async {
      final brokenRepo = _BrokenAppSettingsRepository();
      final notifier = RecentSearchesNotifier(repository: brokenRepo);
      await Future<void>.delayed(Duration.zero);

      // Should not throw.
      notifier.addQuery('flutter');
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state, <String>['flutter']);

      notifier.dispose();
    });
  });

  group('recentSearchesProvider', () {
    late FakeBookmarkItemRepository fakeBookmarkRepo;
    late FakeAppSettingsRepository fakeSettingsRepo;
    late ProviderContainer container;

    setUp(() {
      fakeBookmarkRepo = FakeBookmarkItemRepository();
      fakeSettingsRepo = FakeAppSettingsRepository();
      container = createContainer(
        fakeRepo: fakeBookmarkRepo,
        fakeSettingsRepo: fakeSettingsRepo,
      );
    });

    tearDown(() => container.dispose());

    test('exposes empty list by default', () async {
      final subscription = container.listen(
        recentSearchesProvider,
        (_, __) {},
      );
      await Future<void>.delayed(Duration.zero);
      expect(subscription.read(), isEmpty);
      subscription.close();
    });
  });
}

class _BrokenAppSettingsRepository implements AppSettingsRepository {
  @override
  Future<AppSettings?> getSettings() async => throw Exception('broken');

  @override
  Future<void> saveSettings(AppSettings settings) async => throw Exception('broken');

  @override
  Future<void> deleteSettings() async {}
}
