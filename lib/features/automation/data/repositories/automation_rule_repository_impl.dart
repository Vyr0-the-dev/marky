import 'package:isar/isar.dart';

import 'package:marky/features/automation/domain/repositories/automation_rule_repository.dart';
import 'package:marky/shared/models/automation_rule.dart';

/// Isar-backed implementation of [AutomationRuleRepository].
///
/// Expects [isar] to be an open database instance that includes
/// [AutomationRuleSchema].
class AutomationRuleRepositoryImpl implements AutomationRuleRepository {
  AutomationRuleRepositoryImpl({required Isar isar}) : _isar = isar;

  final Isar _isar;

  // ─── BaseRepository<AutomationRule> ────────────────────────────────────

  @override
  Future<AutomationRule?> getById(Id id) async {
    return _isar.automationRules.get(id);
  }

  @override
  Future<List<AutomationRule>> getAll() async {
    return _isar.automationRules.where().findAll();
  }

  @override
  Future<Id> insert(AutomationRule entity) async {
    return _isar.writeTxn(() async {
      return _isar.automationRules.put(entity);
    });
  }

  @override
  Future<Id> update(AutomationRule entity) async {
    return _isar.writeTxn(() async {
      return _isar.automationRules.put(entity);
    });
  }

  @override
  Future<void> delete(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.automationRules.delete(id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.automationRules.clear();
    });
  }

  // ─── AutomationRuleRepository queries ──────────────────────────────────

  @override
  Future<List<AutomationRule>> getEnabled() async {
    return _isar.automationRules
        .where()
        .filter()
        .enabledEqualTo(true)
        .sortByPriority()
        .findAll();
  }

  @override
  Future<List<AutomationRule>> getByPriority() async {
    return _isar.automationRules.where().sortByPriority().findAll();
  }
}
