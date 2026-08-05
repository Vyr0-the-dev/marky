import 'package:isar/isar.dart';
import 'package:marky/core/database/base_repository.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Domain contract for [BookmarkItem] persistence and querying.
///
/// Implementations provide CRUD via [BaseRepository] plus bookmark-specific
/// lookups for deduplication, filtering, and relationship traversal.
abstract class BookmarkItemRepository implements BaseRepository<BookmarkItem> {
  /// Returns all entities of type [BookmarkItem], optionally paginated.
  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit});

  /// Returns the bookmark whose [BookmarkItem.urlHash] equals [urlHash].
  Future<BookmarkItem?> getByUrlHash(String urlHash);

  /// Returns the bookmark whose [BookmarkItem.canonicalUrl] equals [canonicalUrl].
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl);

  /// Returns the bookmark whose [BookmarkItem.externalContentId] equals [externalContentId].
  Future<BookmarkItem?> getByExternalContentId(String externalContentId);

  /// Returns all bookmarks whose [BookmarkItem.duplicateGroupId] equals [groupId].
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId);

  /// Returns all bookmarks marked as favorite.
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit});

  /// Returns all archived bookmarks.
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit});

  /// Returns bookmarks belonging to the collection with [collectionId].
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit});

  /// Returns bookmarks tagged with the tag having [tagId].
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit});

  /// Searches bookmarks using the parsed [query].
  ///
  /// Applies soft-delete guard, vault exclusion (unless `in:vault` operator
  /// is present), free-text OR matching across title/description/snippet/
  /// extractedText/originalUrl, and structured operator filters.
  ///
  /// Defaults to [limit] = 100 to keep all search paths bounded.
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit = 100});
}
