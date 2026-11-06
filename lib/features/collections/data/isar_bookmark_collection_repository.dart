import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/bookmark_entity.dart';
import 'package:marky/core/database/entities/collection_entity.dart';
import 'package:marky/features/collections/data/bookmark_collection_mapper.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';

/// Isar-backed [BookmarkCollectionRepository].
///
/// Mirrors [IsarTagRepository] in shape — same slug-uniqueness
/// pattern, same incr/decr/recompute strategy for `itemCount`. Kept
/// as separate code (not a shared base class) because the entities
/// are typed differently and a base class would force casts on
/// every method.
class IsarBookmarkCollectionRepository implements BookmarkCollectionRepository {
  IsarBookmarkCollectionRepository(this._isar);

  final Isar _isar;

  @override
  Future<BookmarkCollection> save(BookmarkCollection collection) async {
    final BookmarkCollection stamped =
        collection.copyWith(updatedAt: DateTime.now());
    final CollectionEntity entity = BookmarkCollectionMapper.toEntity(stamped);
    final int id = await _isar.writeTxn<int>(() async {
      try {
        return await _isar.collections.put(entity);
      } on IsarError catch (e) {
        if (_isUniqueViolation(e)) {
          throw CollectionSlugConflictException(stamped.slug);
        }
        rethrow;
      }
    });
    return stamped.copyWith(id: id);
  }

  @override
  Future<BookmarkCollection> createFromTitle(
    String title, {
    int? accentColorArgb,
    String? icon,
  }) async {
    final String trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title must not be blank');
    }

    final String baseSlug = BookmarkCollection.slugify(trimmed);
    final DateTime now = DateTime.now();

