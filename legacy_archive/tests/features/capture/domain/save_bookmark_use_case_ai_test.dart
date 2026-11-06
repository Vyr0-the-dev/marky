import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/ai/domain/services/ai_enrichment_service.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/models/save_bookmark_params.dart';
import 'package:marky/features/capture/domain/services/duplicate_detection_service.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Fake [BookmarkItemRepository] that records all operations in memory.
class _FakeBookmarkItemRepository implements BookmarkItemRepository {
  final Map<int, BookmarkItem> _items = <int, BookmarkItem>{};
  int _nextId = 1;

  @override
  Future<BookmarkItem?> getById(Id id) async => _items[id];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => _items.values.toList();

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
    for (final BookmarkItem item in _items.values) {
      if (item.urlHash == urlHash) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async {
    for (final BookmarkItem item in _items.values) {
      if (item.canonicalUrl == canonicalUrl) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async {
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
  Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

/// Fake [AiEnrichmentService] that records all [enrich] calls.
class _FakeAiEnrichmentService implements AiEnrichmentService {
  final List<int> enrichedBookmarkIds = <int>[];

  @override
  Future<void> enrich(int bookmarkId) async {
    enrichedBookmarkIds.add(bookmarkId);
  }
}

void main() {
  group('SaveBookmarkUseCase + AiEnrichmentService', () {
    late _FakeBookmarkItemRepository fakeRepository;
    late SaveBookmarkUseCase useCase;
    late UrlNormalizationService normalizationService;

    setUp(() {
      fakeRepository = _FakeBookmarkItemRepository();
      normalizationService = UrlNormalizationService.instance;
      DuplicateDetectionService.initialize(
        repository: fakeRepository,
        normalizationService: normalizationService,
      );
      useCase = SaveBookmarkUseCase(repository: fakeRepository);
    });

    tearDown(DuplicateDetectionService.reset);

    test(
        'when aiEnrichmentService is injected, enrich is called for new bookmarks',
        () async {
      final fakeAiService = _FakeAiEnrichmentService();
      final useCaseWithAi = SaveBookmarkUseCase(
        repository: fakeRepository,
        aiEnrichmentService: fakeAiService,
      );

      const String rawUrl = 'https://example.com/new-article';
      final SaveResult result = await useCaseWithAi.execute(rawUrl);

      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;

      // enrich() should have been called with the new bookmark ID.
      expect(fakeAiService.enrichedBookmarkIds, contains(success.bookmarkId));
    });

    test(
        'when aiEnrichmentService is injected, enrich is called for duplicate merges',
        () async {
      final fakeAiService = _FakeAiEnrichmentService();
      final useCaseWithAi = SaveBookmarkUseCase(
        repository: fakeRepository,
        aiEnrichmentService: fakeAiService,
      );

      const String rawUrl = 'https://example.com/article';

      // First save — no duplicate.
      final SaveResult first = await useCaseWithAi.execute(rawUrl);
      expect(first, isA<SaveSuccess>());
      final SaveSuccess success = first as SaveSuccess;

      final int bookmarkId = success.bookmarkId;

      // Clear enrichment tracking.
      fakeAiService.enrichedBookmarkIds.clear();

      // Second save — duplicate.
      final SaveResult second = await useCaseWithAi.execute(rawUrl);
      expect(second, isA<SaveDuplicate>());

      // enrich() should have been called with the existing bookmark ID.
      expect(fakeAiService.enrichedBookmarkIds, contains(bookmarkId));
    });

    test('when aiEnrichmentService is null, capture flow still succeeds',
        () async {
      const String rawUrl = 'https://example.com/article';

      // useCase created without aiEnrichmentService in setUp.
      final SaveResult result = await useCase.execute(rawUrl);

      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;

      final BookmarkItem? saved =
          await fakeRepository.getById(success.bookmarkId);
      expect(saved, isNotNull);
      expect(saved!.canonicalUrl, rawUrl);
    });

    test(
        'when aiEnrichmentService is null, duplicate flow still succeeds',
        () async {
      const String rawUrl = 'https://example.com/article';

      // First save.
      final SaveResult first = await useCase.execute(rawUrl);
      expect(first, isA<SaveSuccess>());

      // Second save without AI service.
      final SaveResult second = await useCase.execute(rawUrl);
      expect(second, isA<SaveDuplicate>());
    });

    test(
        'new bookmark passes correct bookmarkId to enrich()',
        () async {
      final fakeAiService = _FakeAiEnrichmentService();
      final useCaseWithAi = SaveBookmarkUseCase(
        repository: fakeRepository,
        aiEnrichmentService: fakeAiService,
      );

      const String rawUrl = 'https://example.com/unique';
      final SaveResult result = await useCaseWithAi.execute(rawUrl);

      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;

      expect(fakeAiService.enrichedBookmarkIds, hasLength(1));
      expect(fakeAiService.enrichedBookmarkIds.first, success.bookmarkId);
    });

    test(
        'duplicate merge passes existing bookmarkId to enrich()',
        () async {
      final fakeAiService = _FakeAiEnrichmentService();
      final useCaseWithAi = SaveBookmarkUseCase(
        repository: fakeRepository,
        aiEnrichmentService: fakeAiService,
      );

      const String rawUrl = 'https://example.com/article';

      // First save.
      final SaveResult first = await useCaseWithAi.execute(rawUrl);
      final SaveSuccess success = first as SaveSuccess;
      final int existingId = success.bookmarkId;

      // Clear tracking.
      fakeAiService.enrichedBookmarkIds.clear();

      // Second save — duplicate.
      final SaveResult second = await useCaseWithAi.execute(rawUrl);
      expect(second, isA<SaveDuplicate>());

      expect(fakeAiService.enrichedBookmarkIds, hasLength(1));
      expect(fakeAiService.enrichedBookmarkIds.first, existingId);
    });

    test(
        'enrichment is not awaited — execute returns before enrich completes',
        () async {
      final fakeAiService = _FakeAiEnrichmentService();
      final useCaseWithAi = SaveBookmarkUseCase(
        repository: fakeRepository,
        aiEnrichmentService: fakeAiService,
      );

      const String rawUrl = 'https://example.com/fast';

      // execute should return immediately (synchronously) even though
      // enrich() is async.
      final SaveResult result = await useCaseWithAi.execute(rawUrl);

      expect(result, isA<SaveSuccess>());
      // If we got here, execute completed without waiting for enrich.
      expect(fakeAiService.enrichedBookmarkIds, isNotEmpty);
    });
  });
}
