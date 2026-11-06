import 'dart:convert';

import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/automation_rule_entity.dart';
import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';

abstract final class AutomationRuleMapper {
  static const String _compoundTriggerPrefix = 'marky.conditions.v1:';

  static AutomationRule toDomain(AutomationRuleEntity e) {
    // Defensive: if the parallel lists ever drift in length (e.g.
    // a corrupted import), pair only the in-range slots so we don't
    // throw at read time. The repository's invariant check on save
    // prevents this from being introduced via the app itself.
    final int n = e.actionTypes.length < e.actionArgs.length
        ? e.actionTypes.length
        : e.actionArgs.length;
    final List<AutomationAction> actions = <AutomationAction>[
      for (int i = 0; i < n; i++)
        AutomationAction(type: e.actionTypes[i], arg: e.actionArgs[i]),
    ];
    final _DecodedTrigger decoded =
        _decodeTrigger(e.triggerType, e.triggerValue);
    final AutomationCondition primary = decoded.conditions.first;

    return AutomationRule(
      id: e.id == Isar.autoIncrement ? null : e.id,
      name: e.name,
      description: e.description,
      enabled: e.enabled,
      triggerType: primary.type,
      triggerValue: primary.value,
      triggerLogic: decoded.logic,
      conditions: decoded.conditions,
      actions: actions,
      priority: e.priority,
      executionCount: e.executionCount,
      lastExecutedAt: e.lastExecutedAt,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  static AutomationRuleEntity toEntity(AutomationRule r) {
    final List<AutomationActionType> types = <AutomationActionType>[
      for (final AutomationAction a in r.actions) a.type,
    ];
    final List<String> args = <String>[
      for (final AutomationAction a in r.actions) a.arg,
    ];

    final AutomationRuleEntity entity = AutomationRuleEntity(
      name: r.name,
      description: r.description,
      enabled: r.enabled,
      triggerType: r.conditions.first.type,
      triggerValue: _encodeTriggerValue(r),
      actionTypes: types,
      actionArgs: args,
      priority: r.priority,
      executionCount: r.executionCount,
      lastExecutedAt: r.lastExecutedAt,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
    if (r.id != null) entity.id = r.id!;
    return entity;
  }

  static String _encodeTriggerValue(AutomationRule rule) {
    if (rule.triggerLogic == AutomationTriggerLogic.all &&
        rule.conditions.length == 1) {
      return rule.conditions.first.value;
    }
    return '$_compoundTriggerPrefix${jsonEncode(<String, Object>{
          'logic': rule.triggerLogic.name,
          'conditions': <Map<String, String>>[
            for (final AutomationCondition condition in rule.conditions)
              <String, String>{
                'type': condition.type.name,
                'value': condition.value,
              },
          ],
        })}';
  }

  static _DecodedTrigger _decodeTrigger(
    AutomationTriggerType fallbackType,
    String value,
  ) {
    if (!value.startsWith(_compoundTriggerPrefix)) {
      return _DecodedTrigger(
        logic: AutomationTriggerLogic.all,
        conditions: <AutomationCondition>[
          AutomationCondition(type: fallbackType, value: value),
        ],
      );
    }
    try {
      final Object? decoded = jsonDecode(
        value.substring(_compoundTriggerPrefix.length),
      );
      if (decoded is! Map<String, Object?>) {
        throw const FormatException();
      }
      final AutomationTriggerLogic logic =
          decoded['logic'] == AutomationTriggerLogic.any.name
              ? AutomationTriggerLogic.any
              : AutomationTriggerLogic.all;
      final Object? rawConditions = decoded['conditions'];
      final List<AutomationCondition> conditions = <AutomationCondition>[
        if (rawConditions is List<Object?>)
          for (final Object? rawCondition in rawConditions)
            if (rawCondition is Map<String, Object?>)
              AutomationCondition(
                type: _triggerTypeByName(rawCondition['type']) ?? fallbackType,
                value: rawCondition['value']?.toString() ?? '',
              ),
      ].where((AutomationCondition condition) {
        return condition.value.trim().isNotEmpty;
      }).toList(growable: false);
      if (conditions.isEmpty) throw const FormatException();
      return _DecodedTrigger(logic: logic, conditions: conditions);
    } on Object {
      return _DecodedTrigger(
        logic: AutomationTriggerLogic.all,
        conditions: <AutomationCondition>[
          AutomationCondition(type: fallbackType, value: value),
        ],
      );
    }
  }

  static AutomationTriggerType? _triggerTypeByName(Object? name) {
    if (name is! String) return null;
    for (final AutomationTriggerType type in AutomationTriggerType.values) {
      if (type.name == name) return type;
    }
    return null;
  }
}

class _DecodedTrigger {
  const _DecodedTrigger({
    required this.logic,
    required this.conditions,
  });

  final AutomationTriggerLogic logic;
  final List<AutomationCondition> conditions;
}
