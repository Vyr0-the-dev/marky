/// Background metadata enrichment for a freshly-captured bookmark.
///
/// The capture pipeline saves the bookmark immediately so the user
/// gets instant feedback, then fires this orchestrator off to
/// fetch and merge metadata asynchronously.  The bookmark stream
/// updates reactively when scraping completes.
///
/// Implementations must:
/// - mark scrapingStatus → processing on start,
/// - mark scrapingStatus → done on success,
/// - mark scrapingStatus → failed on any unrecoverable error,
/// - never throw (errors are surfaced via scrapingStatus).
abstract interface class ScrapingOrchestrator {
  /// Enriches the bookmark identified by [bookmarkId] with scraped
  /// metadata. Safe to fire-and-forget — never throws.
  Future<void> enrich(int bookmarkId);
}
