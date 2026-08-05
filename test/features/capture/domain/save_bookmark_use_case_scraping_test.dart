import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/scraping/enums/scraping_status.dart';
import 'package:marky/core/scraping/metadata_scraper_service.dart';
import 'package:marky/core/scraping/models/parsed_metadata.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';
import 'package:marky/core/scraping/services/favicon_cache_service.dart';
import 'package:marky/core/scraping/services/image_cache_service.dart';
import 'package:marky/core/scraping/source_parser_registry.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/services/duplicate_detection_service.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';

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
  Future<void> delete(Id id) async => _items.remove(id);

  @override
  Future<void> clear() async {
    _items.clear();
    _nextId = 1;
  }

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

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

/// Spy service that records calls.
class _SpyMetadataScraperService extends MetadataScraperService {
  _SpyMetadataScraperService({
    required super.registry,
    required super.repository,
  });

  final List<Map<String, dynamic>> calls = <Map<String, dynamic>>[];

  @override
  Future<void> scrapeAndUpdate(int bookmarkId, String url) async {
    calls.add(<String, dynamic>{'bookmarkId': bookmarkId, 'url': url});
  }
}

/// Spy image cache service that records downloadAndCache calls.
class _SpyImageCacheService extends ImageCacheService {
  _SpyImageCacheService({
    required super.repository,
  });

  final List<int> calls = <int>[];

  @override
  Future<void> downloadAndCache(int bookmarkId) async {
    calls.add(bookmarkId);
  }
}

/// Spy favicon cache service that records downloadAndCache calls.
class _SpyFaviconCacheService extends FaviconCacheService {
  _SpyFaviconCacheService({
    required super.repository,
  });

  final List<int> calls = <int>[];

  @override
  Future<void> downloadAndCache(int bookmarkId) async {
    calls.add(bookmarkId);
  }
}

/// Fake parser that returns predetermined metadata.
class _FakeParser extends SourceParser {
  _FakeParser(this._result);

  final ParsedMetadata? _result;

  @override
  Set<String> get hosts => <String>{'example.com'};

  @override
  Future<ParsedMetadata?> parse(String url) async => _result;
}

/// Failing parser that throws.
class _FailingParser extends SourceParser {
  @override
  Set<String> get hosts => <String>{'fail.com'};

  @override
  Future<ParsedMetadata?> parse(String url) async {
    throw Exception('parse failed');
  }
}

