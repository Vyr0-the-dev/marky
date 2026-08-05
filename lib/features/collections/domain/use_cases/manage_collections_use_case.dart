import 'package:isar/isar.dart';

import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/shared/models/collection.dart';

/// Use case for managing collections: creation, update, deletion, and lookups.
///
/// Handles slug generation with collision resolution and cleans up
/// bookmark references when a collection is deleted.
class ManageCollectionsUseCase {
  ManageCollectionsUseCase({
    required CollectionRepository collectionRepository,
    required BookmarkItemRepository bookmarkRepository,
  })  : _collectionRepository = collectionRepository,
        _bookmarkRepository = bookmarkRepository;

  final CollectionRepository _collectionRepository;
  final BookmarkItemRepository _bookmarkRepository;

  // ─── Create ────────────────────────────────────────────────────────────

  /// Creates a new collection with the given [title].
  ///
  /// Optional [description], [icon], [accentColor], [coverMode],
  /// [coverImageUrl], [coverLocalPath], [sortMode] can be provided.
  /// Slug is auto-generated from [title] with collision resolution.
  ///
  /// Returns the ID of the newly created collection.
  Future<Id> create(
    String title, {
    String? description,
    String? icon,
    String? accentColor,
    String? coverMode,
    String? coverImageUrl,
    String? coverLocalPath,
    String? sortMode,
  }) async {
    final String slug = await _generateUniqueSlug(_toSlug(title));
    final DateTime now = DateTime.now();

    final BookmarkCollection collection = BookmarkCollection(
      title: title.trim(),
      slug: slug,
      description: description,
      icon: icon,
      accentColor: accentColor,
      coverMode: coverMode,
      coverImageUrl: coverImageUrl,
      coverLocalPath: coverLocalPath,
      sortMode: sortMode,
      createdAt: now,
      updatedAt: now,
    );

    return _collectionRepository.insert(collection);
  }

  // ─── Update ────────────────────────────────────────────────────────────

  /// Updates an existing [collection] in place.
  ///
  /// Sets [updatedAt] to now before persisting.
  Future<Id> update(BookmarkCollection collection) async {
    collection.updatedAt = DateTime.now();
    return _collectionRepository.update(collection);
  }

  // ─── Delete ────────────────────────────────────────────────────────────

  /// Deletes the collection with [id] and cleans up bookmark references.
  ///
  /// After deletion, finds all bookmarks whose [collectionIds] contain [id],
  /// removes the ID from each, and persists the bookmarks.
  Future<void> delete(Id id) async {
    final collection = await _collectionRepository.getById(id);
    if (collection == null) {
      return;
    }

    // Remove collection reference from all bookmarks.
    final bookmarks = await _bookmarkRepository.getByCollectionId(id);
    for (final bookmark in bookmarks) {
      final List<int>? collectionIds = bookmark.collectionIds;
      if (collectionIds != null && collectionIds.contains(id)) {
        collectionIds.remove(id);
        bookmark.collectionIds = collectionIds.isEmpty ? null : collectionIds;
        bookmark.updatedAt = DateTime.now();
        await _bookmarkRepository.update(bookmark);
      }
    }

    // Delete the collection itself.
    await _collectionRepository.delete(id);
  }

  // ─── Read ──────────────────────────────────────────────────────────────

  /// Returns all collections.
  Future<List<BookmarkCollection>> getAll() => _collectionRepository.getAll();

  /// Returns the collection with [id], or `null` if not found.
  Future<BookmarkCollection?> getById(Id id) =>
      _collectionRepository.getById(id);

  /// Returns the collection whose slug equals [slug], or `null` if not found.
  Future<BookmarkCollection?> getBySlug(String slug) =>
      _collectionRepository.getBySlug(slug);

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
    var candidate = baseSlug.isEmpty ? 'collection' : baseSlug;
    int counter = 1;

    while (await _collectionRepository.getBySlug(candidate) != null) {
      candidate = '$baseSlug-$counter';
      counter++;
    }

    return candidate;
  }
}
