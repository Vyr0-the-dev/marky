import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';
import 'package:marky/features/automation/domain/automation_debug_log.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';
import 'package:marky/features/automation/domain/automation_rule_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

/// Evaluates all enabled [AutomationRule]s against a newly captured
/// bookmark and executes matching actions. Called once per capture,
/// after the bookmark is persisted.
///
/// Deterministic: rules are evaluated in priority order and each
/// fires at most once per capture. No loops — a rule's action cannot
/// re-trigger other rules.
class AutomationEngine {
  const AutomationEngine({
    required AutomationRuleRepository ruleRepo,
    required BookmarkRepository bookmarkRepo,
    required TagRepository tagRepo,
    required BookmarkCollectionRepository collectionRepo,
    ReminderRepository? reminderRepo,
    AutomationDebugLogController? debugLogSink,
    DateTime Function()? now,
    String Function()? timezoneName,
  })  : _ruleRepo = ruleRepo,
        _bookmarkRepo = bookmarkRepo,
        _tagRepo = tagRepo,
        _collectionRepo = collectionRepo,
        _reminderRepo = reminderRepo,
        _debugLogSink = debugLogSink,
        _now = now ?? DateTime.now,
        _timezoneName = timezoneName ?? _defaultTimezoneName;

  final AutomationRuleRepository _ruleRepo;
  final BookmarkRepository _bookmarkRepo;
  final TagRepository _tagRepo;
  final BookmarkCollectionRepository _collectionRepo;
  final ReminderRepository? _reminderRepo;
  final AutomationDebugLogController? _debugLogSink;
  final DateTime Function() _now;
  final String Function() _timezoneName;

  /// Evaluate all enabled rules against [bookmark]. Returns the list
  /// of rules that fired. The bookmark is re-fetched after each action
  /// so later rules see the effects of earlier ones.
  Future<List<AutomationRule>> evaluate(Bookmark bookmark) async {
    final List<AutomationRule> rules = await _ruleRepo.getEnabled();
    final List<AutomationRule> fired = <AutomationRule>[];

    Bookmark current = bookmark;

    for (final AutomationRule rule in rules) {
      if (!_matches(rule, current)) continue;

      for (final AutomationAction action in rule.actions) {
        current = await _execute(action, current);
      }

      if (rule.id != null) {
        await _ruleRepo.recordExecution(rule.id!);
      }
      _log(rule, current, 'Rule fired with ${rule.actions.length} action(s)');
      fired.add(rule);
    }

    return fired;
  }

  // ─── Trigger matching ───────────────────────────────────────────

  bool _matches(AutomationRule rule, Bookmark bookmark) {
    final List<AutomationCondition> conditions = rule.conditions.isEmpty
        ? <AutomationCondition>[
            AutomationCondition(
              type: rule.triggerType,
              value: rule.triggerValue,
            ),
          ]
        : rule.conditions;
    return switch (rule.triggerLogic) {
      AutomationTriggerLogic.all => conditions.every(
          (AutomationCondition condition) =>
              _matchesCondition(condition, bookmark),
        ),
      AutomationTriggerLogic.any => conditions.any(
          (AutomationCondition condition) =>
              _matchesCondition(condition, bookmark),
        ),
    };
  }

  bool _matchesCondition(AutomationCondition condition, Bookmark bookmark) {
    final String value = condition.value.trim().toLowerCase();
    if (value.isEmpty) return false;
    switch (condition.type) {
      case AutomationTriggerType.domainEquals:
        return (bookmark.normalizedHost ?? '').toLowerCase() == value;
      case AutomationTriggerType.domainContains:
        return (bookmark.normalizedHost ?? '').toLowerCase().contains(value);
      case AutomationTriggerType.urlContains:
        return bookmark.originalUrl.toLowerCase().contains(value);
      case AutomationTriggerType.sourceTypeEquals:
        return bookmark.sourceType.name.toLowerCase() == value;
      case AutomationTriggerType.tagContains:
        final int? tagId = int.tryParse(value);
        return tagId != null && bookmark.tagIds.contains(tagId);
      case AutomationTriggerType.unreadForDays:
        final int? days = int.tryParse(value);
        if (days == null || days < 0 || bookmark.isRead) return false;
        return _now().difference(bookmark.createdAt).inDays >= days;
      case AutomationTriggerType.addedWithinDays:
        final int? days = int.tryParse(value);
        if (days == null || days < 0) return false;
        final DateTime threshold = _now().subtract(Duration(days: days));
        return !bookmark.createdAt.isBefore(threshold);
      case AutomationTriggerType.contentTypeEquals:
        final String currentType = bookmark.contentType.name.toLowerCase();
        if (currentType == value) return true;
        return switch (value) {
          'tweet' || 'twitter' || 'social' => currentType == 'discussion',
          'repository' || 'repo' => currentType == 'code',
          _ => false,
        };
      case AutomationTriggerType.readingTimeGreaterThan:
        final int? targetMinutes = int.tryParse(value);
        if (targetMinutes == null || bookmark.readingTimeMinutes == null) {
          return false;
        }
        return bookmark.readingTimeMinutes! > targetMinutes;
      case AutomationTriggerType.titleContains:
        return bookmark.title
                ?.toLowerCase()
                .contains(condition.value.trim().toLowerCase()) ??
            false;
      case AutomationTriggerType.titleMatchesRegex:
        try {
          final RegExp regExp = RegExp(condition.value, caseSensitive: false);
          return regExp.hasMatch(bookmark.title ?? '');
        } catch (_) {
          return false;
        }
    }
  }

