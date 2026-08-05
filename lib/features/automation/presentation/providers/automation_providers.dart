import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/features/automation/domain/models/rule_action.dart';
import 'package:marky/features/automation/domain/models/rule_trigger.dart';
import 'package:marky/features/automation/domain/repositories/automation_rule_repository.dart';
import 'package:marky/features/automation/domain/services/automation_engine_service.dart';
import 'package:marky/shared/models/automation_rule.dart';

// ─── Simple providers ──────────────────────────────────────────────────

/// Provider for [AutomationEngineService], wired to live repositories.
final Provider<AutomationEngineService> automationEngineServiceProvider =
    Provider<AutomationEngineService>((Ref ref) {
  return AutomationEngineService(
    ruleRepository: ref.watch(automationRuleRepositoryProvider),
    bookmarkRepository: ref.watch(bookmarkRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    collectionRepository: ref.watch(collectionRepositoryProvider),
    reminderRepository: ref.watch(reminderRepositoryProvider),
  );
});

/// Loads all automation rules ordered by priority.
final FutureProvider<List<AutomationRule>> automationRuleListProvider =
    FutureProvider<List<AutomationRule>>((Ref ref) async {
  final AutomationRuleRepository repository =
      ref.watch(automationRuleRepositoryProvider);
  return repository.getByPriority();
});

// ─── State notifier ────────────────────────────────────────────────────

/// Notifier that manages the automation rule list with CRUD operations.
class AutomationRuleNotifier
    extends StateNotifier<AsyncValue<List<AutomationRule>>> {
  /// Creates the notifier and immediately loads the rule list.
  AutomationRuleNotifier({required AutomationRuleRepository repository})
      : _repository = repository,
        super(const AsyncValue<List<AutomationRule>>.loading()) {
    unawaited(load());
  }

  final AutomationRuleRepository _repository;
  final Logger _logger = Logger();

  /// Reloads the full rule list from the repository.
  Future<void> load() async {
    state = const AsyncValue<List<AutomationRule>>.loading();
    try {
      final List<AutomationRule> rules = await _repository.getByPriority();
      state = AsyncValue<List<AutomationRule>>.data(rules);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to load automation rules',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<List<AutomationRule>>.error(e, stackTrace);
    }
  }

  /// Creates a new automation rule and refreshes the list.
  Future<void> create({
    required String name,
    String? description,
    required RuleTriggerType triggerType,
    required Map<String, dynamic> triggerConfig,
    required List<RuleAction> actions,
    int priority = 0,
  }) async {
    try {
      final DateTime now = DateTime.now();
      final AutomationRule rule = AutomationRule(
        name: name,
        description: description,
        triggerType: triggerType.name,
        triggerConfig: jsonEncode(
          RuleTrigger(triggerType: triggerType, config: triggerConfig).toJson(),
        ),
        actions: jsonEncode(actions.map((RuleAction a) => a.toJson()).toList()),
        priority: priority,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.insert(rule);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to create automation rule',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<List<AutomationRule>>.error(e, stackTrace);
    }
  }

  /// Updates an existing automation rule and refreshes the list.
  Future<void> update(AutomationRule rule) async {
    try {
      rule.updatedAt = DateTime.now();
      await _repository.update(rule);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to update automation rule',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<List<AutomationRule>>.error(e, stackTrace);
    }
  }

  /// Deletes an automation rule by ID and refreshes the list.
  Future<void> delete(int id) async {
    try {
      await _repository.delete(id);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to delete automation rule',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<List<AutomationRule>>.error(e, stackTrace);
    }
  }

  /// Toggles the enabled state of a rule.
  Future<void> toggleEnabled(AutomationRule rule) async {
    try {
      rule.enabled = !rule.enabled;
      rule.updatedAt = DateTime.now();
      await _repository.update(rule);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to toggle automation rule',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<List<AutomationRule>>.error(e, stackTrace);
    }
  }
}

/// Provider for [AutomationRuleNotifier].
final StateNotifierProvider<AutomationRuleNotifier,
        AsyncValue<List<AutomationRule>>>
    automationRuleNotifierProvider =
    StateNotifierProvider<AutomationRuleNotifier,
        AsyncValue<List<AutomationRule>>>(
  (Ref ref) => AutomationRuleNotifier(
    repository: ref.watch(automationRuleRepositoryProvider),
  ),
);
