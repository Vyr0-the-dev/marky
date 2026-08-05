import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:marky/core/ai/domain/models/smart_tag_rule.dart';
import 'package:marky/core/ai/domain/services/smart_tag_engine_service.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/features/tags/domain/use_cases/assign_tags_to_bookmark_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/tag.dart';

// ---------------------------------------------------------------------------
// Fake implementations (no external mocking package)
// ---------------------------------------------------------------------------
class FakeTagRepository implements TagRepository {
  List<Tag> _tags = [];

  void setTags(List<Tag> tags) => _tags = tags;

  @override
  Future<List<Tag>> getAll() async => List.unmodifiable(_tags);

  @override
  Future<Tag?> getById(Id id) async =>
      _tags.cast<Tag?>().firstWhere((t) => t?.id == id, orElse: () => null);

  @override
  Future<Tag?> getBySlug(String slug) async => _tags.cast<Tag?>().firstWhere(
        (t) => t?.slug == slug,
        orElse: () => null,
      );

  @override
  Future<Id> insert(Tag entity) async {
    _tags.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(Tag entity) async => entity.id;

  @override
  Future<void> delete(Id id) async => _tags.removeWhere((t) => t.id == id);

  @override
  Future<void> clear() async => _tags.clear();
}

class FakeAssignTagsToBookmarkUseCase implements AssignTagsToBookmarkUseCase {
  final List<(Id, Id)> calls = [];

  @override
  Future<void> addTagToBookmark(Id bookmarkId, Id tagId) async {
    calls.add((bookmarkId, tagId));
  }

  @override
  Future<void> removeTagFromBookmark(Id bookmarkId, Id tagId) async {}

