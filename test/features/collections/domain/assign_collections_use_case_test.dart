import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/collections/domain/use_cases/assign_collections_to_bookmark_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';

/// Pure-Dart fake [CollectionRepository] for fast, deterministic tests.
class FakeCollectionRepository implements CollectionRepository {
  final Map<Id, BookmarkCollection> _collections = <Id, BookmarkCollection>{};
  int _nextId = 1;
  int saveCount = 0;

  @override
  Future<BookmarkCollection?> getById(Id id) async => _collections[id];

  @override
  Future<List<BookmarkCollection>> getAll() async =>
      _collections.values.toList();

  @override
  Future<Id> insert(BookmarkCollection entity) async {
    entity.id = _nextId++;
    _collections[entity.id] = entity;
    saveCount++;
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkCollection entity) async {
    _collections[entity.id] = entity;
    saveCount++;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _collections.remove(id);
    saveCount++;
  }

  @override
  Future<void> clear() async {
    _collections.clear();
    _nextId = 1;
    saveCount++;
  }

  @override
  Future<BookmarkCollection?> getBySlug(String slug) async {
    for (final collection in _collections.values) {
      if (collection.slug == slug) return collection;
    }
    return null;
  }
}

/// Pure-Dart fake [BookmarkItemRepository] for fast, deterministic tests.
class FakeBookmarkRepository implements BookmarkItemRepository {
  final Map<Id, BookmarkItem> _bookmarks = <Id, BookmarkItem>{};
  int _nextId = 1;
  int saveCount = 0;

  @override
  Future<BookmarkItem?> getById(Id id) async => _bookmarks[id];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => _bookmarks.values.toList();

  @override
  Future<Id> insert(BookmarkItem entity) async {
    entity.id = _nextId++;
    _bookmarks[entity.id] = entity;
    saveCount++;
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    _bookmarks[entity.id] = entity;
    saveCount++;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _bookmarks.remove(id);
    saveCount++;
  }

  @override
  Future<void> clear() async {
    _bookmarks.clear();
    _nextId = 1;
    saveCount++;
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async =>
      null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => [];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async {
    return _bookmarks.values
        .where((b) => b.collectionIds?.contains(collectionId) ?? false)
        .toList();
  }

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async => [];
}

void main() {
  group('AssignCollectionsToBookmarkUseCase', () {
    late FakeCollectionRepository collectionRepo;
    late FakeBookmarkRepository bookmarkRepo;
    late AssignCollectionsToBookmarkUseCase useCase;

    setUp(() {
      collectionRepo = FakeCollectionRepository();
      bookmarkRepo = FakeBookmarkRepository();
      useCase = AssignCollectionsToBookmarkUseCase(
        bookmarkRepository: bookmarkRepo,
        collectionRepository: collectionRepo,
      );
    });

    Future<Id> createCollection(String title, {int itemCount = 0}) async {
      final collection = BookmarkCollection(
        title: title,
        slug: title.toLowerCase().replaceAll(' ', '-'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        itemCount: itemCount,
      );
      return collectionRepo.insert(collection);
    }

    Future<Id> createBookmark({List<int>? collectionIds}) async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        collectionIds: collectionIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return bookmarkRepo.insert(bookmark);
    }

    // ─── addCollectionToBookmark ─────────────────────────────────────────

    test('addCollectionToBookmark appends collection and increments itemCount',
        () async {
      final collectionId = await createCollection('Research');
      final bookmarkId = await createBookmark();

      await useCase.addCollectionToBookmark(bookmarkId, collectionId);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      final collection = await collectionRepo.getById(collectionId);

      expect(bookmark!.collectionIds, [collectionId]);
      expect(collection!.itemCount, 1);
    });

    test('addCollectionToBookmark is idempotent when collection already present',
        () async {
      final collectionId = await createCollection('Research');
      final bookmarkId = await createBookmark(collectionIds: [collectionId]);

      final initialSaveCount = collectionRepo.saveCount;
      await useCase.addCollectionToBookmark(bookmarkId, collectionId);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      final collection = await collectionRepo.getById(collectionId);

      expect(bookmark!.collectionIds, [collectionId]);
      expect(collection!.itemCount, 0); // unchanged
      expect(collectionRepo.saveCount, initialSaveCount); // no save occurred
    });

    test('addCollectionToBookmark no-op when bookmark does not exist',
        () async {
      final collectionId = await createCollection('Research');

      await useCase.addCollectionToBookmark(999, collectionId);

      final collection = await collectionRepo.getById(collectionId);
      expect(collection!.itemCount, 0);
      expect(bookmarkRepo.saveCount, 0); // no bookmark was ever inserted
    });

    test('addCollectionToBookmark no-op when collection does not exist',
        () async {
      final bookmarkId = await createBookmark();

      await useCase.addCollectionToBookmark(bookmarkId, 999);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.collectionIds, isNull);
      expect(bookmarkRepo.saveCount, 1); // only initial insert
    });

    test('addCollectionToBookmark appends to existing collections', () async {
      final c1 = await createCollection('Research');
      final c2 = await createCollection('Reading List');
      final bookmarkId = await createBookmark(collectionIds: [c1]);

      await useCase.addCollectionToBookmark(bookmarkId, c2);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.collectionIds, [c1, c2]);

      final col1 = await collectionRepo.getById(c1);
      final col2 = await collectionRepo.getById(c2);
      expect(col1!.itemCount, 0); // already present, not incremented
      expect(col2!.itemCount, 1);
    });

    // ─── removeCollectionFromBookmark ────────────────────────────────────

    test(
        'removeCollectionFromBookmark removes collection and decrements itemCount',
        () async {
      final collectionId = await createCollection('Research', itemCount: 1);
      final bookmarkId = await createBookmark(collectionIds: [collectionId]);

      await useCase.removeCollectionFromBookmark(bookmarkId, collectionId);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      final collection = await collectionRepo.getById(collectionId);

      expect(bookmark!.collectionIds, isNull);
      expect(collection!.itemCount, 0);
    });

    test(
        'removeCollectionFromBookmark is idempotent when collection not present',
        () async {
      final collectionId = await createCollection('Research');
      final bookmarkId = await createBookmark();

      final initialSaveCount = collectionRepo.saveCount;
      await useCase.removeCollectionFromBookmark(bookmarkId, collectionId);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.collectionIds, isNull);
      expect(collectionRepo.saveCount, initialSaveCount);
    });

