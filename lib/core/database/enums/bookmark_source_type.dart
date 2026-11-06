/// Where a bookmark came from — useful for analytics, automation
/// rules ("when source = share, add tag X"), and UI badges.
enum BookmarkSourceType {
  /// User typed/pasted a URL in the Add screen.
  manual,

  /// OS share sheet forwarded a URL to Marky.
  share,

  /// Clipboard monitor detected a URL and the user tapped "Review".
  clipboard,

  /// Imported from a file (HTML bookmarks export, CSV, JSON).
  import,

  /// Created by an automation rule (e.g. re-save of a failed scrape).
  automation,
}
