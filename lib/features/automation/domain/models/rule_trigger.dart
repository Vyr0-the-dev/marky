/// Trigger types supported by the automation engine.
///
/// All triggers are evaluated against the bookmark's **initial** state
/// before any actions are applied (no cascading).
enum RuleTriggerType {
  /// Exact match on [BookmarkItem.sourceDomain] or [BookmarkItem.normalizedHost].
  domainEquals,

  /// Substring match on [BookmarkItem.sourceDomain] or [BookmarkItem.normalizedHost].
  domainContains,

  /// Exact match on [BookmarkItem.sourceType] ('manual', 'share_sheet', etc.).
  sourceTypeEquals,

  /// Substring match on [BookmarkItem.originalUrl].
  urlContains,

  /// Checks if [BookmarkItem.tagIds] contains the configured tag id.
  hasTag,

  /// Checks if [BookmarkItem.isRead] is `false`.
  isUnread,
}

/// Lightweight trigger configuration evaluated by [AutomationEngineService].
class RuleTrigger {
  const RuleTrigger({
    required this.triggerType,
    required this.config,
  });

  factory RuleTrigger.fromJson(Map<String, dynamic> json) {
    return RuleTrigger(
      triggerType: RuleTriggerType.values.byName(json['triggerType'] as String),
      config: (json['config'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
    );
  }

  final RuleTriggerType triggerType;

  /// Type-specific configuration map.
  ///
  /// Keys per type:
  /// - `domainEquals` / `domainContains` → `{'domain': 'youtube.com'}`
  /// - `sourceTypeEquals` → `{'sourceType': 'share_sheet'}`
  /// - `urlContains` → `{'pattern': 'github.com/flutter'}`
  /// - `hasTag` → `{'tagId': 42}` (or `{'tagSlug': 'flutter'}`)
  /// - `isUnread` → `{}`
  final Map<String, dynamic> config;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'triggerType': triggerType.name,
        'config': config,
      };
}
