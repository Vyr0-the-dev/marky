import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/scraping/enums/scraping_status.dart';
import 'package:marky/core/scraping/metadata_scraper_service.dart';
import 'package:marky/core/scraping/models/parsed_metadata.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';
import 'package:marky/core/scraping/source_parser_registry.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/services/duplicate_detection_service.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ─── Fakes ─────────────────────────────────────────────────────────────

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

class _FakeParser extends SourceParser {
  _FakeParser(this._hosts, this._result);

  final Set<String> _hosts;
  final ParsedMetadata? _result;

  @override
  Set<String> get hosts => _hosts;

  @override
  Future<ParsedMetadata?> parse(String url) async => _result;
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('Parser Integration', () {
    late _FakeBookmarkItemRepository fakeRepository;

    setUp(() {
      fakeRepository = _FakeBookmarkItemRepository();
      MetadataScraperService.reset();
      SourceParserRegistry.instance.clear();
      DuplicateDetectionService.initialize(
        repository: fakeRepository,
        normalizationService: UrlNormalizationService.instance,
      );
    });

    tearDown(() {
      MetadataScraperService.reset();
      SourceParserRegistry.instance.clear();
      DuplicateDetectionService.reset();
    });

    test('instanceOrNull returns null before initialization', () {
      expect(MetadataScraperService.instanceOrNull, isNull);
    });

    test('instanceOrNull returns instance after initialization', () {
      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      expect(MetadataScraperService.instanceOrNull, isNotNull);
      expect(MetadataScraperService.instanceOrNull, same(MetadataScraperService.instance));
    });

    test('initialize registers all 5 platform parsers', () {
      expect(SourceParserRegistry.instance.length, 0);

      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      expect(SourceParserRegistry.instance.length, 5);
    });

    test('registry resolves YouTube URLs after initialize', () {
      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      final SourceParser? parser = SourceParserRegistry.instance
          .resolve('https://www.youtube.com/watch?v=dQw4w9WgXcQ');

      expect(parser, isNotNull);
      expect(parser!.hosts, contains('youtube.com'));
    });

    test('registry resolves Reddit URLs after initialize', () {
      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      final SourceParser? parser = SourceParserRegistry.instance
          .resolve('https://www.reddit.com/r/flutterdev/comments/abc123');

      expect(parser, isNotNull);
      expect(parser!.hosts, contains('reddit.com'));
    });

    test('registry resolves GitHub URLs after initialize', () {
      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      final SourceParser? parser = SourceParserRegistry.instance
          .resolve('https://github.com/user/repo');

      expect(parser, isNotNull);
      expect(parser!.hosts, contains('github.com'));
    });

    test('registry resolves Twitter URLs after initialize', () {
      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      final SourceParser? parser = SourceParserRegistry.instance
          .resolve('https://x.com/elonmusk/status/123456');

      expect(parser, isNotNull);
      expect(parser!.hosts, contains('x.com'));
    });

    test('registry resolves Medium URLs after initialize', () {
      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      final SourceParser? parser = SourceParserRegistry.instance
          .resolve('https://medium.com/@author/article-slug');

      expect(parser, isNotNull);
      expect(parser!.hosts, contains('medium.com'));
    });

    test('registry resolves Medium publication subdomains after initialize', () {
      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      final SourceParser? parser = SourceParserRegistry.instance
          .resolve('https://pub.medium.com/some-article');

      expect(parser, isNotNull);
    });

    test('unknown URLs fall back to null (GenericParser used by service)', () {
      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      final SourceParser? parser = SourceParserRegistry.instance
          .resolve('https://unknown-site.com/article');

      expect(parser, isNull);
    });

    test('end-to-end scrape lifecycle updates bookmark metadata', () async {
      const String rawUrl = 'https://youtube.com/watch?v=abc123';
      const ParsedMetadata metadata = ParsedMetadata(
        title: 'YouTube Video Title',
        description: 'Video description',
        thumbnailUrl: 'https://img.youtube.com/vi/abc123/0.jpg',
        siteName: 'YouTube',
        author: 'Channel Name',
      );

      // Register a fake YouTube-like parser to avoid real network calls.
      SourceParserRegistry.instance.register(
        _FakeParser({'youtube.com'}, metadata),
      );

      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      final SaveBookmarkUseCase useCase = SaveBookmarkUseCase(
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
      expect(updated.title, 'YouTube Video Title');
      expect(updated.description, 'Video description');
      expect(updated.thumbnailUrl, 'https://img.youtube.com/vi/abc123/0.jpg');
      expect(updated.siteName, 'YouTube');
      expect(updated.author, 'Channel Name');
    });

    test('end-to-end scrape failure records failed status', () async {
      const String rawUrl = 'https://youtube.com/watch?v=fail';

      // Register a fake parser that returns null (simulating failure).
      SourceParserRegistry.instance.register(
        _FakeParser({'youtube.com'}, null),
      );

      MetadataScraperService.initialize(
        registry: SourceParserRegistry.instance,
        repository: fakeRepository,
      );

      final SaveBookmarkUseCase useCase = SaveBookmarkUseCase(
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
      expect(updated!.scrapingStatus, ScrapingStatus.failed);
    });

    test('capture provider uses instanceOrNull without throwing', () {
      // This simulates what happens when the provider is accessed
      // in a widget test where initialize() was not called.
      expect(MetadataScraperService.instanceOrNull, isNull);

      // Passing null to SaveBookmarkUseCase should work without error.
      final SaveBookmarkUseCase useCase = SaveBookmarkUseCase(
        repository: fakeRepository,
        metadataScraperService: MetadataScraperService.instanceOrNull,
      );
      expect(useCase, isNotNull);
    });
  });
}
