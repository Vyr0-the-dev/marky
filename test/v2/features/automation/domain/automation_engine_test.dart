import 'package:flutter_test/flutter_test.dart';

import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';
import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/automation/domain/automation_debug_log.dart';
import 'package:marky/features/automation/domain/automation_engine.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';
import 'package:marky/features/automation/domain/automation_rule_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

// ─── Helpers ─────────────────────────────────────────────────────

Bookmark _bm({
  int? id = 1,
  String url = 'https://www.youtube.com/watch?v=abc',
  String? host = 'www.youtube.com',
  BookmarkSourceType source = BookmarkSourceType.manual,
  BookmarkContentType contentType = BookmarkContentType.video,
  int? readingTimeMinutes,
  List<int> tagIds = const <int>[],
  List<int> collectionIds = const <int>[],
  bool fav = false,
  bool archived = false,
  bool pinned = false,
  bool read = false,
  DateTime? createdAt,
  String? title,
}) {
  final DateTime now = createdAt ?? DateTime(2026);
  return Bookmark(
    id: id,
    originalUrl: url,
    canonicalUrl: url,
    normalizedHost: host,
    sourceType: source,
    contentType: contentType,
    readingTimeMinutes: readingTimeMinutes,
    title: title,
    tagIds: tagIds,
    collectionIds: collectionIds,
    isFavorite: fav,
    isArchived: archived,
    isPinned: pinned,
    isRead: read,
    createdAt: now,
    updatedAt: now,
  );
}

