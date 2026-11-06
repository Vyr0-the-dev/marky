import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/metadata_scraper.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';
import 'package:marky/features/capture/domain/upsert_merge_service.dart';

/// Default implementation of [ScrapingOrchestrator].
///
/// Pipeline:
/// 1. Load bookmark by id.
/// 2. Mark scrapingStatus → processing, persist.
/// 3. Run [MetadataScraperService.scrape] on the original URL.
/// 4. Convert [MetadataResult] into a stub [Bookmark] for merging.
/// 5. Call [UpsertMergeService.merge] to fill gaps.
/// 6. Mark scrapingStatus → done (or failed) and persist.
class DefaultScrapingOrchestrator implements ScrapingOrchestrator {
  const DefaultScrapingOrchestrator({
    required BookmarkRepository bookmarkRepo,
    required MetadataScraper scraper,
    required UpsertMergeService merger,
  })  : _bookmarkRepo = bookmarkRepo,
        _scraper = scraper,
        _merger = merger;

  final BookmarkRepository _bookmarkRepo;
  final MetadataScraper _scraper;
  final UpsertMergeService _merger;

  @override
  Future<void> enrich(int bookmarkId) async {
    Bookmark? bookmark = await _bookmarkRepo.getById(bookmarkId);
    if (bookmark == null) return; // deleted while we were preparing

    // Step 1: mark processing.
    try {
      bookmark = await _bookmarkRepo.save(
        bookmark.copyWith(scrapingStatus: BookmarkScrapingStatus.processing),
      );
    } catch (_) {
      return; // can't even mark — give up.
    }

    // Step 2: scrape. Contract says never-throws, but be defensive.
    MetadataResult result;
    try {
      result = await _scraper.scrape(bookmark.originalUrl);
    } catch (_) {
      result = const MetadataResult();
    }

    // Step 3: merge into existing bookmark.
    // Re-read the bookmark so we don't overwrite changes made by
    // automation rules (or any other concurrent modifier) since we
    // started scraping.
    try {
      final Bookmark? fresh = await _bookmarkRepo.getById(bookmarkId);
      if (fresh == null) return; // deleted while scraping
      final Bookmark stub = _stubFromMetadata(fresh, result);
      final Bookmark merged = _merger.merge(fresh, stub);

      // Mark final status. If the scrape produced nothing useful
      // (no title, no description, no image), surface as failed so
      // the UI can show a fallback.
      final BookmarkScrapingStatus finalStatus = _isUseful(result)
          ? BookmarkScrapingStatus.done
          : BookmarkScrapingStatus.failed;

      await _bookmarkRepo.save(
        merged.copyWith(scrapingStatus: finalStatus),
      );
    } catch (_) {
      // Mark failed but never throw out of this orchestrator.
      try {
        await _bookmarkRepo.save(
          bookmark.copyWith(scrapingStatus: BookmarkScrapingStatus.failed),
        );
      } catch (_) {
        // Database is in trouble — nothing more we can do.
      }
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────

  /// Builds a transient [Bookmark] from a [MetadataResult] suitable
  /// for [UpsertMergeService.merge].  Only metadata-derived fields
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
