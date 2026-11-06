import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/core/input/marky_input_limits.dart';
import 'package:marky/core/url/content_type_detector.dart';
import 'package:marky/core/url/dio_redirect_resolver.dart';
import 'package:marky/core/url/external_content_id_extractor.dart';
import 'package:marky/core/url/redirect_resolver.dart';
import 'package:marky/core/url/url_extractor.dart';
import 'package:marky/core/url/url_hasher.dart';
import 'package:marky/core/url/url_normalizer.dart';
import 'package:marky/features/automation/domain/automation_engine.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/capture/domain/capture_service.dart';
import 'package:marky/features/capture/domain/duplicate_check_result.dart';
import 'package:marky/features/capture/domain/duplicate_detector.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';

/// Default implementation of [CaptureService].
///
/// Orchestrates the capture pipeline:
///   raw input → normalise → hash → detect content type →
///   extract external id → duplicate check → persist.
///
/// This class is intentionally thin — all heavy lifting is delegated
/// to pure helper classes and the repository/detector interfaces.
class CaptureServiceImpl implements CaptureService {
  CaptureServiceImpl({
    required BookmarkRepository bookmarkRepo,
    required DuplicateDetector duplicateDetector,
    UrlNormalizer? normalizer,
    UrlHasher? hasher,
    ContentTypeDetector? contentTypeDetector,
    ExternalContentIdExtractor? contentIdExtractor,
    UrlExtractor? urlExtractor,
    RedirectResolver? redirectResolver,
    ScrapingOrchestrator? scrapingOrchestrator,
    AutomationEngine? automationEngine,
  })  : _bookmarkRepo = bookmarkRepo,
        _duplicateDetector = duplicateDetector,
        _normalizer = normalizer ?? const UrlNormalizer(),
        _hasher = hasher ?? const UrlHasher(),
        _contentTypeDetector =
            contentTypeDetector ?? const ContentTypeDetector(),
        _contentIdExtractor =
            contentIdExtractor ?? const ExternalContentIdExtractor(),
        _urlExtractor = urlExtractor ?? const UrlExtractor(),
        _redirectResolver = redirectResolver ?? const NoOpRedirectResolver(),
        _scrapingOrchestrator = scrapingOrchestrator,
        _automationEngine = automationEngine;

  final BookmarkRepository _bookmarkRepo;
  final DuplicateDetector _duplicateDetector;
  final UrlNormalizer _normalizer;
  final UrlHasher _hasher;
  final ContentTypeDetector _contentTypeDetector;
  final ExternalContentIdExtractor _contentIdExtractor;
  final UrlExtractor _urlExtractor;
  final RedirectResolver _redirectResolver;

  /// Optional — when provided, fires asynchronously after each
  /// successful save to enrich the bookmark with scraped metadata.
  /// Tests that don't care about scraping leave this null.
  final ScrapingOrchestrator? _scrapingOrchestrator;

  /// Optional — when provided, evaluates automation rules after
  /// each successful capture. Fire-and-forget like scraping.
  final AutomationEngine? _automationEngine;

