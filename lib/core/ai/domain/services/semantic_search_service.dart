import 'package:logger/logger.dart';
import 'package:marky/core/ai/domain/services/embedding_similarity_service.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Contract for services that perform semantic search over bookmarks.
///
/// Implementations are deterministic and never throw; they return an empty
/// list when no results are found, when AI is disabled, or when an error
/// occurs. This interface is designed to be future-proof — a full
/// embedding-based implementation can be swapped in without changing
/// consumers.
abstract class SemanticSearchService {
  /// Finds bookmarks most similar to [source] using whatever signals
  /// the implementation supports (embeddings, keywords, etc.).
  ///
  /// Results are sorted by relevance (descending) with a deterministic
  /// alphabetical tie-breaker on title.
  Future<List<BookmarkItem>> findSimilar(
    BookmarkItem source, {
    int limit = 10,
  });

  /// Performs a semantic search for bookmarks matching [query].
  ///
  /// The query is interpreted semantically — keyword overlap, embedding
  /// similarity, or both depending on the implementation.
  ///
  /// Results are sorted by relevance (descending) with a deterministic
  /// alphabetical tie-breaker on title.
  Future<List<BookmarkItem>> semanticSearch(
    String query, {
    int limit = 10,
  });
}

// ---------------------------------------------------------------------------
// Naive keyword-overlap implementation
// ---------------------------------------------------------------------------

/// A naive semantic search implementation that uses keyword overlap
/// as its primary signal.
///
/// ## findSimilar
/// Scores candidates using [EmbeddingSimilarityService.computeSimilarityFromBookmarks]
/// (keyword overlap in the naive case). The source bookmark is excluded.
///
/// ## semanticSearch
/// Tokenizes the query into keywords, then scores each bookmark by
/// keyword overlap between query tokens and [BookmarkItem.aiKeywords].
///
/// ## Vault Isolation
/// - Non-vault sources only see non-vault candidates.
/// - Vault sources see all candidates.
///
/// ## AI Toggle
/// When [aiEnabled] is false, both methods return empty lists immediately.
/// This allows the feature to be disabled without removing consumers.
class NaiveSemanticSearchService implements SemanticSearchService {
  NaiveSemanticSearchService({
    required BookmarkItemRepository repository,
    required EmbeddingSimilarityService similarityService,
    Logger? logger,
    bool aiEnabled = true,
  })  : _repository = repository,
        _similarityService = similarityService,
        _logger = logger ?? Logger(),
        _aiEnabled = aiEnabled;

  final BookmarkItemRepository _repository;
  final EmbeddingSimilarityService _similarityService;
  final Logger _logger;
  final bool _aiEnabled;

  @override
  Future<List<BookmarkItem>> findSimilar(
    BookmarkItem source, {
    int limit = 10,
  }) async {
    try {
      _logger.d(
        'NaiveSemanticSearch: findSimilar start for bookmark ${source.id}',
      );

      if (!_aiEnabled) {
        _logger.d(
          'NaiveSemanticSearch: aiEnabled=false, returning empty',
        );
        return [];
      }

      final all = await _repository.getAll();

      // Exclude the source bookmark itself.
      final candidates = all.where((b) => b.id != source.id).toList();

      // Apply vault isolation.
      final visibleCandidates = _applyVaultIsolation(source, candidates);

      if (visibleCandidates.isEmpty) {
        _logger.d(
          'NaiveSemanticSearch: bookmark ${source.id} — '
          'no candidates after filtering, returning empty',
        );
        return [];
      }

      // Score each candidate.
      final scored = <_ScoredBookmark>[];
      for (final candidate in visibleCandidates) {
        final score = _similarityService.computeSimilarityFromBookmarks(
          source,
          candidate,
        );
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
        'NaiveSemanticSearch: bookmark ${source.id} — '
        '${visibleCandidates.length} candidates, '
        'returning ${top.length} results',
      );

      return top;
    } catch (e, stack) {
      _logger.w(
        'NaiveSemanticSearch: error in findSimilar for bookmark '
        '${source.id}: $e',
        error: e,
        stackTrace: stack,
      );
      return [];
    }
  }

  @override
  Future<List<BookmarkItem>> semanticSearch(
    String query, {
    int limit = 10,
  }) async {
    try {
      _logger.d(
        'NaiveSemanticSearch: semanticSearch start for query "$query"',
      );

      if (!_aiEnabled) {
        _logger.d(
          'NaiveSemanticSearch: aiEnabled=false, returning empty',
        );
        return [];
      }

      final queryTokens = _tokenize(query);
      if (queryTokens.isEmpty) {
        _logger.d(
          'NaiveSemanticSearch: query "$query" produced no tokens, '
          'returning empty',
        );
        return [];
      }

      final all = await _repository.getAll();

      if (all.isEmpty) {
        _logger.d(
          'NaiveSemanticSearch: empty corpus, returning empty',
        );
        return [];
      }

      // Score each bookmark by keyword overlap with query tokens.
      final scored = <_ScoredBookmark>[];
      for (final bookmark in all) {
        final score = _scoreBookmarkByKeywords(bookmark, queryTokens);
        scored.add(_ScoredBookmark(bookmark, score));
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
        'NaiveSemanticSearch: query "$query" — '
        '${all.length} bookmarks scanned, returning ${top.length} results',
      );

      return top;
    } catch (e, stack) {
      _logger.w(
        'NaiveSemanticSearch: error in semanticSearch for query '
        '"$query": $e',
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

  /// Tokenizes a query string into lowercase keyword tokens.
  static Set<String> _tokenize(String query) {
    if (query.trim().isEmpty) return <String>{};
    return query
        .toLowerCase()
        .split(RegExp('[^a-z0-9]+'))
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  /// Computes keyword overlap score between a bookmark and query tokens.
  ///
  /// Score = intersection size / min(queryTokens.size, bookmarkKeywords.size)
  /// Returns 0.0 when either set is empty.
  double _scoreBookmarkByKeywords(
    BookmarkItem bookmark,
    Set<String> queryTokens,
  ) {
    final bookmarkKeywords = _toSet(bookmark.aiKeywords);
    if (bookmarkKeywords.isEmpty) return 0;

    final intersection = queryTokens.intersection(bookmarkKeywords);
    final minSize = queryTokens.length < bookmarkKeywords.length
        ? queryTokens.length
        : bookmarkKeywords.length;

    return intersection.length / minSize;
  }

  /// Normalizes a nullable keyword list into a case-insensitive Set.
  static Set<String> _toSet(List<String>? keywords) {
    if (keywords == null || keywords.isEmpty) return <String>{};
    return keywords.map((k) => k.toLowerCase().trim()).toSet();
  }
}

/// Internal helper that pairs a bookmark with its computed score.
class _ScoredBookmark {
  _ScoredBookmark(this.bookmark, this.score);

  final BookmarkItem bookmark;
  final double score;
}
