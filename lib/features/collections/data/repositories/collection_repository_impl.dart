import 'package:isar/isar.dart';

import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/shared/models/collection.dart';

/// Isar-backed implementation of [CollectionRepository].
///
/// Expects [isar] to be an open database instance that includes
/// [BookmarkCollectionSchema].
class CollectionRepositoryImpl implements CollectionRepository {
  CollectionRepositoryImpl({required Isar isar}) : _isar = isar;

  final Isar _isar;

  // ─── BaseRepository<BookmarkCollection> ────────────────────────────────

  @override
  Future<BookmarkCollection?> getById(Id id) async {
    return _isar.bookmarkCollections.get(id);
  }

  @override
  Future<List<BookmarkCollection>> getAll() async {
    return _isar.bookmarkCollections.where().findAll();
  }

  @override
  Future<Id> insert(BookmarkCollection entity) async {
    return _isar.writeTxn(() async {
      return _isar.bookmarkCollections.put(entity);
    });
  }

  @override
  Future<Id> update(BookmarkCollection entity) async {
    return _isar.writeTxn(() async {
      return _isar.bookmarkCollections.put(entity);
    });
  }

  @override
  Future<void> delete(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.bookmarkCollections.delete(id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.bookmarkCollections.clear();
    });
  }

  // ─── CollectionRepository queries ──────────────────────────────────────

  @override
  Future<BookmarkCollection?> getBySlug(String slug) async {
    return _isar.bookmarkCollections
        .where()
        .slugEqualTo(slug)
        .findFirst();
  }
}
