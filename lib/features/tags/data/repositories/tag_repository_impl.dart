import 'package:isar/isar.dart';

import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/shared/models/tag.dart';

/// Isar-backed implementation of [TagRepository].
///
/// Expects [isar] to be an open database instance that includes
/// [TagSchema].
class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl({required Isar isar}) : _isar = isar;

  final Isar _isar;

  // ─── BaseRepository<Tag> ───────────────────────────────────────────────

  @override
  Future<Tag?> getById(Id id) async {
    return _isar.tags.get(id);
  }

  @override
  Future<List<Tag>> getAll() async {
    return _isar.tags.where().findAll();
  }

  @override
  Future<Id> insert(Tag entity) async {
    return _isar.writeTxn(() async {
      return _isar.tags.put(entity);
    });
  }

  @override
  Future<Id> update(Tag entity) async {
    return _isar.writeTxn(() async {
      return _isar.tags.put(entity);
    });
  }

  @override
  Future<void> delete(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.tags.delete(id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.tags.clear();
    });
  }

  // ─── TagRepository queries ─────────────────────────────────────────────

  @override
  Future<Tag?> getBySlug(String slug) async {
    return _isar.tags
        .where()
        .slugEqualTo(slug)
        .findFirst();
  }
}
