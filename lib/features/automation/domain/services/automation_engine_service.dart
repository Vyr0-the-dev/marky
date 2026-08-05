import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:marky/features/automation/domain/models/rule_action.dart';
import 'package:marky/features/automation/domain/models/rule_trigger.dart';
import 'package:marky/features/automation/domain/repositories/automation_rule_repository.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/shared/models/automation_rule.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/reminder.dart';

/// Core automation engine that evaluates rules against a bookmark at capture time
/// and executes matching actions in a single, deterministic pass.
///
/// ## Evaluation model
/// 1. Fetch all **enabled** rules sorted by `priority` ascending (lower = higher priority).
/// 2. Evaluate every rule's trigger against the bookmark's **initial** state.
/// 3. Collect actions from all matching rules.
/// 4. Deduplicate actions: same [RuleActionType] + same config = one execution.
/// 5. Execute deduplicated actions in priority order.
/// 6. Save the bookmark if it was mutated.
/// 7. Update `executionCount` and `lastExecutedAt` for every rule that matched.
///
/// ## No-cascading guarantee
/// Because triggers are evaluated against the *initial* bookmark state, a rule
/// that adds a tag will never cause another rule whose trigger is `hasTag` to
/// fire in the same cycle.
class AutomationEngineService {
  AutomationEngineService({
    required AutomationRuleRepository ruleRepository,
    required BookmarkItemRepository bookmarkRepository,
    required TagRepository tagRepository,
    required CollectionRepository collectionRepository,
    required ReminderRepository reminderRepository,
    Logger? logger,
  })  : _ruleRepository = ruleRepository,
        _bookmarkRepository = bookmarkRepository,
        _tagRepository = tagRepository,
        _collectionRepository = collectionRepository,
        _reminderRepository = reminderRepository,
        _logger = logger ?? Logger();

  final AutomationRuleRepository _ruleRepository;
  final BookmarkItemRepository _bookmarkRepository;
  final TagRepository _tagRepository;
  final CollectionRepository _collectionRepository;
  final ReminderRepository _reminderRepository;
  final Logger _logger;

  /// Evaluates all enabled automation rules against [bookmark] and executes
  /// matching actions.
  ///
  /// Errors during rule evaluation or action execution are logged and swallowed
  /// so that capture flow is never interrupted.
  Future<void> evaluateAndExecute(BookmarkItem bookmark) async {
    try {
      final rules = await _ruleRepository.getEnabled();
      _logger.d(
        'AutomationEngine: evaluating ${rules.length} enabled rules against bookmark ${bookmark.id}',
      );

      if (rules.isEmpty) {
        return;
      }

      // ── 1. Evaluate triggers against INITIAL bookmark state ─────────────
      final matchedRules = <_MatchedRule>[];
      for (final rule in rules) {
        try {
          final trigger = RuleTrigger.fromJson(
            jsonDecode(rule.triggerConfig) as Map<String, dynamic>,
          );
          if (_evaluateTrigger(trigger, bookmark)) {
            final actions = (jsonDecode(rule.actions) as List<dynamic>)
                .cast<Map<String, dynamic>>()
                .map(RuleAction.fromJson)
                .toList();
            matchedRules.add(_MatchedRule(rule: rule, actions: actions));
          }
        } catch (e, st) {
          _logger.e(
            'AutomationEngine: failed to evaluate rule "${rule.name}" (id:${rule.id})',
            error: e,
            stackTrace: st,
          );
        }
      }

      _logger.d(
        'AutomationEngine: ${matchedRules.length}/${rules.length} rules matched',
      );

      if (matchedRules.isEmpty) {
        return;
      }

      // ── 2. Deduplicate actions (same type + same config = once) ─────────
      final seenActions = <RuleAction>{};
      final actionsToExecute = <RuleAction>[];
      for (final matched in matchedRules) {
        for (final action in matched.actions) {
          if (seenActions.add(action)) {
            actionsToExecute.add(action);
          }
        }
      }

      _logger.d(
        'AutomationEngine: executing ${actionsToExecute.length} deduplicated actions',
      );

      // ── 3. Execute actions ──────────────────────────────────────────────
      var bookmarkMutated = false;
      for (final action in actionsToExecute) {
        try {
          final didMutate = await _executeAction(action, bookmark);
          if (didMutate) bookmarkMutated = true;
        } catch (e, st) {
          _logger.e(
            'AutomationEngine: action ${action.actionType.name} failed',
            error: e,
            stackTrace: st,
          );
        }
      }

      // ── 4. Save bookmark if mutated ─────────────────────────────────────
      if (bookmarkMutated) {
        bookmark.updatedAt = DateTime.now();
        await _bookmarkRepository.update(bookmark);
        _logger.d('AutomationEngine: bookmark ${bookmark.id} updated');
      }

      // ── 5. Update rule stats ────────────────────────────────────────────
      for (final matched in matchedRules) {
        matched.rule.executionCount++;
        matched.rule.lastExecutedAt = DateTime.now();
        await _ruleRepository.update(matched.rule);
      }

      _logger.i(
        'AutomationEngine: finished — ${matchedRules.length} rules, ${actionsToExecute.length} actions executed for bookmark ${bookmark.id}',
      );
    } catch (e, st) {
      _logger.e(
        'AutomationEngine: unhandled error during evaluateAndExecute',
        error: e,
        stackTrace: st,
      );
    }
  }