AutomationRule _rule({
  int? id = 1,
  AutomationTriggerType trigger = AutomationTriggerType.domainEquals,
  String value = 'www.youtube.com',
  List<AutomationAction> actions = const <AutomationAction>[
    AutomationAction(type: AutomationActionType.addTag, arg: '42'),
  ],
  AutomationTriggerLogic triggerLogic = AutomationTriggerLogic.all,
  List<AutomationCondition>? conditions,
  bool enabled = true,
  int priority = 100,
}) {
  final DateTime now = DateTime(2026);
  return AutomationRule(
    id: id,
    name: 'r$id',
    triggerType: trigger,
    triggerValue: value,
    triggerLogic: triggerLogic,
    conditions: conditions,
    actions: actions,
    enabled: enabled,
    priority: priority,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late _FakeRuleRepo ruleRepo;
  late _FakeBookmarkRepo bookmarkRepo;
  late _FakeTagRepo tagRepo;
  late _FakeCollectionRepo collectionRepo;
  late _FakeReminderRepo reminderRepo;
  late AutomationDebugLogController debugLog;
  late AutomationEngine engine;

  setUp(() {
    ruleRepo = _FakeRuleRepo();
    bookmarkRepo = _FakeBookmarkRepo();
    tagRepo = _FakeTagRepo();
    collectionRepo = _FakeCollectionRepo();
    reminderRepo = _FakeReminderRepo();
    debugLog = AutomationDebugLogController();
    engine = AutomationEngine(
      ruleRepo: ruleRepo,
      bookmarkRepo: bookmarkRepo,
      tagRepo: tagRepo,
      collectionRepo: collectionRepo,
      reminderRepo: reminderRepo,
      debugLogSink: debugLog,
      now: () => DateTime(2026, 1, 10, 9),
      timezoneName: () => 'Europe/Istanbul',
    );
  });

  // ─── Trigger matching ─────────────────────────────────────────

  group('trigger matching', () {
    test('domainEquals fires only on exact host match (case-insensitive)',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(value: 'WWW.YOUTUBE.COM'),
      ];

      final List<AutomationRule> fired = await engine.evaluate(_bm());

      expect(fired, hasLength(1));
    });

    test('domainEquals does NOT fire on subdomain mismatch', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(value: 'youtube.com'),
      ];

      final List<AutomationRule> fired = await engine.evaluate(_bm());

      expect(fired, isEmpty);
    });

    test('domainContains matches partial host', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.domainContains,
          value: 'youtube',
        ),
      ];

      final List<AutomationRule> fired =
          await engine.evaluate(_bm(host: 'm.youtube.com'));

      expect(fired, hasLength(1));
    });

    test('urlContains matches in original URL', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.urlContains,
          value: '/watch',
        ),
      ];

      final List<AutomationRule> fired =
          await engine.evaluate(_bm(url: 'https://example.com/watch?v=42'));

      expect(fired, hasLength(1));
    });

    test('sourceTypeEquals matches enum name', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.sourceTypeEquals,
          value: 'share',
        ),
      ];

      final List<AutomationRule> fired =
          await engine.evaluate(_bm(source: BookmarkSourceType.share));

      expect(fired, hasLength(1));
    });

    test('tagContains matches existing bookmark tag', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.tagContains,
          value: '7',
        ),
      ];

      final List<AutomationRule> fired =
          await engine.evaluate(_bm(tagIds: const <int>[7]));

      expect(fired, hasLength(1));
    });

    test('unreadForDays matches old unread bookmarks', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.unreadForDays,
          value: '5',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(_bm());

      expect(fired, hasLength(1));
    });

    test('addedWithinDays matches recent bookmarks', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.addedWithinDays,
          value: '3',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(createdAt: DateTime(2026, 1, 8)),
      );

      expect(fired, hasLength(1));
    });

    test('contentTypeEquals matches exact content type (case-insensitive)',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.contentTypeEquals,
          value: 'Article',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(contentType: BookmarkContentType.article),
      );

      expect(fired, hasLength(1));
    });

    test('contentTypeEquals does NOT match different content type', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.contentTypeEquals,
          value: 'video',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(contentType: BookmarkContentType.article),
      );

      expect(fired, isEmpty);
    });

    test('contentTypeEquals matches aliases like tweet and repository',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.contentTypeEquals,
          value: 'tweet',
        ),
        _rule(
          id: 2,
          trigger: AutomationTriggerType.contentTypeEquals,
          value: 'repository',
        ),
      ];

      final List<AutomationRule> firedDiscussion = await engine.evaluate(
        _bm(contentType: BookmarkContentType.discussion),
      );
      expect(firedDiscussion, hasLength(1));
      expect(firedDiscussion.first.id, 1);

      final List<AutomationRule> firedCode = await engine.evaluate(
        _bm(contentType: BookmarkContentType.code),
      );
      expect(firedCode, hasLength(1));
      expect(firedCode.first.id, 2);
    });

    test('readingTimeGreaterThan matches when reading time strictly greater',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.readingTimeGreaterThan,
          value: '5',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(readingTimeMinutes: 8),
      );

      expect(fired, hasLength(1));
    });

    test(
        'readingTimeGreaterThan does NOT match when reading time less or equal',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.readingTimeGreaterThan,
          value: '5',
        ),
      ];

      final List<AutomationRule> equalFired = await engine.evaluate(
        _bm(readingTimeMinutes: 5),
      );
      expect(equalFired, isEmpty);

      final List<AutomationRule> lessFired = await engine.evaluate(
        _bm(readingTimeMinutes: 3),
      );
      expect(lessFired, isEmpty);
    });

    test(
        'readingTimeGreaterThan does NOT match when readingTimeMinutes is null',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.readingTimeGreaterThan,
          value: '5',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(_bm());

      expect(fired, isEmpty);
    });

    test(
        'readingTimeGreaterThan does NOT match when value is invalid integer',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.readingTimeGreaterThan,
          value: 'not-a-number',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(readingTimeMinutes: 10),
      );

      expect(fired, isEmpty);
    });

    test('titleContains matches substring in bookmark title case-insensitively',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.titleContains,
          value: 'FLUTTER',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(title: 'Getting started with Flutter development'),
      );

      expect(fired, hasLength(1));
    });

    test('titleContains does not fire when keyword is absent', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.titleContains,
          value: 'Dart',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(title: 'React Native guide'),
      );

      expect(fired, isEmpty);
    });

    test('titleContains returns false when bookmark title is null', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.titleContains,
          value: 'Flutter',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(),
      );

      expect(fired, isEmpty);
    });

    test('titleContains returns false when condition value is empty or whitespace',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.titleContains,
          value: '   ',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(title: 'Some title'),
      );

      expect(fired, isEmpty);
    });

    test(
        'titleMatchesRegex matches bookmark title with regex pattern case-insensitively',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.titleMatchesRegex,
          value: r'v[0-9]+\.[0-9]+',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(title: 'Marky Release v1.2 is here'),
      );

      expect(fired, hasLength(1));
    });

    test('titleMatchesRegex does not match non-matching regex', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.titleMatchesRegex,
          value: '^Tutorial:',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(title: 'Reference guide: Dart & Flutter'),
      );

      expect(fired, isEmpty);
    });

    test('titleMatchesRegex returns false when bookmark title is null',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.titleMatchesRegex,
          value: r'v[0-9]+\.[0-9]+',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(),
      );

      expect(fired, isEmpty);
    });

    test('titleMatchesRegex safely handles invalid regex syntax without throwing',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.titleMatchesRegex,
          value: '[invalid(regex',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(title: 'Any title'),
      );

      expect(fired, isEmpty);
    });

    test(
        'titleMatchesRegex returns false when condition value is empty or whitespace',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          trigger: AutomationTriggerType.titleMatchesRegex,
          value: '   ',
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(
        _bm(title: 'Any title'),
      );

      expect(fired, isEmpty);
    });

    test('AND logic requires all conditions to match', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          conditions: const <AutomationCondition>[
            AutomationCondition(
              type: AutomationTriggerType.domainContains,
              value: 'youtube',
            ),
            AutomationCondition(
              type: AutomationTriggerType.urlContains,
              value: 'watch',
            ),
          ],
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(_bm());

      expect(fired, hasLength(1));
    });

    test('AND logic skips when one condition does not match', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          conditions: const <AutomationCondition>[
            AutomationCondition(
              type: AutomationTriggerType.domainContains,
              value: 'youtube',
            ),
            AutomationCondition(
              type: AutomationTriggerType.urlContains,
              value: 'missing',
            ),
          ],
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(_bm());

      expect(fired, isEmpty);
    });

    test('OR logic fires when any condition matches', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(
          triggerLogic: AutomationTriggerLogic.any,
          conditions: const <AutomationCondition>[
            AutomationCondition(
              type: AutomationTriggerType.domainContains,
              value: 'missing',
            ),
            AutomationCondition(
              type: AutomationTriggerType.urlContains,
              value: 'watch',
            ),
          ],
        ),
      ];

      final List<AutomationRule> fired = await engine.evaluate(_bm());

      expect(fired, hasLength(1));
    });

    test('disabled rules are skipped (only enabled returned)', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(enabled: false),
      ];

      final List<AutomationRule> fired = await engine.evaluate(_bm());

      expect(fired, isEmpty);
    });
  });

  // ─── Actions ──────────────────────────────────────────────────

  group('action execution', () {
    test('addTag appends to bookmark.tagIds and increments usage', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(actions: const <AutomationAction>[
          AutomationAction(type: AutomationActionType.addTag, arg: '7'),
        ]),
      ];

      await engine.evaluate(_bm(tagIds: <int>[3]));

      expect(bookmarkRepo.savedBookmarks.last.tagIds, <int>[3, 7]);
      expect(tagRepo.incrementCalls, <int>[7]);
    });

    test('addTag does not duplicate existing tag', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(actions: const <AutomationAction>[
          AutomationAction(type: AutomationActionType.addTag, arg: '3'),
        ]),
      ];

      await engine.evaluate(_bm(tagIds: <int>[3]));

      expect(bookmarkRepo.savedBookmarks, isEmpty);
      expect(tagRepo.incrementCalls, isEmpty);
    });

    test('addToCollection appends collectionId and increments item count',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(actions: const <AutomationAction>[
          AutomationAction(
            type: AutomationActionType.addToCollection,
            arg: '5',
          ),
        ]),
      ];

      await engine.evaluate(_bm());

      expect(bookmarkRepo.savedBookmarks.last.collectionIds, <int>[5]);
      expect(collectionRepo.incrementItemCalls, <int>[5]);
    });

    test('setFavorite saves bookmark with new flag', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(actions: const <AutomationAction>[
          AutomationAction(
            type: AutomationActionType.setFavorite,
            arg: 'true',
          ),
        ]),
      ];

      await engine.evaluate(_bm());

      expect(bookmarkRepo.savedBookmarks.last.isFavorite, isTrue);
    });

    test('setArchived true archives the bookmark', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(actions: const <AutomationAction>[
          AutomationAction(
            type: AutomationActionType.setArchived,
            arg: 'true',
          ),
        ]),
      ];

      await engine.evaluate(_bm());

      expect(bookmarkRepo.savedBookmarks.last.isArchived, isTrue);
    });

    test('setPinned true pins the bookmark', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(actions: const <AutomationAction>[
          AutomationAction(
            type: AutomationActionType.setPinned,
            arg: 'true',
          ),
        ]),
      ];

      await engine.evaluate(_bm());

      expect(bookmarkRepo.savedBookmarks.last.isPinned, isTrue);
    });

    test('addReminder creates relative reminder for persisted bookmark',
        () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(actions: const <AutomationAction>[
          AutomationAction(
            type: AutomationActionType.addReminder,
            arg: '2',
          ),
        ]),
      ];

      await engine.evaluate(_bm(title: 'Watch later'));

      expect(reminderRepo.savedReminders.single.bookmarkId, 1);
      expect(reminderRepo.savedReminders.single.title, 'Watch later');
      expect(
        reminderRepo.savedReminders.single.scheduledAt,
        DateTime(2026, 1, 12, 9),
      );
      expect(reminderRepo.savedReminders.single.timezone, 'Europe/Istanbul');
    });

    test('execution recorded for fired rules', () async {
      ruleRepo.rules = <AutomationRule>[_rule(id: 99)];

      await engine.evaluate(_bm());

      expect(ruleRepo.recordedExecutions, <int>[99]);
    });

    test('debug log records fired rule', () async {
      ruleRepo.rules = <AutomationRule>[_rule(id: 99)];

      await engine.evaluate(_bm());

      expect(debugLog.entries.single.ruleId, 99);
      expect(debugLog.entries.single.bookmarkId, 1);
      expect(debugLog.entries.single.message, contains('Rule fired'));
    });
  });

  // ─── Multi-rule sequencing ────────────────────────────────────

  group('multi-rule sequencing', () {
    test('multiple matching rules all fire in order', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(actions: const <AutomationAction>[
          AutomationAction(type: AutomationActionType.addTag, arg: '1'),
        ]),
        _rule(id: 2, actions: const <AutomationAction>[
          AutomationAction(type: AutomationActionType.addTag, arg: '2'),
        ]),
      ];

      final List<AutomationRule> fired = await engine.evaluate(_bm());

      expect(fired.map((AutomationRule r) => r.id), <int>[1, 2]);
      expect(bookmarkRepo.savedBookmarks.last.tagIds, <int>[1, 2]);
    });

    test('non-matching rules are filtered out', () async {
      ruleRepo.rules = <AutomationRule>[
        _rule(value: 'wrong.com'),
        _rule(id: 2),
      ];

      final List<AutomationRule> fired = await engine.evaluate(_bm());

      expect(fired.map((AutomationRule r) => r.id), <int>[2]);
    });
  });
}