  @override
  Future<CaptureResult> capture(
    String rawInput, {
    BookmarkSourceType sourceType = BookmarkSourceType.manual,
  }) async {
    if (rawInput.length > MarkyInputLimits.maxUrlInputLength) {
      return const CaptureResult.invalidUrl();
    }

    // Step 1: Normalise.
    String? normalizedUrl = _normalizer.normalize(rawInput);
    if (normalizedUrl == null) {
      return const CaptureResult.invalidUrl();
    }

    String? normalizedHost = _normalizer.extractNormalizedHost(rawInput);

    // Step 1b: Resolve shorteners (t.co, bit.ly, etc.) so we hash and
    // dedupe by the *final* URL.  Only resolves for known shortener
    // hosts — direct URLs skip the network round-trip.
    if (normalizedHost != null && _isShortenerHost(normalizedHost)) {
      final String resolved = await _redirectResolver.resolve(normalizedUrl);
      if (resolved != normalizedUrl) {
        final String? renormalized = _normalizer.normalize(resolved);
        if (renormalized != null) {
          normalizedUrl = renormalized;
          normalizedHost = _normalizer.extractNormalizedHost(resolved);
        }
      }
    }

    // Step 2: Compute URL hash.
    final String urlHash = _hasher.hash(normalizedUrl);

    // Step 3: Detect content type + extract external content ID.
    final BookmarkContentType contentType =
        _contentTypeDetector.detect(normalizedUrl);
    final String? externalContentId =
        _contentIdExtractor.extract(normalizedUrl);

    // Step 4: Duplicate check.
    try {
      final DuplicateCheckResult dupeResult = await _duplicateDetector.check(
        urlHash: urlHash,
        canonicalUrl: normalizedUrl,
        externalContentId: externalContentId,
      );

      if (!dupeResult.isNew) {
        return CaptureResult.duplicate(
          dupeResult.existingBookmark!,
          dupeResult.matchLevel!,
        );
      }

      // Step 5: Persist the new bookmark.
      final DateTime now = DateTime.now();
      final Bookmark newBookmark = Bookmark(
        originalUrl: rawInput.trim(),
        canonicalUrl: normalizedUrl,
        normalizedHost: normalizedHost,
        urlHash: urlHash,
        externalContentId: externalContentId,
        contentType: contentType,
        sourceType: sourceType,
        createdAt: now,
        updatedAt: now,
      );

      final Bookmark saved = await _bookmarkRepo.save(newBookmark);

      // Run automation FIRST so that tags/collections are set before
      // scraping re-reads the bookmark. Automation is fast (no network)
      // and must not be overwritten by the scraper's merge.
      await _runAutomationFor(saved);

      // Fire-and-forget background enrichment.  We don't await —
      // the user gets immediate feedback and the bookmark stream
      // will re-emit when scraping completes.
      _fireScrapingFor(saved);

      return CaptureResult.saved(saved);
    } catch (e) {
      return CaptureResult.error(e.toString());
    }
  }

  /// Kicks off background metadata enrichment when an orchestrator
  /// is wired.  Never throws — orchestrator failures are absorbed.
  void _fireScrapingFor(Bookmark saved) {
    final ScrapingOrchestrator? orchestrator = _scrapingOrchestrator;
    if (orchestrator == null || saved.id == null) return;

    // Intentionally not awaited.
    // ignore: discarded_futures
    orchestrator.enrich(saved.id!).catchError((_) {});
  }

  /// Evaluates automation rules against a newly saved bookmark.
  /// Awaited so tags/collections are persisted before scraping starts.
  /// Never throws — engine failures are absorbed.
  Future<void> _runAutomationFor(Bookmark saved) async {
    final AutomationEngine? engine = _automationEngine;
    if (engine == null) return;

    try {
      await engine.evaluate(saved);
    } catch (_) {
      // Automation failure is non-fatal.
    }
  }

  @override
  Future<CaptureResult> captureFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  }) async {
    if (text.length > MarkyInputLimits.maxSharedTextLength) {
      return const CaptureResult.invalidUrl();
    }

    final String? url = _urlExtractor.extractFirst(text);
    if (url == null) return const CaptureResult.invalidUrl();
    return capture(url, sourceType: sourceType);
  }

  @override
  Future<List<CaptureResult>> captureAllFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  }) async {
    if (text.length > MarkyInputLimits.maxSharedTextLength) {
      return const <CaptureResult>[];
    }

    final List<String> urls = _urlExtractor.extractAll(text);
    if (urls.isEmpty) return const <CaptureResult>[];

    final List<CaptureResult> results = <CaptureResult>[];
    for (final String url in urls) {
      results.add(await capture(url, sourceType: sourceType));
    }
    return results;
  }

  /// Known URL shortener hosts.  Capture resolves these so the
  /// canonical URL we hash and dedupe by is the destination, not the
  /// shortener.  Direct URLs skip the network round-trip entirely.
  ///
  /// `youtu.be` is intentionally omitted — the content-id extractor
  /// already collapses it to the same `youtube:<id>` id used by
  /// full YouTube URLs, so no network call is needed for dedup.
  static const Set<String> _shortenerHosts = <String>{
    't.co',
    'bit.ly',
    'tinyurl.com',
    'goo.gl',
    'ow.ly',
    'is.gd',
    'buff.ly',
    'lnkd.in',
    'fb.me',
    'amzn.to',
    'wp.me',
    'dlvr.it',
    'shar.es',
    'rb.gy',
    'cutt.ly',
  };

  static bool _isShortenerHost(String host) {
    return _shortenerHosts.contains(host.toLowerCase());
  }
}
