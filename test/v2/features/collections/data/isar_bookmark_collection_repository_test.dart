@Tags(<String>['integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/collection_sort_mode.dart';
import 'package:marky/core/database/marky_database.dart';
import 'package:marky/features/bookmarks/data/isar_bookmark_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/data/isar_bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late BookmarkCollectionRepository repo;
  late BookmarkRepository bookmarkRepo;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('collection_repo_test_');
    isar = await MarkyDatabase.open(
      directory: tempDir.path,
      name: 'test_${tempDir.path.hashCode}',
    );
    repo = IsarBookmarkCollectionRepository(isar);
    bookmarkRepo = IsarBookmarkRepository(isar);
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('createFromTitle', () {
    test('first call uses base slug', () async {
      final BookmarkCollection col =
          await repo.createFromTitle('Research Papers');
      expect(col.slug, 'research-papers');
      expect(col.title, 'Research Papers');
      expect(col.id, isNotNull);
      expect(col.sortMode, CollectionSortMode.newestFirst);
    });

    test('second call dedupes with -2', () async {
      await repo.createFromTitle('Reading');
      final BookmarkCollection dup = await repo.createFromTitle('Reading');
      expect(dup.slug, 'reading-2');
    });

    test('blank title throws ArgumentError', () async {
      expect(
        () async => repo.createFromTitle(''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('createSmartFromRule', () {
    test('persists a smart collection with encoded rule JSON', () async {
      const SmartCollectionRule rule = SmartCollectionRule(
        tagId: 7,
        host: 'flutter.dev',
        contentType: BookmarkContentType.article,
        addedWithinDays: 7,
      );

      final BookmarkCollection collection =
          await repo.createSmartFromRule('Fresh Flutter', rule);

      expect(collection.id, isNotNull);
      expect(collection.slug, 'fresh-flutter');
      expect(collection.isSmart, isTrue);
      expect(collection.itemCount, 0);
      expect(SmartCollectionRule.decode(collection.smartRuleJson!), rule);

      final BookmarkCollection? roundTrip = await repo.getById(collection.id!);
      expect(roundTrip!.isSmart, isTrue);
      expect(SmartCollectionRule.decode(roundTrip.smartRuleJson!), rule);
    });

    test('dedupes smart collection slugs like manual collections', () async {
      const SmartCollectionRule rule = SmartCollectionRule(
        contentType: BookmarkContentType.video,
      );

      await repo.createSmartFromRule('Videos', rule);
      final BookmarkCollection duplicate =
          await repo.createSmartFromRule('Videos', rule);

      expect(duplicate.slug, 'videos-2');
      expect(duplicate.isSmart, isTrue);
    });
  });

  group('save', () {
    test('explicit slug conflict throws CollectionSlugConflictException',
        () async {
      await repo.createFromTitle('Reading');
      final DateTime now = DateTime.now();
      expect(
        () async => repo.save(BookmarkCollection(
          title: 'Other',
          slug: 'reading',
          createdAt: now,
          updatedAt: now,
        )),
        throwsA(isA<CollectionSlugConflictException>()),
      );
    });
  });

  group('getAll', () {
    test('excludes archived by default', () async {
      final BookmarkCollection live = await repo.createFromTitle('Live');
      final BookmarkCollection done = await repo.createFromTitle('Done');
      await repo.save(done.copyWith(isArchived: true));

      final List<BookmarkCollection> visible = await repo.getAll();
      expect(visible.length, 1);
      expect(visible.first.id, live.id);
    });

    test('includeArchived flips the predicate', () async {
      await repo.createFromTitle('Live');
      final BookmarkCollection done = await repo.createFromTitle('Done');
      await repo.save(done.copyWith(isArchived: true));

      final List<BookmarkCollection> all =
          await repo.getAll(includeArchived: true);
      expect(all.length, 2);
    });

    test('pinned first, then orderIndex, then title', () async {
      final BookmarkCollection a = await repo.createFromTitle('Alpha');
      final BookmarkCollection b = await repo.createFromTitle('Bravo');
      final BookmarkCollection c = await repo.createFromTitle('Charlie');

      await repo.save(b.copyWith(isPinned: true));
      await repo.save(a.copyWith(orderIndex: 5));
      await repo.save(c.copyWith(orderIndex: 1));

      final List<BookmarkCollection> all = await repo.getAll();
      expect(
        all.map((BookmarkCollection c) => c.title),
        <String>['Bravo', 'Charlie', 'Alpha'],
      );
    });
  });

  group('item count maintenance', () {
    test('increment / decrement adjust the row', () async {
      final BookmarkCollection col = await repo.createFromTitle('C1');
      await repo.incrementItemCount(col.id!);
      await repo.incrementItemCount(col.id!);
      BookmarkCollection? after = await repo.getById(col.id!);
      expect(after!.itemCount, 2);

      await repo.decrementItemCount(col.id!);
      after = await repo.getById(col.id!);
      expect(after!.itemCount, 1);
    });

    test('decrement clamps at zero', () async {
      final BookmarkCollection col = await repo.createFromTitle('C2');
      await repo.decrementItemCount(col.id!);
      final BookmarkCollection? after = await repo.getById(col.id!);
      expect(after!.itemCount, 0);
    });

    test('recompute corrects drift', () async {
      final BookmarkCollection col = await repo.createFromTitle('C3');
      await repo.save(col.copyWith(itemCount: 99));

      await bookmarkRepo.save(Bookmark(
        originalUrl: 'https://x.test/',
        collectionIds: <int>[col.id!],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final int actual = await repo.recomputeItemCount(col.id!);
      expect(actual, 1);
      final BookmarkCollection? after = await repo.getById(col.id!);
      expect(after!.itemCount, 1);
    });

    test('recomputeAllItemCounts walks every collection', () async {
      final BookmarkCollection a = await repo.createFromTitle('A');
      final BookmarkCollection b = await repo.createFromTitle('B');
      await repo.save(a.copyWith(itemCount: 10));
      await repo.save(b.copyWith(itemCount: 20));

      final Map<int, int> result = await repo.recomputeAllItemCounts();
      expect(result[a.id!], 0);
      expect(result[b.id!], 0);
    });
  });
}
