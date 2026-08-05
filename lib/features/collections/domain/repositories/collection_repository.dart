import 'package:marky/core/database/base_repository.dart';
import 'package:marky/shared/models/collection.dart';

/// Domain contract for [BookmarkCollection] persistence and querying.
///
/// Implementations provide CRUD via [BaseRepository] plus collection-specific
/// lookups for slug-based resolution.
abstract class CollectionRepository implements BaseRepository<BookmarkCollection> {
  /// Returns the collection whose [BookmarkCollection.slug] equals [slug].
  Future<BookmarkCollection?> getBySlug(String slug);
}