// ─── Fakes ────────────────────────────────────────────────────────

class _FakeRuleRepo implements AutomationRuleRepository {
  List<AutomationRule> rules = <AutomationRule>[];
  final List<int> recordedExecutions = <int>[];

  @override
  Future<List<AutomationRule>> getEnabled() async =>
      rules.where((AutomationRule r) => r.enabled).toList();

  @override
  Future<void> recordExecution(int ruleId) async {
    recordedExecutions.add(ruleId);
  }

  // ─── Unused stubs ──────────────────────────────────────────────

  @override
  Future<AutomationRule> save(AutomationRule rule) =>
      throw UnimplementedError();
  @override
  Future<AutomationRule?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<AutomationRule>> getAll() => throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Stream<List<AutomationRule>> watchAll() => throw UnimplementedError();
  @override
  Stream<AutomationRule?> watchById(int id) => throw UnimplementedError();
}

class _FakeBookmarkRepo implements BookmarkRepository {
  final List<Bookmark> savedBookmarks = <Bookmark>[];

  @override
  Future<Bookmark> save(Bookmark bookmark) async {
    savedBookmarks.add(bookmark);
    return bookmark;
  }

  // ─── Unused stubs ──────────────────────────────────────────────

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) =>
      throw UnimplementedError();
  @override
  Future<Bookmark?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> getByIds(List<int> ids) => throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<int> deleteAll(List<int> ids) => throw UnimplementedError();
  @override
  Future<Bookmark?> findByUrlHash(String urlHash) => throw UnimplementedError();
  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) =>
      throw UnimplementedError();
  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) =>
      throw UnimplementedError();
  @override
  Future<int> countAll() => throw UnimplementedError();
  @override
  Future<int> count(BookmarkFeedQuery query) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) =>
      throw UnimplementedError();
  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      throw UnimplementedError();
  @override
  Stream<Bookmark?> watchById(int id) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) =>
      throw UnimplementedError();
}

