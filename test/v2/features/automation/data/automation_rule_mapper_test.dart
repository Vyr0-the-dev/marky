import 'package:flutter_test/flutter_test.dart';

import 'package:marky/core/database/entities/automation_rule_entity.dart';
import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';
import 'package:marky/features/automation/data/automation_rule_mapper.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';

void main() {
  final DateTime testDate = DateTime(2026, 3, 14, 12);

  group('AutomationRuleMapper', () {
    test('round-trips single condition with contentTypeEquals', () {
      final AutomationRule rule = AutomationRule(
        id: 42,
        name: 'Auto-tag Videos',
        description: 'Tag all video bookmarks',
        triggerType: AutomationTriggerType.contentTypeEquals,
        triggerValue: 'video',
        actions: const <AutomationAction>[
          AutomationAction(type: AutomationActionType.addTag, arg: 'video-tag'),
        ],
        priority: 50,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final AutomationRuleEntity entity = AutomationRuleMapper.toEntity(rule);
      expect(entity.id, 42);
      expect(entity.name, 'Auto-tag Videos');
      expect(entity.triggerType, AutomationTriggerType.contentTypeEquals);
      expect(entity.triggerValue, 'video');
      expect(entity.actionTypes, <AutomationActionType>[
        AutomationActionType.addTag,
      ]);
      expect(entity.actionArgs, <String>['video-tag']);

      final AutomationRule restored = AutomationRuleMapper.toDomain(entity);
      expect(restored.id, rule.id);
      expect(restored.name, rule.name);
      expect(restored.triggerType, AutomationTriggerType.contentTypeEquals);
      expect(restored.triggerValue, 'video');
      expect(restored.conditions, rule.conditions);
      expect(restored.actions, rule.actions);
    });

    test('round-trips single condition with readingTimeGreaterThan', () {
      final AutomationRule rule = AutomationRule(
        id: 99,
        name: 'Long Read',
        triggerType: AutomationTriggerType.readingTimeGreaterThan,
        triggerValue: '15',
        actions: const <AutomationAction>[
          AutomationAction(type: AutomationActionType.setPinned, arg: 'true'),
        ],
        createdAt: testDate,
        updatedAt: testDate,
      );

      final AutomationRuleEntity entity = AutomationRuleMapper.toEntity(rule);
      expect(entity.triggerType, AutomationTriggerType.readingTimeGreaterThan);
      expect(entity.triggerValue, '15');

      final AutomationRule restored = AutomationRuleMapper.toDomain(entity);
      expect(restored.triggerType, AutomationTriggerType.readingTimeGreaterThan);
      expect(restored.triggerValue, '15');
      expect(restored.actions, rule.actions);
    });

    test('round-trips compound conditions with new triggers and any logic', () {
      final AutomationRule rule = AutomationRule(
        id: 101,
        name: 'Media or Long Read',
        triggerType: AutomationTriggerType.contentTypeEquals,
        triggerValue: 'video',
        triggerLogic: AutomationTriggerLogic.any,
        conditions: const <AutomationCondition>[
          AutomationCondition(
            type: AutomationTriggerType.contentTypeEquals,
            value: 'video',
          ),
          AutomationCondition(
            type: AutomationTriggerType.readingTimeGreaterThan,
            value: '20',
          ),
        ],
        actions: const <AutomationAction>[
          AutomationAction(type: AutomationActionType.setFavorite, arg: 'true'),
        ],
        createdAt: testDate,
        updatedAt: testDate,
      );

      final AutomationRuleEntity entity = AutomationRuleMapper.toEntity(rule);
      expect(entity.triggerType, AutomationTriggerType.contentTypeEquals);
      expect(entity.triggerValue.startsWith('marky.conditions.v1:'), isTrue);

      final AutomationRule restored = AutomationRuleMapper.toDomain(entity);
      expect(restored.triggerLogic, AutomationTriggerLogic.any);
      expect(restored.conditions, hasLength(2));
      expect(
        restored.conditions[0].type,
        AutomationTriggerType.contentTypeEquals,
      );
      expect(restored.conditions[0].value, 'video');
      expect(
        restored.conditions[1].type,
        AutomationTriggerType.readingTimeGreaterThan,
      );
      expect(restored.conditions[1].value, '20');
      expect(restored.actions, rule.actions);
    });
  });
}
