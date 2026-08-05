import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/collections/domain/use_cases/manage_collections_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';

/// Pure-Dart fake [CollectionRepository] for fast, deterministic tests.
class FakeCollectionRepository implements CollectionRepository {
  final Map<Id, BookmarkCollection> _collections = <Id, BookmarkCollection>{};
  int _nextId = 1;
  int saveCount = 0;

  List<BookmarkCollection> get savedCollections => _collections.values.toList();

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
  group('ManageCollectionsUseCase', () {
    late FakeCollectionRepository collectionRepo;
    late FakeBookmarkRepository bookmarkRepo;
    late ManageCollectionsUseCase useCase;

    setUp(() {
      collectionRepo = FakeCollectionRepository();
      bookmarkRepo = FakeBookmarkRepository();
      useCase = ManageCollectionsUseCase(
        collectionRepository: collectionRepo,
        bookmarkRepository: bookmarkRepo,
      );
    });

    // ─── create ──────────────────────────────────────────────────────────

    test('create inserts a collection with auto-generated slug', () async {
      final id = await useCase.create('Research Papers');

      expect(id, greaterThan(0));

      final collection = await collectionRepo.getById(id);
      expect(collection, isNotNull);
      expect(collection!.title, 'Research Papers');
      expect(collection.slug, 'research-papers');
    });

    test('create trims name and strips special chars from slug', () async {
      final id = await useCase.create('  Dart & Flutter!!!  ');

      final collection = await collectionRepo.getById(id);
      expect(collection!.slug, 'dart-flutter');
    });

    test('create resolves slug collision by appending counter', () async {
      await useCase.create('Flutter');
      final id2 = await useCase.create('Flutter');
      final id3 = await useCase.create('Flutter');

      final c1 = await collectionRepo.getById(1);
      final c2 = await collectionRepo.getById(id2);
      final c3 = await collectionRepo.getById(id3);

      expect(c1!.slug, 'flutter');
      expect(c2!.slug, 'flutter-1');
      expect(c3!.slug, 'flutter-2');
    });

    test('create stores optional fields', () async {
      final id = await useCase.create(
        'Flutter',
        description: 'Flutter resources',
        icon: 'flutter_logo',
        accentColor: '#FF5722',
        coverMode: 'color',
        coverImageUrl: 'https://example.com/cover.png',
        coverLocalPath: '/local/cover.png',
        sortMode: 'dateDesc',
      );

      final collection = await collectionRepo.getById(id);
      expect(collection!.description, 'Flutter resources');
      expect(collection.icon, 'flutter_logo');
      expect(collection.accentColor, '#FF5722');
      expect(collection.coverMode, 'color');
      expect(collection.coverImageUrl, 'https://example.com/cover.png');
      expect(collection.coverLocalPath, '/local/cover.png');
      expect(collection.sortMode, 'dateDesc');
    });

    test('create sets timestamps', () async {
      final before = DateTime.now();
      final id = await useCase.create('Test');
      final after = DateTime.now();

      final collection = await collectionRepo.getById(id);
      expect(
        collection!.createdAt.isAfter(before) ||
            collection.createdAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        collection.createdAt.isBefore(after) ||
            collection.createdAt.isAtSameMomentAs(after),
        isTrue,
      );
      expect(collection.updatedAt, collection.createdAt);
    });

    test('create falls back to "collection" slug for empty name', () async {
      final id = await useCase.create('!!!');

      final collection = await collectionRepo.getById(id);
      expect(collection!.slug, 'collection');
    });

    // ─── update ──────────────────────────────────────────────────────────

    test('update persists changes and refreshes updatedAt', () async {
      final id = await useCase.create('Old Name');
      final collection = await collectionRepo.getById(id);

      await Future.delayed(const Duration(milliseconds: 10));

      collection!.title = 'New Name';
      collection.itemCount = 5;
      await useCase.update(collection);

      final updated = await collectionRepo.getById(id);
      expect(updated!.title, 'New Name');
      expect(updated.itemCount, 5);
      expect(updated.updatedAt.isAfter(updated.createdAt), isTrue);
    });

    // ─── getById / getBySlug / getAll ────────────────────────────────────

    test('getById returns collection or null', () async {
      final id = await useCase.create('Test');

      expect(await useCase.getById(id), isNotNull);
      expect(await useCase.getById(999), isNull);
    });

    test('getBySlug returns collection or null', () async {
      await useCase.create('Flutter');

      expect(await useCase.getBySlug('flutter'), isNotNull);
      expect(await useCase.getBySlug('nonexistent'), isNull);
    });

    test('getAll returns all collections', () async {
      await useCase.create('A');
      await useCase.create('B');

      final all = await useCase.getAll();
      expect(all.length, 2);
    });

    // ─── delete ──────────────────────────────────────────────────────────

    test('delete removes the collection', () async {
      final id = await useCase.create('ToDelete');
      expect(await collectionRepo.getById(id), isNotNull);

      await useCase.delete(id);

      expect(await collectionRepo.getById(id), isNull);
    });

    test('delete is no-op for non-existent id', () async {
      await useCase.delete(999);
      expect(collectionRepo.saveCount, 0);
    });

    test('delete removes collection from bookmark collectionIds', () async {
      final collectionId = await useCase.create('Flutter');
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        collectionIds: [collectionId, 99],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      await useCase.delete(collectionId);

      final updatedBookmark = await bookmarkRepo.getById(bookmark.id);
      expect(updatedBookmark!.collectionIds, [99]);
    });

    test('delete cleans up multiple bookmarks referencing the collection',
        () async {
      final collectionId = await useCase.create('Flutter');

      final b1 = BookmarkItem(
        originalUrl: 'https://a.com',
        collectionIds: [collectionId, 1],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final b2 = BookmarkItem(
        originalUrl: 'https://b.com',
        collectionIds: [collectionId],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(b1);
      await bookmarkRepo.insert(b2);

      await useCase.delete(collectionId);

      final ub1 = await bookmarkRepo.getById(b1.id);
      final ub2 = await bookmarkRepo.getById(b2.id);

      expect(ub1!.collectionIds, [1]);
      expect(ub2!.collectionIds, isNull);
    });
  });
}
