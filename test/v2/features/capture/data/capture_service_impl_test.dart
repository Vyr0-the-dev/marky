import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/automation_rule_entity.dart';
import 'package:marky/core/database/entities/backup_meta_entity.dart';
import 'package:marky/core/database/entities/bookmark_entity.dart';
import 'package:marky/core/database/entities/collection_entity.dart';
import 'package:marky/core/database/entities/reminder_entity.dart';
import 'package:marky/core/database/entities/tag_entity.dart';
import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/core/input/marky_input_limits.dart';
import 'package:marky/core/url/redirect_resolver.dart';
import 'package:marky/features/bookmarks/data/isar_bookmark_repository.dart';
import 'package:marky/features/capture/data/capture_service_impl.dart';
import 'package:marky/features/capture/data/isar_duplicate_detector.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/capture/domain/duplicate_check_result.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';

void main() {
  late Isar isar;
  late IsarBookmarkRepository bookmarkRepo;
  late IsarDuplicateDetector duplicateDetector;
  late CaptureServiceImpl captureService;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      <CollectionSchema<dynamic>>[
        BookmarkEntitySchema,
        TagEntitySchema,
        CollectionEntitySchema,
        ReminderEntitySchema,
        AutomationRuleEntitySchema,
        BackupMetaEntitySchema,
      ],
      directory: Directory.systemTemp.createTempSync('capture_test_').path,
      name: 'capture_test_${DateTime.now().microsecondsSinceEpoch}',
    );
    bookmarkRepo = IsarBookmarkRepository(isar);
    duplicateDetector = IsarDuplicateDetector(bookmarkRepo);
    captureService = CaptureServiceImpl(
      bookmarkRepo: bookmarkRepo,
      duplicateDetector: duplicateDetector,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  // ─── Valid URL capture ─────────────────────────────────────────

  group('capture – valid URL', () {
    test('saves a new bookmark and returns CaptureStatus.saved', () async {
      final CaptureResult result = await captureService.capture(
        'https://example.com/article?utm_source=twitter',
      );

      expect(result.status, CaptureStatus.saved);
      expect(result.isSaved, isTrue);
      expect(result.bookmark, isNotNull);
      expect(result.bookmark!.id, isNotNull);
    });

    test('normalises the URL before saving', () async {
      final CaptureResult result = await captureService.capture(
        'https://www.example.com/page?fbclid=abc123',
      );

      expect(result.bookmark!.canonicalUrl, 'https://example.com/page');
      expect(result.bookmark!.normalizedHost, 'example.com');
    });

    test('computes urlHash from the normalised URL', () async {
      final CaptureResult result = await captureService.capture(
        'https://example.com/test',
      );

      expect(result.bookmark!.urlHash, isNotNull);
      expect(result.bookmark!.urlHash!.length, 64);
    });

    test('detects content type from URL', () async {
      final CaptureResult result = await captureService.capture(
        'https://youtube.com/watch?v=dQw4w9WgXcQ',
      );

      expect(result.bookmark!.contentType, BookmarkContentType.video);
    });

    test('extracts external content ID for known platforms', () async {
      final CaptureResult result = await captureService.capture(
        'https://youtube.com/watch?v=dQw4w9WgXcQ',
      );

      expect(result.bookmark!.externalContentId, 'youtube:dQw4w9WgXcQ');
    });

    test('sets sourceType from parameter', () async {
      final CaptureResult result = await captureService.capture(
        'https://example.com/page',
        sourceType: BookmarkSourceType.share,
      );

      expect(result.bookmark!.sourceType, BookmarkSourceType.share);
    });

    test('sets scrapingStatus to pending', () async {
      final CaptureResult result = await captureService.capture(
        'https://example.com/page',
      );

      expect(result.bookmark!.scrapingStatus, BookmarkScrapingStatus.pending);
    });

    test('preserves raw input as originalUrl', () async {
      const String raw = '  https://www.example.com/page?utm_source=x  ';
      final CaptureResult result = await captureService.capture(raw);

      expect(result.bookmark!.originalUrl, raw.trim());
    });
  });

  // ─── Duplicate detection ───────────────────────────────────────

  group('capture – duplicates', () {
    test('detects duplicate by urlHash on second capture', () async {
      final CaptureResult first = await captureService.capture(
        'https://example.com/article',
      );
      expect(first.status, CaptureStatus.saved);

      final CaptureResult second = await captureService.capture(
        'https://www.example.com/article', // same normalised URL
      );

      expect(second.status, CaptureStatus.duplicate);
      expect(second.bookmark!.id, first.bookmark!.id);
      expect(second.duplicateMatchLevel, DuplicateMatchLevel.urlHash);
    });

    test('detects duplicate by externalContentId across URL variants',
        () async {
      // First: full YouTube URL.
      final CaptureResult first = await captureService.capture(
        'https://youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(first.status, CaptureStatus.saved);

      // Second: youtu.be short link (different canonical, same content ID).
      final CaptureResult second = await captureService.capture(
        'https://youtu.be/dQw4w9WgXcQ',
      );

      expect(second.status, CaptureStatus.duplicate);
      expect(second.bookmark!.id, first.bookmark!.id);
      expect(
        second.duplicateMatchLevel,
        DuplicateMatchLevel.externalContentId,
      );
    });

    test('detects duplicate across mobile hosts and tracking params', () async {
      final CaptureResult first = await captureService.capture(
        'https://example.com/article',
      );

      final CaptureResult second = await captureService.capture(
        'http://m.example.com/article/?utm_source=newsletter&fbclid=abc',
      );

      expect(first.status, CaptureStatus.saved);
      expect(second.status, CaptureStatus.duplicate);
      expect(second.bookmark!.id, first.bookmark!.id);
      expect(second.duplicateMatchLevel, DuplicateMatchLevel.urlHash);
    });

    test('detects duplicate after shortener redirect resolution', () async {
      final _StubRedirectResolver resolver =
          _StubRedirectResolver(<String, String>{
        'https://bit.ly/marky': 'https://example.com/article',
      });
      final CaptureServiceImpl service = CaptureServiceImpl(
        bookmarkRepo: bookmarkRepo,
        duplicateDetector: duplicateDetector,
        redirectResolver: resolver,
      );

      final CaptureResult first = await service.capture('https://bit.ly/marky');
      final CaptureResult second =
          await service.capture('https://example.com/article');

      expect(first.status, CaptureStatus.saved);
      expect(second.status, CaptureStatus.duplicate);
      expect(second.bookmark!.id, first.bookmark!.id);
      expect(second.duplicateMatchLevel, DuplicateMatchLevel.urlHash);
    });

    test('detects duplicate across common AMP path variants', () async {
      final CaptureResult first = await captureService.capture(
        'https://www.example.com/amp/article?utm_medium=social',
      );

      final CaptureResult second = await captureService.capture(
        'https://example.com/article/amp/',
      );

      expect(first.status, CaptureStatus.saved);
      expect(first.bookmark!.canonicalUrl, 'https://example.com/article');
      expect(second.status, CaptureStatus.duplicate);
      expect(second.bookmark!.id, first.bookmark!.id);
    });

    test('two different URLs are not duplicates', () async {
      final CaptureResult first = await captureService.capture(
        'https://example.com/page-a',
      );
      final CaptureResult second = await captureService.capture(
        'https://example.com/page-b',
      );

      expect(first.status, CaptureStatus.saved);
      expect(second.status, CaptureStatus.saved);
      expect(first.bookmark!.id, isNot(second.bookmark!.id));
    });
  });

  // ─── Invalid URL ───────────────────────────────────────────────

  group('capture – invalid URL', () {
    test('returns invalidUrl for empty input', () async {
      final CaptureResult result = await captureService.capture('');
      expect(result.status, CaptureStatus.invalidUrl);
      expect(result.bookmark, isNull);
    });

    test('returns invalidUrl for non-URL text', () async {
      final CaptureResult result = await captureService.capture(
        'just some random text',
      );
      expect(result.status, CaptureStatus.invalidUrl);
    });

    test('returns invalidUrl for ftp scheme', () async {
      final CaptureResult result = await captureService.capture(
        'ftp://files.example.com',
      );
      expect(result.status, CaptureStatus.invalidUrl);
    });

    test('returns invalidUrl for oversized direct input', () async {
      final CaptureResult result = await captureService.capture(
        'https://example.com/${'a' * MarkyInputLimits.maxUrlInputLength}',
      );

      expect(result.status, CaptureStatus.invalidUrl);
      expect(result.bookmark, isNull);
    });

    test('returns invalidUrl for malformed port instead of throwing', () async {
      final CaptureResult result = await captureService.capture(
        'https://example.com:bad/path',
      );

      expect(result.status, CaptureStatus.invalidUrl);
      expect(result.bookmark, isNull);
    });
  });

  // ─── Real-world scenarios ──────────────────────────────────────

  group('capture – real-world', () {
    test('Reddit post with tracking params', () async {
      final CaptureResult result = await captureService.capture(
        'https://www.reddit.com/r/flutter/comments/abc123/my_post/'
        '?utm_source=share&utm_medium=web3x',
      );

      expect(result.status, CaptureStatus.saved);
      expect(result.bookmark!.contentType, BookmarkContentType.discussion);
      expect(result.bookmark!.externalContentId, 'reddit:abc123');
      expect(result.bookmark!.normalizedHost, 'reddit.com');
    });

    test('GitHub repo link', () async {
      final CaptureResult result = await captureService.capture(
        'https://github.com/flutter/flutter',
      );

      expect(result.status, CaptureStatus.saved);
      expect(result.bookmark!.contentType, BookmarkContentType.code);
      expect(result.bookmark!.externalContentId, 'github:flutter/flutter');
    });

    test('bare domain auto-prepends https', () async {
      final CaptureResult result = await captureService.capture(
        'example.com/article',
      );

      expect(result.status, CaptureStatus.saved);
      expect(
        result.bookmark!.canonicalUrl,
        'https://example.com/article',
      );
    });
  });

  // ─── captureFromText ───────────────────────────────────────────

  group('captureFromText', () {
    test('extracts URL from surrounding text and saves', () async {
      final CaptureResult result = await captureService.captureFromText(
        'Check this out: https://example.com/article - amazing!',
      );

      expect(result.status, CaptureStatus.saved);
      expect(result.bookmark!.canonicalUrl, 'https://example.com/article');
    });

    test('defaults to BookmarkSourceType.share', () async {
      final CaptureResult result = await captureService.captureFromText(
        'https://example.com/shared',
      );

      expect(result.bookmark!.sourceType, BookmarkSourceType.share);
    });

    test('returns invalidUrl when text has no URL', () async {
      final CaptureResult result = await captureService.captureFromText(
        'just some text without any links',
      );

      expect(result.status, CaptureStatus.invalidUrl);
    });

    test('detects duplicate from text capture', () async {
      await captureService.capture('https://example.com/page');

      final CaptureResult result = await captureService.captureFromText(
        'Look at https://example.com/page - wow',
      );

      expect(result.status, CaptureStatus.duplicate);
    });

    test('handles Twitter share format', () async {
      final CaptureResult result = await captureService.captureFromText(
        '"Great Flutter tips" https://x.com/user/status/1234567890',
      );

      expect(result.status, CaptureStatus.saved);
      expect(result.bookmark!.contentType, BookmarkContentType.discussion);
    });

    test('returns invalidUrl for oversized shared text', () async {
      final CaptureResult result = await captureService.captureFromText(
        '${'x' * MarkyInputLimits.maxSharedTextLength} https://example.com',
      );

      expect(result.status, CaptureStatus.invalidUrl);
      expect(result.bookmark, isNull);
    });
  });

  // ─── captureAllFromText ────────────────────────────────────────

  group('captureAllFromText', () {
    test('captures multiple URLs from text', () async {
      final List<CaptureResult> results =
          await captureService.captureAllFromText(
        'Links: https://example.com/a and https://example.com/b',
      );

      expect(results.length, 2);
      expect(results[0].status, CaptureStatus.saved);
      expect(results[1].status, CaptureStatus.saved);
      expect(results[0].bookmark!.id, isNot(results[1].bookmark!.id));
    });

    test('returns empty list when no URLs found', () async {
      final List<CaptureResult> results =
          await captureService.captureAllFromText('no links here');

      expect(results, isEmpty);
    });

    test('marks duplicates within multi-URL capture', () async {
      final List<CaptureResult> results =
          await captureService.captureAllFromText(
        'https://example.com/same https://www.example.com/same',
      );

      expect(results.length, 2);
      expect(results[0].status, CaptureStatus.saved);
      expect(results[1].status, CaptureStatus.duplicate);
    });

    test('returns empty list for oversized multi-capture text', () async {
      final List<CaptureResult> results =
          await captureService.captureAllFromText(
        '${'x' * MarkyInputLimits.maxSharedTextLength} https://example.com',
      );

      expect(results, isEmpty);
    });
  });

  // ─── Scraping orchestrator integration ─────────────────────────

  group('scraping orchestrator', () {
    test('fires orchestrator with the saved bookmark id', () async {
      final _RecordingOrchestrator orchestrator = _RecordingOrchestrator();
      final CaptureServiceImpl service = CaptureServiceImpl(
        bookmarkRepo: bookmarkRepo,
        duplicateDetector: duplicateDetector,
        scrapingOrchestrator: orchestrator,
      );

      final CaptureResult result = await service.capture(
        'https://example.com/needs-scraping',
      );

      expect(result.status, CaptureStatus.saved);
      // Allow the microtask queue to drain.
      await Future<void>.delayed(Duration.zero);
      expect(orchestrator.calls, <int>[result.bookmark!.id!]);
    });

    test('does not fire orchestrator on duplicate', () async {
      final _RecordingOrchestrator orchestrator = _RecordingOrchestrator();
      final CaptureServiceImpl service = CaptureServiceImpl(
        bookmarkRepo: bookmarkRepo,
        duplicateDetector: duplicateDetector,
        scrapingOrchestrator: orchestrator,
      );

      await service.capture('https://example.com/page');
      // Drain microtasks for the first call.
      await Future<void>.delayed(Duration.zero);
      orchestrator.calls.clear();

      final CaptureResult dupe =
          await service.capture('https://example.com/page');
      await Future<void>.delayed(Duration.zero);

      expect(dupe.status, CaptureStatus.duplicate);
      expect(orchestrator.calls, isEmpty);
    });

    test('capture still returns saved if orchestrator throws', () async {
      final CaptureServiceImpl service = CaptureServiceImpl(
        bookmarkRepo: bookmarkRepo,
        duplicateDetector: duplicateDetector,
        scrapingOrchestrator: _ThrowingOrchestrator(),
      );

      final CaptureResult result =
          await service.capture('https://example.com/page');

      expect(result.status, CaptureStatus.saved);
      await Future<void>.delayed(Duration.zero);
    });

    test('does not wait for slow orchestrator before returning saved',
        () async {
      final _BlockingOrchestrator orchestrator = _BlockingOrchestrator();
      final CaptureServiceImpl service = CaptureServiceImpl(
        bookmarkRepo: bookmarkRepo,
        duplicateDetector: duplicateDetector,
        scrapingOrchestrator: orchestrator,
      );

      final CaptureResult result =
          await service.capture('https://example.com/slow-scrape');

      expect(result.status, CaptureStatus.saved);
      expect(orchestrator.completed, isFalse);
      orchestrator.complete();
      await Future<void>.delayed(Duration.zero);
      expect(orchestrator.completed, isTrue);
    });
  });

  // ─── Shortener resolution ──────────────────────────────────────

  group('shortener resolution', () {
    test('resolves bit.ly link to canonical URL', () async {
      final _StubRedirectResolver resolver =
          _StubRedirectResolver(<String, String>{
        'https://bit.ly/abc': 'https://example.com/article',
      });
      final CaptureServiceImpl service = CaptureServiceImpl(
        bookmarkRepo: bookmarkRepo,
        duplicateDetector: duplicateDetector,
        redirectResolver: resolver,
      );

      final CaptureResult result = await service.capture('https://bit.ly/abc');

      expect(result.status, CaptureStatus.saved);
      expect(result.bookmark!.canonicalUrl, 'https://example.com/article');
      expect(result.bookmark!.normalizedHost, 'example.com');
      expect(resolver.calls, <String>['https://bit.ly/abc']);
    });

    test('does NOT call resolver for non-shortener hosts', () async {
      final _StubRedirectResolver resolver = _StubRedirectResolver(
        const <String, String>{},
      );
      final CaptureServiceImpl service = CaptureServiceImpl(
        bookmarkRepo: bookmarkRepo,
        duplicateDetector: duplicateDetector,
        redirectResolver: resolver,
      );

      await service.capture('https://example.com/article');

      expect(resolver.calls, isEmpty);
    });

    test('dedupe collapses shortener + canonical to one bookmark', () async {
      final _StubRedirectResolver resolver =
          _StubRedirectResolver(<String, String>{
        'https://t.co/abc': 'https://example.com/article',
      });
      final CaptureServiceImpl service = CaptureServiceImpl(
        bookmarkRepo: bookmarkRepo,
        duplicateDetector: duplicateDetector,
        redirectResolver: resolver,
      );

      final CaptureResult first =
          await service.capture('https://example.com/article');
      final CaptureResult second = await service.capture('https://t.co/abc');

      expect(first.status, CaptureStatus.saved);
      expect(second.status, CaptureStatus.duplicate);
      expect(second.bookmark!.id, first.bookmark!.id);
    });

    test('falls back to original URL when resolver returns same input',
        () async {
      // Some shorteners may not resolve cleanly — never block save.
      final _StubRedirectResolver resolver = _StubRedirectResolver(
        const <String, String>{},
      );
      final CaptureServiceImpl service = CaptureServiceImpl(
        bookmarkRepo: bookmarkRepo,
        duplicateDetector: duplicateDetector,
        redirectResolver: resolver,
      );

      final CaptureResult result =
          await service.capture('https://bit.ly/unknown');

      expect(result.status, CaptureStatus.saved);
      expect(result.bookmark!.canonicalUrl, 'https://bit.ly/unknown');
    });
  });
}

class _StubRedirectResolver implements RedirectResolver {
  _StubRedirectResolver(this._mapping);

  final Map<String, String> _mapping;
  final List<String> calls = <String>[];

  @override
  Future<String> resolve(String url) async {
    calls.add(url);
    return _mapping[url] ?? url;
  }
}

class _RecordingOrchestrator implements ScrapingOrchestrator {
  final List<int> calls = <int>[];
  final List<int> cancelled = <int>[];

  @override
  Future<void> enrich(int bookmarkId) async {
    calls.add(bookmarkId);
  }

  @override
  void cancel(int bookmarkId) {
    cancelled.add(bookmarkId);
  }
}

class _ThrowingOrchestrator implements ScrapingOrchestrator {
  @override
  Future<void> enrich(int bookmarkId) async {
    throw Exception('boom');
  }

  @override
  void cancel(int bookmarkId) {}
}

class _BlockingOrchestrator implements ScrapingOrchestrator {
  final Completer<void> _completer = Completer<void>();
  bool completed = false;

  @override
  Future<void> enrich(int bookmarkId) async {
    await _completer.future;
    completed = true;
  }

  @override
  void cancel(int bookmarkId) {}

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}
