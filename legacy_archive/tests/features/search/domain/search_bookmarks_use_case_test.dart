import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/ai/domain/services/semantic_search_service.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/search/domain/use_cases/search_bookmarks_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';

class _FakeBookmarkRepository implements BookmarkItemRepository {
  List<BookmarkItem> searchResults = <BookmarkItem>[];
  int? lastSearchLimit;
  int? lastSearchOffset;

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async {
    lastSearchOffset = offset;
    lastSearchLimit = limit;
    return searchResults;
  }

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<BookmarkItem?> getById(Id id) async => null;

  @override
  Future<Id> insert(BookmarkItem item) async => 0;

  @override
  Future<Id> update(BookmarkItem item) async => 0;

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

class _FakeSemanticSearchService implements SemanticSearchService {
  List<BookmarkItem> semanticResults = <BookmarkItem>[];
  String? lastQuery;

  @override
  Future<List<BookmarkItem>> findSimilar(BookmarkItem source, {int limit = 10}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> semanticSearch(String query, {int limit = 10}) async {
    lastQuery = query;
    return semanticResults;
  }
}

BookmarkItem _makeBookmark({required int id, required String url, String? title}) {
  final item = BookmarkItem(
    originalUrl: url,
    title: title,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  item.id = id;
  return item;
}

void main() {
  group('SearchBookmarksUseCase', () {
    late _FakeBookmarkRepository repository;
    late SearchBookmarksUseCase useCase;

    setUp(() {
      repository = _FakeBookmarkRepository();
      useCase = SearchBookmarksUseCase(repository: repository);
    });

    group('execute', () {
      test('empty query returns empty list', () async {
        final result = await useCase.execute(const SearchQuery());
        expect(result, isEmpty);
      });

      test('delegates to repository.search for non-empty query', () async {
        final bookmark = _makeBookmark(
          id: 1,
          url: 'https://example.com',
          title: 'Example',
        );
        repository.searchResults = <BookmarkItem>[bookmark];

        final result = await useCase.execute(
          const SearchQuery(freeText: <String>['test']),
        );

        expect(result, hasLength(1));
        expect(result.first.id, 1);
        expect(repository.lastSearchLimit, 100);
      });

      test('passes custom limit when provided', () async {
        repository.searchResults = <BookmarkItem>[];

        await useCase.execute(
          const SearchQuery(freeText: <String>['test']),
          limit: 50,
        );

        expect(repository.lastSearchLimit, 50);
      });
    });

    group('executeSemantic', () {
      test('returns empty list when semanticSearchService is null', () async {
        final result = await useCase.executeSemantic('flutter');
        expect(result, isEmpty);
      });

      test('delegates to semanticSearchService when provided', () async {
        final semanticService = _FakeSemanticSearchService();
        final bookmark = _makeBookmark(
          id: 2,
          url: 'https://flutter.dev',
          title: 'Flutter',
        );
        semanticService.semanticResults = <BookmarkItem>[bookmark];

        useCase = SearchBookmarksUseCase(
          repository: repository,
          semanticSearchService: semanticService,
        );

        final result = await useCase.executeSemantic('flutter');

        expect(result, hasLength(1));
        expect(result.first.id, 2);
        expect(semanticService.lastQuery, 'flutter');
      });

      test('returns empty when semantic service returns empty', () async {
        final semanticService = _FakeSemanticSearchService();
        useCase = SearchBookmarksUseCase(
          repository: repository,
          semanticSearchService: semanticService,
        );

        final result = await useCase.executeSemantic('unknown');

        expect(result, isEmpty);
        expect(semanticService.lastQuery, 'unknown');
      });
    });
  });
}
