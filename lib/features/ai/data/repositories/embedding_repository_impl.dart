import 'package:isar/isar.dart';

import 'package:marky/core/ai/domain/models/embedding_document.dart';
import 'package:marky/core/ai/domain/repositories/embedding_repository.dart';

/// Isar-backed implementation of [EmbeddingRepository].
///
/// Expects [isar] to be an open database instance that includes
/// [EmbeddingDocumentSchema].
class EmbeddingRepositoryImpl implements EmbeddingRepository {
  EmbeddingRepositoryImpl({required Isar isar}) : _isar = isar;

  final Isar _isar;

  // ─── BaseRepository<EmbeddingDocument> ────────────────────────────────

  @override
  Future<EmbeddingDocument?> getById(Id id) async {
    return _isar.embeddingDocuments.get(id);
  }

  @override
  Future<List<EmbeddingDocument>> getAll() async {
    return _isar.embeddingDocuments.where().findAll();
  }

  @override
  Future<Id> insert(EmbeddingDocument entity) async {
    return _isar.writeTxn(() async {
      return _isar.embeddingDocuments.put(entity);
    });
  }

  @override
  Future<Id> update(EmbeddingDocument entity) async {
    return _isar.writeTxn(() async {
      return _isar.embeddingDocuments.put(entity);
    });
  }

  @override
  Future<void> delete(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.embeddingDocuments.delete(id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.embeddingDocuments.clear();
    });
  }

  // ─── EmbeddingRepository queries ──────────────────────────────────────

  @override
  Future<EmbeddingDocument?> getByBookmarkId(int bookmarkId) async {
    return _isar.embeddingDocuments
        .filter()
        .bookmarkIdEqualTo(bookmarkId)
        .findFirst();
  }

  @override
  Future<void> deleteByBookmarkId(int bookmarkId) async {
    await _isar.writeTxn(() async {
      await _isar.embeddingDocuments
          .filter()
          .bookmarkIdEqualTo(bookmarkId)
          .deleteAll();
    });
  }
}
