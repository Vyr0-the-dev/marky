import 'package:marky/core/ai/domain/models/embedding_document.dart';
import 'package:marky/core/database/base_repository.dart';

/// Domain contract for [EmbeddingDocument] persistence and querying.
///
/// Implementations provide CRUD via [BaseRepository] plus bookmark-specific
/// lookups for embedding-based semantic search.
abstract class EmbeddingRepository implements BaseRepository<EmbeddingDocument> {
  /// Returns the embedding whose [EmbeddingDocument.bookmarkId] equals [bookmarkId].
  Future<EmbeddingDocument?> getByBookmarkId(int bookmarkId);

  /// Deletes all embeddings whose [EmbeddingDocument.bookmarkId] equals [bookmarkId].
  ///
  /// No-op if no matching embeddings exist.
  Future<void> deleteByBookmarkId(int bookmarkId);
}
