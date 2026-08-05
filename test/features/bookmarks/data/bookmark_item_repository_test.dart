import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/data/repositories/bookmark_item_repository_impl.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';

void main() {
  group('BookmarkItemRepositoryImpl', () {
    late Directory tempDir;
    late Isar isar;
    late BookmarkItemRepository repository;

    BookmarkItem makeBookmark({
      required String originalUrl,
      String? urlHash,
      String? canonicalUrl,
      String? externalContentId,
      String? duplicateGroupId,
      bool isFavorite = false,
      bool isArchived = false,
      List<int>? tagIds,
      List<int>? collectionIds,
      String? title,
    }) {
      final now = DateTime.now();
      return BookmarkItem(
        originalUrl: originalUrl,
        urlHash: urlHash,
        canonicalUrl: canonicalUrl,
        externalContentId: externalContentId,
        duplicateGroupId: duplicateGroupId,
        isFavorite: isFavorite,
        isArchived: isArchived,
        tagIds: tagIds,
        collectionIds: collectionIds,
        title: title,
        createdAt: now,
        updatedAt: now,
      );
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('bookmark_item_test_');

      isar = await Isar.open(
        [BookmarkItemSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      repository = BookmarkItemRepositoryImpl(isar: isar);
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

    test('getById returns null when no bookmark exists', () async {
      final result = await repository.getById(999);
      expect(result, isNull);
    });

    test('insert assigns an Id and the bookmark can be fetched', () async {
      final bookmark = makeBookmark(originalUrl: 'https://example.com');
      final id = await repository.insert(bookmark);

      expect(id, greaterThan(0));

      final fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.originalUrl, 'https://example.com');
    });

    test('getAll returns all bookmarks', () async {
      final b1 = makeBookmark(originalUrl: 'https://a.com');
      final b2 = makeBookmark(originalUrl: 'https://b.com');

      await repository.insert(b1);
      await repository.insert(b2);

      final all = await repository.getAll();
      expect(all.length, 2);
      expect(all.map((b) => b.originalUrl).toSet(),
          {'https://a.com', 'https://b.com'});
    });

    test('getAll returns empty list when no bookmarks exist', () async {
      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('update modifies existing bookmark', () async {
      final bookmark = makeBookmark(
        originalUrl: 'https://example.com',
        title: 'Old Title',
      );
      final id = await repository.insert(bookmark);

      final fetched = await repository.getById(id);
      fetched!.title = 'New Title';
      await repository.update(fetched);

      final updated = await repository.getById(id);
      expect(updated!.title, 'New Title');
    });

    test('delete removes bookmark', () async {
      final bookmark = makeBookmark(originalUrl: 'https://example.com');
      final id = await repository.insert(bookmark);

      expect(await repository.getById(id), isNotNull);

      await repository.delete(id);

      expect(await repository.getById(id), isNull);
    });

    test('delete on non-existent id is no-op', () async {
      // Should not throw.
      await repository.delete(99999);

      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('clear removes all bookmarks', () async {
      await repository.insert(makeBookmark(originalUrl: 'https://a.com'));
      await repository.insert(makeBookmark(originalUrl: 'https://b.com'));

      expect((await repository.getAll()).length, 2);

      await repository.clear();

      expect(await repository.getAll(), isEmpty);
    });

    test('full CRUD cycle', () async {
      // Create
      final bookmark = makeBookmark(
        originalUrl: 'https://example.com',
        title: 'Example',
      );
      final id = await repository.insert(bookmark);

      // Read
      var fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.originalUrl, 'https://example.com');
      expect(fetched.title, 'Example');

      // Update
      fetched.title = 'Updated';
      await repository.update(fetched);

      fetched = await repository.getById(id);
      expect(fetched!.title, 'Updated');

      // Delete
      await repository.delete(id);
      expect(await repository.getById(id), isNull);
    });

    // ─── Query methods ───────────────────────────────────────────────────

    test('getByUrlHash returns matching bookmark', () async {
      final b1 = makeBookmark(
        originalUrl: 'https://a.com',
        urlHash: 'hash_a',
      );
      final b2 = makeBookmark(
        originalUrl: 'https://b.com',
        urlHash: 'hash_b',
      );

      await repository.insert(b1);
      await repository.insert(b2);

      final result = await repository.getByUrlHash('hash_b');
      expect(result, isNotNull);
      expect(result!.originalUrl, 'https://b.com');
    });

    test('getByUrlHash returns null when no match', () async {
      final result = await repository.getByUrlHash('nonexistent');
      expect(result, isNull);
    });

    test('getFavorites returns only favorited bookmarks', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://fav.com',
        isFavorite: true,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://plain.com',
        
      ));

      final favorites = await repository.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.originalUrl, 'https://fav.com');
    });

    test('getFavorites returns empty list when none favorited', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://plain.com',
        
      ));

      final favorites = await repository.getFavorites();
      expect(favorites, isEmpty);
    });

    test('getArchived returns only archived bookmarks', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://archived.com',
        isArchived: true,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://active.com',
        
      ));

      final archived = await repository.getArchived();
      expect(archived.length, 1);
      expect(archived.first.originalUrl, 'https://archived.com');
    });

    test('getArchived returns empty list when none archived', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://active.com',
        
      ));

      final archived = await repository.getArchived();
      expect(archived, isEmpty);
    });

    test('getByCollectionId returns bookmarks in collection', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://in-col.com',
        collectionIds: [1, 2],
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://other.com',
        collectionIds: [3],
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://no-col.com',
      ));

      final results = await repository.getByCollectionId(2);
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://in-col.com');
    });

    test('getByCollectionId returns empty list when no matches', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        collectionIds: [1],
      ));

      final results = await repository.getByCollectionId(99);
      expect(results, isEmpty);
    });

    test('getByTagId returns bookmarks with tag', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://tagged.com',
        tagIds: [10, 20],
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://other.com',
        tagIds: [30],
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://no-tags.com',
      ));

      final results = await repository.getByTagId(20);
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://tagged.com');
    });

    test('getByTagId returns empty list when no matches', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        tagIds: [1],
      ));

      final results = await repository.getByTagId(99);
      expect(results, isEmpty);
    });

    test('multiple bookmarks can match the same collection or tag', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        collectionIds: [1],
        tagIds: [1],
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://b.com',
        collectionIds: [1],
        tagIds: [1],
      ));

      final byCollection = await repository.getByCollectionId(1);
      final byTag = await repository.getByTagId(1);

      expect(byCollection.length, 2);
      expect(byTag.length, 2);
    });

    test('getByCanonicalUrl returns matching bookmark', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        canonicalUrl: 'https://a.com',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://b.com',
        canonicalUrl: 'https://b.com',
      ));

      final result = await repository.getByCanonicalUrl('https://b.com');
      expect(result, isNotNull);
      expect(result!.originalUrl, 'https://b.com');
    });

    test('getByCanonicalUrl returns null when no match', () async {
      final result = await repository.getByCanonicalUrl('https://missing.com');
      expect(result, isNull);
    });

    test('getByExternalContentId returns matching bookmark', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://youtube.com/watch?v=abc123',
        externalContentId: 'abc123',
      ));

      final result = await repository.getByExternalContentId('abc123');
      expect(result, isNotNull);
      expect(result!.externalContentId, 'abc123');
    });

    test('getByExternalContentId returns null when no match', () async {
      final result = await repository.getByExternalContentId('missing');
      expect(result, isNull);
    });

    test('getByDuplicateGroupId returns bookmarks in group', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        duplicateGroupId: 'group-1',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://b.com',
        duplicateGroupId: 'group-1',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://c.com',
        duplicateGroupId: 'group-2',
      ));

      final results = await repository.getByDuplicateGroupId('group-1');
      expect(results.length, 2);
      expect(
        results.map((b) => b.originalUrl).toSet(),
        {'https://a.com', 'https://b.com'},
      );
    });

    test('getByDuplicateGroupId returns empty list when no match', () async {
      final results = await repository.getByDuplicateGroupId('missing');
      expect(results, isEmpty);
    });

    // ─── Pagination ─────────────────────────────────────────────────────

    test('getAll with limit returns first N bookmarks', () async {
      for (int i = 0; i < 5; i++) {
        await repository.insert(makeBookmark(originalUrl: 'https://$i.com'));
      }

      final results = await repository.getAll(limit: 2);
      expect(results.length, 2);
      expect(results.first.originalUrl, 'https://0.com');
      expect(results.last.originalUrl, 'https://1.com');
    });

    test('getAll with offset skips first N bookmarks', () async {
      for (int i = 0; i < 5; i++) {
        await repository.insert(makeBookmark(originalUrl: 'https://$i.com'));
      }

      final results = await repository.getAll(offset: 3);
      expect(results.length, 2);
      expect(results.first.originalUrl, 'https://3.com');
      expect(results.last.originalUrl, 'https://4.com');
    });

    test('getAll with offset and limit returns correct slice', () async {
      for (int i = 0; i < 5; i++) {
        await repository.insert(makeBookmark(originalUrl: 'https://$i.com'));
      }

      final results = await repository.getAll(offset: 1, limit: 2);
      expect(results.length, 2);
      expect(results.first.originalUrl, 'https://1.com');
      expect(results.last.originalUrl, 'https://2.com');
    });

    test('getAll with offset beyond total returns empty list', () async {
      await repository.insert(makeBookmark(originalUrl: 'https://a.com'));

      final results = await repository.getAll(offset: 10);
      expect(results, isEmpty);
    });

    test('getAll with limit of zero returns empty list', () async {
      for (int i = 0; i < 5; i++) {
        await repository.insert(makeBookmark(originalUrl: 'https://$i.com'));
      }

      final results = await repository.getAll(limit: 0);
      expect(results, isEmpty);
    });

    test('getFavorites with pagination returns sliced favorites', () async {
      for (int i = 0; i < 5; i++) {
        await repository.insert(makeBookmark(
          originalUrl: 'https://fav-$i.com',
          isFavorite: true,
        ));
      }
      // Insert non-favorites to ensure filtering happens before pagination
      for (int i = 0; i < 3; i++) {
        await repository.insert(makeBookmark(
          originalUrl: 'https://plain-$i.com',
        ));
      }

      final results = await repository.getFavorites(offset: 1, limit: 2);
      expect(results.length, 2);
      expect(results.first.originalUrl, 'https://fav-1.com');
      expect(results.last.originalUrl, 'https://fav-2.com');
    });

    test('getArchived with pagination returns sliced archived', () async {
      for (int i = 0; i < 5; i++) {
        await repository.insert(makeBookmark(
          originalUrl: 'https://arch-$i.com',
          isArchived: true,
        ));
      }
      for (int i = 0; i < 3; i++) {
        await repository.insert(makeBookmark(
          originalUrl: 'https://active-$i.com',
        ));
      }

      final results = await repository.getArchived(offset: 2, limit: 2);
      expect(results.length, 2);
      expect(results.first.originalUrl, 'https://arch-2.com');
      expect(results.last.originalUrl, 'https://arch-3.com');
    });

    test('getByCollectionId with pagination returns sliced results', () async {
      for (int i = 0; i < 5; i++) {
        await repository.insert(makeBookmark(
          originalUrl: 'https://in-col-$i.com',
          collectionIds: [1],
        ));
      }
      for (int i = 0; i < 3; i++) {
        await repository.insert(makeBookmark(
          originalUrl: 'https://other-$i.com',
          collectionIds: [2],
        ));
      }

      final results = await repository.getByCollectionId(1, offset: 1, limit: 2);
      expect(results.length, 2);
      expect(results.first.originalUrl, 'https://in-col-1.com');
      expect(results.last.originalUrl, 'https://in-col-2.com');
    });

    test('getByTagId with pagination returns sliced results', () async {
      for (int i = 0; i < 5; i++) {
        await repository.insert(makeBookmark(
          originalUrl: 'https://tagged-$i.com',
          tagIds: [10],
        ));
      }
      for (int i = 0; i < 3; i++) {
        await repository.insert(makeBookmark(
          originalUrl: 'https://other-$i.com',
          tagIds: [20],
        ));
      }

      final results = await repository.getByTagId(10, offset: 2, limit: 2);
      expect(results.length, 2);
      expect(results.first.originalUrl, 'https://tagged-2.com');
      expect(results.last.originalUrl, 'https://tagged-3.com');
    });

    test('search with pagination returns sliced results', () async {
      for (int i = 0; i < 5; i++) {
        await repository.insert(makeBookmark(
          originalUrl: 'https://alpha-$i.com',
          title: 'alpha article $i',
        ));
      }
      for (int i = 0; i < 3; i++) {
        await repository.insert(makeBookmark(
          originalUrl: 'https://beta-$i.com',
          title: 'beta article $i',
        ));
      }

      final query = SearchQuery(
        freeText: const ['alpha'],
        operators: const {},
      );

      final results = await repository.search(query, offset: 1, limit: 2);
      expect(results.length, 2);
      expect(results.first.title, 'alpha article 1');
      expect(results.last.title, 'alpha article 2');
    });

    test('pagination boundary: offset + limit exceeds total', () async {
      for (int i = 0; i < 3; i++) {
        await repository.insert(makeBookmark(originalUrl: 'https://$i.com'));
      }

      final results = await repository.getAll(offset: 1, limit: 10);
      expect(results.length, 2);
      expect(results.first.originalUrl, 'https://1.com');
      expect(results.last.originalUrl, 'https://2.com');
    });
  });
}
