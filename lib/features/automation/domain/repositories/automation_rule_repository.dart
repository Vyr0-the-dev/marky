import 'package:marky/core/database/base_repository.dart';
import 'package:marky/shared/models/automation_rule.dart';

/// Domain contract for [AutomationRule] persistence and querying.
///
/// Implementations provide CRUD via [BaseRepository] plus rule-specific
/// lookups for enabled rules and priority ordering.
abstract class AutomationRuleRepository implements BaseRepository<AutomationRule> {
  /// Returns all enabled rules ordered by [AutomationRule.priority] ascending.
  Future<List<AutomationRule>> getEnabled();

  /// Returns all rules ordered by [AutomationRule.priority] ascending.
  Future<List<AutomationRule>> getByPriority();
}