    for (int attempt = 0; attempt < 100; attempt++) {
      final String candidate =
          attempt == 0 ? baseSlug : '$baseSlug-${attempt + 1}';
      try {
        return await save(BookmarkCollection(
          title: trimmed,
          slug: candidate,
          accentColorArgb: accentColorArgb,
          icon: icon,
          createdAt: now,
          updatedAt: now,
        ));
      } on CollectionSlugConflictException {
        // try next suffix
      }
    }
    throw StateError(
      'Could not allocate a unique slug for "$title" after 100 attempts.',
    );
  }

  @override
  Future<BookmarkCollection> createSmartFromRule(
    String title,
    SmartCollectionRule rule, {
    int? accentColorArgb,
    String? icon,
  }) async {
    final String trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title must not be blank');
    }

    final String baseSlug = BookmarkCollection.slugify(trimmed);
    final DateTime now = DateTime.now();

    for (int attempt = 0; attempt < 100; attempt++) {
      final String candidate =
          attempt == 0 ? baseSlug : '$baseSlug-${attempt + 1}';
      try {
        return await save(BookmarkCollection(
          title: trimmed,
          slug: candidate,
          accentColorArgb: accentColorArgb,
          icon: icon,
          isSmart: true,
          smartRuleJson: rule.encode(),
          createdAt: now,
          updatedAt: now,
        ));
      } on CollectionSlugConflictException {
        // try next suffix
      }
    }
    throw StateError(
      'Could not allocate a unique slug for "$title" after 100 attempts.',
    );
  }

  @override
  Future<BookmarkCollection?> getById(int id) async {
    final CollectionEntity? e = await _isar.collections.get(id);
    return e == null ? null : BookmarkCollectionMapper.toDomain(e);
  }

  @override
  Future<BookmarkCollection?> findBySlug(String slug) async {
    final CollectionEntity? e =
        await _isar.collections.where().slugEqualTo(slug).findFirst();
    return e == null ? null : BookmarkCollectionMapper.toDomain(e);
  }

  @override
  Future<List<BookmarkCollection>> getAll({
    bool includeArchived = false,
  }) async {
    final List<CollectionEntity> rows = includeArchived
        ? await _isar.collections
            .where()
            .sortByIsPinnedDesc()
            .thenByOrderIndex()
            .thenByTitle()
            .findAll()
        : await _isar.collections
            .filter()
            .isArchivedEqualTo(false)
            .sortByIsPinnedDesc()
            .thenByOrderIndex()
            .thenByTitle()
            .findAll();
    return rows.map(BookmarkCollectionMapper.toDomain).toList(growable: false);
  }

  @override
  Future<List<BookmarkCollection>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return const <BookmarkCollection>[];
    final List<CollectionEntity?> rows = await _isar.collections.getAll(ids);
    return rows
        .whereType<CollectionEntity>()
        .map(BookmarkCollectionMapper.toDomain)
        .toList(growable: false);
  }

  @override
  Future<bool> delete(int id) {
    return _isar.writeTxn<bool>(() async => _isar.collections.delete(id));
  }

  // ─── Item-count maintenance ─────────────────────────────────────

  @override
  Future<void> incrementItemCount(int collectionId) async {
    await _isar.writeTxn<void>(() async {
      final CollectionEntity? e = await _isar.collections.get(collectionId);
      if (e == null) return;
      e.itemCount += 1;
      e.updatedAt = DateTime.now();
      await _isar.collections.put(e);
    });
  }

  @override
  Future<void> decrementItemCount(int collectionId) async {
    await _isar.writeTxn<void>(() async {
      final CollectionEntity? e = await _isar.collections.get(collectionId);
      if (e == null || e.itemCount <= 0) return;
      e.itemCount -= 1;
      e.updatedAt = DateTime.now();
      await _isar.collections.put(e);
    });
  }

  @override
  Future<int> recomputeItemCount(int collectionId) async {
    return _isar.writeTxn<int>(() async {
      final int actual = await _isar.bookmarks
          .filter()
          .collectionIdsElementEqualTo(collectionId)
          .count();
      final CollectionEntity? e = await _isar.collections.get(collectionId);
      if (e != null && e.itemCount != actual) {
        e.itemCount = actual;
        e.updatedAt = DateTime.now();
        await _isar.collections.put(e);
      }
      return actual;
    });
  }

  @override
  Future<Map<int, int>> recomputeAllItemCounts() async {
    return _isar.writeTxn<Map<int, int>>(() async {
      final List<CollectionEntity> all =
          await _isar.collections.where().findAll();
      final Map<int, int> result = <int, int>{};
      final DateTime now = DateTime.now();
      final List<CollectionEntity> dirty = <CollectionEntity>[];

      for (final CollectionEntity c in all) {
        final int actual = await _isar.bookmarks
            .filter()
            .collectionIdsElementEqualTo(c.id)
            .count();
        result[c.id] = actual;
        if (c.itemCount != actual) {
          c.itemCount = actual;
          c.updatedAt = now;
          dirty.add(c);
        }
      }
      if (dirty.isNotEmpty) await _isar.collections.putAll(dirty);
      return result;
    });
  }

  // ─── Streams ────────────────────────────────────────────────────

  @override
  Stream<List<BookmarkCollection>> watchAll({
    bool includeArchived = false,
  }) {
    final Query<CollectionEntity> q = includeArchived
        ? _isar.collections
            .where()
            .sortByIsPinnedDesc()
            .thenByOrderIndex()
            .thenByTitle()
            .build()
        : _isar.collections
            .filter()
            .isArchivedEqualTo(false)
            .sortByIsPinnedDesc()
            .thenByOrderIndex()
            .thenByTitle()
            .build();
    return q.watch(fireImmediately: true).map(
          (List<CollectionEntity> rows) => rows
              .map(BookmarkCollectionMapper.toDomain)
              .toList(growable: false),
        );
  }

  @override
  Stream<BookmarkCollection?> watchById(int id) {
    return _isar.collections.watchObject(id, fireImmediately: true).map(
          (CollectionEntity? e) =>
              e == null ? null : BookmarkCollectionMapper.toDomain(e),
        );
  }

  // ─── Helpers ────────────────────────────────────────────────────

  bool _isUniqueViolation(IsarError e) {
    final String lower = e.message.toLowerCase();
    return lower.contains('unique') || lower.contains('duplicate');
  }
}

class CollectionSlugConflictException implements Exception {
  const CollectionSlugConflictException(this.slug);
  final String slug;

  @override
  String toString() =>
      'CollectionSlugConflictException: slug "$slug" already exists';
}
