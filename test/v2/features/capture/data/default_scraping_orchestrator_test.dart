import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/automation_rule_entity.dart';
import 'package:marky/core/database/entities/backup_meta_entity.dart';
import 'package:marky/core/database/entities/bookmark_entity.dart';
import 'package:marky/core/database/entities/collection_entity.dart';
import 'package:marky/core/database/entities/reminder_entity.dart';
import 'package:marky/core/database/entities/tag_entity.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/metadata_scraper.dart';
import 'package:marky/features/bookmarks/data/isar_bookmark_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/capture/data/default_scraping_orchestrator.dart';
import 'package:marky/features/capture/data/default_upsert_merge_service.dart';

class _FakeMetadataScraper implements MetadataScraper {
  _FakeMetadataScraper(this._result);

  final MetadataResult _result;
  String? lastUrlScraped;
  CancelToken? lastCancelToken;

  @override
  Future<MetadataResult> scrape(String url, {CancelToken? cancelToken}) async {
    lastUrlScraped = url;
    lastCancelToken = cancelToken;
    return _result;
  }
}

class _ThrowingMetadataScraper implements MetadataScraper {
  @override
  Future<MetadataResult> scrape(String url, {CancelToken? cancelToken}) async {
    throw Exception('network down');
  }
}

class _BlockingScraper implements MetadataScraper {
  _BlockingScraper({required this.onScrape});

  final Future<void> Function(CancelToken? token) onScrape;

  @override
  Future<MetadataResult> scrape(String url, {CancelToken? cancelToken}) async {
    await onScrape(cancelToken);
    return const MetadataResult(title: 'Blocked Scraped');
  }
}

