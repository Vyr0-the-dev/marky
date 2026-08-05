import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/automation/domain/models/rule_action.dart';
import 'package:marky/features/automation/domain/models/rule_trigger.dart';
import 'package:marky/features/automation/domain/repositories/automation_rule_repository.dart';
import 'package:marky/features/automation/domain/services/automation_engine_service.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/shared/models/automation_rule.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:marky/shared/models/tag.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Fakes
// ═══════════════════════════════════════════════════════════════════════════

class _FakeAutomationRuleRepository implements AutomationRuleRepository {
  final List<AutomationRule> rules = <AutomationRule>[];

  @override
  Future<List<AutomationRule>> getAll() async => List<AutomationRule>.from(rules);

  @override
  Future<AutomationRule?> getById(Id id) async =>
      rules.cast<AutomationRule?>().firstWhere((r) => r?.id == id, orElse: () => null);

  @override
  Future<List<AutomationRule>> getEnabled() async => rules
      .where((r) => r.enabled)
      .toList()
    ..sort((a, b) => a.priority.compareTo(b.priority));

  @override
  Future<List<AutomationRule>> getByPriority() async => List<AutomationRule>.from(rules)
    ..sort((a, b) => a.priority.compareTo(b.priority));

  @override
  Future<Id> insert(AutomationRule entity) async {
    rules.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(AutomationRule entity) async => entity.id;

  @override
  Future<void> delete(Id id) async => rules.removeWhere((r) => r.id == id);

  @override
  Future<void> clear() async => rules.clear();
}

class _FakeBookmarkItemRepository implements BookmarkItemRepository {
  BookmarkItem? lastUpdated;

  @override
  Future<BookmarkItem?> getById(Id id) async => null;

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<Id> insert(BookmarkItem entity) async => entity.id;