  // ── Trigger evaluation ──────────────────────────────────────────────────

  bool _evaluateTrigger(RuleTrigger trigger, BookmarkItem bookmark) {
    switch (trigger.triggerType) {
      case RuleTriggerType.domainEquals:
        final domain = trigger.config['domain'] as String?;
        if (domain == null) return false;
        return bookmark.sourceDomain == domain ||
            bookmark.normalizedHost == domain;

      case RuleTriggerType.domainContains:
        final domain = trigger.config['domain'] as String?;
        if (domain == null) return false;
        final source = bookmark.sourceDomain ?? '';
        final host = bookmark.normalizedHost ?? '';
        return source.contains(domain) || host.contains(domain);

      case RuleTriggerType.sourceTypeEquals:
        final sourceType = trigger.config['sourceType'] as String?;
        if (sourceType == null) return false;
        return bookmark.sourceType == sourceType;

      case RuleTriggerType.urlContains:
        final pattern = trigger.config['pattern'] as String?;
        if (pattern == null) return false;
        return bookmark.originalUrl.contains(pattern);

      case RuleTriggerType.hasTag:
        final tagId = trigger.config['tagId'] as int?;
        if (tagId == null) return false;
        return bookmark.tagIds?.contains(tagId) ?? false;

      case RuleTriggerType.isUnread:
        return !bookmark.isRead;
    }
  }

  // ── Action execution ────────────────────────────────────────────────────

  /// Executes a single action against [bookmark].
  ///
  /// Returns `true` if the bookmark was mutated (requires save).
  Future<bool> _executeAction(RuleAction action, BookmarkItem bookmark) async {
    switch (action.actionType) {
      case RuleActionType.addTag:
        return _executeAddTag(action, bookmark);

      case RuleActionType.addToCollection:
        return _executeAddToCollection(action, bookmark);

      case RuleActionType.archive:
        if (!bookmark.isArchived) {
          bookmark.isArchived = true;
          return true;
        }
        return false;

      case RuleActionType.markAsFavorite:
        if (!bookmark.isFavorite) {
          bookmark.isFavorite = true;
          return true;
        }
        return false;

      case RuleActionType.moveToVault:
        if (!bookmark.isInVault) {
          bookmark.isInVault = true;
          return true;
        }
        return false;

      case RuleActionType.addReminder:
        await _executeAddReminder(action, bookmark);
        return false; // reminder is a separate entity
    }
  }

  Future<bool> _executeAddTag(RuleAction action, BookmarkItem bookmark) async {
    int? tagId = action.config['tagId'] as int?;

    if (tagId == null) {
      final slug = action.config['tagSlug'] as String?;
      if (slug != null) {
        final tag = await _tagRepository.getBySlug(slug);
        tagId = tag?.id;
      }
    }

    if (tagId == null) {
      _logger.w('AutomationEngine: addTag resolved to null tagId');
      return false;
    }

    bookmark.tagIds ??= <int>[];
    if (!bookmark.tagIds!.contains(tagId)) {
      bookmark.tagIds!.add(tagId);
      return true;
    }
    return false;
  }

  Future<bool> _executeAddToCollection(
    RuleAction action,
    BookmarkItem bookmark,
  ) async {
    int? collectionId = action.config['collectionId'] as int?;

    if (collectionId == null) {
      final slug = action.config['collectionSlug'] as String?;
      if (slug != null) {
        final collection = await _collectionRepository.getBySlug(slug);
        collectionId = collection?.id;
      }
    }

    if (collectionId == null) {
      _logger.w('AutomationEngine: addToCollection resolved to null collectionId');
      return false;
    }

    bookmark.collectionIds ??= <int>[];
    if (!bookmark.collectionIds!.contains(collectionId)) {
      bookmark.collectionIds!.add(collectionId);
      return true;
    }
    return false;
  }

  Future<void> _executeAddReminder(
    RuleAction action,
    BookmarkItem bookmark,
  ) async {
    final title = action.config['title'] as String?;
    if (title == null || title.isEmpty) {
      _logger.w('AutomationEngine: addReminder missing title');
      return;
    }

    DateTime? scheduledAt;
    final rawScheduled = action.config['scheduledAt'];
    if (rawScheduled is String) {
      scheduledAt = DateTime.tryParse(rawScheduled);
    } else if (rawScheduled is DateTime) {
      scheduledAt = rawScheduled;
    }
    scheduledAt ??= DateTime.now().add(const Duration(days: 1));

    final reminder = Reminder(
      bookmarkId: bookmark.id,
      title: title,
      body: action.config['body'] as String?,
      scheduledAt: scheduledAt,
      timezone: action.config['timezone'] as String? ?? 'UTC',
      createdAt: DateTime.now(),
    );

    await _reminderRepository.insert(reminder);
    _logger.d('AutomationEngine: reminder created for bookmark ${bookmark.id}');
  }
}

/// Internal tuple linking a matched rule with its parsed actions.
class _MatchedRule {
  _MatchedRule({required this.rule, required this.actions});

  final AutomationRule rule;
  final List<RuleAction> actions;
}
