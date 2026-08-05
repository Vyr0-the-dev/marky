import 'package:logger/logger.dart';
import 'package:marky/core/ai/domain/models/embedding_vector.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Contract for computing similarity between embeddings or bookmarks.
///
/// Implementations must be deterministic and never throw; they return 0.0
/// when inputs are invalid, incompatible, or insufficient for comparison.
abstract class EmbeddingSimilarityService {
  /// Computes similarity between two dense embedding vectors.
  ///
  /// Returns a value in the range [-1.0, 1.0] for cosine-based
  /// implementations, or [0.0, 1.0] for set-based implementations.
  /// Returns 0.0 when inputs are incompatible or invalid.
  double computeSimilarity(EmbeddingVector a, EmbeddingVector b);

  /// Computes similarity between two bookmarks using whatever signals
  /// the implementation supports (embeddings, keywords, etc.).
  ///
  /// Returns 0.0 when no comparable signals are available.
  double computeSimilarityFromBookmarks(BookmarkItem a, BookmarkItem b);
}

// ---------------------------------------------------------------------------
// Cosine similarity
// ---------------------------------------------------------------------------

/// Cosine similarity between dense embedding vectors.
///
/// Returns 1.0 for identical vectors, 0.0 for orthogonal vectors,
/// -1.0 for opposite vectors. Guards against zero-vectors and
/// dimension mismatches by returning 0.0 with debug logs.
class CosineEmbeddingSimilarity implements EmbeddingSimilarityService {
  CosineEmbeddingSimilarity({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  @override
  double computeSimilarity(EmbeddingVector a, EmbeddingVector b) {
    _logger.d(
      'CosineSimilarity: computing similarity between '
      '${a.dimensions}D and ${b.dimensions}D vectors',
    );

    if (a.dimensions != b.dimensions) {
      _logger.w(
        'CosineSimilarity: dimension mismatch — '
        '${a.dimensions} vs ${b.dimensions}, returning 0.0',
      );
      return 0;
    }

    final valuesA = a.values;
    final valuesB = b.values;

    var dotProduct = 0.0;
    var magnitudeA = 0.0;
    var magnitudeB = 0.0;

    for (var i = 0; i < valuesA.length; i++) {
      final va = valuesA[i];
      final vb = valuesB[i];
      dotProduct += va * vb;
      magnitudeA += va * va;
      magnitudeB += vb * vb;
    }

    magnitudeA = _sqrt(magnitudeA);
    magnitudeB = _sqrt(magnitudeB);

    if (magnitudeA == 0.0 || magnitudeB == 0.0) {
      _logger.d(
        'CosineSimilarity: zero-vector detected '
        '(|a|=$magnitudeA, |b|=$magnitudeB), returning 0.0',
      );
      return 0;
    }

    final similarity = dotProduct / (magnitudeA * magnitudeB);

    _logger.d(
      'CosineSimilarity: dot=$dotProduct, |a|=$magnitudeA, |b|=$magnitudeB, '
      'similarity=$similarity',
    );

    return similarity;
  }

  @override
  double computeSimilarityFromBookmarks(BookmarkItem a, BookmarkItem b) {
    // TODO: When ML integration is wired, resolve aiEmbeddingRef via
    // EmbeddingRepository and compute actual vector similarity.
    // For now, embeddings are not yet populated by the capture pipeline.
    _logger.d(
      'CosineSimilarity: bookmark-to-bookmark not yet implemented '
      '(aiEmbeddingRef is a future ML integration point), returning 0.0',
    );
    return 0;
  }

  /// Fast square-root approximation using Newton-Raphson.
  ///
  /// Sufficient for similarity scoring where high precision is not required.
  /// Falls back to [dart:math] sqrt if available at call site; kept inline
  /// here to avoid an import for a single call.
  static double _sqrt(double x) {
    if (x <= 0.0) return 0;
    var z = x;
    var prev = 0.0;
    // Converge quickly for typical embedding magnitudes
    for (var i = 0; i < 10; i++) {
      prev = z;
      z = (z + x / z) * 0.5;
      if ((z - prev).abs() < 1e-12) break;
    }
    return z;
  }
}

// ---------------------------------------------------------------------------
// Keyword overlap similarity
// ---------------------------------------------------------------------------

/// Keyword overlap coefficient between bookmark keyword sets.
///
/// overlap = |intersection| / min(|A|, |B|)
///
/// Returns 0.0 when either set is empty or when raw vector comparison
/// is requested (this implementation only supports bookmark-to-bookmark).
class KeywordOverlapSimilarity implements EmbeddingSimilarityService {
  KeywordOverlapSimilarity({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  @override
  double computeSimilarity(EmbeddingVector a, EmbeddingVector b) {
    _logger.d(
      'KeywordOverlapSimilarity: raw vector comparison not supported, '
      'returning 0.0',
    );
    return 0;
  }

  @override
  double computeSimilarityFromBookmarks(BookmarkItem a, BookmarkItem b) {
    final keywordsA = _toSet(a.aiKeywords);
    final keywordsB = _toSet(b.aiKeywords);

    _logger.d(
      'KeywordOverlapSimilarity: comparing bookmarks '
      '${a.id} (${keywordsA.length} keywords) vs '
      '${b.id} (${keywordsB.length} keywords)',
    );

    if (keywordsA.isEmpty || keywordsB.isEmpty) {
      _logger.d(
        'KeywordOverlapSimilarity: one or both keyword sets are empty, '
        'returning 0.0',
      );
      return 0;
    }

    final intersection = keywordsA.intersection(keywordsB);
    final minSize = keywordsA.length < keywordsB.length
        ? keywordsA.length
        : keywordsB.length;

    final similarity = intersection.length / minSize;

    _logger.d(
      'KeywordOverlapSimilarity: intersection=${intersection.length}, '
      'minSize=$minSize, similarity=$similarity',
    );

    return similarity;
  }

  /// Normalizes a nullable keyword list into a case-insensitive Set.
  static Set<String> _toSet(List<String>? keywords) {
    if (keywords == null || keywords.isEmpty) return <String>{};
    return keywords.map((k) => k.toLowerCase().trim()).toSet();
  }
}
