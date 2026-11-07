import 'package:dio/dio.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/metadata_scraper.dart';
import 'package:marky/core/scraping/parsers/generic_html_parser.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';
import 'package:marky/features/capture/domain/upsert_merge_service.dart';

/// Default implementation of [ScrapingOrchestrator].
///
/// Pipeline:
/// 1. Load bookmark by id.
/// 2. Mark scrapingStatus → processing, persist.
/// 3. Run [MetadataScraperService.scrape] on the original URL with a bound [CancelToken].
/// 4. Convert [MetadataResult] into a stub [Bookmark] for merging.
/// 5. Call [UpsertMergeService.merge] to fill gaps.
/// 6. Mark scrapingStatus → done (or failed) and persist.
class DefaultScrapingOrchestrator implements ScrapingOrchestrator {
  DefaultScrapingOrchestrator({
    required BookmarkRepository bookmarkRepo,
    required MetadataScraper scraper,
    required UpsertMergeService merger,
  })  : _bookmarkRepo = bookmarkRepo,
        _scraper = scraper,
        _merger = merger;

  final BookmarkRepository _bookmarkRepo;
  final MetadataScraper _scraper;
  final UpsertMergeService _merger;
  final Map<int, CancelToken> _activeTokens = <int, CancelToken>{};
  final Set<int> _attemptedIncompleteIds = <int>{};
  bool _isEnrichingIncomplete = false;

  @override
  void cancel(int bookmarkId) {
    final CancelToken? token = _activeTokens.remove(bookmarkId);
    if (token != null && !token.isCancelled) {
      token.cancel('Scraping cancelled for bookmark #$bookmarkId');
    }
  }

  @override
  Future<void> enrich(int bookmarkId) async {
    if (_activeTokens.containsKey(bookmarkId)) {
      return;
    }
    final CancelToken token = CancelToken();
    _activeTokens[bookmarkId] = token;

    try {
      Bookmark? bookmark = await _bookmarkRepo.getById(bookmarkId);
      if (bookmark == null || token.isCancelled) return; // deleted while we were preparing

      // Step 1: mark processing.
      try {
        bookmark = await _bookmarkRepo.save(
          bookmark.copyWith(scrapingStatus: BookmarkScrapingStatus.processing),
        );
      } catch (_) {
        return; // can't even mark — give up.
      }

      if (token.isCancelled) return;

      // Step 2: scrape. Contract says never-throws, but be defensive.
      MetadataResult result;
      try {
        result = await _scraper.scrape(
          bookmark.originalUrl,
          cancelToken: token,
        );
      } catch (_) {
        result = const MetadataResult();
      }

      if (token.isCancelled) return;

      // Step 3: merge into existing bookmark.
      // Re-read the bookmark so we don't overwrite changes made by
      // automation rules (or any other concurrent modifier) since we
      // started scraping.
      try {
        final Bookmark? fresh = await _bookmarkRepo.getById(bookmarkId);
        if (fresh == null || token.isCancelled) return; // deleted or cancelled while scraping

        // Mark final status based on primary scraper result before applying
        // URL-slug fallback metadata so retry semantics remain intact.
        final BookmarkScrapingStatus finalStatus = _isUseful(result)
            ? BookmarkScrapingStatus.done
            : BookmarkScrapingStatus.failed;

        MetadataResult effectiveResult = result;
        if (result.title == null || result.siteName == null) {
          final MetadataResult fallback =
              GenericHtmlParser.synthesizeFallbackMetadata(
            result.canonicalUrl ?? fresh.canonicalUrl ?? fresh.originalUrl,
          );
          effectiveResult = MetadataResult(
            title: result.title ?? fallback.title,
            description: result.description,
            snippet: result.snippet,
            author: result.author,
            siteName: result.siteName ?? fallback.siteName,
            publisher: result.publisher,
            publishDate: result.publishDate,
            languageCode: result.languageCode,
            heroImageUrl: result.heroImageUrl,
            faviconUrl: result.faviconUrl,
            canonicalUrl: result.canonicalUrl,
            readingTimeMinutes: result.readingTimeMinutes,
          );
        }

        final Bookmark stub = _stubFromMetadata(fresh, effectiveResult);
        final Bookmark merged = _merger.merge(fresh, stub);

        if (token.isCancelled) return;

        await _bookmarkRepo.save(
          merged.copyWith(scrapingStatus: finalStatus),
        );
      } catch (_) {
        if (token.isCancelled) return;
        // Mark failed but never throw out of this orchestrator.
        try {
          await _bookmarkRepo.save(
            bookmark.copyWith(scrapingStatus: BookmarkScrapingStatus.failed),
          );
        } catch (_) {
          // Database is in trouble — nothing more we can do.
        }
      }
    } finally {
      _activeTokens.remove(bookmarkId);
    }
  }

  @override
  Future<void> enrichIncomplete({int limit = 3}) async {
    if (_isEnrichingIncomplete) return;
    _isEnrichingIncomplete = true;
    try {
      final List<Bookmark> recent = await _bookmarkRepo.feed(
        const BookmarkFeedQuery(
          limit: 15,
        ),
      );
      final DateTime now = DateTime.now();
      final List<Bookmark> incomplete = recent.where((Bookmark b) {
        final int? id = b.id;
        if (id == null || _attemptedIncompleteIds.contains(id)) {
          return false;
        }
        if (now.difference(b.createdAt).inMinutes > 30) {
          return false;
        }
        if (b.scrapingStatus == BookmarkScrapingStatus.pending ||
            b.scrapingStatus == BookmarkScrapingStatus.processing) {
          return true;
        }
        final bool neverEnriched =
            (b.heroImageUrl == null || b.heroImageUrl!.isEmpty) &&
                (b.faviconUrl == null || b.faviconUrl!.isEmpty);
        return b.scrapingStatus == BookmarkScrapingStatus.failed &&
            neverEnriched;
      }).take(limit).toList();

      for (final Bookmark b in incomplete) {
        final int? id = b.id;
        if (id != null) {
          _attemptedIncompleteIds.add(id);
          await enrich(id);
        }
      }
    } catch (_) {
      // Incomplete enrichment is best-effort.
    } finally {
      _isEnrichingIncomplete = false;
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────

  /// Builds a transient [Bookmark] from a [MetadataResult] suitable
  /// for [UpsertMergeService.merge]. Only metadata-derived fields
  /// are populated; identity / flags come from the existing record.
  static Bookmark _stubFromMetadata(Bookmark existing, MetadataResult m) {
    return existing.copyWith(
      title: m.title,
      description: m.description,
      snippet: m.snippet,
      author: m.author,
      siteName: m.siteName,
      publisher: m.publisher,
      publishDate: m.publishDate,
      languageCode: m.languageCode,
      heroImageUrl: m.heroImageUrl ?? m.faviconUrl,
      faviconUrl: m.faviconUrl,
      canonicalUrl: m.canonicalUrl ?? existing.canonicalUrl,
      readingTimeMinutes: m.readingTimeMinutes,
    );
  }

  /// "Useful" means at least one of the user-visible fields
  /// (title, description, hero image) was successfully extracted.
  static bool _isUseful(MetadataResult m) =>
      m.title != null ||
      m.description != null ||
      m.heroImageUrl != null ||
      m.faviconUrl != null;
}
