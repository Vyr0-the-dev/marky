import 'package:flutter/foundation.dart';

import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';

/// A single (type, arg) pair that pairs up positionally inside an
/// [AutomationRule]. Modelling the action this way keeps the domain
/// clean even though the entity stores `actionTypes` and `actionArgs`
/// as parallel lists.
@immutable
class AutomationAction {
  const AutomationAction({required this.type, required this.arg});

  final AutomationActionType type;

  /// Per-type encoding:
  /// - `addTag` / `addToCollection` → `int.parse(arg)` is the id.
  /// - `setFavorite` / `setArchived` / `setPinned` → `arg == 'true'`.
  ///
  /// Validation lives in the use case that constructs the rule;
  /// the repository trusts the values it's handed.
  final String arg;

  AutomationAction copyWith({
    AutomationActionType? type,
    String? arg,
  }) {
    return AutomationAction(type: type ?? this.type, arg: arg ?? this.arg);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationAction && other.type == type && other.arg == arg;
  }

  @override
  int get hashCode => Object.hash(type, arg);

  @override
  String toString() => 'AutomationAction($type → $arg)';
}

enum AutomationTriggerLogic { all, any }

@immutable
class AutomationCondition {
  const AutomationCondition({required this.type, required this.value});

  final AutomationTriggerType type;
  final String value;

  AutomationCondition copyWith({
    AutomationTriggerType? type,
    String? value,
  }) {
    return AutomationCondition(
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationCondition &&
        other.type == type &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(type, value);

  @override
  String toString() => 'AutomationCondition($type → $value)';
}

/// Immutable domain model for an automation rule.
///
/// The entity stores `actionTypes` + `actionArgs` as parallel lists
/// for Isar-friendliness. The domain model recombines those into a
/// `List<AutomationAction>` so feature code can iterate without
/// worrying about list-length parity. The mapper is the only file
/// that has to think about that invariant.
@immutable
class AutomationRule {
  AutomationRule({
    this.id,
    required this.name,
    this.description,
    this.enabled = true,
    required this.triggerType,
    required this.triggerValue,
    this.triggerLogic = AutomationTriggerLogic.all,
    List<AutomationCondition>? conditions,
    this.actions = const <AutomationAction>[],
    this.priority = 100,
    this.executionCount = 0,
    this.lastExecutedAt,
    required this.createdAt,
    required this.updatedAt,
  }) : conditions = conditions == null || conditions.isEmpty
            ? <AutomationCondition>[
                AutomationCondition(type: triggerType, value: triggerValue),
              ]
            : conditions;

  final int? id;
  final String name;
  final String? description;
  final bool enabled;
  final AutomationTriggerType triggerType;
  final String triggerValue;
  final AutomationTriggerLogic triggerLogic;
  final List<AutomationCondition> conditions;
  final List<AutomationAction> actions;
  final int priority;
  final int executionCount;
  final DateTime? lastExecutedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AutomationRule copyWith({
    int? id,
    String? name,
    String? description,
    bool? enabled,
    AutomationTriggerType? triggerType,
    String? triggerValue,
    AutomationTriggerLogic? triggerLogic,
    List<AutomationCondition>? conditions,
    List<AutomationAction>? actions,
    int? priority,
    int? executionCount,
    DateTime? lastExecutedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final bool primaryChanged = triggerType != null || triggerValue != null;
    final List<AutomationCondition> resolvedConditions = conditions ??
        (primaryChanged
            ? <AutomationCondition>[
                AutomationCondition(
                  type: triggerType ?? this.triggerType,
                  value: triggerValue ?? this.triggerValue,
                ),
              ]
            : this.conditions);
    final AutomationCondition primaryCondition = resolvedConditions.isEmpty
        ? AutomationCondition(
            type: triggerType ?? this.triggerType,
            value: triggerValue ?? this.triggerValue,
          )
        : resolvedConditions.first;
    return AutomationRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      triggerType: triggerType ?? primaryCondition.type,
      triggerValue: triggerValue ?? primaryCondition.value,
      triggerLogic: triggerLogic ?? this.triggerLogic,
      conditions: resolvedConditions,
      actions: actions ?? this.actions,
      priority: priority ?? this.priority,
      executionCount: executionCount ?? this.executionCount,
      lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationRule &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.enabled == enabled &&
        other.triggerType == triggerType &&
        other.triggerValue == triggerValue &&
        other.triggerLogic == triggerLogic &&
        listEquals(other.conditions, conditions) &&
        listEquals(other.actions, actions) &&
        other.priority == priority &&
        other.executionCount == executionCount &&
        other.lastExecutedAt == lastExecutedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        enabled,
        triggerType,
        triggerValue,
        triggerLogic,
        Object.hashAll(conditions),
        Object.hashAll(actions),
        priority,
        executionCount,
        lastExecutedAt,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'AutomationRule(id: $id, name: $name, enabled: $enabled, '
      'trigger: $triggerLogic ${conditions.length}, actions: ${actions.length})';
}
