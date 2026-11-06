import 'package:flutter_test/flutter_test.dart';

import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/search/domain/bookmark_search_service.dart';
import 'package:marky/features/search/domain/search_query.dart';
import 'package:marky/features/search/domain/search_query_repository.dart';
import 'package:marky/features/search/presentation/search_notifier.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

void main() {
  late _FakeBookmarkRepository repo;
  late _FakeSearchQueryRepository searchQueryRepo;
  late SearchNotifier notifier;

  setUp(() {
    repo = _FakeBookmarkRepository();
    searchQueryRepo = _FakeSearchQueryRepository();
    notifier = SearchNotifier(
        BookmarkSearchService(
          bookmarkRepository: repo,
          tagRepository: _FakeTagRepository(),
        ),
        searchQueryRepo);
  });

  tearDown(() {
    notifier.dispose();
  });

  test('initial state has no query and no results', () {
    expect(notifier.state.query, '');
    expect(notifier.state.results, isEmpty);
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.hasSearched, isFalse);
  });

  test('updateQuery with empty string resets state', () {
    notifier.updateQuery('test');
    notifier.updateQuery('');

    expect(notifier.state.query, '');
    expect(notifier.state.results, isEmpty);
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.hasSearched, isFalse);
  });

  test('updateQuery sets isLoading true before debounce fires', () {
    notifier.updateQuery('flutter');
    expect(notifier.state.isLoading, isTrue);
    expect(notifier.state.query, 'flutter');
  });

  test('clear resets everything', () {
    notifier.updateQuery('dart');
    notifier.clear();

    expect(notifier.state.query, '');
    expect(notifier.state.results, isEmpty);
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.hasSearched, isFalse);
  });

  test('search executes after debounce and updates results', () async {
    repo.mockResults = <Bookmark>[
      _bookmark(1, 'Flutter Guide'),
      _bookmark(2, 'Dart Docs'),
    ];

    notifier.updateQuery('guide');

    // Wait for debounce (300ms) + async
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(notifier.state.results, hasLength(2));
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.hasSearched, isTrue);
    expect(searchQueryRepo.recentQueries, <String>['guide']);
  });

  test('stale results from older query are ignored', () async {
    repo.mockResults = <Bookmark>[_bookmark(1, 'Old')];
    notifier.updateQuery('old');

    // Immediately update with a new query before debounce fires
    repo.mockResults = <Bookmark>[_bookmark(2, 'New')];
    notifier.updateQuery('new');

    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Only the "new" results should appear
    expect(notifier.state.query, 'new');
    expect(notifier.state.results.first.title, 'New');
  });
}

class _FakeSearchQueryRepository implements SearchQueryRepository {
  final List<String> recentQueries = <String>[];

  @override
  Future<SearchQuery> recordRecent(String query) async {
    recentQueries.add(query);
    final DateTime now = DateTime.now();
    return SearchQuery(
      query: query,
      normalizedQuery: SearchQuery.normalize(query),
      createdAt: now,
      lastUsedAt: now,
    );
  }

  @override
  Future<SearchQuery> saveSearch(String query, {String? label}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchQuery?> findByNormalizedQuery(String normalizedQuery) {
    throw UnimplementedError();
  }

  @override
  Future<List<SearchQuery>> getRecent({int limit = 10}) {
    throw UnimplementedError();
  }

  @override
  Future<List<SearchQuery>> getSaved() {
    throw UnimplementedError();
  }

  @override
  Future<void> removeRecent(int id) {
    throw UnimplementedError();
  }

  @override
  Future<void> unsave(int id) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearRecent() {
    throw UnimplementedError();
  }

  @override
  Stream<List<SearchQuery>> watchRecent({int limit = 10}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<SearchQuery>> watchSaved() {
    throw UnimplementedError();
  }
}

Bookmark _bookmark(int id, String title) {
  final DateTime now = DateTime.now();
  return Bookmark(
    id: id,
    originalUrl: 'https://example.com/$id',
    title: title,
    createdAt: now,
    updatedAt: now,
  );
}

/// Minimal fake that only implements [search].
class _FakeBookmarkRepository implements BookmarkRepository {
  List<Bookmark> mockResults = <Bookmark>[];

  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async {
    return mockResults;
  }

  // ─── Unused stubs ──────────────────────────────────────────────

  @override
  Future<Bookmark> save(Bookmark bookmark) => throw UnimplementedError();

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) =>
      throw UnimplementedError();

  @override
  Future<Bookmark?> getById(int id) => throw UnimplementedError();

  @override
  Future<List<Bookmark>> getByIds(List<int> ids) => throw UnimplementedError();

  @override
  Future<bool> delete(int id) => throw UnimplementedError();

  @override
  Future<int> deleteAll(List<int> ids) => throw UnimplementedError();

  @override
  Future<Bookmark?> findByUrlHash(String urlHash) => throw UnimplementedError();

  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) =>
      throw UnimplementedError();

  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) =>
      throw UnimplementedError();

  @override
  Future<int> countAll() => throw UnimplementedError();

  @override
  Future<int> count(BookmarkFeedQuery query) => throw UnimplementedError();

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) =>
      throw UnimplementedError();

  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      throw UnimplementedError();

  @override
  Stream<Bookmark?> watchById(int id) => throw UnimplementedError();
}

class _FakeTagRepository implements TagRepository {
  @override
  Future<Tag?> findBySlug(String slug) async => null;

  @override
  Future<Tag> save(Tag tag) => throw UnimplementedError();
  @override
  Future<Tag> createFromName(String name, {int? colorArgb, String? icon}) =>
      throw UnimplementedError();
  @override
  Future<Tag?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<Tag>> getAll() => throw UnimplementedError();
  @override
  Future<List<Tag>> getByIds(List<int> ids) => throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<void> incrementUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<void> decrementUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<int> recomputeUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<Map<int, int>> recomputeAllUsageCounts() => throw UnimplementedError();
  @override
  Stream<List<Tag>> watchAll() => throw UnimplementedError();
  @override
  Stream<Tag?> watchById(int id) => throw UnimplementedError();
}
