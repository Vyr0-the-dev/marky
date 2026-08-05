import 'package:isar/isar.dart';

part 'automation_rule.g.dart';

/// An automation rule that triggers on bookmark properties and executes
/// actions at capture time.
///
/// [triggerType] and [triggerConfig] describe when the rule fires.
/// [actions] is a JSON-encoded list of actions to execute.
@collection
class AutomationRule {
  AutomationRule({
    required this.name,
    this.description,
    this.enabled = true,
    required this.triggerType,
    required this.triggerConfig,
    required this.actions,
    this.priority = 0,
    this.executionCount = 0,
    this.lastExecutedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Auto-increment primary key.
  Id id = Isar.autoIncrement;

  /// Display name of the rule.
  String name;

  /// Optional description explaining what the rule does.
  String? description;

  /// Whether the rule is currently active.
  bool enabled;

  /// Trigger discriminator (e.g. 'domain', 'source_type', 'url_pattern').
  String triggerType;

  /// JSON-encoded trigger configuration.
  String triggerConfig;

  /// JSON-encoded list of actions to execute.
  String actions;

  /// Evaluation priority — lower numbers run first.
  int priority;

  /// How many times the rule has been evaluated.
  int executionCount;

  /// When the rule was last evaluated.
  DateTime? lastExecutedAt;

  /// When the rule was created.
  DateTime createdAt;

  /// When the rule was last modified.
  DateTime updatedAt;
}
