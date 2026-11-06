import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/features/tags/domain/use_cases/manage_tags_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/tag.dart';

/// Pure-Dart fake [TagRepository] for fast, deterministic tests.
class FakeTagRepository implements TagRepository {
  final Map<Id, Tag> _tags = <Id, Tag>{};
  int _nextId = 1;
  int saveCount = 0;

  List<Tag> get savedTags => _tags.values.toList();

  @override
  Future<Tag?> getById(Id id) async => _tags[id];

  @override
  Future<List<Tag>> getAll() async => _tags.values.toList();

  @override
  Future<Id> insert(Tag entity) async {
    entity.id = _nextId++;
    _tags[entity.id] = entity;
    saveCount++;
    return entity.id;
  }

  @override
  Future<Id> update(Tag entity) async {
    _tags[entity.id] = entity;
    saveCount++;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _tags.remove(id);
    saveCount++;
  }

  @override
  Future<void> clear() async {
    _tags.clear();
    _nextId = 1;
    saveCount++;
  }

  @override
  Future<Tag?> getBySlug(String slug) async {
    for (final tag in _tags.values) {
      if (tag.slug == slug) return tag;
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
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async => null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => [];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async {
    return _bookmarks.values
        .where((b) => b.tagIds?.contains(tagId) ?? false)
        .toList();
  }

  @override
  Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async => [];
}

void main() {
  group('ManageTagsUseCase', () {
    late FakeTagRepository tagRepo;
    late FakeBookmarkRepository bookmarkRepo;
    late ManageTagsUseCase useCase;

    setUp(() {
      tagRepo = FakeTagRepository();
      bookmarkRepo = FakeBookmarkRepository();
      useCase = ManageTagsUseCase(
        tagRepository: tagRepo,
        bookmarkRepository: bookmarkRepo,
      );
    });

    // ─── create ──────────────────────────────────────────────────────────

    test('create inserts a tag with auto-generated slug', () async {
      final id = await useCase.create('Flutter Tips');

      expect(id, greaterThan(0));

      final tag = await tagRepo.getById(id);
      expect(tag, isNotNull);
      expect(tag!.name, 'Flutter Tips');
      expect(tag.slug, 'flutter-tips');
    });

    test('create trims name and strips special chars from slug', () async {
      final id = await useCase.create('  Dart & Flutter!!!  ');

      final tag = await tagRepo.getById(id);
      expect(tag!.slug, 'dart-flutter');
    });

    test('create resolves slug collision by appending counter', () async {
      await useCase.create('Flutter');
      final id2 = await useCase.create('Flutter');
      final id3 = await useCase.create('Flutter');

      final tag1 = await tagRepo.getById(1);
      final tag2 = await tagRepo.getById(id2);
      final tag3 = await tagRepo.getById(id3);

      expect(tag1!.slug, 'flutter');
      expect(tag2!.slug, 'flutter-1');
      expect(tag3!.slug, 'flutter-2');
    });

    test('create stores optional color and icon', () async {
      final id = await useCase.create(
        'Flutter',
        color: '#FF5722',
        icon: 'flutter_logo',
      );

      final tag = await tagRepo.getById(id);
      expect(tag!.color, '#FF5722');
      expect(tag.icon, 'flutter_logo');
    });

    test('create sets timestamps', () async {
      final before = DateTime.now();
      final id = await useCase.create('Test');
      final after = DateTime.now();

      final tag = await tagRepo.getById(id);
      expect(tag!.createdAt.isAfter(before) || tag.createdAt.isAtSameMomentAs(before), isTrue);
      expect(tag.createdAt.isBefore(after) || tag.createdAt.isAtSameMomentAs(after), isTrue);
      expect(tag.updatedAt, tag.createdAt);
    });

    test('create falls back to "tag" slug for empty name', () async {
      final id = await useCase.create('!!!');

      final tag = await tagRepo.getById(id);
      expect(tag!.slug, 'tag');
    });

    // ─── update ──────────────────────────────────────────────────────────

    test('update persists changes and refreshes updatedAt', () async {
      final id = await useCase.create('Old Name');
      final tag = await tagRepo.getById(id);

      await Future.delayed(const Duration(milliseconds: 10));

      tag!.name = 'New Name';
      tag.usageCount = 5;
      await useCase.update(tag);

      final updated = await tagRepo.getById(id);
      expect(updated!.name, 'New Name');
      expect(updated.usageCount, 5);
      expect(updated.updatedAt.isAfter(tag.createdAt), isTrue);
    });

    // ─── getById / getBySlug / getAll ────────────────────────────────────

    test('getById returns tag or null', () async {
      final id = await useCase.create('Test');

      expect(await useCase.getById(id), isNotNull);
      expect(await useCase.getById(999), isNull);
    });

    test('getBySlug returns tag or null', () async {
      await useCase.create('Flutter');

      expect(await useCase.getBySlug('flutter'), isNotNull);
      expect(await useCase.getBySlug('nonexistent'), isNull);
    });

    test('getAll returns all tags', () async {
      await useCase.create('A');
      await useCase.create('B');

      final all = await useCase.getAll();
      expect(all.length, 2);
    });

    // ─── delete ──────────────────────────────────────────────────────────

    test('delete removes the tag', () async {
      final id = await useCase.create('ToDelete');
      expect(await tagRepo.getById(id), isNotNull);

      await useCase.delete(id);

      expect(await tagRepo.getById(id), isNull);
    });

    test('delete is no-op for non-existent id', () async {
      await useCase.delete(999);
      expect(tagRepo.saveCount, 0);
    });

    test('delete removes tag from bookmark tagIds', () async {
      final tagId = await useCase.create('Flutter');
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        tagIds: [tagId, 99],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(bookmark);

      await useCase.delete(tagId);

      final updatedBookmark = await bookmarkRepo.getById(bookmark.id);
      expect(updatedBookmark!.tagIds, [99]);
    });

    test('delete cleans up multiple bookmarks referencing the tag', () async {
      final tagId = await useCase.create('Flutter');

      final b1 = BookmarkItem(
        originalUrl: 'https://a.com',
        tagIds: [tagId, 1],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final b2 = BookmarkItem(
        originalUrl: 'https://b.com',
        tagIds: [tagId],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await bookmarkRepo.insert(b1);
      await bookmarkRepo.insert(b2);

      await useCase.delete(tagId);

      final ub1 = await bookmarkRepo.getById(b1.id);
      final ub2 = await bookmarkRepo.getById(b2.id);

      expect(ub1!.tagIds, [1]);
      expect(ub2!.tagIds, isNull);
    });
  });
}