  // ─── Action execution ───────────────────────────────────────────

  Future<Bookmark> _execute(AutomationAction action, Bookmark bookmark) async {
    switch (action.type) {
      case AutomationActionType.addTag:
        final int? tagId = await _resolveTagId(action.arg);
        if (tagId != null && tagId > 0 && !bookmark.tagIds.contains(tagId)) {
          final Bookmark updated = bookmark.copyWith(
            tagIds: <int>[...bookmark.tagIds, tagId],
          );
          await _bookmarkRepo.save(updated);
          // Also increment tag usage.
          try {
            await _tagRepo.incrementUsageCount(tagId);
          } catch (_) {
            // Tag may have been deleted; non-fatal.
          }
          return updated;
        }
        return bookmark;

      case AutomationActionType.addToCollection:
        final int collectionId = await _resolveCollectionId(action.arg);
        if (collectionId > 0 &&
            !bookmark.collectionIds.contains(collectionId)) {
          final Bookmark updated = bookmark.copyWith(
            collectionIds: <int>[...bookmark.collectionIds, collectionId],
          );
          await _bookmarkRepo.save(updated);
          try {
            await _collectionRepo.incrementItemCount(collectionId);
          } catch (_) {
            // Collection may have been deleted; non-fatal.
          }
          return updated;
        }
        return bookmark;

      case AutomationActionType.setFavorite:
        final bool flag = _parseBool(action.arg);
        final Bookmark updated = bookmark.copyWith(isFavorite: flag);
        return _bookmarkRepo.save(updated);

      case AutomationActionType.setArchived:
        final bool flag = _parseBool(action.arg);
        final Bookmark updated = bookmark.copyWith(isArchived: flag);
        return _bookmarkRepo.save(updated);

      case AutomationActionType.setPinned:
        final bool flag = _parseBool(action.arg);
        final Bookmark updated = bookmark.copyWith(isPinned: flag);
        return _bookmarkRepo.save(updated);
      case AutomationActionType.addReminder:
        await _createReminder(action, bookmark);
        return bookmark;
    }
  }

  Future<void> _createReminder(
    AutomationAction action,
    Bookmark bookmark,
  ) async {
    final ReminderRepository? repo = _reminderRepo;
    final int? bookmarkId = bookmark.id;
    final int? days = int.tryParse(action.arg.trim());
    if (repo == null || bookmarkId == null || days == null || days < 0) return;

    final DateTime now = _now();
    final Reminder reminder = Reminder(
      bookmarkId: bookmarkId,
      title: _reminderTitle(bookmark),
      scheduledAt: now.add(Duration(days: days)),
      timezone: _timezoneName(),
      createdAt: now,
    );
    await repo.save(reminder);
  }

  void _log(AutomationRule rule, Bookmark bookmark, String message) {
    _debugLogSink?.add(
      AutomationDebugLogEntry(
        timestamp: _now(),
        bookmarkId: bookmark.id,
        ruleId: rule.id,
        ruleName: rule.name,
        message: message,
      ),
    );
  }

  static bool _parseBool(String value) {
    return value.trim().toLowerCase() == 'true';
  }

  static String _reminderTitle(Bookmark bookmark) {
    final String? title = bookmark.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    final String? host = bookmark.normalizedHost?.trim();
    if (host != null && host.isNotEmpty) return host;
    return 'Marky reminder';
  }

  /// Resolves a tag identifier that can be a numeric ID or a tag name.
  /// If name-based and no matching tag exists, creates one on-the-fly.
  Future<int?> _resolveTagId(String arg) async {
    final String trimmed = arg.trim();
    final int? parsed = int.tryParse(trimmed);
    if (parsed != null) return parsed;
    // Treat as tag name — look up by slug first.
    final String slug = trimmed
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.isEmpty) return null;
    final existing = await _tagRepo.findBySlug(slug);
    if (existing != null) return existing.id;
    // Create the tag on-the-fly.
    try {
      final created = await _tagRepo.createFromName(trimmed);
      return created.id;
    } catch (_) {
      return null;
    }
  }

  /// Resolves a collection identifier that can be a numeric ID or a
  /// collection title. Unlike tags, collections are not auto-created.
  Future<int> _resolveCollectionId(String arg) async {
    final String trimmed = arg.trim();
    final int? parsed = int.tryParse(trimmed);
    if (parsed != null) return parsed;
    final String slug = trimmed
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.isEmpty) return -1;
    final existing = await _collectionRepo.findBySlug(slug);
    return existing?.id ?? -1;
  }

  static String _defaultTimezoneName() => 'UTC';
}
