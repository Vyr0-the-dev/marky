import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/ai/domain/models/embedding_document.dart';
import 'package:marky/features/ai/data/repositories/embedding_repository_impl.dart';
import 'package:marky/core/ai/domain/repositories/embedding_repository.dart';

void main() {
  group('EmbeddingRepositoryImpl', () {
    late Directory tempDir;
    late Isar isar;
    late EmbeddingRepository repository;

    EmbeddingDocument makeEmbedding({
      required int bookmarkId,
      required List<double> values,
      String? modelName,
    }) {
      return EmbeddingDocument(
        bookmarkId: bookmarkId,
        values: values,
        dimensions: values.length,
        modelName: modelName,
        createdAt: DateTime.now(),
      );
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('embedding_test_');

      isar = await Isar.open(
        [EmbeddingDocumentSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      repository = EmbeddingRepositoryImpl(isar: isar);
    });

    tearDown(() async {
      if (isar.isOpen) {
        await isar.close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    // ─── BaseRepository CRUD ─────────────────────────────────────────────

    test('getById returns null when no embedding exists', () async {
      final result = await repository.getById(999);
      expect(result, isNull);
    });

    test('insert assigns an Id and the embedding can be fetched', () async {
      final embedding = makeEmbedding(
        bookmarkId: 1,
        values: [0.1, 0.2, 0.3],
        modelName: 'test-model',
      );
      final id = await repository.insert(embedding);

      expect(id, greaterThan(0));

      final fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.bookmarkId, 1);
      expect(fetched.values, [0.1, 0.2, 0.3]);
      expect(fetched.dimensions, 3);
      expect(fetched.modelName, 'test-model');
    });

    test('getAll returns all embeddings', () async {
      final e1 = makeEmbedding(bookmarkId: 1, values: [0.1, 0.2]);
      final e2 = makeEmbedding(bookmarkId: 2, values: [0.3, 0.4]);

      await repository.insert(e1);
      await repository.insert(e2);

      final all = await repository.getAll();
      expect(all.length, 2);
      expect(all.map((e) => e.bookmarkId).toSet(), {1, 2});
    });

    test('getAll returns empty list when no embeddings exist', () async {
      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('update modifies existing embedding', () async {
      final embedding = makeEmbedding(
        bookmarkId: 1,
        values: [0.1, 0.2],
        modelName: 'old-model',
      );
      final id = await repository.insert(embedding);

      final fetched = await repository.getById(id);
      fetched!.values = [0.5, 0.6];
      fetched.modelName = 'new-model';
      await repository.update(fetched);

      final updated = await repository.getById(id);
      expect(updated!.values, [0.5, 0.6]);
      expect(updated.modelName, 'new-model');
    });

    test('delete removes embedding', () async {
      final embedding = makeEmbedding(bookmarkId: 1, values: [0.1, 0.2]);
      final id = await repository.insert(embedding);

      expect(await repository.getById(id), isNotNull);

      await repository.delete(id);

      expect(await repository.getById(id), isNull);
    });

    test('delete on non-existent id is no-op', () async {
      await repository.delete(99999);

      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('clear removes all embeddings', () async {
      await repository.insert(makeEmbedding(bookmarkId: 1, values: [0.1]));
      await repository.insert(makeEmbedding(bookmarkId: 2, values: [0.2]));

      expect((await repository.getAll()).length, 2);

      await repository.clear();

      expect(await repository.getAll(), isEmpty);
    });

    test('full CRUD cycle', () async {
      final embedding = makeEmbedding(bookmarkId: 42, values: [0.1, 0.2, 0.3]);
      final id = await repository.insert(embedding);

      var fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.bookmarkId, 42);

      fetched.values = [0.9, 0.8, 0.7];
      await repository.update(fetched);

      fetched = await repository.getById(id);
      expect(fetched!.values, [0.9, 0.8, 0.7]);

      await repository.delete(id);
      expect(await repository.getById(id), isNull);
    });

    // ─── EmbeddingRepository queries ─────────────────────────────────────

    test('getByBookmarkId returns matching embedding', () async {
      final e1 = makeEmbedding(bookmarkId: 10, values: [0.1, 0.2]);
      final e2 = makeEmbedding(bookmarkId: 20, values: [0.3, 0.4]);

      await repository.insert(e1);
      await repository.insert(e2);

      final result = await repository.getByBookmarkId(20);
      expect(result, isNotNull);
      expect(result!.bookmarkId, 20);
      expect(result.values, [0.3, 0.4]);
    });

    test('getByBookmarkId returns null when no match', () async {
      final result = await repository.getByBookmarkId(999);
      expect(result, isNull);
    });

    test('deleteByBookmarkId removes matching embeddings', () async {
      await repository.insert(makeEmbedding(bookmarkId: 5, values: [0.1]));
      await repository.insert(makeEmbedding(bookmarkId: 6, values: [0.2]));

      expect((await repository.getAll()).length, 2);

      await repository.deleteByBookmarkId(5);

      final all = await repository.getAll();
      expect(all.length, 1);
      expect(all.first.bookmarkId, 6);
    });

    test('deleteByBookmarkId is no-op when no match', () async {
      await repository.insert(makeEmbedding(bookmarkId: 7, values: [0.1]));

      await repository.deleteByBookmarkId(999);

      final all = await repository.getAll();
      expect(all.length, 1);
    });
  });
}
