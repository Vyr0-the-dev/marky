/// Types of conditions that can be evaluated against a bookmark.
enum SmartTagRuleConditionType {
  domainContains,
  urlContains,
  titleContains,
  keywordContains,
  categoryEquals,
}

/// A single condition within a [SmartTagRule].
///
/// The [config] map holds type-specific parameters. For example:
/// - `domainContains`: `{ 'value': 'github.com' }`
/// - `titleContains`: `{ 'value': 'flutter' }`
class SmartTagRuleCondition {
  const SmartTagRuleCondition({
    required this.conditionType,
    required this.config,
  });

  factory SmartTagRuleCondition.fromJson(Map<String, dynamic> json) {
    return SmartTagRuleCondition(
      conditionType: SmartTagRuleConditionType.values.byName(
        json['conditionType'] as String,
      ),
      config: (json['config'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );
  }

  final SmartTagRuleConditionType conditionType;
  final Map<String, dynamic> config;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'conditionType': conditionType.name,
        'config': config,
      };

  @override
  String toString() =>
      'SmartTagRuleCondition(${conditionType.name}, $config)';
}

/// A rule that auto-assigns a tag to bookmarks when all/any conditions match.
///
/// Rules are stored as JSON in [Tag.ruleJson] and parsed at evaluation time.
/// The [version] field allows forward-compatible evolution of the rule format.
class SmartTagRule {
  const SmartTagRule({
    required this.tagId,
    required this.conditions,
    this.matchOperator = 'all',
    this.version = 1,
  });

  factory SmartTagRule.fromJson(Map<String, dynamic> json) {
    return SmartTagRule(
      tagId: json['tagId'] as int,
      conditions: (json['conditions'] as List<dynamic>)
          .map(
            (c) => SmartTagRuleCondition.fromJson(c as Map<String, dynamic>),
          )
          .toList(),
      matchOperator: (json['matchOperator'] as String?) ?? 'all',
      version: (json['version'] as int?) ?? 1,
    );
  }

  final int tagId;
  final List<SmartTagRuleCondition> conditions;
  final String matchOperator;
  final int version;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tagId': tagId,
        'conditions': conditions.map((c) => c.toJson()).toList(),
        'matchOperator': matchOperator,
        'version': version,
      };

  @override
  String toString() =>
      'SmartTagRule(tagId: $tagId, operator: $matchOperator, '
      '${conditions.length} conditions, v$version)';
}