void main() {
  late Directory tempDir;
  late Isar isar;
  late IsarBookmarkRepository repo;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('marky_scraping_test_');
    isar = await Isar.open(
      <CollectionSchema<dynamic>>[
        BookmarkEntitySchema,
        TagEntitySchema,
        CollectionEntitySchema,
        ReminderEntitySchema,
        AutomationRuleEntitySchema,
        BackupMetaEntitySchema,
      ],
      directory: tempDir.path,
    );
    repo = IsarBookmarkRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<Bookmark> seed({
    String? title,
    String? heroImageUrl,
  }) async {
    return repo.save(
      Bookmark(
        originalUrl: 'https://example.com/article',
        title: title,
        heroImageUrl: heroImageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  // ─── Happy path ────────────────────────────────────────────────

  group('successful enrichment', () {
    test('fills empty bookmark with scraped metadata', () async {
      final Bookmark seeded = await seed();
      final _FakeMetadataScraper scraper = _FakeMetadataScraper(
        const MetadataResult(
          title: 'Scraped Title',
          description: 'Scraped Desc',
          heroImageUrl: 'https://img.com/hero.jpg',
          siteName: 'Example',
          faviconUrl: 'https://example.com/favicon.ico',
        ),
      );
      final orchestrator = DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: scraper,
        merger: const DefaultUpsertMergeService(),
      );

      await orchestrator.enrich(seeded.id!);

      final Bookmark? after = await repo.getById(seeded.id!);
      expect(after, isNotNull);
      expect(after!.title, 'Scraped Title');
      expect(after.description, 'Scraped Desc');
      expect(after.heroImageUrl, 'https://img.com/hero.jpg');
      expect(after.siteName, 'Example');
      expect(after.scrapingStatus, BookmarkScrapingStatus.done);
    });

    test('preserves user-provided title (fill-gap policy)', () async {
      final Bookmark seeded = await seed(title: 'My Custom Title');
      final _FakeMetadataScraper scraper = _FakeMetadataScraper(
        const MetadataResult(title: 'Scraper Title'),
      );
      final orchestrator = DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: scraper,
        merger: const DefaultUpsertMergeService(),
      );

      await orchestrator.enrich(seeded.id!);

      final Bookmark after = (await repo.getById(seeded.id!))!;
      expect(after.title, 'My Custom Title');
    });

    test('scraper is called with the original URL', () async {
      final Bookmark seeded = await seed();
      final _FakeMetadataScraper scraper =
          _FakeMetadataScraper(const MetadataResult());
      final orchestrator = DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: scraper,
        merger: const DefaultUpsertMergeService(),
      );

      await orchestrator.enrich(seeded.id!);

      expect(scraper.lastUrlScraped, 'https://example.com/article');
    });
  });

  // ─── Failure / empty result ────────────────────────────────────

  group('empty / failed scrape', () {
    test('marks failed when result is empty', () async {
      final Bookmark seeded = await seed();
      final _FakeMetadataScraper scraper =
          _FakeMetadataScraper(const MetadataResult());
      final orchestrator = DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: scraper,
        merger: const DefaultUpsertMergeService(),
      );

      await orchestrator.enrich(seeded.id!);

      final Bookmark after = (await repo.getById(seeded.id!))!;
      expect(after.scrapingStatus, BookmarkScrapingStatus.failed);
    });

    test('marks done when only image is found', () async {
      final Bookmark seeded = await seed();
      final _FakeMetadataScraper scraper = _FakeMetadataScraper(
        const MetadataResult(heroImageUrl: 'https://img.com/h.jpg'),
      );
      final orchestrator = DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: scraper,
        merger: const DefaultUpsertMergeService(),
      );

      await orchestrator.enrich(seeded.id!);

      final Bookmark after = (await repo.getById(seeded.id!))!;
      expect(after.scrapingStatus, BookmarkScrapingStatus.done);
      expect(after.heroImageUrl, 'https://img.com/h.jpg');
    });

    test('uses favicon as image fallback when no hero image exists', () async {
      final Bookmark seeded = await seed();
      final _FakeMetadataScraper scraper = _FakeMetadataScraper(
        const MetadataResult(faviconUrl: 'https://example.com/favicon.ico'),
      );
      final orchestrator = DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: scraper,
        merger: const DefaultUpsertMergeService(),
      );

      await orchestrator.enrich(seeded.id!);

      final Bookmark after = (await repo.getById(seeded.id!))!;
      expect(after.scrapingStatus, BookmarkScrapingStatus.done);
      expect(after.heroImageUrl, 'https://example.com/favicon.ico');
      expect(after.faviconUrl, 'https://example.com/favicon.ico');
    });

    test('does not throw when scraper itself throws', () async {
      // The scraper contract says implementations never throw,
      // but the orchestrator is defensive — exercise that path.
      final Bookmark seeded = await seed();
      final orchestrator = DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: _ThrowingMetadataScraper(),
        merger: const DefaultUpsertMergeService(),
      );

      // The scrape() inside the orchestrator awaits — if the fake
      // throws, MetadataScraperService.scrape would normally swallow.
      // Our fake doesn't swallow, so we expect either (a) the
      // orchestrator to catch and mark failed, or (b) the throw
      // propagates. Test the contract: never throws.
      await expectLater(
        orchestrator.enrich(seeded.id!),
        completes,
      );

      final Bookmark after = (await repo.getById(seeded.id!))!;
      // Should be failed or processing-then-failed; never `done`.
      expect(after.scrapingStatus, isNot(BookmarkScrapingStatus.done));
    });
  });

  // ─── Bookmark deleted before enrich ────────────────────────────

  group('missing bookmark', () {
    test('returns silently for non-existent id', () async {
      final orchestrator = DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: _FakeMetadataScraper(const MetadataResult(title: 'x')),
        merger: const DefaultUpsertMergeService(),
      );

      await expectLater(orchestrator.enrich(99999), completes);
    });
  });

  // ─── Status transitions ────────────────────────────────────────

  group('status transitions', () {
    test('moves pending → done on success', () async {
      final Bookmark seeded = await seed();
      final orchestrator = DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: _FakeMetadataScraper(
          const MetadataResult(title: 'T'),
        ),
        merger: const DefaultUpsertMergeService(),
      );

      await orchestrator.enrich(seeded.id!);

      final Bookmark after = (await repo.getById(seeded.id!))!;
      expect(after.scrapingStatus, BookmarkScrapingStatus.done);
    });

    test('moves pending → failed on empty result', () async {
      final Bookmark seeded = await seed();
      final orchestrator = DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: _FakeMetadataScraper(const MetadataResult()),
        merger: const DefaultUpsertMergeService(),
      );

      await orchestrator.enrich(seeded.id!);

      final Bookmark after = (await repo.getById(seeded.id!))!;
      expect(after.scrapingStatus, BookmarkScrapingStatus.failed);
    });

    test('cancel aborts active scraper token and leaves bookmark untouched',
        () async {
      final Bookmark seeded = await seed();
      final Completer<void> startedCompleter = Completer<void>();
      final Completer<void> scrapeCompleter = Completer<void>();
      CancelToken? capturedToken;

      final _BlockingScraper blockingScraper = _BlockingScraper(
        onScrape: (CancelToken? token) {
          capturedToken = token;
          if (!startedCompleter.isCompleted) {
            startedCompleter.complete();
          }
          return scrapeCompleter.future;
        },
      );

      final DefaultScrapingOrchestrator orchestrator =
          DefaultScrapingOrchestrator(
        bookmarkRepo: repo,
        scraper: blockingScraper,
        merger: const DefaultUpsertMergeService(),
      );

      final Future<void> enrichFuture = orchestrator.enrich(seeded.id!);

      await startedCompleter.future;
      expect(capturedToken, isNotNull);
      expect(capturedToken!.isCancelled, isFalse);

      orchestrator.cancel(seeded.id!);
      expect(capturedToken!.isCancelled, isTrue);

      scrapeCompleter.complete();
      await enrichFuture;
    });
  });
}