class _FakeTagRepo implements TagRepository {
  final List<int> incrementCalls = <int>[];

  @override
  Future<void> incrementUsageCount(int tagId) async {
    incrementCalls.add(tagId);
  }

  // ─── Unused stubs ──────────────────────────────────────────────

  @override
  Future<Tag> save(Tag tag) => throw UnimplementedError();
  @override
  Future<Tag> createFromName(String name, {int? colorArgb, String? icon}) =>
      throw UnimplementedError();
  @override
  Future<Tag?> getById(int id) => throw UnimplementedError();
  @override
  Future<Tag?> findBySlug(String slug) => throw UnimplementedError();
  @override
  Future<List<Tag>> getAll() => throw UnimplementedError();
  @override
  Future<List<Tag>> getByIds(List<int> ids) => throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<void> decrementUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<int> recomputeUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<Map<int, int>> recomputeAllUsageCounts() => throw UnimplementedError();
  @override
  Stream<List<Tag>> watchAll() => throw UnimplementedError();
  @override
  Stream<Tag?> watchById(int id) => throw UnimplementedError();
}

class _FakeCollectionRepo implements BookmarkCollectionRepository {
  final List<int> incrementItemCalls = <int>[];

  @override
  Future<void> incrementItemCount(int collectionId) async {
    incrementItemCalls.add(collectionId);
  }