  @override
  Future<void> setTagsForBookmark(Id bookmarkId, List<Id> tagIds) async {}
}

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

BookmarkItem _makeBookmark({
  int id = 1,
  String originalUrl = 'https://example.com/page',
  String? canonicalUrl,
  String? resolvedUrl,
  String? normalizedHost,
  String? sourceDomain,
  String? title,
  List<String>? aiKeywords,
  String? aiCategory,
}) {
  final bm = BookmarkItem(
    originalUrl: originalUrl,
    canonicalUrl: canonicalUrl,
    resolvedUrl: resolvedUrl,
    normalizedHost: normalizedHost,
    sourceDomain: sourceDomain,
    title: title,
    aiKeywords: aiKeywords,
    aiCategory: aiCategory,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  bm.id = id; // Isar auto-increment — assign manually for tests
  return bm;
}

Tag _makeSmartTag({
  int id = 10,
  required String name,
  required String slug,
  String? ruleJson,
}) {
  final tag = Tag(
    name: name,
    slug: slug,
    isSmartTag: true,
    ruleJson: ruleJson,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  tag.id = id;
  return tag;
}

Tag _makeRegularTag({
  int id = 20,
  required String name,
  required String slug,
}) {
  final tag = Tag(
    name: name,
    slug: slug,
    isSmartTag: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  tag.id = id;
  return tag;
}

SmartTagRule _makeRule({
  int tagId = 10,
  required List<SmartTagRuleCondition> conditions,
  String matchOperator = 'all',
}) {
  return SmartTagRule(
    tagId: tagId,
    conditions: conditions,
    matchOperator: matchOperator,
  );
}

SmartTagRuleCondition _condition(
  SmartTagRuleConditionType type,
  String value,
) {
  return SmartTagRuleCondition(
    conditionType: type,
    config: <String, dynamic>{'value': value},
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeTagRepository fakeTagRepo;
  late FakeAssignTagsToBookmarkUseCase fakeAssignUseCase;
  late SmartTagEngineServiceImpl engine;

  setUp(() {
    fakeTagRepo = FakeTagRepository();
    fakeAssignUseCase = FakeAssignTagsToBookmarkUseCase();
    engine = SmartTagEngineServiceImpl(
      tagRepository: fakeTagRepo,
      assignTagsUseCase: fakeAssignUseCase,
      logger: Logger(level: Level.nothing),
    );
  });

  // -----------------------------------------------------------------
  // 1. domainContains matching
  // -----------------------------------------------------------------
  group('domainContains', () {
    test('matches when normalizedHost equals domain', () async {
      final tag = _makeSmartTag(
        id: 10,
        name: 'GitHub',
        slug: 'github',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 10,
            conditions: [
              _condition(SmartTagRuleConditionType.domainContains, 'github.com'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(normalizedHost: 'github.com');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 10)));
    });

    test('matches when sourceDomain equals domain (fallback)', () async {
      final tag = _makeSmartTag(
        id: 10,
        name: 'GitHub',
        slug: 'github',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 10,
            conditions: [
              _condition(SmartTagRuleConditionType.domainContains, 'github.com'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(
        normalizedHost: null,
        sourceDomain: 'github.com',
      );
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 10)));
    });

    test('does not match when domain is different', () async {
      final tag = _makeSmartTag(
        id: 10,
        name: 'GitHub',
        slug: 'github',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 10,
            conditions: [
              _condition(SmartTagRuleConditionType.domainContains, 'github.com'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(normalizedHost: 'gitlab.com');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });
  });

  // -----------------------------------------------------------------
  // 2. titleContains matching
  // -----------------------------------------------------------------
  group('titleContains', () {
    test('matches when title contains keyword (case-insensitive)', () async {
      final tag = _makeSmartTag(
        id: 11,
        name: 'Flutter',
        slug: 'flutter',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 11,
            conditions: [
              _condition(SmartTagRuleConditionType.titleContains, 'flutter'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(title: 'Advanced Flutter Patterns');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 11)));
    });

    test('matches uppercase query against lowercase title', () async {
      final tag = _makeSmartTag(
        id: 11,
        name: 'Flutter',
        slug: 'flutter',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 11,
            conditions: [
              _condition(SmartTagRuleConditionType.titleContains, 'FLUTTER'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(title: 'advanced flutter patterns');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 11)));
    });

    test('does not match when title is null', () async {
      final tag = _makeSmartTag(
        id: 11,
        name: 'Flutter',
        slug: 'flutter',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 11,
            conditions: [
              _condition(SmartTagRuleConditionType.titleContains, 'flutter'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(title: null);
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });
  });

  // -----------------------------------------------------------------
  // 3. keywordContains matching
  // -----------------------------------------------------------------
  group('keywordContains', () {
    test('matches when aiKeywords contains keyword', () async {
      final tag = _makeSmartTag(
        id: 12,
        name: 'Dart',
        slug: 'dart',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 12,
            conditions: [
              _condition(SmartTagRuleConditionType.keywordContains, 'dart'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(aiKeywords: ['flutter', 'dart', 'riverpod']);
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 12)));
    });

    test('is case-insensitive', () async {
      final tag = _makeSmartTag(
        id: 12,
        name: 'Dart',
        slug: 'dart',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 12,
            conditions: [
              _condition(SmartTagRuleConditionType.keywordContains, 'DART'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(aiKeywords: ['dart']);
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 12)));
    });

    test('does not match partial keyword', () async {
      final tag = _makeSmartTag(
        id: 12,
        name: 'Dart',
        slug: 'dart',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 12,
            conditions: [
              _condition(SmartTagRuleConditionType.keywordContains, 'dar'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(aiKeywords: ['dart']);
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });

    test('does not match when aiKeywords is null', () async {
      final tag = _makeSmartTag(
        id: 12,
        name: 'Dart',
        slug: 'dart',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 12,
            conditions: [
              _condition(SmartTagRuleConditionType.keywordContains, 'dart'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(aiKeywords: null);
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });
  });

  // -----------------------------------------------------------------
  // 4. urlContains matching
  // -----------------------------------------------------------------
  group('urlContains', () {
    test('matches when originalUrl contains substring', () async {
      final tag = _makeSmartTag(
        id: 13,
        name: 'YouTube',
        slug: 'youtube',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 13,
            conditions: [
              _condition(SmartTagRuleConditionType.urlContains, 'youtube.com'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(originalUrl: 'https://youtube.com/watch?v=123');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 13)));
    });

    test('matches when canonicalUrl contains substring', () async {
      final tag = _makeSmartTag(
        id: 13,
        name: 'YouTube',
        slug: 'youtube',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 13,
            conditions: [
              _condition(SmartTagRuleConditionType.urlContains, 'youtube.com'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(
        originalUrl: 'https://example.com/redirect',
        canonicalUrl: 'https://youtube.com/watch?v=123',
      );
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 13)));
    });
  });

  // -----------------------------------------------------------------
  // 5. categoryEquals matching
  // -----------------------------------------------------------------
  group('categoryEquals', () {
    test('matches when aiCategory equals value', () async {
      final tag = _makeSmartTag(
        id: 14,
        name: 'Dev',
        slug: 'dev',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 14,
            conditions: [
              _condition(SmartTagRuleConditionType.categoryEquals, 'development'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(aiCategory: 'development');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 14)));
    });

    test('is case-insensitive', () async {
      final tag = _makeSmartTag(
        id: 14,
        name: 'Dev',
        slug: 'dev',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 14,
            conditions: [
              _condition(SmartTagRuleConditionType.categoryEquals, 'DEVELOPMENT'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(aiCategory: 'development');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 14)));
    });

    test('does not match partial category', () async {
      final tag = _makeSmartTag(
        id: 14,
        name: 'Dev',
        slug: 'dev',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 14,
            conditions: [
              _condition(SmartTagRuleConditionType.categoryEquals, 'develop'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(aiCategory: 'development');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });
  });

  // -----------------------------------------------------------------
  // 6. matchOperator: all
  // -----------------------------------------------------------------
  group('matchOperator all', () {
    test('matches only when ALL conditions pass', () async {
      final tag = _makeSmartTag(
        id: 15,
        name: 'Flutter Dev',
        slug: 'flutter-dev',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 15,
            conditions: [
              _condition(SmartTagRuleConditionType.domainContains, 'github.com'),
              _condition(SmartTagRuleConditionType.titleContains, 'flutter'),
            ],
            matchOperator: 'all',
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      // Both conditions pass
      final bookmark = _makeBookmark(
        normalizedHost: 'github.com',
        title: 'Flutter Tips',
      );
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 15)));
    });

    test('does not match when one condition fails', () async {
      final tag = _makeSmartTag(
        id: 15,
        name: 'Flutter Dev',
        slug: 'flutter-dev',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 15,
            conditions: [
              _condition(SmartTagRuleConditionType.domainContains, 'github.com'),
              _condition(SmartTagRuleConditionType.titleContains, 'flutter'),
            ],
            matchOperator: 'all',
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      // Title matches but domain does not
      final bookmark = _makeBookmark(
        normalizedHost: 'gitlab.com',
        title: 'Flutter Tips',
      );
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });
  });

  // -----------------------------------------------------------------
  // 7. matchOperator: any
  // -----------------------------------------------------------------
  group('matchOperator any', () {
    test('matches when ANY condition passes', () async {
      final tag = _makeSmartTag(
        id: 16,
        name: 'Any Flutter',
        slug: 'any-flutter',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 16,
            conditions: [
              _condition(SmartTagRuleConditionType.domainContains, 'github.com'),
              _condition(SmartTagRuleConditionType.titleContains, 'flutter'),
            ],
            matchOperator: 'any',
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      // Only title matches
      final bookmark = _makeBookmark(
        normalizedHost: 'gitlab.com',
        title: 'Flutter Tips',
      );
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 16)));
    });

    test('does not match when no conditions pass', () async {
      final tag = _makeSmartTag(
        id: 16,
        name: 'Any Flutter',
        slug: 'any-flutter',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 16,
            conditions: [
              _condition(SmartTagRuleConditionType.domainContains, 'github.com'),
              _condition(SmartTagRuleConditionType.titleContains, 'flutter'),
            ],
            matchOperator: 'any',
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(
        normalizedHost: 'gitlab.com',
        title: 'Rust Tips',
      );
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });
  });

  // -----------------------------------------------------------------
  // 8. Malformed ruleJson
  // -----------------------------------------------------------------
  group('malformed ruleJson', () {
    test('skips gracefully when ruleJson is invalid JSON', () async {
      final tag = _makeSmartTag(
        id: 17,
        name: 'Broken',
        slug: 'broken',
        ruleJson: 'not valid json',
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark();
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });

    test('skips gracefully when ruleJson is null', () async {
      final tag = _makeSmartTag(
        id: 17,
        name: 'Broken',
        slug: 'broken',
        ruleJson: null,
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark();
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });
  });

  // -----------------------------------------------------------------
  // 9. Non-smart tags are ignored
  // -----------------------------------------------------------------
  group('non-smart tags', () {
    test('ignores regular tags', () async {
      final regularTag = _makeRegularTag(
        id: 20,
        name: 'Manual',
        slug: 'manual',
      );
      fakeTagRepo.setTags([regularTag]);

      final bookmark = _makeBookmark();
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });
  });

  // -----------------------------------------------------------------
  // 10. Usage count via assign use case
  // -----------------------------------------------------------------
  group('usage count consistency', () {
    test('calls addTagToBookmark for matching tag', () async {
      final tag = _makeSmartTag(
        id: 21,
        name: 'Match',
        slug: 'match',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 21,
            conditions: [
              _condition(SmartTagRuleConditionType.titleContains, 'test'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(title: 'test page');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, [(bookmark.id, 21)]);
    });
  });

  // -----------------------------------------------------------------
  // 11. Duplicate assignments are idempotent
  // -----------------------------------------------------------------
  group('idempotency', () {
    test('assign use case handles duplicate gracefully', () async {
      final tag = _makeSmartTag(
        id: 22,
        name: 'Idempotent',
        slug: 'idempotent',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 22,
            conditions: [
              _condition(SmartTagRuleConditionType.titleContains, 'dart'),
            ],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(title: 'dart tutorial');

      // Evaluate twice — the use case itself is idempotent
      await engine.evaluate(bookmark);
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls.length, 2);
      expect(fakeAssignUseCase.calls, [(bookmark.id, 22), (bookmark.id, 22)]);
    });
  });

  // -----------------------------------------------------------------
  // 12. Model JSON serialization
  // -----------------------------------------------------------------
  group('SmartTagRule JSON serialization', () {
    test('toJson and fromJson round-trip preserves data', () {
      final rule = _makeRule(
        tagId: 42,
        conditions: [
          _condition(SmartTagRuleConditionType.domainContains, 'github.com'),
          _condition(SmartTagRuleConditionType.titleContains, 'flutter'),
        ],
        matchOperator: 'any',
      );

      final json = rule.toJson();
      final restored = SmartTagRule.fromJson(json);

      expect(restored.tagId, 42);
      expect(restored.matchOperator, 'any');
      expect(restored.version, 1);
      expect(restored.conditions.length, 2);
      expect(restored.conditions[0].conditionType,
          SmartTagRuleConditionType.domainContains);
      expect(restored.conditions[0].config['value'], 'github.com');
      expect(restored.conditions[1].conditionType,
          SmartTagRuleConditionType.titleContains);
      expect(restored.conditions[1].config['value'], 'flutter');
    });

    test('fromJson uses defaults for missing optional fields', () {
      final json = <String, dynamic>{
        'tagId': 99,
        'conditions': [
          {
            'conditionType': 'keywordContains',
            'config': {'value': 'dart'},
          },
        ],
      };

      final rule = SmartTagRule.fromJson(json);

      expect(rule.tagId, 99);
      expect(rule.matchOperator, 'all');
      expect(rule.version, 1);
      expect(rule.conditions.length, 1);
    });

    test('ruleJson can be parsed after jsonEncode', () {
      final rule = _makeRule(
        tagId: 10,
        conditions: [
          _condition(SmartTagRuleConditionType.categoryEquals, 'video'),
        ],
      );

      final encoded = jsonEncode(rule.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final restored = SmartTagRule.fromJson(decoded);

      expect(restored.tagId, 10);
      expect(restored.conditions[0].config['value'], 'video');
    });
  });

  // -----------------------------------------------------------------
  // 13. Empty conditions
  // -----------------------------------------------------------------
  group('empty conditions', () {
    test('rule with no conditions does not match', () async {
      final tag = _makeSmartTag(
        id: 23,
        name: 'Empty',
        slug: 'empty',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 23,
            conditions: [],
          ).toJson(),
        ),
      );
      fakeTagRepo.setTags([tag]);

      final bookmark = _makeBookmark(title: 'anything');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, isEmpty);
    });
  });

  // -----------------------------------------------------------------
  // 14. Multiple tags evaluated independently
  // -----------------------------------------------------------------
  group('multiple tags', () {
    test('evaluates all smart tags independently', () async {
      final tag1 = _makeSmartTag(
        id: 30,
        name: 'GitHub',
        slug: 'github',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 30,
            conditions: [
              _condition(SmartTagRuleConditionType.domainContains, 'github.com'),
            ],
          ).toJson(),
        ),
      );

      final tag2 = _makeSmartTag(
        id: 31,
        name: 'Flutter',
        slug: 'flutter',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 31,
            conditions: [
              _condition(SmartTagRuleConditionType.titleContains, 'flutter'),
            ],
          ).toJson(),
        ),
      );

      fakeTagRepo.setTags([tag1, tag2]);

      final bookmark = _makeBookmark(
        normalizedHost: 'github.com',
        title: 'flutter tutorial',
      );
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, contains((bookmark.id, 30)));
      expect(fakeAssignUseCase.calls, contains((bookmark.id, 31)));
      expect(fakeAssignUseCase.calls.length, 2);
    });

    test('one failing rule does not stop other rules', () async {
      final brokenTag = _makeSmartTag(
        id: 30,
        name: 'Broken',
        slug: 'broken',
        ruleJson: 'invalid json',
      );

      final goodTag = _makeSmartTag(
        id: 31,
        name: 'Good',
        slug: 'good',
        ruleJson: jsonEncode(
          _makeRule(
            tagId: 31,
            conditions: [
              _condition(SmartTagRuleConditionType.titleContains, 'test'),
            ],
          ).toJson(),
        ),
      );

      fakeTagRepo.setTags([brokenTag, goodTag]);

      final bookmark = _makeBookmark(title: 'test page');
      await engine.evaluate(bookmark);

      expect(fakeAssignUseCase.calls, [(bookmark.id, 31)]);
    });
  });
}
