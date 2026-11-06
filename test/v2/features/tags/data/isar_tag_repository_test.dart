@Tags(<String>['integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/marky_database.dart';
import 'package:marky/features/bookmarks/data/isar_bookmark_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/tags/data/isar_tag_repository.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late TagRepository repo;
  late BookmarkRepository bookmarkRepo;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('tag_repo_test_');
    isar = await MarkyDatabase.open(
      directory: tempDir.path,
      name: 'test_${tempDir.path.hashCode}',
    );
    repo = IsarTagRepository(isar);
    bookmarkRepo = IsarBookmarkRepository(isar);
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('Tag.slugify', () {
    test('lowercases + dashes non-alphanumerics', () {
      expect(Tag.slugify('Machine Learning'), 'machine-learning');
      expect(Tag.slugify('  to-read  '), 'to-read');
      expect(Tag.slugify('ABC123!@#xyz'), 'abc123-xyz');
    });
    test('non-Latin scripts collapse to "tag" sentinel', () {
      expect(Tag.slugify('日本語'), 'tag');
      // Turkish: ı/ğ/ü/ş/ç → all stripped because we don't
      // transliterate (documented behaviour).
      expect(Tag.slugify('Türkçe'), 't-rk-e');
    });
  });

  group('createFromName', () {
    test('first call uses base slug', () async {
      final Tag tag = await repo.createFromName('Design');
      expect(tag.slug, 'design');
      expect(tag.name, 'Design');
      expect(tag.id, isNotNull);
    });

    test('second call with same name appends -2', () async {
      await repo.createFromName('Design');
      final Tag dup = await repo.createFromName('Design');
      expect(dup.slug, 'design-2');
    });

    test('third call appends -3', () async {
      await repo.createFromName('Design');
      await repo.createFromName('Design');
      final Tag t3 = await repo.createFromName('Design');
      expect(t3.slug, 'design-3');
    });

    test('blank name throws ArgumentError', () async {
      expect(
        () async => repo.createFromName('   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('save', () {
    test('explicit slug conflict throws TagSlugConflictException', () async {
      await repo.createFromName('Design');
      final DateTime now = DateTime.now();
      expect(
        () async => repo.save(Tag(
          name: 'Other',
          slug: 'design',
          createdAt: now,
          updatedAt: now,
        )),
        throwsA(isA<TagSlugConflictException>()),
      );
    });

    test('save updates updatedAt automatically', () async {
      final Tag created = await repo.createFromName('Reading');
      // Manually rewind updatedAt to verify the repo overwrites it.
      final Tag stale = created.copyWith(updatedAt: DateTime(2020));
      final Tag saved = await repo.save(stale);
      expect(saved.updatedAt.isAfter(DateTime(2020)), isTrue);
    });
  });

  group('findBySlug', () {
    test('case-insensitive match', () async {
      await repo.createFromName('Design');
      final Tag? upper = await repo.findBySlug('DESIGN');
      expect(upper, isNotNull);
      expect(upper!.name, 'Design');
    });
    test('miss returns null', () async {
      expect(await repo.findBySlug('nonexistent'), isNull);
    });
  });

  group('getAll ordering', () {
    test('pinned first, then orderIndex, then name', () async {
      // Create three tags, two unpinned with different orderIndex,
      // one pinned. Verify ordering.
      final Tag a = await repo.createFromName('Aleph');
      final Tag b = await repo.createFromName('Bet');
      final Tag c = await repo.createFromName('Gimel');

      // Bet pinned. Aleph orderIndex = 5, Gimel orderIndex = 1.
      await repo.save(b.copyWith(isPinned: true));
      await repo.save(a.copyWith(orderIndex: 5));
      await repo.save(c.copyWith(orderIndex: 1));

      final List<Tag> all = await repo.getAll();
      // Pinned first (Bet), then by orderIndex ASC: Gimel(1) before Aleph(5).
      expect(all.map((Tag t) => t.name), <String>['Bet', 'Gimel', 'Aleph']);
    });
  });

  group('usage count maintenance', () {
    test('increment / decrement adjust the row', () async {
      final Tag tag = await repo.createFromName('Counted');
      await repo.incrementUsageCount(tag.id!);
      await repo.incrementUsageCount(tag.id!);
      Tag? after = await repo.getById(tag.id!);
      expect(after!.usageCount, 2);

      await repo.decrementUsageCount(tag.id!);
      after = await repo.getById(tag.id!);
      expect(after!.usageCount, 1);
    });

    test('decrement clamps at zero', () async {
      final Tag tag = await repo.createFromName('Zero');
      await repo.decrementUsageCount(tag.id!);
      await repo.decrementUsageCount(tag.id!);
      final Tag? after = await repo.getById(tag.id!);
      expect(after!.usageCount, 0);
    });

    test('recompute corrects drift', () async {
      final Tag tag = await repo.createFromName('Drifted');
      // Manually set count to a wrong value.
      await repo.save(tag.copyWith(usageCount: 99));

      // Persist a real bookmark referencing the tag.
      await bookmarkRepo.save(Bookmark(
        originalUrl: 'https://x.test/',
        tagIds: <int>[tag.id!],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final int actual = await repo.recomputeUsageCount(tag.id!);
      expect(actual, 1);
      final Tag? after = await repo.getById(tag.id!);
      expect(after!.usageCount, 1);
    });

    test('recomputeAllUsageCounts walks every tag', () async {
      final Tag t1 = await repo.createFromName('A');
      final Tag t2 = await repo.createFromName('B');
      // Save both with bogus counts.
      await repo.save(t1.copyWith(usageCount: 10));
      await repo.save(t2.copyWith(usageCount: 20));
      // No bookmarks reference them yet.

      final Map<int, int> result = await repo.recomputeAllUsageCounts();
      expect(result[t1.id!], 0);
      expect(result[t2.id!], 0);
    });
  });

  group('delete', () {
    test('removes the row, returns true', () async {
      final Tag tag = await repo.createFromName('Bye');
      expect(await repo.delete(tag.id!), isTrue);
      expect(await repo.getById(tag.id!), isNull);
    });
  });
}
