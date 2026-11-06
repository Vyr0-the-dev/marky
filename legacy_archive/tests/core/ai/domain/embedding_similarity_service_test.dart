import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/ai/domain/models/embedding_vector.dart';
import 'package:marky/core/ai/domain/services/embedding_similarity_service.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

BookmarkItem _makeBookmark({
  int id = 1,
  List<String>? aiKeywords,
}) {
  return BookmarkItem(
    originalUrl: 'https://example.com',
    aiKeywords: aiKeywords,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  )..id = id;
}

EmbeddingVector _makeVector(List<double> values) {
  return EmbeddingVector(
    values: values,
    dimensions: values.length,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CosineEmbeddingSimilarity', () {
    late CosineEmbeddingSimilarity service;

    setUp(() {
      service = CosineEmbeddingSimilarity();
    });

    // ── computeSimilarity ───────────────────────────────────────────────

    test('identical vectors → 1.0', () {
      final a = _makeVector([1.0, 2.0, 3.0]);
      final b = _makeVector([1.0, 2.0, 3.0]);

      expect(service.computeSimilarity(a, b), closeTo(1.0, 1e-9));
    });

    test('orthogonal vectors → 0.0', () {
      final a = _makeVector([1.0, 0.0, 0.0]);
      final b = _makeVector([0.0, 1.0, 0.0]);

      expect(service.computeSimilarity(a, b), closeTo(0.0, 1e-9));
    });

    test('opposite vectors → -1.0', () {
      final a = _makeVector([1.0, 2.0, 3.0]);
      final b = _makeVector([-1.0, -2.0, -3.0]);

      expect(service.computeSimilarity(a, b), closeTo(-1.0, 1e-9));
    });

    test('zero vector → 0.0', () {
      final a = _makeVector([0.0, 0.0, 0.0]);
      final b = _makeVector([1.0, 2.0, 3.0]);

      expect(service.computeSimilarity(a, b), 0.0);
    });

    test('dimension mismatch → 0.0', () {
      final a = _makeVector([1.0, 2.0]);
      final b = _makeVector([1.0, 2.0, 3.0]);

      expect(service.computeSimilarity(a, b), 0.0);
    });

    test('different length vectors (both 3D but different values)', () {
      // This test verifies that vectors of same dimension but different
      // magnitudes produce a valid cosine similarity.
      final a = _makeVector([1.0, 0.0, 0.0]);
      final b = _makeVector([1.0, 1.0, 0.0]);

      // cos(45°) = 1/√2 ≈ 0.7071
      expect(service.computeSimilarity(a, b), closeTo(0.70710678, 1e-6));
    });

    // ── computeSimilarityFromBookmarks ──────────────────────────────────

    test('bookmark-to-bookmark returns 0.0 (placeholder)', () {
      final a = _makeBookmark(id: 1);
      final b = _makeBookmark(id: 2);

      expect(service.computeSimilarityFromBookmarks(a, b), 0.0);
    });
  });

  group('KeywordOverlapSimilarity', () {
    late KeywordOverlapSimilarity service;

    setUp(() {
      service = KeywordOverlapSimilarity();
    });

    // ── computeSimilarity (raw vectors not supported) ───────────────────

    test('raw vector comparison returns 0.0', () {
      final a = _makeVector([1.0, 2.0, 3.0]);
      final b = _makeVector([1.0, 2.0, 3.0]);

      expect(service.computeSimilarity(a, b), 0.0);
    });

    // ── computeSimilarityFromBookmarks ──────────────────────────────────

    test('identical keywords → 1.0', () {
      final a = _makeBookmark(
        id: 1,
        aiKeywords: ['flutter', 'dart', 'riverpod'],
      );
      final b = _makeBookmark(
        id: 2,
        aiKeywords: ['flutter', 'dart', 'riverpod'],
      );

      expect(service.computeSimilarityFromBookmarks(a, b), 1.0);
    });

    test('no overlap → 0.0', () {
      final a = _makeBookmark(
        id: 1,
        aiKeywords: ['flutter', 'dart'],
      );
      final b = _makeBookmark(
        id: 2,
        aiKeywords: ['python', 'java'],
      );

      expect(service.computeSimilarityFromBookmarks(a, b), 0.0);
    });

    test('partial overlap → expected fractional value', () {
      final a = _makeBookmark(
        id: 1,
        aiKeywords: ['flutter', 'dart', 'riverpod'],
      );
      final b = _makeBookmark(
        id: 2,
        aiKeywords: ['flutter', 'dart', 'bloc'],
      );

      // intersection = 2, min(|A|, |B|) = 3 → 2/3 ≈ 0.666...
      expect(
        service.computeSimilarityFromBookmarks(a, b),
        closeTo(2.0 / 3.0, 1e-9),
      );
    });

    test('null keywords → 0.0', () {
      final a = _makeBookmark(id: 1, aiKeywords: null);
      final b = _makeBookmark(id: 2, aiKeywords: null);

      expect(service.computeSimilarityFromBookmarks(a, b), 0.0);
    });

    test('one null, one non-null → 0.0', () {
      final a = _makeBookmark(
        id: 1,
        aiKeywords: ['flutter', 'dart'],
      );
      final b = _makeBookmark(id: 2, aiKeywords: null);

      expect(service.computeSimilarityFromBookmarks(a, b), 0.0);
    });

    test('case insensitivity', () {
      final a = _makeBookmark(
        id: 1,
        aiKeywords: ['Flutter', 'DART'],
      );
      final b = _makeBookmark(
        id: 2,
        aiKeywords: ['flutter', 'dart'],
      );

      expect(service.computeSimilarityFromBookmarks(a, b), 1.0);
    });

    test('empty keyword list → 0.0', () {
      final a = _makeBookmark(id: 1, aiKeywords: []);
      final b = _makeBookmark(
        id: 2,
        aiKeywords: ['flutter'],
      );

      expect(service.computeSimilarityFromBookmarks(a, b), 0.0);
    });

    test('asymmetric sets with subset overlap', () {
      final a = _makeBookmark(
        id: 1,
        aiKeywords: ['flutter', 'dart', 'riverpod', 'bloc'],
      );
      final b = _makeBookmark(
        id: 2,
        aiKeywords: ['flutter', 'dart'],
      );

      // intersection = 2, min(|A|, |B|) = 2 → 2/2 = 1.0
      expect(service.computeSimilarityFromBookmarks(a, b), 1.0);
    });
  });
}
