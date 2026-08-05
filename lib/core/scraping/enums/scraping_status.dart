/// Lifecycle states for the metadata scraping process.
///
/// Each bookmark item transitions through these states as its metadata
/// is fetched and parsed from the source URL.
enum ScrapingStatus {
  /// Initial state — scraping has been requested but not yet started.
  pending,

  /// Scraper is actively fetching / parsing the URL.
  processing,

  /// Metadata successfully extracted and persisted.
  done,

  /// Scraper encountered an unrecoverable error (network, parse, timeout).
  failed,
}
