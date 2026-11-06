import 'package:marky/features/automation/domain/automation_rule.dart';

abstract interface class AutomationRuleRepository {
  /// Inserts/updates [rule]. Stamps `updatedAt`. Validates that the
  /// rule has at least one [AutomationAction] — empty rules don't
  /// make sense in the UI and shouldn't slip through here.
  Future<AutomationRule> save(AutomationRule rule);

  Future<AutomationRule?> getById(int id);

  /// All rules, ordered by [AutomationRule.priority] ascending and
  /// then `createdAt` ascending (so older rules at the same priority
  /// run first). Default sort for the rules screen.
  Future<List<AutomationRule>> getAll();

  /// Same order as [getAll] but filtered to enabled == true. Used by
  /// the automation engine on every capture.
  Future<List<AutomationRule>> getEnabled();

  Future<bool> delete(int id);

  /// Records that this rule fired against a captured bookmark.
  /// Increments [AutomationRule.executionCount] and stamps
  /// [AutomationRule.lastExecutedAt]. Done in a single Isar
  /// transaction so concurrent captures don't lose updates.
  Future<void> recordExecution(int ruleId);

  Stream<List<AutomationRule>> watchAll();
  Stream<AutomationRule?> watchById(int id);
}

/// Thrown by [AutomationRuleRepository.save] when invariants are
/// violated. Currently the only invariant is "at least one action";
/// future invariants (cyclic action chains, etc.) can extend this
/// without changing the call sites.
class AutomationRuleInvariantException implements Exception {
  const AutomationRuleInvariantException(this.reason);
  final String reason;

  @override
  String toString() => 'AutomationRuleInvariantException: $reason';
}
