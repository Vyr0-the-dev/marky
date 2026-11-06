import 'package:isar/isar.dart';

import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';

part 'automation_rule_entity.g.dart';

/// User-authored "when X capture happens, do Y" rule, evaluated by
/// the automation engine immediately after a bookmark is created
/// (Faz 9).
///
/// Schema philosophy:
/// - **Single trigger** per rule. Compound triggers (AND/OR) are a
///   classic over-engineering pitfall — instead users author multiple
///   rules and the engine runs them in priority order. Easier to
///   debug, easier to UI.
/// - **Parallel action lists** (`actionTypes` + `actionArgs`).
///   `actionTypes[i]` pairs with `actionArgs[i]`. Avoids needing a
///   separate `Action` collection at MVP scale; one row, one rule,
///   no joins. The trade-off is a tiny invariant the engine has to
///   guard ("the lists must be the same length"); we'll enforce that
///   in the repository's create/update path.
/// - **Trigger config is a single string**, not JSON. The four
///   trigger types in [AutomationTriggerType] all need exactly one
///   scalar argument — encoding it as JSON would just add parse cost.
@Collection(accessor: 'automationRules')
class AutomationRuleEntity {
  AutomationRuleEntity({
    required this.name,
    this.description,
    this.enabled = true,
    required this.triggerType,
    required this.triggerValue,
    this.actionTypes = const <AutomationActionType>[],
    this.actionArgs = const <String>[],
    this.priority = 100,
    this.executionCount = 0,
    this.lastExecutedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Id id = Isar.autoIncrement;

  String name;

  /// Optional explanation shown in the rule list. The engine never
  /// reads it.
  String? description;

  /// When false, the engine skips this rule entirely.
  bool enabled;

  @Enumerated(EnumType.name)
  AutomationTriggerType triggerType;

  /// Scalar argument paired with [triggerType]:
  /// - `domainEquals` / `domainContains` → host substring.
  /// - `urlContains` → URL substring.
  /// - `sourceTypeEquals` → `BookmarkSourceType.name` value.
  String triggerValue;

  /// What this rule does on a match. Same length as [actionArgs].
  /// Decoding is per-action-type (see [AutomationActionType] doc).
  @Enumerated(EnumType.name)
  List<AutomationActionType> actionTypes;

  /// Per-action scalar argument. Indexed positionally with
  /// [actionTypes].
  List<String> actionArgs;

  /// Lower runs first. Defaults to 100 so user-created rules can be
  /// shoved before or after the default cohort without renumbering.
  int priority;

  /// Cumulative count of how many bookmarks this rule has matched.
  /// Used by the dashboard to surface dormant rules ("This rule
  /// hasn't fired in 30 days — disable?").
  int executionCount;

  DateTime? lastExecutedAt;

  DateTime createdAt;
  DateTime updatedAt;
}
