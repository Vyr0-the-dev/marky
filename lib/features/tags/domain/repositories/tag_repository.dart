import 'package:marky/core/database/base_repository.dart';
import 'package:marky/shared/models/tag.dart';

/// Domain contract for [Tag] persistence and querying.
///
/// Implementations provide CRUD via [BaseRepository] plus tag-specific
/// lookups for slug-based resolution.
abstract class TagRepository implements BaseRepository<Tag> {
  /// Returns the tag whose [Tag.slug] equals [slug].
  Future<Tag?> getBySlug(String slug);
}