    test('removeCollectionFromBookmark no-op when bookmark does not exist',
        () async {
      final collectionId = await createCollection('Research', itemCount: 1);

      await useCase.removeCollectionFromBookmark(999, collectionId);

      final collection = await collectionRepo.getById(collectionId);
      expect(collection!.itemCount, 1);
    });

    test('removeCollectionFromBookmark no-op when collection does not exist',
        () async {
      final bookmarkId = await createBookmark(collectionIds: [1]);

      await useCase.removeCollectionFromBookmark(bookmarkId, 999);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.collectionIds, [1]);
    });

    test(
        'removeCollectionFromBookmark never decrements itemCount below 0',
        () async {
      final collectionId = await createCollection('Research');
      final bookmarkId = await createBookmark(collectionIds: [collectionId]);

      await useCase.removeCollectionFromBookmark(bookmarkId, collectionId);

      final collection = await collectionRepo.getById(collectionId);
      expect(collection!.itemCount, 0);
    });

    test('removeCollectionFromBookmark keeps remaining collections', () async {
      final c1 = await createCollection('Research');
      final c2 = await createCollection('Reading List');
      final bookmarkId = await createBookmark(collectionIds: [c1, c2]);

      await useCase.removeCollectionFromBookmark(bookmarkId, c1);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.collectionIds, [c2]);
    });

    // ─── setCollectionsForBookmark ───────────────────────────────────────

    test('setCollectionsForBookmark replaces all collections', () async {
      final c1 = await createCollection('Research');
      final c2 = await createCollection('Reading List');
      final c3 = await createCollection('Archive');
      final bookmarkId = await createBookmark(collectionIds: [c1]);

      await useCase.setCollectionsForBookmark(bookmarkId, [c2, c3]);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.collectionIds, [c2, c3]);

      final col1 = await collectionRepo.getById(c1);
      final col2 = await collectionRepo.getById(c2);
      final col3 = await collectionRepo.getById(c3);

      expect(col1!.itemCount, 0); // removed
      expect(col2!.itemCount, 1); // added
      expect(col3!.itemCount, 1); // added
    });

    test('setCollectionsForBookmark clears all collections when empty list',
        () async {
      final c1 = await createCollection('Research');
      final bookmarkId = await createBookmark(collectionIds: [c1]);

      await useCase.setCollectionsForBookmark(bookmarkId, []);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.collectionIds, isNull);

      final collection = await collectionRepo.getById(c1);
      expect(collection!.itemCount, 0);
    });

    test('setCollectionsForBookmark is no-op when bookmark does not exist',
        () async {
      final collectionId = await createCollection('Research');

      await useCase.setCollectionsForBookmark(999, [collectionId]);

      final collection = await collectionRepo.getById(collectionId);
      expect(collection!.itemCount, 0);
      expect(bookmarkRepo.saveCount, 0);
    });

    test('setCollectionsForBookmark handles partial overlaps', () async {
      final c1 = await createCollection('Research');
      final c2 = await createCollection('Reading List');
      final c3 = await createCollection('Archive');
      final bookmarkId = await createBookmark(collectionIds: [c1, c2]);

      await useCase.setCollectionsForBookmark(bookmarkId, [c2, c3]);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.collectionIds, [c2, c3]);

      final col1 = await collectionRepo.getById(c1);
      final col2 = await collectionRepo.getById(c2);
      final col3 = await collectionRepo.getById(c3);

      expect(col1!.itemCount, 0); // removed
      expect(col2!.itemCount, 0); // unchanged (already present)
      expect(col3!.itemCount, 1); // added
    });

    test('setCollectionsForBookmark updates timestamps', () async {
      final c1 = await createCollection('Research');
      final bookmarkId = await createBookmark(collectionIds: [c1]);
      final before = DateTime.now();

      await Future.delayed(const Duration(milliseconds: 10));
      await useCase.setCollectionsForBookmark(bookmarkId, []);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.updatedAt.isAfter(before), isTrue);
    });
  });
}
