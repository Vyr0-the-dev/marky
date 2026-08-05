import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/vault/domain/use_cases/move_bookmark_to_vault_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// In-memory fake implementation of [BookmarkItemRepository] for testing.
class _FakeBookmarkItemRepository implements BookmarkItemRepository {
  final Map<int, BookmarkItem> _items = <int, BookmarkItem>{};
  int _nextId = 1;

  @override
  Future<BookmarkItem?> getById(Id id) async => _items[id];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => _items.values.toList();

  @override
  Future<Id> insert(BookmarkItem entity) async {
    final int id = _nextId++;
    entity.id = id;
    _items[id] = entity;
    return id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    _items[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _items.remove(id);
  }

  @override
  Future<void> clear() async {
    _items.clear();
    _nextId = 1;
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async =>
      null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

void main() {
  group('MoveBookmarkToVaultUseCase', () {
    late _FakeBookmarkItemRepository fakeRepository;
    late MoveBookmarkToVaultUseCase useCase;

    setUp(() {
      fakeRepository = _FakeBookmarkItemRepository();
      useCase = MoveBookmarkToVaultUseCase(repository: fakeRepository);
    });

    test('returns true and sets isInVault=true when bookmark exists', () async {
      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/secret',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await fakeRepository.insert(bookmark);

      final bool result = await useCase.execute(bookmark.id);

      expect(result, isTrue);

      final BookmarkItem? updated = await fakeRepository.getById(bookmark.id);
      expect(updated, isNotNull);
      expect(updated!.isInVault, isTrue);
    });

    test('updates updatedAt timestamp', () async {
      final DateTime originalUpdatedAt = DateTime(2024, 1, 1, 12);
      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/secret',
        createdAt: DateTime.now(),
        updatedAt: originalUpdatedAt,
      );
      await fakeRepository.insert(bookmark);

      // Wait a tick to ensure timestamp changes.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await useCase.execute(bookmark.id);

      final BookmarkItem? updated = await fakeRepository.getById(bookmark.id);
      expect(updated!.updatedAt.isAfter(originalUpdatedAt), isTrue);
    });

    test('returns false when bookmark does not exist', () async {
      final bool result = await useCase.execute(999);

      expect(result, isFalse);
    });

    test('is idempotent — already in vault still updates timestamp', () async {
      final DateTime originalUpdatedAt = DateTime(2024, 1, 1, 12);
      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/secret',
        isInVault: true,
        createdAt: DateTime.now(),
        updatedAt: originalUpdatedAt,
      );
      await fakeRepository.insert(bookmark);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final bool result = await useCase.execute(bookmark.id);

      expect(result, isTrue);

      final BookmarkItem? updated = await fakeRepository.getById(bookmark.id);
      expect(updated!.isInVault, isTrue);
      expect(updated.updatedAt.isAfter(originalUpdatedAt), isTrue);
    });
  });
}
