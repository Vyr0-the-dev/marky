import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/automation_rule_entity.dart';
import 'package:marky/features/automation/data/automation_rule_mapper.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';
import 'package:marky/features/automation/domain/automation_rule_repository.dart';

class IsarAutomationRuleRepository implements AutomationRuleRepository {
  IsarAutomationRuleRepository(this._isar);

  final Isar _isar;

  @override
  Future<AutomationRule> save(AutomationRule rule) async {
    if (rule.actions.isEmpty) {
      throw const AutomationRuleInvariantException(
        'Rule must have at least one action',
      );
    }
    final AutomationRule stamped = rule.copyWith(updatedAt: DateTime.now());
    final AutomationRuleEntity entity = AutomationRuleMapper.toEntity(stamped);
    final int id = await _isar.writeTxn<int>(() async {
      return _isar.automationRules.put(entity);
    });
    return stamped.copyWith(id: id);
  }

  @override
  Future<AutomationRule?> getById(int id) async {
    final AutomationRuleEntity? e = await _isar.automationRules.get(id);
    return e == null ? null : AutomationRuleMapper.toDomain(e);
  }

  @override
  Future<List<AutomationRule>> getAll() async {
    final List<AutomationRuleEntity> rows = await _isar.automationRules
        .where()
        .sortByPriority()
        .thenByCreatedAt()
        .findAll();
    return rows.map(AutomationRuleMapper.toDomain).toList(growable: false);
  }

  @override
  Future<List<AutomationRule>> getEnabled() async {
    final List<AutomationRuleEntity> rows = await _isar.automationRules
        .filter()
        .enabledEqualTo(true)
        .sortByPriority()
        .thenByCreatedAt()
        .findAll();
    return rows.map(AutomationRuleMapper.toDomain).toList(growable: false);
  }

  @override
  Future<bool> delete(int id) {
    return _isar.writeTxn<bool>(
      () async => _isar.automationRules.delete(id),
    );
  }

  @override
  Future<void> recordExecution(int ruleId) async {
    await _isar.writeTxn<void>(() async {
      final AutomationRuleEntity? e = await _isar.automationRules.get(ruleId);
      if (e == null) return;
      e.executionCount += 1;
      e.lastExecutedAt = DateTime.now();
      e.updatedAt = e.lastExecutedAt!;
      await _isar.automationRules.put(e);
    });
  }

  // ─── Streams ────────────────────────────────────────────────────

  @override
  Stream<List<AutomationRule>> watchAll() {
    final Query<AutomationRuleEntity> q = _isar.automationRules
        .where()
        .sortByPriority()
        .thenByCreatedAt()
        .build();
    return q.watch(fireImmediately: true).map(
          (List<AutomationRuleEntity> rows) =>
              rows.map(AutomationRuleMapper.toDomain).toList(growable: false),
        );
  }

  @override
  Stream<AutomationRule?> watchById(int id) {
    return _isar.automationRules.watchObject(id, fireImmediately: true).map(
          (AutomationRuleEntity? e) =>
              e == null ? null : AutomationRuleMapper.toDomain(e),
        );
  }
}
