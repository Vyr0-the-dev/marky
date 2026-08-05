import 'package:isar/isar.dart';

part 'embedding_document.g.dart';

/// Isar collection storing pre-computed embedding vectors for bookmarks.
///
/// Each document holds a dense vector along with metadata about the model
/// that produced it. The [bookmarkId] is indexed for fast lookups.
@collection
class EmbeddingDocument {
  EmbeddingDocument({
    required this.bookmarkId,
    required this.values,
    required this.dimensions,
    this.modelName,
    required this.createdAt,
  });

  /// Auto-increment primary key.
  Id id = Isar.autoIncrement;

  /// Reference to the bookmark this embedding belongs to.
  @Index()
  int bookmarkId;

  /// The dense embedding vector values.
  List<double> values;

  /// Declared dimensionality of the vector.
  int dimensions;

  /// Optional name of the embedding model (e.g. 'all-MiniLM-L6-v2').
  String? modelName;

  /// When this embedding was computed and stored.
  DateTime createdAt;
}