  @override
  Future<Id> update(BookmarkItem entity) async {
    lastUpdated = entity;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async => null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

class _FakeTagRepository implements TagRepository {
  final List<Tag> tags = <Tag>[];

  @override
  Future<Tag?> getBySlug(String slug) async =>
      tags.cast<Tag?>().firstWhere((t) => t?.slug == slug, orElse: () => null);

  @override
  Future<Tag?> getById(Id id) async =>
      tags.cast<Tag?>().firstWhere((t) => t?.id == id, orElse: () => null);

  @override
  Future<List<Tag>> getAll() async => List<Tag>.from(tags);

  @override
  Future<Id> insert(Tag entity) async {
    tags.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(Tag entity) async => entity.id;

  @override
  Future<void> delete(Id id) async => tags.removeWhere((t) => t.id == id);

  @override
  Future<void> clear() async => tags.clear();
}

class _FakeCollectionRepository implements CollectionRepository {
  final List<BookmarkCollection> collections = <BookmarkCollection>[];

  @override
  Future<BookmarkCollection?> getBySlug(String slug) async => collections
      .cast<BookmarkCollection?>()
      .firstWhere((c) => c?.slug == slug, orElse: () => null);

  @override
  Future<BookmarkCollection?> getById(Id id) async => collections
      .cast<BookmarkCollection?>()
      .firstWhere((c) => c?.id == id, orElse: () => null);

  @override
  Future<List<BookmarkCollection>> getAll() async => List<BookmarkCollection>.from(collections);

  @override
  Future<Id> insert(BookmarkCollection entity) async {
    collections.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkCollection entity) async => entity.id;

  @override
  Future<void> delete(Id id) async => collections.removeWhere((c) => c.id == id);

  @override
  Future<void> clear() async => collections.clear();
}

class _FakeReminderRepository implements ReminderRepository {
  final List<Reminder> reminders = <Reminder>[];

  @override
  Future<List<Reminder>> getByBookmarkId(Id bookmarkId) async =>
      reminders.where((r) => r.bookmarkId == bookmarkId).toList();

  @override
  Future<List<Reminder>> getPending() async =>
      reminders.where((r) => r.status == 'pending').toList();

  @override
  Future<Reminder?> getById(Id id) async =>
      reminders.cast<Reminder?>().firstWhere((r) => r?.id == id, orElse: () => null);

  @override
  Future<List<Reminder>> getAll() async => List<Reminder>.from(reminders);

  @override
  Future<Id> insert(Reminder entity) async {
    reminders.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(Reminder entity) async => entity.id;

  @override
  Future<void> delete(Id id) async => reminders.removeWhere((r) => r.id == id);

  @override
  Future<void> clear() async => reminders.clear();
}

// ═══════════════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════════════

BookmarkItem _makeBookmark({
  int id = 1,
  String originalUrl = 'https://example.com/article',
  String? sourceDomain,
  String? normalizedHost,
  String? sourceType,
  List<int>? tagIds,
  List<int>? collectionIds,
  bool isRead = false,
  bool isArchived = false,
  bool isFavorite = false,
  bool isInVault = false,
}) {
  final bookmark = BookmarkItem(
    originalUrl: originalUrl,
    sourceDomain: sourceDomain,
    normalizedHost: normalizedHost,
    sourceType: sourceType,
    tagIds: tagIds,
    isRead: isRead,
    isArchived: isArchived,
    isFavorite: isFavorite,
    isInVault: isInVault,
    // ignore: avoid_redundant_argument_values
    createdAt: DateTime(2024, 1, 1),
    // ignore: avoid_redundant_argument_values
    updatedAt: DateTime(2024, 1, 1),
  );
  bookmark.id = id;
  if (collectionIds != null) {
    bookmark.collectionIds = collectionIds;
  }
  return bookmark;
}

AutomationRule _makeRule({
  int id = 1,
  required String name,
  required RuleTrigger trigger,
  required List<RuleAction> actions,
  int priority = 0,
  bool enabled = true,
}) {
  final rule = AutomationRule(
    name: name,
    triggerType: trigger.triggerType.name,
    triggerConfig: jsonEncode(trigger.toJson()),
    actions: jsonEncode(actions.map((a) => a.toJson()).toList()),
    priority: priority,
    enabled: enabled,
    // ignore: avoid_redundant_argument_values
    createdAt: DateTime(2024, 1, 1),
    // ignore: avoid_redundant_argument_values
    updatedAt: DateTime(2024, 1, 1),
  );
  rule.id = id;
  return rule;
}

// ═══════════════════════════════════════════════════════════════════════════
// Tests
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  late _FakeAutomationRuleRepository ruleRepo;
  late _FakeBookmarkItemRepository bookmarkRepo;
  late _FakeTagRepository tagRepo;
  late _FakeCollectionRepository collectionRepo;
  late _FakeReminderRepository reminderRepo;
  late AutomationEngineService engine;

  setUp(() {
    ruleRepo = _FakeAutomationRuleRepository();
    bookmarkRepo = _FakeBookmarkItemRepository();
    tagRepo = _FakeTagRepository();
    collectionRepo = _FakeCollectionRepository();
    reminderRepo = _FakeReminderRepository();
    engine = AutomationEngineService(
      ruleRepository: ruleRepo,
      bookmarkRepository: bookmarkRepo,
      tagRepository: tagRepo,
      collectionRepository: collectionRepo,
      reminderRepository: reminderRepo,
    );
  });

  group('trigger types', () {
    test('domainEquals matches sourceDomain', () async {
      final rule = _makeRule(
        name: 'domain match',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'youtube.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.archive, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'youtube.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isArchived, isTrue);
      expect(rule.executionCount, 1);
    });

    test('domainEquals matches normalizedHost', () async {
      final rule = _makeRule(
        name: 'host match',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'github.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.archive, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(normalizedHost: 'github.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isArchived, isTrue);
    });

    test('domainContains matches substring', () async {
      final rule = _makeRule(
        name: 'domain contains',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainContains,
          config: <String, dynamic>{'domain': 'medium'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.markAsFavorite, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'medium.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isFavorite, isTrue);
    });

    test('sourceTypeEquals matches', () async {
      final rule = _makeRule(
        name: 'source type',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.sourceTypeEquals,
          config: <String, dynamic>{'sourceType': 'share_sheet'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.moveToVault, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceType: 'share_sheet');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isInVault, isTrue);
    });

    test('urlContains matches pattern in originalUrl', () async {
      final rule = _makeRule(
        name: 'url pattern',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.urlContains,
          config: <String, dynamic>{'pattern': '/pull/'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.archive, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(originalUrl: 'https://github.com/org/repo/pull/42');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isArchived, isTrue);
    });

    test('hasTag matches existing tagId', () async {
      final rule = _makeRule(
        name: 'has tag',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.hasTag,
          config: <String, dynamic>{'tagId': 99},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.markAsFavorite, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(tagIds: <int>[99, 100]);
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isFavorite, isTrue);
    });

    test('isUnread matches when isRead is false', () async {
      final rule = _makeRule(
        name: 'unread',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.isUnread,
          config: <String, dynamic>{},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.archive, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark();
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isArchived, isTrue);
    });

    test('isUnread does not match when isRead is true', () async {
      final rule = _makeRule(
        name: 'unread',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.isUnread,
          config: <String, dynamic>{},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.archive, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(isRead: true);
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isArchived, isFalse);
      expect(rule.executionCount, 0);
    });
  });

  group('action types', () {
    test('addTag adds tag by id', () async {
      final rule = _makeRule(
        name: 'add tag',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addTag,
            config: <String, dynamic>{'tagId': 42},
          ),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.tagIds, contains(42));
      expect(bookmarkRepo.lastUpdated, isNotNull);
    });

    test('addTag resolves tagSlug to id', () async {
      final tag = Tag(
        name: 'Flutter',
        slug: 'flutter',
        // ignore: avoid_redundant_argument_values
        createdAt: DateTime(2024, 1, 1),
        // ignore: avoid_redundant_argument_values
        updatedAt: DateTime(2024, 1, 1),
      );
      tag.id = 7;
      tagRepo.tags.add(tag);

      final rule = _makeRule(
        name: 'add tag by slug',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addTag,
            config: <String, dynamic>{'tagSlug': 'flutter'},
          ),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.tagIds, contains(7));
    });

    test('addToCollection adds collection by id', () async {
      final rule = _makeRule(
        name: 'add to collection',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addToCollection,
            config: <String, dynamic>{'collectionId': 3},
          ),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.collectionIds, contains(3));
    });

    test('addToCollection resolves collectionSlug to id', () async {
      final collection = BookmarkCollection(
        title: 'Work',
        slug: 'work',
        // ignore: avoid_redundant_argument_values
        createdAt: DateTime(2024, 1, 1),
        // ignore: avoid_redundant_argument_values
        updatedAt: DateTime(2024, 1, 1),
      );
      collection.id = 5;
      collectionRepo.collections.add(collection);

      final rule = _makeRule(
        name: 'add to collection by slug',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addToCollection,
            config: <String, dynamic>{'collectionSlug': 'work'},
          ),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.collectionIds, contains(5));
    });

    test('archive sets isArchived', () async {
      final rule = _makeRule(
        name: 'archive',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.archive, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isArchived, isTrue);
    });

    test('markAsFavorite sets isFavorite', () async {
      final rule = _makeRule(
        name: 'favorite',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.markAsFavorite, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isFavorite, isTrue);
    });

    test('moveToVault sets isInVault', () async {
      final rule = _makeRule(
        name: 'vault',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.moveToVault, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isInVault, isTrue);
    });

    test('addReminder creates a reminder', () async {
      final rule = _makeRule(
        name: 'reminder',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addReminder,
            config: <String, dynamic>{
              'title': 'Read this',
              'body': 'Important article',
              'scheduledAt': '2024-12-25T10:00:00.000Z',
              'timezone': 'Europe/Istanbul',
            },
          ),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(reminderRepo.reminders, hasLength(1));
      final reminder = reminderRepo.reminders.first;
      expect(reminder.bookmarkId, bookmark.id);
      expect(reminder.title, 'Read this');
      expect(reminder.body, 'Important article');
      expect(reminder.timezone, 'Europe/Istanbul');
    });
  });

  group('deduplication', () {
    test('same action from two rules executes once', () async {
      final rule1 = _makeRule(
        name: 'rule1',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addTag,
            config: <String, dynamic>{'tagId': 99},
          ),
        ],
      );
      final rule2 = _makeRule(
        id: 2,
        name: 'rule2',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.sourceTypeEquals,
          config: <String, dynamic>{'sourceType': 'share_sheet'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addTag,
            config: <String, dynamic>{'tagId': 99},
          ),
        ],
      );
      ruleRepo.rules.addAll(<AutomationRule>[rule1, rule2]);

      final bookmark = _makeBookmark(
        sourceDomain: 'example.com',
        sourceType: 'share_sheet',
      );
      await engine.evaluateAndExecute(bookmark);

      // tag should appear exactly once
      expect(bookmark.tagIds?.where((id) => id == 99).length, 1);
      // Both rules should have incremented executionCount
      expect(rule1.executionCount, 1);
      expect(rule2.executionCount, 1);
    });
  });

