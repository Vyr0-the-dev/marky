import 'package:isar/isar.dart';

import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/tag.dart';

/// Use case for assigning and removing tags on bookmarks.
///
/// Maintains bidirectional consistency: updating [BookmarkItem.tagIds]
/// and [Tag.usageCount] together.
class AssignTagsToBookmarkUseCase {
  AssignTagsToBookmarkUseCase({
    required BookmarkItemRepository bookmarkRepository,
    required TagRepository tagRepository,
  })  : _bookmarkRepository = bookmarkRepository,
        _tagRepository = tagRepository;

  final BookmarkItemRepository _bookmarkRepository;
  final TagRepository _tagRepository;

  // ─── Public API ────────────────────────────────────────────────────────

  /// Adds [tagId] to the bookmark with [bookmarkId].
  ///
  /// No-op if the tag is already assigned. Increments [Tag.usageCount]
  /// by 1.
  Future<void> addTagToBookmark(Id bookmarkId, Id tagId) async {
    final bookmark = await _bookmarkRepository.getById(bookmarkId);
    final tag = await _tagRepository.getById(tagId);

    if (bookmark == null || tag == null) {
      return;
    }

    final tagIds = bookmark.tagIds ?? <int>[];
    if (tagIds.contains(tagId)) {
      return; // Already assigned — idempotent.
    }

    tagIds.add(tagId);
    bookmark.tagIds = tagIds;
    bookmark.updatedAt = DateTime.now();

    tag.usageCount++;
    tag.updatedAt = DateTime.now();

    await _bookmarkRepository.update(bookmark);
    await _tagRepository.update(tag);
  }

  /// Removes [tagId] from the bookmark with [bookmarkId].
  ///
  /// No-op if the tag is not assigned. Decrements [Tag.usageCount]
  /// by 1 but never below 0.
  Future<void> removeTagFromBookmark(Id bookmarkId, Id tagId) async {
    final bookmark = await _bookmarkRepository.getById(bookmarkId);
    final tag = await _tagRepository.getById(tagId);

    if (bookmark == null || tag == null) {
      return;
    }

    final tagIds = bookmark.tagIds ?? <int>[];
    if (!tagIds.contains(tagId)) {
      return; // Not assigned — idempotent.
    }

    tagIds.remove(tagId);
    bookmark.tagIds = tagIds.isEmpty ? null : tagIds;
    bookmark.updatedAt = DateTime.now();

    tag.usageCount = tag.usageCount > 0 ? tag.usageCount - 1 : 0;
    tag.updatedAt = DateTime.now();

    await _bookmarkRepository.update(bookmark);
    await _tagRepository.update(tag);
  }

  /// Replaces all tags on the bookmark with [bookmarkId] with [tagIds].
  ///
  /// Adjusts [Tag.usageCount] for all affected tags: increments for
  /// newly added tags, decrements for removed tags (never below 0).
  Future<void> setTagsForBookmark(Id bookmarkId, List<Id> tagIds) async {
    final bookmark = await _bookmarkRepository.getById(bookmarkId);
    if (bookmark == null) {
      return;
    }

    final currentIds = Set<Id>.from(bookmark.tagIds ?? <int>[]);
    final newIds = Set<Id>.from(tagIds);

    final added = newIds.difference(currentIds);
    final removed = currentIds.difference(newIds);

    // Update bookmark tag list.
    bookmark.tagIds = tagIds.isEmpty ? null : List<Id>.from(tagIds);
    bookmark.updatedAt = DateTime.now();
    await _bookmarkRepository.update(bookmark);

    // Increment usageCount for added tags.
    for (final id in added) {
      final tag = await _tagRepository.getById(id);
      if (tag != null) {
        tag.usageCount++;
        tag.updatedAt = DateTime.now();
        await _tagRepository.update(tag);
      }
    }

    // Decrement usageCount for removed tags.
    for (final id in removed) {
      final tag = await _tagRepository.getById(id);
      if (tag != null) {
        tag.usageCount = tag.usageCount > 0 ? tag.usageCount - 1 : 0;
        tag.updatedAt = DateTime.now();
        await _tagRepository.update(tag);
      }
    }
  }
}
