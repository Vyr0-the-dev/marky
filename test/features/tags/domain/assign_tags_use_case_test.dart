import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/features/tags/domain/use_cases/assign_tags_to_bookmark_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/tag.dart';

/// Pure-Dart fake [TagRepository] for fast, deterministic tests.
class FakeTagRepository implements TagRepository {
  final Map<Id, Tag> _tags = <Id, Tag>{};
  int _nextId = 1;
  int saveCount = 0;

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
  group('AssignTagsToBookmarkUseCase', () {
    late FakeTagRepository tagRepo;
    late FakeBookmarkRepository bookmarkRepo;
    late AssignTagsToBookmarkUseCase useCase;

    setUp(() {
      tagRepo = FakeTagRepository();
      bookmarkRepo = FakeBookmarkRepository();
      useCase = AssignTagsToBookmarkUseCase(
        bookmarkRepository: bookmarkRepo,
        tagRepository: tagRepo,
      );
    });

    Future<Id> createTag(String name, {int usageCount = 0}) async {
      final tag = Tag(
        name: name,
        slug: name.toLowerCase().replaceAll(' ', '-'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        usageCount: usageCount,
      );
      return tagRepo.insert(tag);
    }

    Future<Id> createBookmark({List<int>? tagIds}) async {
      final bookmark = BookmarkItem(
        originalUrl: 'https://example.com',
        tagIds: tagIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return bookmarkRepo.insert(bookmark);
    }

    // ─── addTagToBookmark ────────────────────────────────────────────────

    test('addTagToBookmark appends tag and increments usageCount', () async {
      final tagId = await createTag('Flutter');
      final bookmarkId = await createBookmark();

      await useCase.addTagToBookmark(bookmarkId, tagId);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      final tag = await tagRepo.getById(tagId);

      expect(bookmark!.tagIds, [tagId]);
      expect(tag!.usageCount, 1);
    });

    test('addTagToBookmark is idempotent when tag already present', () async {
      final tagId = await createTag('Flutter');
      final bookmarkId = await createBookmark(tagIds: [tagId]);

      final initialSaveCount = tagRepo.saveCount;
      await useCase.addTagToBookmark(bookmarkId, tagId);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      final tag = await tagRepo.getById(tagId);

      expect(bookmark!.tagIds, [tagId]);
      expect(tag!.usageCount, 0); // unchanged
      expect(tagRepo.saveCount, initialSaveCount); // no save occurred
    });

    test('addTagToBookmark no-op when bookmark does not exist', () async {
      final tagId = await createTag('Flutter');

      await useCase.addTagToBookmark(999, tagId);

      final tag = await tagRepo.getById(tagId);
      expect(tag!.usageCount, 0);
      expect(bookmarkRepo.saveCount, 0); // no bookmark was ever inserted
    });

    test('addTagToBookmark no-op when tag does not exist', () async {
      final bookmarkId = await createBookmark();

      await useCase.addTagToBookmark(bookmarkId, 999);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.tagIds, isNull);
      expect(bookmarkRepo.saveCount, 1); // only initial insert
    });

    test('addTagToBookmark appends to existing tags', () async {
      final tag1 = await createTag('Flutter');
      final tag2 = await createTag('Dart');
      final bookmarkId = await createBookmark(tagIds: [tag1]);

      await useCase.addTagToBookmark(bookmarkId, tag2);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.tagIds, [tag1, tag2]);

      final t1 = await tagRepo.getById(tag1);
      final t2 = await tagRepo.getById(tag2);
      expect(t1!.usageCount, 0); // already present, not incremented
      expect(t2!.usageCount, 1);
    });

    // ─── removeTagFromBookmark ───────────────────────────────────────────

    test('removeTagFromBookmark removes tag and decrements usageCount', () async {
      final tagId = await createTag('Flutter', usageCount: 1);
      final bookmarkId = await createBookmark(tagIds: [tagId]);

      await useCase.removeTagFromBookmark(bookmarkId, tagId);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      final tag = await tagRepo.getById(tagId);

      expect(bookmark!.tagIds, isNull);
      expect(tag!.usageCount, 0);
    });

    test('removeTagFromBookmark is idempotent when tag not present', () async {
      final tagId = await createTag('Flutter');
      final bookmarkId = await createBookmark();

      final initialSaveCount = tagRepo.saveCount;
      await useCase.removeTagFromBookmark(bookmarkId, tagId);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.tagIds, isNull);
      expect(tagRepo.saveCount, initialSaveCount);
    });

    test('removeTagFromBookmark no-op when bookmark does not exist', () async {
      final tagId = await createTag('Flutter', usageCount: 1);

      await useCase.removeTagFromBookmark(999, tagId);

      final tag = await tagRepo.getById(tagId);
      expect(tag!.usageCount, 1);
    });

    test('removeTagFromBookmark no-op when tag does not exist', () async {
      final bookmarkId = await createBookmark(tagIds: [1]);

      await useCase.removeTagFromBookmark(bookmarkId, 999);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.tagIds, [1]);
    });