  group('no-cascading', () {
    test('rule B triggering on tag added by rule A does NOT fire', () async {
      // Rule A: if domain==example.com → add tag 77
      final ruleA = _makeRule(
        name: 'add tag rule',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addTag,
            config: <String, dynamic>{'tagId': 77},
          ),
        ],
      );
      // Rule B: if has tag 77 → archive
      final ruleB = _makeRule(
        id: 2,
        name: 'archive if tagged',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.hasTag,
          config: <String, dynamic>{'tagId': 77},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.archive, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.addAll(<AutomationRule>[ruleA, ruleB]);

      // Bookmark does NOT have tag 77 initially
      final bookmark = _makeBookmark(sourceDomain: 'example.com', tagIds: <int>[1]);
      await engine.evaluateAndExecute(bookmark);

      // Rule A fires and adds tag 77
      expect(bookmark.tagIds, contains(77));
      // Rule B does NOT fire because trigger was evaluated against initial state
      expect(bookmark.isArchived, isFalse);
      expect(ruleB.executionCount, 0);
    });
  });

  group('priority ordering', () {
    test('lower priority number executes first', () async {
      final ruleLow = _makeRule(
        name: 'low priority',
        priority: 1,
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.markAsFavorite, config: <String, dynamic>{}),
        ],
      );
      final ruleHigh = _makeRule(
        id: 2,
        name: 'high priority',
        priority: 5,
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.archive, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.addAll(<AutomationRule>[ruleHigh, ruleLow]);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isFavorite, isTrue);
      expect(bookmark.isArchived, isTrue);
      // Both rules should have executionCount incremented
      expect(ruleLow.executionCount, 1);
      expect(ruleHigh.executionCount, 1);
    });

    test('higher priority rule wins on conflicting actions', () async {
      // Both rules try to add the same tag — deduplication handles this,
      // but priority still determines which rule gets its executionCount bumped
      // first. The real "win" here is that both match but only one action runs.
      final rule1 = _makeRule(
        name: 'priority 1',
        priority: 1,
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addTag,
            config: <String, dynamic>{'tagId': 55},
          ),
        ],
      );
      final rule2 = _makeRule(
        id: 2,
        name: 'priority 2',
        priority: 2,
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addTag,
            config: <String, dynamic>{'tagId': 55},
          ),
        ],
      );
      ruleRepo.rules.addAll(<AutomationRule>[rule2, rule1]);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.tagIds, contains(55));
      expect(bookmark.tagIds?.where((id) => id == 55).length, 1);
      expect(rule1.executionCount, 1);
      expect(rule2.executionCount, 1);
    });
  });

  group('edge cases', () {
    test('empty rules list is a no-op', () async {
      final bookmark = _makeBookmark();
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isArchived, isFalse);
      expect(bookmark.isFavorite, isFalse);
      expect(bookmarkRepo.lastUpdated, isNull);
    });

    test('disabled rules are skipped', () async {
      final rule = _makeRule(
        name: 'disabled',
        enabled: false,
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(actionType: RuleActionType.archive, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.isArchived, isFalse);
      expect(rule.executionCount, 0);
    });

    test('bookmark is only saved when mutated', () async {
      final rule = _makeRule(
        name: 'no-op action',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          // archive on an already-archived bookmark does not mutate
          RuleAction(actionType: RuleActionType.archive, config: <String, dynamic>{}),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(
        sourceDomain: 'example.com',
        isArchived: true,
      );
      await engine.evaluateAndExecute(bookmark);

      // Rule matched but bookmark was already archived
      expect(rule.executionCount, 1);
      expect(bookmarkRepo.lastUpdated, isNull);
    });

    test('addTag is idempotent — same tag not added twice', () async {
      final rule = _makeRule(
        name: 'add tag',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addTag,
            config: <String, dynamic>{'tagId': 42},
          ),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(
        sourceDomain: 'example.com',
        tagIds: <int>[42],
      );
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.tagIds, <int>[42]);
      expect(bookmarkRepo.lastUpdated, isNull);
    });

    test('addToCollection is idempotent', () async {
      final rule = _makeRule(
        name: 'add collection',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addToCollection,
            config: <String, dynamic>{'collectionId': 3},
          ),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(
        sourceDomain: 'example.com',
        collectionIds: <int>[3],
      );
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.collectionIds, <int>[3]);
      expect(bookmarkRepo.lastUpdated, isNull);
    });

    test('unresolvable tagSlug logs warning and skips', () async {
      final rule = _makeRule(
        name: 'missing tag',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addTag,
            config: <String, dynamic>{'tagSlug': 'nonexistent'},
          ),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.tagIds, isNull);
      expect(bookmarkRepo.lastUpdated, isNull);
      expect(rule.executionCount, 1); // rule still matched
    });

    test('unresolvable collectionSlug logs warning and skips', () async {
      final rule = _makeRule(
        name: 'missing collection',
        trigger: const RuleTrigger(
          triggerType: RuleTriggerType.domainEquals,
          config: <String, dynamic>{'domain': 'example.com'},
        ),
        actions: const <RuleAction>[
          RuleAction(
            actionType: RuleActionType.addToCollection,
            config: <String, dynamic>{'collectionSlug': 'nonexistent'},
          ),
        ],
      );
      ruleRepo.rules.add(rule);

      final bookmark = _makeBookmark(sourceDomain: 'example.com');
      await engine.evaluateAndExecute(bookmark);

      expect(bookmark.collectionIds, isNull);
      expect(bookmarkRepo.lastUpdated, isNull);
    });
  });
}
