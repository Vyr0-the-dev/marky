/// What condition fires an [AutomationRuleEntity].
///
/// Kept deliberately narrow for the MVP — four trigger shapes cover
/// 90% of the "auto-tag things from YouTube" / "send tweets to
/// archive" workflows users expect. Richer predicates (regex, AND/OR
/// composition) are a post-MVP enhancement.
enum AutomationTriggerType {
  /// Fires when the normalized host equals [triggerValue]
  /// (e.g. `youtube.com`).
  domainEquals,

  /// Fires when the normalized host contains [triggerValue]
  /// as a substring (e.g. `github` matches `github.com` +
  /// `raw.githubusercontent.com`).
  domainContains,

  /// Fires when the full URL contains [triggerValue] as a substring.
  /// Case-insensitive. Used for capturing tracked UTM campaigns or
  /// query-string markers.
  urlContains,

  /// Fires when the capture's [BookmarkSourceType.name] equals
  /// [triggerValue] — e.g. tag everything that came from the share
  /// sheet with "inbox".
  sourceTypeEquals,
  tagContains,
  unreadForDays,
  addedWithinDays,

  /// Fires when bookmark content type matches [triggerValue]
  /// (e.g. `video`, `article`, `image`, `audio`, `tweet`, `repository`).
  contentTypeEquals,

  /// Fires when estimated reading time in minutes is strictly greater than
  /// [triggerValue].
  readingTimeGreaterThan,

  /// Fires when the bookmark title contains [triggerValue] as a substring.
  /// Case-insensitive.
  titleContains,

  /// Fires when the bookmark title matches the regular expression pattern
  /// in [triggerValue]. Case-insensitive, safely ignoring invalid syntax.
  titleMatchesRegex,
}
