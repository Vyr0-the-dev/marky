import 'package:isar/isar.dart';

import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Isar-backed implementation of [BookmarkItemRepository].
///
/// Expects [isar] to be an open database instance that includes
/// [BookmarkItemSchema].
///
/// Optionally accepts a [tagRepository] to resolve `tag:` search operators
/// by slug, and a [collectionRepository] to resolve `collection:` search
/// operators by slug.
class BookmarkItemRepositoryImpl implements BookmarkItemRepository {
  BookmarkItemRepositoryImpl({
    required Isar isar,
    TagRepository? tagRepository,
    CollectionRepository? collectionRepository,
  })  : _isar = isar,
        _tagRepository = tagRepository,
        _collectionRepository = collectionRepository;

  final Isar _isar;
  final TagRepository? _tagRepository;
  final CollectionRepository? _collectionRepository;

  // ─── BaseRepository<BookmarkItem> ──────────────────────────────────────

  @override
  Future<BookmarkItem?> getById(Id id) async {
    return _isar.bookmarkItems.get(id);
  }

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async {
    return _isar.bookmarkItems
        .where()
        .optional(offset != null, (q) => q.offset(offset!))
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
  }

  @override
  Future<Id> insert(BookmarkItem entity) async {
    return _isar.writeTxn(() async {
      return _isar.bookmarkItems.put(entity);
    });
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    return _isar.writeTxn(() async {
      return _isar.bookmarkItems.put(entity);
    });
  }

  @override
  Future<void> delete(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.bookmarkItems.delete(id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.bookmarkItems.clear();
    });
  }

  // ─── BookmarkItemRepository queries ────────────────────────────────────

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async {
    return _isar.bookmarkItems
        .where()
        .urlHashEqualTo(urlHash)
        .findFirst();
  }

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async {
    return _isar.bookmarkItems
        .where()
        .canonicalUrlEqualTo(canonicalUrl)
        .findFirst();
  }

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async {
    return _isar.bookmarkItems
        .filter()
        .externalContentIdEqualTo(externalContentId)
        .findFirst();
  }

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async {
    return _isar.bookmarkItems
        .filter()
        .duplicateGroupIdEqualTo(groupId)
        .findAll();
  }

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async {
    return _isar.bookmarkItems
        .where()
        .isFavoriteEqualTo(true)
        .optional(offset != null, (q) => q.offset(offset!))
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
  }

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async {
    return _isar.bookmarkItems
        .filter()
        .isArchivedEqualTo(true)
        .optional(offset != null, (q) => q.offset(offset!))
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
  }

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async {
    return _isar.bookmarkItems
        .filter()
        .collectionIdsElementEqualTo(collectionId)
        .optional(offset != null, (q) => q.offset(offset!))
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
  }

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async {
    return _isar.bookmarkItems
        .filter()
        .tagIdsElementEqualTo(tagId)
        .optional(offset != null, (q) => q.offset(offset!))
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
  }

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit = 100}) async {
    // Start with soft-delete guard.
    QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> qb =
        _isar.bookmarkItems.filter().isDeletedEqualTo(false);

    // Default vault exclusion unless `in:vault` operator is present.
    final bool includeVault = query.hasOperator('in') &&
        query.operatorValues('in').any((v) => v.toLowerCase() == 'vault');
    if (includeVault) {
      qb = qb.and().isInVaultEqualTo(true);
    } else {
      qb = qb.and().isInVaultEqualTo(false);
    }

    // Free-text: each term must match at least one of 5 fields.
    for (final term in query.freeText) {
      qb = qb.and().group((q) {
        return q
            .titleContains(term, caseSensitive: false)
            .or()
            .descriptionContains(term, caseSensitive: false)
            .or()
            .snippetContains(term, caseSensitive: false)
            .or()
            .extractedTextContains(term, caseSensitive: false)
            .or()
            .originalUrlContains(term, caseSensitive: false);
      });
    }

    // Structured operators.
    for (final entry in query.operators.entries) {
      final key = entry.key;
      final values = entry.value;

      for (final value in values) {
        switch (key) {
          case 'is':
            qb = _applyIsOperator(qb, value);
          case 'has':
            qb = _applyHasOperator(qb, value);
          case 'in':
            // `in:vault` is handled above; other values are ignored.
            break;
          case 'domain':
            qb = qb.and().group((q) {
              return q
                  .normalizedHostContains(value, caseSensitive: false)
                  .or()
                  .sourceDomainContains(value, caseSensitive: false);
            });
          case 'source':
            qb = qb.and().sourceTypeEqualTo(value);
          case 'type':
            qb = qb.and().contentTypeEqualTo(value);
          case 'before':
            final date = DateTime.tryParse(value);
            if (date != null) {
              qb = qb.and().createdAtLessThan(date);
            }
          case 'after':
            final date = DateTime.tryParse(value);
            if (date != null) {
              qb = qb.and().createdAtGreaterThan(date);
            }
          case 'tag':
            if (_tagRepository != null) {
              final tag = await _tagRepository.getBySlug(value);
              if (tag != null) {
                qb = qb.and().tagIdsElementEqualTo(tag.id);
              } else {
                qb = qb.and().idEqualTo(-1);
              }
            } else {
              qb = qb.and().idEqualTo(-1);
            }
          case 'collection':
            if (_collectionRepository != null) {
              final collection = await _collectionRepository.getBySlug(value);
              if (collection != null) {
                qb = qb.and().collectionIdsElementEqualTo(collection.id);
              } else {
                qb = qb.and().idEqualTo(-1);
              }
            } else {
              qb = qb.and().idEqualTo(-1);
            }
        }
      }
    }

    return qb
        .optional(offset != null, (q) => q.offset(offset!))
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
  }

  // ─── Operator helpers ────────────────────────────────────────────────

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      _applyIsOperator(
    QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> qb,
    String value,
  ) {
    switch (value.toLowerCase()) {
      case 'favorite':
        return qb.and().isFavoriteEqualTo(true);
      case 'archived':
        // Use filter() not where() — composite index gotcha MEM034.
        return qb.and().isArchivedEqualTo(true);
      case 'unread':
        return qb.and().isReadEqualTo(false);
      default:
        // Unknown `is:` value — ignored.
        return qb;
    }
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      _applyHasOperator(
    QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> qb,
    String value,
  ) {
    switch (value.toLowerCase()) {
      case 'note':
        // noteIdsElementIsNotNull() does not exist in the generated Isar
        // schema; noteIdsIsNotNull() is sufficient because the repository
        // stores null (not an empty list) when no notes are attached.
        return qb.and().noteIdsIsNotNull();
      default:
        // Unknown `has:` value — ignored.
        return qb;
    }
  }
}
