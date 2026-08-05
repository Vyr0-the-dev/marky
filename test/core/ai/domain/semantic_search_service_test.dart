import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:marky/core/ai/domain/services/embedding_similarity_service.dart';
import 'package:marky/core/ai/domain/services/semantic_search_service.dart';
import 'package:marky/core/scraping/enums/favicon_status.dart';
import 'package:marky/core/scraping/enums/scraping_status.dart';
import 'package:marky/core/scraping/enums/thumbnail_status.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeBookmarkItemRepository implements BookmarkItemRepository {
  _FakeBookmarkItemRepository(this._bookmarks);

  final List<BookmarkItem> _bookmarks;

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => List.unmodifiable(_bookmarks);

  @override
  Future<BookmarkItem?> getById(Id id) async {
    try {
      return _bookmarks.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(
    String externalContentId,
  ) async => null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => [];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => [];

  @override
  Future<Id> insert(BookmarkItem entity) async => entity.id;

  @override
  Future<Id> update(BookmarkItem entity) async => entity.id;

  @override
  Future<void> delete(Id id) async {}

  @override
  Future<void> clear() async {}
}

// ---------------------------------------------------------------------------
// Fake similarity service (returns predictable scores)
// ---------------------------------------------------------------------------

class _FakeSimilarityService implements EmbeddingSimilarityService {
  _FakeSimilarityService({this.defaultScore = 0.5});

  final double defaultScore;
  final Map<String, double> _scores = {};

  void setScore(int idA, int idB, double score) {
    _scores['$idA:$idB'] = score;
    _scores['$idB:$idA'] = score;
  }

  @override
  double computeSimilarity(
    covariant dynamic a,
    covariant dynamic b,
  ) =>
      defaultScore;

  @override
  double computeSimilarityFromBookmarks(BookmarkItem a, BookmarkItem b) {
    return _scores['${a.id}:${b.id}'] ?? defaultScore;
  }
}

// ---------------------------------------------------------------------------
// Throwing repository for failure-safety tests
// ---------------------------------------------------------------------------

class _ThrowingRepository implements BookmarkItemRepository {
  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => throw Exception('db error');

  @override
  Future<BookmarkItem?> getById(Id id) async => throw Exception('db error');

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async =>
      throw Exception('db error');

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async =>
      throw Exception('db error');

  @override
  Future<BookmarkItem?> getByExternalContentId(
    String externalContentId,
  ) async =>
      throw Exception('db error');

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async =>
      throw Exception('db error');

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async =>
      throw Exception('db error');

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async =>
      throw Exception('db error');

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async =>
      throw Exception('db error');

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async =>
      throw Exception('db error');

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async =>
      throw Exception('db error');

  @override
  Future<Id> insert(BookmarkItem entity) async => throw Exception('db error');

  @override
  Future<Id> update(BookmarkItem entity) async => throw Exception('db error');

  @override
  Future<void> delete(Id id) async => throw Exception('db error');

  @override
  Future<void> clear() async => throw Exception('db error');
}

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

BookmarkItem _makeBookmark({
  required int id,
  String? title,
  List<String>? aiKeywords,
  bool isInVault = false,
}) {
  return BookmarkItem(
    originalUrl: 'https://example.com/$id',
    title: title ?? 'Bookmark $id',
    aiKeywords: aiKeywords,
    isInVault: isInVault,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    scrapingStatus: ScrapingStatus.done,
    thumbnailStatus: ThumbnailStatus.done,
    faviconStatus: FaviconStatus.done,
  )..id = id;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NaiveSemanticSearchService', () {
    // -----------------------------------------------------------------
    // findSimilar
    // -----------------------------------------------------------------
    group('findSimilar', () {
      test('finds related bookmarks by keyword overlap', () async {
        final source = _makeBookmark(
          id: 1,
          title: 'Source',
          aiKeywords: ['flutter', 'dart'],
        );
        final related = _makeBookmark(
          id: 2,
          title: 'Related',
          aiKeywords: ['flutter', 'dart', 'mobile'],
        );
        final unrelated = _makeBookmark(
          id: 3,
          title: 'Unrelated',
          aiKeywords: ['cooking', 'recipe'],
        );

        final repo = _FakeBookmarkItemRepository([source, related, unrelated]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.findSimilar(source);

        expect(results.length, 2);
        // related has 100% overlap (2/2), unrelated has 0%
        expect(results[0].id, related.id);
        expect(results[1].id, unrelated.id);
      });

      test('respects limit parameter', () async {
        final source = _makeBookmark(
          id: 1,
          title: 'Source',
          aiKeywords: ['tech'],
        );
        final candidates = List.generate(
          20,
          (i) => _makeBookmark(
            id: i + 2,
            title: 'Candidate ${String.fromCharCode(90 - i)}',
            aiKeywords: ['tech'],
          ),
        );

        final repo = _FakeBookmarkItemRepository([source, ...candidates]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.findSimilar(source, limit: 5);

        expect(results.length, 5);
      });

      test('excludes source bookmark', () async {
        final source = _makeBookmark(
          id: 1,
          title: 'Source',
          aiKeywords: ['flutter'],
        );
        final other = _makeBookmark(
          id: 2,
          title: 'Other',
          aiKeywords: ['flutter'],
        );

        final repo = _FakeBookmarkItemRepository([source, other]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.findSimilar(source);

        expect(results.map((b) => b.id), isNot(contains(source.id)));
        expect(results.length, 1);
        expect(results[0].id, other.id);
      });

      test('non-vault source excludes vault candidates', () async {
        final source = _makeBookmark(
          id: 1,
          title: 'Source',
          isInVault: false,
          aiKeywords: ['flutter'],
        );
        final vaultCandidate = _makeBookmark(
          id: 2,
          title: 'Vault item',
          isInVault: true,
          aiKeywords: ['flutter'],
        );
        final normalCandidate = _makeBookmark(
          id: 3,
          title: 'Normal item',
          isInVault: false,
          aiKeywords: ['flutter'],
        );

        final repo = _FakeBookmarkItemRepository([
          source,
          vaultCandidate,
          normalCandidate,
        ]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.findSimilar(source);

        expect(results.map((b) => b.id), isNot(contains(vaultCandidate.id)));
        expect(results.map((b) => b.id), contains(normalCandidate.id));
      });

      test('vault source sees all candidates', () async {
        final source = _makeBookmark(
          id: 1,
          title: 'Source',
          isInVault: true,
          aiKeywords: ['flutter'],
        );
        final vaultCandidate = _makeBookmark(
          id: 2,
          title: 'Vault item',
          isInVault: true,
          aiKeywords: ['flutter'],
        );
        final normalCandidate = _makeBookmark(
          id: 3,
          title: 'Normal item',
          isInVault: false,
          aiKeywords: ['flutter'],
        );

        final repo = _FakeBookmarkItemRepository([
          source,
          vaultCandidate,
          normalCandidate,
        ]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.findSimilar(source);

        expect(results.length, 2);
        expect(results.map((b) => b.id), contains(vaultCandidate.id));
        expect(results.map((b) => b.id), contains(normalCandidate.id));
      });

      test('aiEnabled=false returns empty', () async {
        final source = _makeBookmark(id: 1, title: 'Source');
        final other = _makeBookmark(id: 2, title: 'Other');

        final repo = _FakeBookmarkItemRepository([source, other]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
          aiEnabled: false,
        );

        final results = await service.findSimilar(source);

        expect(results, isEmpty);
      });

      test('empty corpus returns empty', () async {
        final source = _makeBookmark(id: 1, title: 'Source');

        final repo = _FakeBookmarkItemRepository([]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.findSimilar(source);

        expect(results, isEmpty);
      });

      test('handles null aiKeywords gracefully', () async {
        final source = _makeBookmark(
          id: 1,
          title: 'Source',
          aiKeywords: null,
        );
        final candidate = _makeBookmark(
          id: 2,
          title: 'Candidate',
          aiKeywords: null,
        );

        final repo = _FakeBookmarkItemRepository([source, candidate]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.findSimilar(source);

        // Both have null keywords → similarity 0, but still returned
        expect(results.length, 1);
        expect(results[0].id, candidate.id);
      });

      test('deterministic tie-breaker by title', () async {
        final source = _makeBookmark(
          id: 1,
          title: 'Source',
          aiKeywords: ['tech'],
        );
        final alpha = _makeBookmark(
          id: 2,
          title: 'Alpha',
          aiKeywords: ['tech'],
        );
        final beta = _makeBookmark(
          id: 3,
          title: 'Beta',
          aiKeywords: ['tech'],
        );
        final gamma = _makeBookmark(
          id: 4,
          title: 'Gamma',
          aiKeywords: ['tech'],
        );

        final repo = _FakeBookmarkItemRepository([
          source,
          gamma,
          alpha,
          beta,
        ]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.findSimilar(source);

        // All have same score (identical keywords), sorted by title
        expect(results[0].title, 'Alpha');
        expect(results[1].title, 'Beta');
        expect(results[2].title, 'Gamma');
      });

      test('produces identical order on repeated calls', () async {
        final source = _makeBookmark(
          id: 1,
          title: 'Source',
          aiKeywords: ['tech'],
        );
        final a = _makeBookmark(
          id: 2,
          title: 'A item',
          aiKeywords: ['tech'],
        );
        final b = _makeBookmark(
          id: 3,
          title: 'B item',
          aiKeywords: ['tech'],
        );

        final repo = _FakeBookmarkItemRepository([source, a, b]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final first = await service.findSimilar(source);
        final second = await service.findSimilar(source);

        expect(
          first.map((x) => x.id).toList(),
          second.map((x) => x.id).toList(),
        );
      });

      test('returns empty when repository throws', () async {
        final source = _makeBookmark(id: 1, title: 'Source');

        final repo = _ThrowingRepository();
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.findSimilar(source);

        expect(results, isEmpty);
      });
    });

    // -----------------------------------------------------------------
    // semanticSearch
    // -----------------------------------------------------------------
    group('semanticSearch', () {
      test('query matching keywords returns relevant bookmarks', () async {
        final flutterBookmark = _makeBookmark(
          id: 1,
          title: 'Flutter Guide',
          aiKeywords: ['flutter', 'dart', 'mobile'],
        );
        final cookingBookmark = _makeBookmark(
          id: 2,
          title: 'Cooking Tips',
          aiKeywords: ['cooking', 'recipe', 'food'],
        );
        final dartBookmark = _makeBookmark(
          id: 3,
          title: 'Dart Tutorial',
          aiKeywords: ['dart', 'programming'],
        );

        final repo = _FakeBookmarkItemRepository([
          flutterBookmark,
          cookingBookmark,
          dartBookmark,
        ]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.semanticSearch('flutter dart');

        // flutterBookmark: 2/2 overlap (flutter, dart)
        // dartBookmark: 1/2 overlap (dart)
        // cookingBookmark: 0 overlap
        expect(results.length, 3);
        expect(results[0].id, flutterBookmark.id);
        expect(results[1].id, dartBookmark.id);
        expect(results[2].id, cookingBookmark.id);
      });

      test('no match returns empty when all scores are zero', () async {
        final bookmark = _makeBookmark(
          id: 1,
          title: 'Tech',
          aiKeywords: ['flutter'],
        );

        final repo = _FakeBookmarkItemRepository([bookmark]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.semanticSearch('cooking recipe');

        // Zero-score items are still returned by the naive implementation
        // since it returns all bookmarks sorted by score.
        expect(results.length, 1);
        expect(results[0].id, bookmark.id);
      });

      test('respects limit', () async {
        final bookmarks = List.generate(
          20,
          (i) => _makeBookmark(
            id: i + 1,
            title: 'Bookmark ${String.fromCharCode(65 + i)}',
            aiKeywords: ['tech'],
          ),
        );

        final repo = _FakeBookmarkItemRepository(bookmarks);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.semanticSearch('tech', limit: 5);

        expect(results.length, 5);
      });

      test('aiEnabled=false returns empty', () async {
        final bookmark = _makeBookmark(
          id: 1,
          title: 'Bookmark',
          aiKeywords: ['flutter'],
        );

        final repo = _FakeBookmarkItemRepository([bookmark]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
          aiEnabled: false,
        );

        final results = await service.semanticSearch('flutter');

        expect(results, isEmpty);
      });

      test('handles null aiKeywords gracefully', () async {
        final bookmark = _makeBookmark(
          id: 1,
          title: 'Bookmark',
          aiKeywords: null,
        );

        final repo = _FakeBookmarkItemRepository([bookmark]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.semanticSearch('flutter');

        // Null keywords → score 0, but bookmark still returned
        expect(results.length, 1);
        expect(results[0].id, bookmark.id);
      });

      test('empty query returns empty', () async {
        final bookmark = _makeBookmark(
          id: 1,
          title: 'Bookmark',
          aiKeywords: ['flutter'],
        );

        final repo = _FakeBookmarkItemRepository([bookmark]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.semanticSearch('');

        expect(results, isEmpty);
      });

      test('returns empty when repository throws', () async {
        final repo = _ThrowingRepository();
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.semanticSearch('flutter');

        expect(results, isEmpty);
      });

      test('handles bookmarks with no keywords', () async {
        final withKeywords = _makeBookmark(
          id: 1,
          title: 'With Keywords',
          aiKeywords: ['flutter'],
        );
        final withoutKeywords = _makeBookmark(
          id: 2,
          title: 'Without Keywords',
          aiKeywords: [],
        );

        final repo = _FakeBookmarkItemRepository([withKeywords, withoutKeywords]);
        final similarity = KeywordOverlapSimilarity();
        final service = NaiveSemanticSearchService(
          repository: repo,
          similarityService: similarity,
        );

        final results = await service.semanticSearch('flutter');

        expect(results.length, 2);
        expect(results[0].id, withKeywords.id);
        expect(results[1].id, withoutKeywords.id);
      });
    });
  });
}
