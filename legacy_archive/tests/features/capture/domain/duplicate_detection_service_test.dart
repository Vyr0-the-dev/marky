import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/models/duplicate_check_result.dart';
import 'package:marky/features/capture/domain/services/duplicate_detection_service.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// In-memory fake implementation of [BookmarkItemRepository] for testing.
class _FakeBookmarkItemRepository implements BookmarkItemRepository {
  final Map<int, BookmarkItem> _items = <int, BookmarkItem>{};
  int _nextId = 1;

  // Call counters for early-exit verification.
  int getByUrlHashCalls = 0;
  int getByExternalContentIdCalls = 0;
  int getByCanonicalUrlCalls = 0;
  int getAllCalls = 0;

  void resetCounters() {
    getByUrlHashCalls = 0;
    getByExternalContentIdCalls = 0;
    getByCanonicalUrlCalls = 0;
    getAllCalls = 0;
  }

  @override
  Future<BookmarkItem?> getById(Id id) async => _items[id];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async {
    getAllCalls++;
    return _items.values.toList();
  }

  @override
  Future<Id> insert(BookmarkItem entity) async {
    final int id = _nextId++;
    entity.id = id;
    _items[id] = entity;
    return id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    _items[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _items.remove(id);
  }

  @override
  Future<void> clear() async {
    _items.clear();
    _nextId = 1;
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async {
    getByUrlHashCalls++;
    for (final BookmarkItem item in _items.values) {
      if (item.urlHash == urlHash) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async {
    getByCanonicalUrlCalls++;
    for (final BookmarkItem item in _items.values) {
      if (item.canonicalUrl == canonicalUrl) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async {
    getByExternalContentIdCalls++;
    for (final BookmarkItem item in _items.values) {
      if (item.externalContentId == externalContentId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async {
    return _items.values
        .where((BookmarkItem item) => item.duplicateGroupId == groupId)
        .toList();
  }

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

void main() {
  group('DuplicateCheckResult model', () {
    test('NoDuplicate instantiates', () {
      const DuplicateCheckResult result = NoDuplicate();
      expect(result, isA<NoDuplicate>());
    });

    test('DuplicateFound instantiates with urlHash match type', () {
      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final DuplicateCheckResult result = DuplicateFound(
        matchType: DuplicateMatchType.urlHash,
        existing: existing,
      );
      expect(result, isA<DuplicateFound>());
      final DuplicateFound found = result as DuplicateFound;
      expect(found.matchType, DuplicateMatchType.urlHash);
      expect(found.existing, same(existing));
      expect(found.duplicateGroupId, isNull);
    });

    test('DuplicateFound supports all match types', () {
      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      for (final DuplicateMatchType type in DuplicateMatchType.values) {
        final DuplicateFound found = DuplicateFound(
          matchType: type,
          existing: existing,
        );
        expect(found.matchType, type);
      }
    });

    test('DuplicateFound carries duplicateGroupId', () {
      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      const String groupId = 'group-abc';
      final DuplicateFound found = DuplicateFound(
        matchType: DuplicateMatchType.urlHash,
        existing: existing,
        duplicateGroupId: groupId,
      );
      expect(found.duplicateGroupId, groupId);
    });
  });

  group('Fake repository new methods', () {
    late _FakeBookmarkItemRepository fakeRepo;

    setUp(() {
      fakeRepo = _FakeBookmarkItemRepository();
    });

    test('getByCanonicalUrl returns matching bookmark', () async {
      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        canonicalUrl: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(bookmark);

      final BookmarkItem? result =
          await fakeRepo.getByCanonicalUrl('https://example.com');
      expect(result, isNotNull);
      expect(result!.canonicalUrl, 'https://example.com');
    });

    test('getByCanonicalUrl returns null when no match', () async {
      final BookmarkItem? result =
          await fakeRepo.getByCanonicalUrl('https://missing.com');
      expect(result, isNull);
    });

    test('getByExternalContentId returns matching bookmark', () async {
      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://youtube.com/watch?v=abc123',
        externalContentId: 'abc123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(bookmark);

      final BookmarkItem? result =
          await fakeRepo.getByExternalContentId('abc123');
      expect(result, isNotNull);
      expect(result!.externalContentId, 'abc123');
    });

    test('getByExternalContentId returns null when no match', () async {
      final BookmarkItem? result =
          await fakeRepo.getByExternalContentId('missing');
      expect(result, isNull);
    });

    test('getByDuplicateGroupId returns matching bookmarks', () async {
      final BookmarkItem b1 = BookmarkItem(
        originalUrl: 'https://a.com',
        duplicateGroupId: 'group-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final BookmarkItem b2 = BookmarkItem(
        originalUrl: 'https://b.com',
        duplicateGroupId: 'group-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final BookmarkItem b3 = BookmarkItem(
        originalUrl: 'https://c.com',
        duplicateGroupId: 'group-2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeRepo.insert(b1);
      await fakeRepo.insert(b2);
      await fakeRepo.insert(b3);

      final List<BookmarkItem> results =
          await fakeRepo.getByDuplicateGroupId('group-1');
      expect(results.length, 2);
      expect(
        results.map((BookmarkItem b) => b.originalUrl).toSet(),
        <String>{'https://a.com', 'https://b.com'},
      );
    });

    test('getByDuplicateGroupId returns empty list when no match', () async {
      final List<BookmarkItem> results =
          await fakeRepo.getByDuplicateGroupId('missing');
      expect(results, isEmpty);
    });
  });

  group('DuplicateDetectionService', () {
    late _FakeBookmarkItemRepository fakeRepo;
    late DuplicateDetectionService service;

    setUp(() {
      fakeRepo = _FakeBookmarkItemRepository();
      service = DuplicateDetectionService(
        repository: fakeRepo,
        normalizationService: UrlNormalizationService.instance,
      );
    });

    tearDown(DuplicateDetectionService.reset);

    test('service instantiates with constructor injection', () {
      expect(service, isA<DuplicateDetectionService>());
    });

    test('checkDuplicate returns NoDuplicate for empty repository', () async {
      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: 'https://example.com/article',
      );
      expect(result, isA<NoDuplicate>());
    });

    // ── Level 1: urlHash exact match ───────────────────────────────────

    test('checkDuplicate finds duplicate by urlHash', () async {
      const String canonicalUrl = 'https://example.com/article';
      final String urlHash =
          UrlNormalizationService.instance.computeUrlHash(canonicalUrl);

      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com/article?utm_source=email',
        canonicalUrl: canonicalUrl,
        urlHash: urlHash,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: canonicalUrl,
      );
      expect(result, isA<DuplicateFound>());
      final DuplicateFound found = result as DuplicateFound;
      expect(found.matchType, DuplicateMatchType.urlHash);
      expect(found.existing.id, existing.id);
    });

    test('urlHash match returns generated groupId when existing has none',
        () async {
      const String canonicalUrl = 'https://example.com/article';
      final String urlHash =
          UrlNormalizationService.instance.computeUrlHash(canonicalUrl);

      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com/article',
        canonicalUrl: canonicalUrl,
        urlHash: urlHash,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: canonicalUrl,
      );
      final DuplicateFound found = result as DuplicateFound;
      expect(found.duplicateGroupId, isNotNull);
      expect(
        found.duplicateGroupId,
        UrlNormalizationService.instance.computeUrlHash(canonicalUrl),
      );
    });

    test('urlHash match reuses existing groupId when present', () async {
      const String canonicalUrl = 'https://example.com/article';
      final String urlHash =
          UrlNormalizationService.instance.computeUrlHash(canonicalUrl);
      const String existingGroupId = 'pre-existing-group';

      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com/article',
        canonicalUrl: canonicalUrl,
        urlHash: urlHash,
        duplicateGroupId: existingGroupId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: canonicalUrl,
      );
      final DuplicateFound found = result as DuplicateFound;
      expect(found.duplicateGroupId, existingGroupId);
    });

    // ── Level 2: externalContentId match ───────────────────────────────

    test('checkDuplicate finds duplicate by externalContentId', () async {
      const String contentId = 'yt-video-123';
      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://youtube.com/watch?v=yt-video-123',
        canonicalUrl: 'https://youtube.com/watch?v=yt-video-123',
        urlHash: 'some-hash',
        externalContentId: contentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: 'https://youtu.be/yt-video-123',
        externalContentId: contentId,
      );
      expect(result, isA<DuplicateFound>());
      final DuplicateFound found = result as DuplicateFound;
      expect(found.matchType, DuplicateMatchType.externalContentId);
    });

    test('externalContentId match skips query when id is null', () async {
      fakeRepo.resetCounters();

      await service.checkDuplicate(
        canonicalUrl: 'https://example.com/article',
      );

      expect(fakeRepo.getByExternalContentIdCalls, 0);
    });

    test('externalContentId match skips query when id is empty', () async {
      fakeRepo.resetCounters();

      await service.checkDuplicate(
        canonicalUrl: 'https://example.com/article',
        externalContentId: '',
      );

      expect(fakeRepo.getByExternalContentIdCalls, 0);
    });

    // ── Level 3: canonicalUrl exact match ──────────────────────────────

    test('checkDuplicate finds duplicate by canonicalUrl', () async {
      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com/article',
        canonicalUrl: 'https://example.com/article',
        urlHash: 'different-hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: 'https://example.com/article',
      );
      expect(result, isA<DuplicateFound>());
      final DuplicateFound found = result as DuplicateFound;
      expect(found.matchType, DuplicateMatchType.canonicalUrl);
    });

    test('canonicalUrl match generates groupId from existing canonicalUrl',
        () async {
      const String canonicalUrl = 'https://example.com/article';
      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com/article',
        canonicalUrl: canonicalUrl,
        urlHash: 'different-hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: canonicalUrl,
      );
      final DuplicateFound found = result as DuplicateFound;
      expect(found.duplicateGroupId,
          UrlNormalizationService.instance.computeUrlHash(canonicalUrl));
    });

    test(
        'canonicalUrl match generates groupId from candidate when existing '
        'lacks canonicalUrl', () async {
      const String candidateCanonical = 'https://example.com/article';
      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com/article',
        urlHash: 'different-hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: candidateCanonical,
      );
      final DuplicateFound found = result as DuplicateFound;
      expect(found.duplicateGroupId,
          UrlNormalizationService.instance.computeUrlHash(candidateCanonical));
    });

    // ── Level 4: normalized URL comparison ─────────────────────────────

    test('checkDuplicate finds duplicate by normalizedUrl fallback', () async {
      const String existingOriginal =
          'https://example.com/article?utm_source=email';
      const String existingCanonical = 'https://example.com/article';

      final BookmarkItem existing = BookmarkItem(
        originalUrl: existingOriginal,
        urlHash: 'totally-different-hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      // Candidate has the same canonical URL but different hash
      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: existingCanonical,
      );
      expect(result, isA<DuplicateFound>());
      final DuplicateFound found = result as DuplicateFound;
      expect(found.matchType, DuplicateMatchType.normalizedUrl);
      expect(found.existing.id, existing.id);
    });

    test(
        'normalizedUrl match compares resolvedUrl and originalUrl of existing',
        () async {
      const String existingResolved = 'https://example.com/page';

      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://old.com/redirect',
        resolvedUrl: existingResolved,
        urlHash: 'hash-a',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      // Candidate's canonical normalizes to the same as existing resolvedUrl
      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: existingResolved,
      );
      expect(result, isA<DuplicateFound>());
      final DuplicateFound found = result as DuplicateFound;
      expect(found.matchType, DuplicateMatchType.normalizedUrl);
    });

    test('normalizedUrl match uses candidate resolvedUrl over canonicalUrl',
        () async {
      const String existingCanonical = 'https://example.com/final';

      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com/other',
        canonicalUrl: existingCanonical,
        urlHash: 'hash-a',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      // Candidate's resolvedUrl matches existing canonical, but canonicalUrl
      // is different — still detects via resolvedUrl normalization
      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: 'https://example.com/different-canonical',
        resolvedUrl: existingCanonical,
      );
      expect(result, isA<DuplicateFound>());
      final DuplicateFound found = result as DuplicateFound;
      expect(found.matchType, DuplicateMatchType.normalizedUrl);
    });

    // ── Early-exit verification ────────────────────────────────────────

    test('urlHash hit skips all lower levels', () async {
      const String canonicalUrl = 'https://example.com/article';
      final String urlHash =
          UrlNormalizationService.instance.computeUrlHash(canonicalUrl);

      final BookmarkItem existing = BookmarkItem(
        originalUrl: canonicalUrl,
        canonicalUrl: canonicalUrl,
        urlHash: urlHash,
        externalContentId: 'content-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      fakeRepo.resetCounters();

      await service.checkDuplicate(
        canonicalUrl: canonicalUrl,
        externalContentId: 'content-123',
      );

      expect(fakeRepo.getByUrlHashCalls, 1);
      expect(fakeRepo.getByExternalContentIdCalls, 0);
      expect(fakeRepo.getByCanonicalUrlCalls, 0);
      expect(fakeRepo.getAllCalls, 0);
    });

    test('externalContentId hit skips canonicalUrl and normalizedUrl',
        () async {
      const String canonicalUrl = 'https://example.com/article';
      const String contentId = 'content-456';

      final BookmarkItem existing = BookmarkItem(
        originalUrl: canonicalUrl,
        canonicalUrl: canonicalUrl,
        urlHash: 'different-hash',
        externalContentId: contentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      fakeRepo.resetCounters();

      await service.checkDuplicate(
        canonicalUrl: canonicalUrl,
        externalContentId: contentId,
      );

      expect(fakeRepo.getByUrlHashCalls, 1);
      expect(fakeRepo.getByExternalContentIdCalls, 1);
      expect(fakeRepo.getByCanonicalUrlCalls, 0);
      expect(fakeRepo.getAllCalls, 0);
    });

    test('canonicalUrl hit skips normalizedUrl fallback', () async {
      const String canonicalUrl = 'https://example.com/article';

      final BookmarkItem existing = BookmarkItem(
        originalUrl: canonicalUrl,
        canonicalUrl: canonicalUrl,
        urlHash: 'different-hash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      fakeRepo.resetCounters();

      await service.checkDuplicate(
        canonicalUrl: canonicalUrl,
      );

      expect(fakeRepo.getByUrlHashCalls, 1);
      expect(fakeRepo.getByExternalContentIdCalls, 0);
      expect(fakeRepo.getByCanonicalUrlCalls, 1);
      expect(fakeRepo.getAllCalls, 0);
    });

    // ── No duplicate ───────────────────────────────────────────────────

    test('no duplicate returns NoDuplicate', () async {
      final BookmarkItem unrelated = BookmarkItem(
        originalUrl: 'https://other.com/page',
        canonicalUrl: 'https://other.com/page',
        urlHash: UrlNormalizationService.instance
            .computeUrlHash('https://other.com/page'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(unrelated);

      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: 'https://example.com/new',
      );
      expect(result, isA<NoDuplicate>());
    });

    // ── Singleton ──────────────────────────────────────────────────────

    test('singleton initialize and instance accessors work', () {
      DuplicateDetectionService.initialize(
        repository: fakeRepo,
        normalizationService: UrlNormalizationService.instance,
      );
      expect(
          DuplicateDetectionService.instance, isA<DuplicateDetectionService>());
    });

    test('singleton throws when accessed before initialize', () {
      DuplicateDetectionService.reset();
      expect(
        () => DuplicateDetectionService.instance,
        throwsA(isA<StateError>()),
      );
    });

    // ── Graceful null handling ─────────────────────────────────────────

    test('null canonicalUrl in existing falls back to candidate for groupId',
        () async {
      const String candidateCanonical = 'https://example.com/article';
      final BookmarkItem existing = BookmarkItem(
        originalUrl: 'https://example.com/article',
        urlHash: 'hash-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepo.insert(existing);

      final DuplicateCheckResult result = await service.checkDuplicate(
        canonicalUrl: candidateCanonical,
      );
      final DuplicateFound found = result as DuplicateFound;
      expect(found.duplicateGroupId,
          UrlNormalizationService.instance.computeUrlHash(candidateCanonical));
    });

    test('empty externalContentId is treated as null', () async {
      fakeRepo.resetCounters();

      await service.checkDuplicate(
        canonicalUrl: 'https://example.com/article',
        externalContentId: '',
      );

      expect(fakeRepo.getByExternalContentIdCalls, 0);
    });
  });
}
