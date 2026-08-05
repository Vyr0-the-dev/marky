import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/tags/data/repositories/tag_repository_impl.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/shared/models/tag.dart';

void main() {
  group('TagRepositoryImpl', () {
    late Directory tempDir;
    late Isar isar;
    late TagRepository repository;

    Tag makeTag({
      required String name,
      required String slug,
      String? color,
      int usageCount = 0,
    }) {
      final now = DateTime.now();
      return Tag(
        name: name,
        slug: slug,
        color: color,
        createdAt: now,
        updatedAt: now,
        usageCount: usageCount,
      );
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('tag_test_');

      isar = await Isar.open(
        [TagSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      repository = TagRepositoryImpl(isar: isar);
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

    test('getById returns null when no tag exists', () async {
      final result = await repository.getById(999);
      expect(result, isNull);
    });

    test('insert assigns an Id and the tag can be fetched', () async {
      final tag = makeTag(name: 'Flutter', slug: 'flutter');
      final id = await repository.insert(tag);

      expect(id, greaterThan(0));

      final fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Flutter');
      expect(fetched.slug, 'flutter');
    });

    test('getAll returns all tags', () async {
      final t1 = makeTag(name: 'Dart', slug: 'dart');
      final t2 = makeTag(name: 'Flutter', slug: 'flutter');

      await repository.insert(t1);
      await repository.insert(t2);

      final all = await repository.getAll();
      expect(all.length, 2);
      expect(all.map((t) => t.slug).toSet(), {'dart', 'flutter'});
    });

    test('getAll returns empty list when no tags exist', () async {
      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('update modifies existing tag', () async {
      final tag = makeTag(name: 'Old Name', slug: 'old-name');
      final id = await repository.insert(tag);

      final fetched = await repository.getById(id);
      fetched!.name = 'New Name';
      fetched.usageCount = 5;
      await repository.update(fetched);

      final updated = await repository.getById(id);
      expect(updated!.name, 'New Name');
      expect(updated.usageCount, 5);
    });

    test('delete removes tag', () async {
      final tag = makeTag(name: 'ToDelete', slug: 'to-delete');
      final id = await repository.insert(tag);

      expect(await repository.getById(id), isNotNull);

      await repository.delete(id);

      expect(await repository.getById(id), isNull);
    });

    test('delete on non-existent id is no-op', () async {
      await repository.delete(99999);

      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('clear removes all tags', () async {
      await repository.insert(makeTag(name: 'A', slug: 'a'));
      await repository.insert(makeTag(name: 'B', slug: 'b'));

      expect((await repository.getAll()).length, 2);

      await repository.clear();

      expect(await repository.getAll(), isEmpty);
    });

    test('full CRUD cycle', () async {
      final tag = makeTag(name: 'Test', slug: 'test');
      final id = await repository.insert(tag);

      var fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Test');

      fetched.name = 'Updated';
      await repository.update(fetched);

      fetched = await repository.getById(id);
      expect(fetched!.name, 'Updated');

      await repository.delete(id);
      expect(await repository.getById(id), isNull);
    });

    // ─── Query methods ───────────────────────────────────────────────────

    test('getBySlug returns matching tag', () async {
      await repository.insert(makeTag(name: 'Alpha', slug: 'alpha'));
      await repository.insert(makeTag(name: 'Beta', slug: 'beta'));

      final result = await repository.getBySlug('beta');
      expect(result, isNotNull);
      expect(result!.name, 'Beta');
    });

    test('getBySlug returns null when no match', () async {
      final result = await repository.getBySlug('nonexistent');
      expect(result, isNull);
    });
  });
}