    test('removeTagFromBookmark never decrements usageCount below 0', () async {
      final tagId = await createTag('Flutter');
      final bookmarkId = await createBookmark(tagIds: [tagId]);

      await useCase.removeTagFromBookmark(bookmarkId, tagId);

      final tag = await tagRepo.getById(tagId);
      expect(tag!.usageCount, 0);
    });

    test('removeTagFromBookmark keeps remaining tags', () async {
      final tag1 = await createTag('Flutter');
      final tag2 = await createTag('Dart');
      final bookmarkId = await createBookmark(tagIds: [tag1, tag2]);

      await useCase.removeTagFromBookmark(bookmarkId, tag1);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.tagIds, [tag2]);
    });

    // ─── setTagsForBookmark ──────────────────────────────────────────────

    test('setTagsForBookmark replaces all tags', () async {
      final tag1 = await createTag('Flutter');
      final tag2 = await createTag('Dart');
      final tag3 = await createTag('Kotlin');
      final bookmarkId = await createBookmark(tagIds: [tag1]);

      await useCase.setTagsForBookmark(bookmarkId, [tag2, tag3]);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.tagIds, [tag2, tag3]);

      final t1 = await tagRepo.getById(tag1);
      final t2 = await tagRepo.getById(tag2);
      final t3 = await tagRepo.getById(tag3);

      expect(t1!.usageCount, 0); // removed
      expect(t2!.usageCount, 1); // added
      expect(t3!.usageCount, 1); // added
    });

    test('setTagsForBookmark clears all tags when empty list', () async {
      final tag1 = await createTag('Flutter');
      final bookmarkId = await createBookmark(tagIds: [tag1]);

      await useCase.setTagsForBookmark(bookmarkId, []);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.tagIds, isNull);

      final tag = await tagRepo.getById(tag1);
      expect(tag!.usageCount, 0);
    });

    test('setTagsForBookmark is no-op when bookmark does not exist', () async {
      final tagId = await createTag('Flutter');

      await useCase.setTagsForBookmark(999, [tagId]);

      final tag = await tagRepo.getById(tagId);
      expect(tag!.usageCount, 0);
      expect(bookmarkRepo.saveCount, 0);
    });

    test('setTagsForBookmark handles partial overlaps', () async {
      final tag1 = await createTag('Flutter');
      final tag2 = await createTag('Dart');
      final tag3 = await createTag('Kotlin');
      final bookmarkId = await createBookmark(tagIds: [tag1, tag2]);

      await useCase.setTagsForBookmark(bookmarkId, [tag2, tag3]);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.tagIds, [tag2, tag3]);

      final t1 = await tagRepo.getById(tag1);
      final t2 = await tagRepo.getById(tag2);
      final t3 = await tagRepo.getById(tag3);

      expect(t1!.usageCount, 0); // removed
      expect(t2!.usageCount, 0); // unchanged (already present)
      expect(t3!.usageCount, 1); // added
    });

    test('setTagsForBookmark updates timestamps', () async {
      final tag1 = await createTag('Flutter');
      final bookmarkId = await createBookmark(tagIds: [tag1]);
      final before = DateTime.now();

      await Future.delayed(const Duration(milliseconds: 10));
      await useCase.setTagsForBookmark(bookmarkId, []);

      final bookmark = await bookmarkRepo.getById(bookmarkId);
      expect(bookmark!.updatedAt.isAfter(before), isTrue);
    });
  });
}