  // ─── Unused stubs ──────────────────────────────────────────────

  @override
  Future<BookmarkCollection> save(BookmarkCollection collection) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection> createFromTitle(
    String title, {
    int? accentColorArgb,
    String? icon,
  }) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection> createSmartFromRule(
    String title,
    SmartCollectionRule rule, {
    int? accentColorArgb,
    String? icon,
  }) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection?> getById(int id) => throw UnimplementedError();
  @override
  Future<BookmarkCollection?> findBySlug(String slug) =>
      throw UnimplementedError();
  @override
  Future<List<BookmarkCollection>> getAll({bool includeArchived = false}) =>
      throw UnimplementedError();
  @override
  Future<List<BookmarkCollection>> getByIds(List<int> ids) =>
      throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<void> decrementItemCount(int collectionId) =>
      throw UnimplementedError();
  @override
  Future<int> recomputeItemCount(int collectionId) =>
      throw UnimplementedError();
  @override
  Future<Map<int, int>> recomputeAllItemCounts() => throw UnimplementedError();
  @override
  Stream<List<BookmarkCollection>> watchAll({bool includeArchived = false}) =>
      throw UnimplementedError();
  @override
  Stream<BookmarkCollection?> watchById(int id) => throw UnimplementedError();
}

class _FakeReminderRepo implements ReminderRepository {
  final List<Reminder> savedReminders = <Reminder>[];

  @override
  Future<Reminder> save(Reminder reminder) async {
    savedReminders.add(reminder);
    return reminder;
  }

  @override
  Future<Reminder?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<Reminder>> getByBookmarkId(int bookmarkId) =>
      throw UnimplementedError();
  @override
  Future<List<Reminder>> getUpcoming({
    required DateTime now,
    required Duration window,
  }) =>
      throw UnimplementedError();
  @override
  Future<List<Reminder>> getAllActive() => throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<int> deleteByBookmarkId(int bookmarkId) => throw UnimplementedError();
  @override
  Future<Reminder?> markFired(int id, {DateTime? firedAt}) =>
      throw UnimplementedError();
  @override
  Future<Reminder?> markSnoozed(int id, {required DateTime until}) =>
      throw UnimplementedError();
  @override
  Future<Reminder?> markCancelled(int id) => throw UnimplementedError();
  @override
  Stream<List<Reminder>> watchByBookmarkId(int bookmarkId) =>
      throw UnimplementedError();
  @override
  Stream<Reminder?> watchById(int id) => throw UnimplementedError();
}
