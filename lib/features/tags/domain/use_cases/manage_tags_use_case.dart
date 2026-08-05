import 'package:isar/isar.dart';

import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/shared/models/tag.dart';

/// Use case for managing tags: creation, update, deletion, and lookups.
///
/// Handles slug generation with collision resolution and cleans up
/// bookmark references when a tag is deleted.
class ManageTagsUseCase {
  ManageTagsUseCase({
    required TagRepository tagRepository,
    required BookmarkItemRepository bookmarkRepository,
  })  : _tagRepository = tagRepository,
        _bookmarkRepository = bookmarkRepository;

  final TagRepository _tagRepository;
  final BookmarkItemRepository _bookmarkRepository;

  // ─── Create ────────────────────────────────────────────────────────────

  /// Creates a new tag with the given [name].
  ///
  /// Optional [color] and [icon] can be provided for visual styling.
  /// Slug is auto-generated from [name] with collision resolution.
  ///
  /// Returns the ID of the newly created tag.
  Future<Id> create(
    String name, {
    String? color,
    String? icon,
  }) async {
    final String slug = await _generateUniqueSlug(_toSlug(name));
    final DateTime now = DateTime.now();

    final Tag tag = Tag(
      name: name.trim(),
      slug: slug,
      color: color,
      icon: icon,
      createdAt: now,
      updatedAt: now,
    );

    return _tagRepository.insert(tag);
  }

  // ─── Update ────────────────────────────────────────────────────────────

  /// Updates an existing [tag] in place.
  ///
  /// Sets [updatedAt] to now before persisting.
  Future<Id> update(Tag tag) async {
    tag.updatedAt = DateTime.now();
    return _tagRepository.update(tag);
  }

  // ─── Delete ────────────────────────────────────────────────────────────

  /// Deletes the tag with [id] and cleans up bookmark references.
  ///
  /// After deletion, finds all bookmarks whose [tagIds] contain [id],
  /// removes the ID from each, persists the bookmarks, and decrements
  /// usage counts on any tags that still have orphaned references.
  Future<void> delete(Id id) async {
    final tag = await _tagRepository.getById(id);
    if (tag == null) {
      return;
    }

    // Remove tag reference from all bookmarks.
    final bookmarks = await _bookmarkRepository.getByTagId(id);
    final Set<Id> affectedTagIds = <Id>{};

    for (final bookmark in bookmarks) {
      final List<int>? tagIds = bookmark.tagIds;
      if (tagIds != null && tagIds.contains(id)) {
        tagIds.remove(id);
        bookmark.tagIds = tagIds.isEmpty ? null : tagIds;
        bookmark.updatedAt = DateTime.now();
        await _bookmarkRepository.update(bookmark);

        // Track remaining tags on this bookmark for usageCount cleanup.
        for (final remainingId in tagIds) {
          affectedTagIds.add(remainingId);
        }
      }
    }

    // Delete the tag itself.
    await _tagRepository.delete(id);

    // Defensive: decrement usageCount on tags that still have orphaned
    // references (shouldn't happen in normal flow, but protects against
    // drift).
    for (final tagId in affectedTagIds) {
      final affectedTag = await _tagRepository.getById(tagId);
      if (affectedTag != null && affectedTag.usageCount > 0) {
        final stillUsed =
            (await _bookmarkRepository.getByTagId(tagId)).isNotEmpty;
        if (!stillUsed) {
          affectedTag.usageCount = 0;
        }
        await _tagRepository.update(affectedTag);
      }
    }
  }

  // ─── Read ──────────────────────────────────────────────────────────────

  /// Returns all tags.
  Future<List<Tag>> getAll() => _tagRepository.getAll();

  /// Returns the tag with [id], or `null` if not found.
  Future<Tag?> getById(Id id) => _tagRepository.getById(id);

  /// Returns the tag whose slug equals [slug], or `null` if not found.
  Future<Tag?> getBySlug(String slug) => _tagRepository.getBySlug(slug);

  // ─── Slug utilities ────────────────────────────────────────────────────

  /// Converts a name into a URL-safe slug.
  static String _toSlug(String name) {
    var normalized = name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp('-+'), '-');

    while (normalized.startsWith('-')) {
      normalized = normalized.substring(1);
    }
    while (normalized.endsWith('-')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    return normalized;
  }

  /// Ensures [baseSlug] is unique by appending `-1`, `-2`, etc.
  Future<String> _generateUniqueSlug(String baseSlug) async {
    var candidate = baseSlug.isEmpty ? 'tag' : baseSlug;
    int counter = 1;

    while (await _tagRepository.getBySlug(candidate) != null) {
      candidate = '$baseSlug-$counter';
      counter++;
    }

    return candidate;
  }
}
