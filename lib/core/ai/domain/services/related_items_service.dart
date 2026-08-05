import 'package:logger/logger.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Contract for services that find bookmarks related to a given source.
///
/// Implementations are deterministic and never throw; they return an empty
/// list when no related items are found or when an error occurs.
// ignore: one_member_abstracts
abstract class RelatedItemsService {
  /// Returns up to [limit] bookmarks that are most similar to [source].
  ///
  /// Results are sorted by relevance (descending) with a deterministic
  /// alphabetical tie-breaker on title.
  Future<List<BookmarkItem>> findRelated(
    BookmarkItem source, {
    int limit = 10,
  });
}

/// A heuristic implementation of [RelatedItemsService] that scores candidates
/// by multi-criteria overlap with the source bookmark.
///
/// ## Scoring
/// - Shared AI keyword: +2 points per keyword
/// - Same AI category: +2 points
/// - Same domain (sourceDomain): +1 point
/// - Shared tag: +1 point per tag
///
/// ## Vault Isolation
/// - Non-vault sources only see non-vault candidates.
/// - Vault sources see all candidates (vault + non-vault).
///
/// The source bookmark itself is always excluded.
///
/// The service calls `getAll()` on the repository so it can later be
/// replaced with a targeted query without changing the interface.
class HeuristicRelatedItemsService implements RelatedItemsService {
  HeuristicRelatedItemsService({
    required BookmarkItemRepository repository,
    Logger? logger,
  })  : _repository = repository,
        _logger = logger ?? Logger();

  final BookmarkItemRepository _repository;
  final Logger _logger;

  static const int _keywordScore = 2;
  static const int _categoryScore = 2;
  static const int _domainScore = 1;
  static const int _tagScore = 1;

  @override
  Future<List<BookmarkItem>> findRelated(
    BookmarkItem source, {
    int limit = 10,
  }) async {
    try {
      _logger.d(
        'RelatedItems: starting search for bookmark ${source.id}',
      );

      final all = await _repository.getAll();

      // Exclude the source bookmark itself.
      final candidates = all.where((b) => b.id != source.id).toList();

      // Apply vault isolation.
      final visibleCandidates = _applyVaultIsolation(source, candidates);

      if (visibleCandidates.isEmpty) {
        _logger.d(
          'RelatedItems: bookmark ${source.id} — no candidates after '
          'filtering, returning empty',
        );
        return [];
      }

      // Score each candidate.
      final scored = <_ScoredBookmark>[];
      for (final candidate in visibleCandidates) {
        final score = _computeScore(source, candidate);
        scored.add(_ScoredBookmark(candidate, score));
      }

      // Sort by score desc, then title asc for determinism.
      scored.sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;
        return (a.bookmark.title ?? '')
            .toLowerCase()
            .compareTo((b.bookmark.title ?? '').toLowerCase());
      });

      final top = scored.take(limit).map((s) => s.bookmark).toList();

      _logger.d(
        'RelatedItems: bookmark ${source.id} — '
        '${visibleCandidates.length} candidates, '
        'top score ${scored.first.score}, returning ${top.length} results',
      );

      return top;
    } catch (e, stack) {
      _logger.w(
        'RelatedItems: error finding related for bookmark ${source.id}: $e',
        error: e,
        stackTrace: stack,
      );
      return [];
    }
  }

  /// Returns candidates visible to [source] according to vault isolation rules.
  List<BookmarkItem> _applyVaultIsolation(
    BookmarkItem source,
    List<BookmarkItem> candidates,
  ) {
    if (source.isInVault) {
      // Vault sources can see everything.
      return candidates;
    }
    // Non-vault sources only see non-vault candidates.
    return candidates.where((c) => !c.isInVault).toList();
  }

  /// Computes the overlap score between [source] and [candidate].
  int _computeScore(BookmarkItem source, BookmarkItem candidate) {
    var score = 0;

    // AI keywords overlap.
    final sourceKeywords = _toSet(source.aiKeywords);
    final candidateKeywords = _toSet(candidate.aiKeywords);
    if (sourceKeywords.isNotEmpty && candidateKeywords.isNotEmpty) {
      final shared = sourceKeywords.intersection(candidateKeywords);
      score += shared.length * _keywordScore;
    }

    // Category match.
    final sourceCategory = source.aiCategory;
    final candidateCategory = candidate.aiCategory;
    if (sourceCategory != null &&
        candidateCategory != null &&
        sourceCategory.toLowerCase() == candidateCategory.toLowerCase()) {
      score += _categoryScore;
    }

    // Domain match.
    final sourceDomain = source.sourceDomain;
    final candidateDomain = candidate.sourceDomain;
    if (sourceDomain != null &&
        candidateDomain != null &&
        sourceDomain.toLowerCase() == candidateDomain.toLowerCase()) {
      score += _domainScore;
    }

    // Shared tags.
    final sourceTags = _toSet(source.tagIds);
    final candidateTags = _toSet(candidate.tagIds);
    if (sourceTags.isNotEmpty && candidateTags.isNotEmpty) {
      final shared = sourceTags.intersection(candidateTags);
      score += shared.length * _tagScore;
    }

    return score;
  }

  /// Safely converts a nullable list into a non-null Set.
  Set<T> _toSet<T>(List<T>? list) {
    if (list == null) return <T>{};
    return list.toSet();
  }
}

/// Internal helper that pairs a bookmark with its computed score.
class _ScoredBookmark {
  _ScoredBookmark(this.bookmark, this.score);

  final BookmarkItem bookmark;
  final int score;
}