void main() {
  group('SaveBookmarkUseCase with MetadataScraperService', () {
    late _FakeBookmarkItemRepository fakeRepository;
    late SaveBookmarkUseCase useCase;

    setUp(() {
      fakeRepository = _FakeBookmarkItemRepository();
      MetadataScraperService.reset();
      ImageCacheService.reset();
      FaviconCacheService.reset();
      SourceParserRegistry.instance.clear();
      DuplicateDetectionService.initialize(
        repository: fakeRepository,
        normalizationService: UrlNormalizationService.instance,
      );
    });

    tearDown(() {
      MetadataScraperService.reset();
      ImageCacheService.reset();
      FaviconCacheService.reset();
      SourceParserRegistry.instance.clear();
      DuplicateDetectionService.reset();
    });

    test('scrapeAndUpdate is called after save', () async {
      const String rawUrl = 'https://example.com/article';

      final _SpyMetadataScraperService spyService = _SpyMetadataScraperService(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      useCase = SaveBookmarkUseCase(
        repository: fakeRepository,
        metadataScraperService: spyService,
      );

      final SaveResult result = await useCase.execute(rawUrl);

      expect(result, isA<SaveSuccess>());
      expect(spyService.calls, hasLength(1));
      expect(spyService.calls.first['bookmarkId'], greaterThan(0));
      expect(spyService.calls.first['url'], 'https://example.com/article');
    });

    test('scraping failure does not prevent SaveSuccess', () async {
      const String rawUrl = 'https://fail.com/article';

      SourceParserRegistry.instance.register(_FailingParser());

      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      useCase = SaveBookmarkUseCase(
        repository: fakeRepository,
        metadataScraperService: MetadataScraperService.instance,
      );

      final SaveResult result = await useCase.execute(rawUrl);

      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;
      expect(success.bookmarkId, greaterThan(0));
    });

    test('bookmark scrapingStatus is updated by service', () async {
      const String rawUrl = 'https://example.com/article';
      const ParsedMetadata metadata = ParsedMetadata(
        title: 'Test Title',
        description: 'Test Description',
      );

      SourceParserRegistry.instance.register(_FakeParser(metadata));

      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      useCase = SaveBookmarkUseCase(
        repository: fakeRepository,
        metadataScraperService: MetadataScraperService.instance,
      );

      final SaveResult result = await useCase.execute(rawUrl);
      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;

      // Wait for the fire-and-forget scraping to complete.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final BookmarkItem? updated =
          await fakeRepository.getById(success.bookmarkId);
      expect(updated, isNotNull);
      expect(updated!.scrapingStatus, ScrapingStatus.done);
      expect(updated.title, 'Test Title');
      expect(updated.description, 'Test Description');
    });

    test('image cache downloadAndCache is triggered after successful scrape',
        () async {
      const String rawUrl = 'https://example.com/article';
      const ParsedMetadata metadata = ParsedMetadata(
        title: 'Test Title',
        thumbnailUrl: 'https://example.com/image.jpg',
      );

      SourceParserRegistry.instance.register(_FakeParser(metadata));

      final _SpyImageCacheService spyImageCache = _SpyImageCacheService(
        repository: fakeRepository,
      );
      ImageCacheService.initialize(
        repository: fakeRepository,
        instance: spyImageCache,
      );

      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      useCase = SaveBookmarkUseCase(
        repository: fakeRepository,
        metadataScraperService: MetadataScraperService.instance,
      );

      final SaveResult result = await useCase.execute(rawUrl);
      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;

      // Wait for the fire-and-forget scraping and caching to complete.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(spyImageCache.calls, hasLength(1));
      expect(spyImageCache.calls.first, success.bookmarkId);

      final BookmarkItem? updated =
          await fakeRepository.getById(success.bookmarkId);
      expect(updated, isNotNull);
      expect(updated!.scrapingStatus, ScrapingStatus.done);
      expect(updated.thumbnailUrl, 'https://example.com/image.jpg');
    });

    test('favicon cache downloadAndCache is triggered after successful scrape',
        () async {
      const String rawUrl = 'https://example.com/article';
      const ParsedMetadata metadata = ParsedMetadata(
        title: 'Test Title',
        thumbnailUrl: 'https://example.com/image.jpg',
      );

      SourceParserRegistry.instance.register(_FakeParser(metadata));

      final _SpyFaviconCacheService spyFaviconCache = _SpyFaviconCacheService(
        repository: fakeRepository,
      );
      FaviconCacheService.initialize(
        repository: fakeRepository,
        instance: spyFaviconCache,
      );

      final _SpyImageCacheService spyImageCache = _SpyImageCacheService(
        repository: fakeRepository,
      );
      ImageCacheService.initialize(
        repository: fakeRepository,
        instance: spyImageCache,
      );

      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      useCase = SaveBookmarkUseCase(
        repository: fakeRepository,
        metadataScraperService: MetadataScraperService.instance,
      );

      final SaveResult result = await useCase.execute(rawUrl);
      expect(result, isA<SaveSuccess>());
      final SaveSuccess success = result as SaveSuccess;

      // Wait for the fire-and-forget scraping and caching to complete.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(spyFaviconCache.calls, hasLength(1));
      expect(spyFaviconCache.calls.first, success.bookmarkId);

      final BookmarkItem? updated =
          await fakeRepository.getById(success.bookmarkId);
      expect(updated, isNotNull);
      expect(updated!.scrapingStatus, ScrapingStatus.done);
      // Google fallback favicon should be set because metadata has no faviconUrl
      // and normalizedHost is extracted from the URL.
      expect(updated.faviconUrl, isNotNull);
      expect(
        updated.faviconUrl,
        'https://www.google.com/s2/favicons?domain=example.com&sz=128',
      );
    });
  });
}
