import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/core/ai/domain/repositories/embedding_repository.dart';
import 'package:marky/core/ai/domain/services/embedding_similarity_service.dart';
import 'package:marky/core/database/isar_service.dart';
import 'package:marky/features/ai/data/repositories/embedding_repository_impl.dart';

// ─── Repository provider ───────────────────────────────────────────────

/// Provider that exposes the live [EmbeddingRepository].
///
/// Throws [StateError] if the database has not been opened yet.
final Provider<EmbeddingRepository> embeddingRepositoryProvider =
    Provider<EmbeddingRepository>((Ref ref) {
  final isar = IsarService.instance.isar;
  if (isar == null) {
    throw StateError(
      'Isar database not initialized. '
      'Ensure IsarService.instance.open() is called during app bootstrap.',
    );
  }
  return EmbeddingRepositoryImpl(isar: isar);
});

// ─── Similarity service provider ───────────────────────────────────────

/// Provider for [EmbeddingSimilarityService].
///
/// Currently returns [KeywordOverlapSimilarity] as the naive
/// implementation. This can be swapped to [CosineEmbeddingSimilarity]
/// when ML-generated embeddings are wired into the capture pipeline.
final Provider<EmbeddingSimilarityService> embeddingSimilarityServiceProvider =
    Provider<EmbeddingSimilarityService>((Ref ref) {
  return KeywordOverlapSimilarity();
});
