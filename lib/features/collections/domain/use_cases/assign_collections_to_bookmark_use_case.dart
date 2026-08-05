import 'package:isar/isar.dart';

import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';

/// Use case for assigning and removing collections on bookmarks.
///
/// Maintains bidirectional consistency: updating [BookmarkItem.collectionIds]
/// and [BookmarkCollection.itemCount] together.
class AssignCollectionsToBookmarkUseCase {
  AssignCollectionsToBookmarkUseCase({
    required BookmarkItemRepository bookmarkRepository,
    required CollectionRepository collectionRepository,
  })  : _bookmarkRepository = bookmarkRepository,
        _collectionRepository = collectionRepository;

  final BookmarkItemRepository _bookmarkRepository;
  final CollectionRepository _collectionRepository;

  // ─── Public API ────────────────────────────────────────────────────────

  /// Adds [collectionId] to the bookmark with [bookmarkId].
  ///
  /// No-op if the collection is already assigned. Increments
  /// [BookmarkCollection.itemCount] by 1.
  Future<void> addCollectionToBookmark(Id bookmarkId, Id collectionId) async {
    final bookmark = await _bookmarkRepository.getById(bookmarkId);
    final collection = await _collectionRepository.getById(collectionId);

    if (bookmark == null || collection == null) {
      return;
    }

    final collectionIds = bookmark.collectionIds ?? <int>[];
    if (collectionIds.contains(collectionId)) {
      return; // Already assigned — idempotent.
    }

    collectionIds.add(collectionId);
    bookmark.collectionIds = collectionIds;
    bookmark.updatedAt = DateTime.now();

    collection.itemCount++;
    collection.updatedAt = DateTime.now();

    await _bookmarkRepository.update(bookmark);
    await _collectionRepository.update(collection);
  }

  /// Removes [collectionId] from the bookmark with [bookmarkId].
  ///
  /// No-op if the collection is not assigned. Decrements
  /// [BookmarkCollection.itemCount] by 1 but never below 0.
  Future<void> removeCollectionFromBookmark(
    Id bookmarkId,
    Id collectionId,
  ) async {
    final bookmark = await _bookmarkRepository.getById(bookmarkId);
    final collection = await _collectionRepository.getById(collectionId);

    if (bookmark == null || collection == null) {
      return;
    }

    final collectionIds = bookmark.collectionIds ?? <int>[];
    if (!collectionIds.contains(collectionId)) {
      return; // Not assigned — idempotent.
    }

    collectionIds.remove(collectionId);
    bookmark.collectionIds = collectionIds.isEmpty ? null : collectionIds;
    bookmark.updatedAt = DateTime.now();

    collection.itemCount = collection.itemCount > 0 ? collection.itemCount - 1 : 0;
    collection.updatedAt = DateTime.now();

    await _bookmarkRepository.update(bookmark);
    await _collectionRepository.update(collection);
  }

  /// Replaces all collections on the bookmark with [bookmarkId] with
  /// [collectionIds].
  ///
  /// Adjusts [BookmarkCollection.itemCount] for all affected collections:
  /// increments for newly added collections, decrements for removed
  /// collections (never below 0).
  Future<void> setCollectionsForBookmark(
    Id bookmarkId,
    List<Id> collectionIds,
  ) async {
    final bookmark = await _bookmarkRepository.getById(bookmarkId);
    if (bookmark == null) {
      return;
    }

    final currentIds = Set<Id>.from(bookmark.collectionIds ?? <int>[]);
    final newIds = Set<Id>.from(collectionIds);

    final added = newIds.difference(currentIds);
    final removed = currentIds.difference(newIds);

    // Update bookmark collection list.
    bookmark.collectionIds = collectionIds.isEmpty ? null : List<Id>.from(collectionIds);
    bookmark.updatedAt = DateTime.now();
    await _bookmarkRepository.update(bookmark);

    // Increment itemCount for added collections.
    for (final id in added) {
      final collection = await _collectionRepository.getById(id);
      if (collection != null) {
        collection.itemCount++;
        collection.updatedAt = DateTime.now();
        await _collectionRepository.update(collection);
      }
    }

    // Decrement itemCount for removed collections.
    for (final id in removed) {
      final collection = await _collectionRepository.getById(id);
      if (collection != null) {
        collection.itemCount = collection.itemCount > 0 ? collection.itemCount - 1 : 0;
        collection.updatedAt = DateTime.now();
        await _collectionRepository.update(collection);
      }
    }
  }
}
