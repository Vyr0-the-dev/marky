import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/collections/data/repositories/collection_repository_impl.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/shared/models/collection.dart';

void main() {
  group('CollectionRepositoryImpl', () {
    late Directory tempDir;
    late Isar isar;
    late CollectionRepository repository;

    BookmarkCollection makeCollection({
      required String title,
      required String slug,
      bool isPinned = false,
      bool isArchived = false,
    }) {
      final now = DateTime.now();
      return BookmarkCollection(
        title: title,
        slug: slug,
        createdAt: now,
        updatedAt: now,
        isPinned: isPinned,
        isArchived: isArchived,
      );
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('collection_test_');

      isar = await Isar.open(
        [BookmarkCollectionSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      repository = CollectionRepositoryImpl(isar: isar);
    });

    tearDown(() async {
      if (isar.isOpen) {
        await isar.close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    // ─── CRUD ────────────────────────────────────────────────────────────

    test('getById returns null when no collection exists', () async {
      final result = await repository.getById(999);
      expect(result, isNull);
    });

    test('insert assigns an Id and the collection can be fetched', () async {
      final col = makeCollection(title: 'Research', slug: 'research');
      final id = await repository.insert(col);

      expect(id, greaterThan(0));

      final fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Research');
      expect(fetched.slug, 'research');
    });

    test('getAll returns all collections', () async {
      final c1 = makeCollection(title: 'Work', slug: 'work');
      final c2 = makeCollection(title: 'Personal', slug: 'personal');

      await repository.insert(c1);
      await repository.insert(c2);

      final all = await repository.getAll();
      expect(all.length, 2);
      expect(all.map((c) => c.slug).toSet(), {'work', 'personal'});
    });

    test('getAll returns empty list when no collections exist', () async {
      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('update modifies existing collection', () async {
      final col = makeCollection(title: 'Old Title', slug: 'old-title');
      final id = await repository.insert(col);

      final fetched = await repository.getById(id);
      fetched!.title = 'New Title';
      fetched.itemCount = 42;
      await repository.update(fetched);

      final updated = await repository.getById(id);
      expect(updated!.title, 'New Title');
      expect(updated.itemCount, 42);
    });

    test('delete removes collection', () async {
      final col = makeCollection(title: 'ToDelete', slug: 'to-delete');
      final id = await repository.insert(col);

      expect(await repository.getById(id), isNotNull);

      await repository.delete(id);

      expect(await repository.getById(id), isNull);
    });

    test('delete on non-existent id is no-op', () async {
      await repository.delete(99999);

      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('clear removes all collections', () async {
      await repository.insert(makeCollection(title: 'A', slug: 'a'));
      await repository.insert(makeCollection(title: 'B', slug: 'b'));

      expect((await repository.getAll()).length, 2);

      await repository.clear();

      expect(await repository.getAll(), isEmpty);
    });

    test('full CRUD cycle', () async {
      final col = makeCollection(title: 'Test', slug: 'test');
      final id = await repository.insert(col);

      var fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Test');

      fetched.title = 'Updated';
      await repository.update(fetched);

      fetched = await repository.getById(id);
      expect(fetched!.title, 'Updated');

      await repository.delete(id);
      expect(await repository.getById(id), isNull);
    });

    // ─── Query methods ───────────────────────────────────────────────────

    test('getBySlug returns matching collection', () async {
      await repository.insert(makeCollection(title: 'Alpha', slug: 'alpha'));
      await repository.insert(makeCollection(title: 'Beta', slug: 'beta'));

      final result = await repository.getBySlug('beta');
      expect(result, isNotNull);
      expect(result!.title, 'Beta');
    });

    test('getBySlug returns null when no match', () async {
      final result = await repository.getBySlug('nonexistent');
      expect(result, isNull);
    });
  });
}
