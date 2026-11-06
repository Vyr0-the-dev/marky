import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/core/database/database_providers.dart';
import 'package:marky/features/automation/data/isar_automation_rule_repository.dart';
import 'package:marky/features/automation/domain/automation_debug_log.dart';
import 'package:marky/features/automation/domain/automation_engine.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';
import 'package:marky/features/automation/domain/automation_rule_repository.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/tags/data/tag_providers.dart';

final Provider<AutomationRuleRepository> automationRuleRepositoryProvider =
    Provider<AutomationRuleRepository>((Ref ref) {
  return IsarAutomationRuleRepository(ref.watch(markyIsarProvider));
});

final AutoDisposeStreamProvider<List<AutomationRule>> automationRulesProvider =
    StreamProvider.autoDispose<List<AutomationRule>>((Ref ref) {
  return ref.watch(automationRuleRepositoryProvider).watchAll();
});

final Provider<AutomationDebugLogController>
    automationDebugLogControllerProvider =
    Provider<AutomationDebugLogController>((Ref ref) {
  final AutomationDebugLogController controller =
      AutomationDebugLogController();
  ref.onDispose(controller.dispose);
  return controller;
});

final AutoDisposeStreamProvider<List<AutomationDebugLogEntry>>
    automationDebugLogsProvider =
    StreamProvider.autoDispose<List<AutomationDebugLogEntry>>((Ref ref) {
  return ref.watch(automationDebugLogControllerProvider).watch();
});

final Provider<AutomationEngine> automationEngineProvider =
    Provider<AutomationEngine>((Ref ref) {
  return AutomationEngine(
    ruleRepo: ref.watch(automationRuleRepositoryProvider),
    bookmarkRepo: ref.watch(bookmarkRepositoryProvider),
    tagRepo: ref.watch(tagRepositoryProvider),
    collectionRepo: ref.watch(bookmarkCollectionRepositoryProvider),
    reminderRepo: ref.watch(reminderRepositoryProvider),
    debugLogSink: ref.watch(automationDebugLogControllerProvider),
  );
});
