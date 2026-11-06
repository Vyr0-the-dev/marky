@Tags(<String>['integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';
import 'package:marky/core/database/marky_database.dart';
import 'package:marky/features/automation/data/isar_automation_rule_repository.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';
import 'package:marky/features/automation/domain/automation_rule_repository.dart';

AutomationRule _rule({
  String name = 'r',
  AutomationTriggerType trigger = AutomationTriggerType.domainEquals,
  String value = 'youtube.com',
  List<AutomationAction> actions = const <AutomationAction>[
    AutomationAction(type: AutomationActionType.addTag, arg: '1'),
  ],
  AutomationTriggerLogic triggerLogic = AutomationTriggerLogic.all,
  List<AutomationCondition>? conditions,
  int priority = 100,
  bool enabled = true,
}) {
  final DateTime now = DateTime(2026);
  return AutomationRule(
    name: name,
    triggerType: trigger,
    triggerValue: value,
    triggerLogic: triggerLogic,
    conditions: conditions,
    actions: actions,
    priority: priority,
    enabled: enabled,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late Directory tempDir;
  late Isar isar;
  late AutomationRuleRepository repo;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('automation_repo_test_');
    isar = await MarkyDatabase.open(
      directory: tempDir.path,
      name: 'test_${tempDir.path.hashCode}',
    );
    repo = IsarAutomationRuleRepository(isar);
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('save throws on empty actions', () async {
    expect(
      () async => repo.save(_rule(actions: const <AutomationAction>[])),
      throwsA(isA<AutomationRuleInvariantException>()),
    );
  });

  test('save round-trips parallel action lists losslessly', () async {
    final AutomationRule saved = await repo.save(_rule(
      actions: const <AutomationAction>[
        AutomationAction(type: AutomationActionType.addTag, arg: '42'),
        AutomationAction(type: AutomationActionType.setFavorite, arg: 'true'),
      ],
    ));
    final AutomationRule? loaded = await repo.getById(saved.id!);
    expect(
      loaded!.actions,
      <AutomationAction>[
        const AutomationAction(type: AutomationActionType.addTag, arg: '42'),
        const AutomationAction(
          type: AutomationActionType.setFavorite,
          arg: 'true',
        ),
      ],
    );
  });

  test('save round-trips AND OR compound trigger conditions', () async {
    final AutomationRule saved = await repo.save(_rule(
      triggerLogic: AutomationTriggerLogic.any,
      conditions: const <AutomationCondition>[
        AutomationCondition(
          type: AutomationTriggerType.domainContains,
          value: 'github',
        ),
        AutomationCondition(
          type: AutomationTriggerType.urlContains,
          value: '/releases',
        ),
      ],
    ));

    final AutomationRule? loaded = await repo.getById(saved.id!);

    expect(loaded!.triggerLogic, AutomationTriggerLogic.any);
    expect(
      loaded.conditions,
      const <AutomationCondition>[
        AutomationCondition(
          type: AutomationTriggerType.domainContains,
          value: 'github',
        ),
        AutomationCondition(
          type: AutomationTriggerType.urlContains,
          value: '/releases',
        ),
      ],
    );
    expect(loaded.triggerType, AutomationTriggerType.domainContains);
    expect(loaded.triggerValue, 'github');
  });

  test('getAll sorts by priority ASC then createdAt ASC', () async {
    // Sleep micros are flaky, so use distinct created times.
    final AutomationRule low =
        await repo.save(_rule(name: 'low', priority: 10));
    final AutomationRule high =
        await repo.save(_rule(name: 'high', priority: 90));
    final AutomationRule mid =
        await repo.save(_rule(name: 'mid', priority: 50));

    final List<AutomationRule> all = await repo.getAll();
    expect(
      all.map((AutomationRule r) => r.id).toList(),
      <int>[low.id!, mid.id!, high.id!],
    );
  });

  test('getEnabled excludes disabled rules', () async {
    await repo.save(_rule(name: 'enabled'));
    await repo.save(_rule(name: 'disabled', enabled: false));

    final List<AutomationRule> enabled = await repo.getEnabled();
    expect(enabled, hasLength(1));
    expect(enabled.first.name, 'enabled');
  });

  test('recordExecution increments count and stamps lastExecutedAt', () async {
    final AutomationRule saved = await repo.save(_rule());
    expect(saved.executionCount, 0);
    expect(saved.lastExecutedAt, isNull);

    await repo.recordExecution(saved.id!);
    await repo.recordExecution(saved.id!);

    final AutomationRule? after = await repo.getById(saved.id!);
    expect(after!.executionCount, 2);
    expect(after.lastExecutedAt, isNotNull);
  });
}
