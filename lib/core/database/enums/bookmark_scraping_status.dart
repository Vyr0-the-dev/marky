/// State machine for the background scrape that enriches a freshly
/// captured bookmark with title / description / hero image / favicon.
///
/// UI uses this to decide whether to show a skeleton, a partial card,
/// or a full-fidelity card.
enum BookmarkScrapingStatus {
  /// Queued but not yet dispatched to a parser.
  pending,

  /// A parser is actively fetching / parsing.
  processing,

  /// Finished successfully — metadata is populated.
  done,

  /// Tried, gave up; `title` may still hold a fallback (domain) but
  /// hero image / description may be missing. The UI should fall back
  /// to a mono "unable to fetch preview" treatment.
  failed,
}
