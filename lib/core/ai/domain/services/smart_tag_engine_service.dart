import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:marky/core/ai/domain/models/smart_tag_rule.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/features/tags/domain/use_cases/assign_tags_to_bookmark_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/tag.dart';

/// Contract for evaluating smart-tag rules against a bookmark.
// ignore: one_member_abstracts
abstract class SmartTagEngineService {
  /// Evaluates all smart-tag rules against [bookmark] and auto-assigns
  /// matching tags.
  ///
  /// Errors per-tag are swallowed so one bad rule cannot break the whole
  /// evaluation. The bookmark remains usable regardless of enrichment
  /// outcome.
  Future<void> evaluate(BookmarkItem bookmark);
}

/// Default implementation of [SmartTagEngineService].
///
/// Loads all smart tags, parses their [Tag.ruleJson], evaluates conditions
/// against the bookmark, and assigns matching tags via
/// [AssignTagsToBookmarkUseCase] to keep [Tag.usageCount] consistent.
class SmartTagEngineServiceImpl implements SmartTagEngineService {
  SmartTagEngineServiceImpl({
    required TagRepository tagRepository,
    required AssignTagsToBookmarkUseCase assignTagsUseCase,
    Logger? logger,
  })  : _tagRepository = tagRepository,
        _assignTagsUseCase = assignTagsUseCase,
        _logger = logger ?? Logger();

  final TagRepository _tagRepository;
  final AssignTagsToBookmarkUseCase _assignTagsUseCase;
  final Logger _logger;

  @override
  Future<void> evaluate(BookmarkItem bookmark) async {
    _logger.d(
      'SmartTagEngine: starting evaluation for bookmark ${bookmark.id}',
    );

    final allTags = await _tagRepository.getAll();
    final smartTags = allTags.where((t) => t.isSmartTag).toList();

    if (smartTags.isEmpty) {
      _logger.d('SmartTagEngine: no smart tags found, nothing to evaluate');
      return;
    }

    int matchedCount = 0;

    for (final tag in smartTags) {
      try {
        final rule = _parseRule(tag);
        if (rule == null) continue;

        final matches = _evaluateRule(rule, bookmark);
        if (matches) {
          await _assignTagsUseCase.addTagToBookmark(bookmark.id, tag.id);
          matchedCount++;
        }
      } catch (e, stack) {
        _logger.w(
          'SmartTagEngine: error evaluating tag ${tag.id} (${tag.name}): $e',
          error: e,
          stackTrace: stack,
        );
        // Swallow per-tag errors — one bad rule must not break others.
      }
    }

    _logger.d(
      'SmartTagEngine: evaluated ${smartTags.length} smart tags, '
      '$matchedCount matched for bookmark ${bookmark.id}',
    );
  }

  // ─── Parsing ───────────────────────────────────────────────────────────

  /// Parses [tag.ruleJson] into a [SmartTagRule] or returns `null` on failure.
  SmartTagRule? _parseRule(Tag tag) {
    final jsonString = tag.ruleJson;
    if (jsonString == null || jsonString.isEmpty) {
      _logger.w(
        'SmartTagEngine: tag ${tag.id} (${tag.name}) has no ruleJson — skipping',
      );
      return null;
    }

    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return SmartTagRule.fromJson(decoded);
    } catch (e, stack) {
      _logger.w(
        'SmartTagEngine: malformed ruleJson for tag ${tag.id} '
        '(${tag.name}): $e',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  // ─── Evaluation ────────────────────────────────────────────────────────

  /// Returns `true` when [rule] matches [bookmark] according to its
  /// [SmartTagRule.matchOperator].
  bool _evaluateRule(SmartTagRule rule, BookmarkItem bookmark) {
    if (rule.conditions.isEmpty) {
      return false; // No conditions means no match.
    }

    final results = rule.conditions.map((c) => _evaluateCondition(c, bookmark));

    return switch (rule.matchOperator) {
      'any' => results.any((r) => r),
      _ => results.every((r) => r), // default 'all'
    };
  }

  /// Evaluates a single [condition] against [bookmark].
  bool _evaluateCondition(
    SmartTagRuleCondition condition,
    BookmarkItem bookmark,
  ) {
    final config = condition.config;
    final value = (config['value'] as String?) ?? '';
    if (value.isEmpty) return false;

    final lowerValue = value.toLowerCase();

    return switch (condition.conditionType) {
      SmartTagRuleConditionType.domainContains => _anyContains(
          [bookmark.normalizedHost, bookmark.sourceDomain],
          lowerValue,
        ),
      SmartTagRuleConditionType.urlContains => _anyContains(
          [bookmark.originalUrl, bookmark.canonicalUrl, bookmark.resolvedUrl],
          lowerValue,
        ),
      SmartTagRuleConditionType.titleContains => _contains(
          bookmark.title,
          lowerValue,
        ),
      SmartTagRuleConditionType.keywordContains => _listContains(
          bookmark.aiKeywords,
          lowerValue,
        ),
      SmartTagRuleConditionType.categoryEquals => _equals(
          bookmark.aiCategory,
          lowerValue,
        ),
    };
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  bool _contains(String? field, String lowerValue) {
    if (field == null || field.isEmpty) return false;
    return field.toLowerCase().contains(lowerValue);
  }

  bool _anyContains(List<String?> fields, String lowerValue) {
    for (final field in fields) {
      if (_contains(field, lowerValue)) return true;
    }
    return false;
  }

  bool _listContains(List<String>? list, String lowerValue) {
    if (list == null || list.isEmpty) return false;
    for (final item in list) {
      if (item.toLowerCase() == lowerValue) return true;
    }
    return false;
  }

  bool _equals(String? field, String lowerValue) {
    if (field == null || field.isEmpty) return false;
    return field.toLowerCase() == lowerValue;
  }
}
