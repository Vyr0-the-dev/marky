import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/collections/domain/use_cases/assign_collections_to_bookmark_use_case.dart';
import 'package:marky/features/collections/domain/use_cases/manage_collections_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';

// ─── Simple future providers ───────────────────────────────────────────

/// Loads all collections from the repository.
final FutureProvider<List<BookmarkCollection>> collectionListProvider =
    FutureProvider<List<BookmarkCollection>>((Ref ref) async {
  final CollectionRepository repository = ref.watch(collectionRepositoryProvider);
  return repository.getAll();
});

/// Looks up a single collection by its ID.
final FutureProviderFamily<BookmarkCollection?, int> collectionByIdProvider =
    FutureProvider.family<BookmarkCollection?, int>((Ref ref, int id) async {
  final CollectionRepository repository = ref.watch(collectionRepositoryProvider);
  return repository.getById(id);
});

// ─── Use-case providers ────────────────────────────────────────────────

/// Provider for [ManageCollectionsUseCase], wired to live repositories.
final Provider<ManageCollectionsUseCase> manageCollectionsUseCaseProvider =
    Provider<ManageCollectionsUseCase>((Ref ref) {
  final CollectionRepository collectionRepo = ref.watch(collectionRepositoryProvider);
  final BookmarkItemRepository bookmarkRepo = ref.watch(bookmarkRepositoryProvider);
  return ManageCollectionsUseCase(
    collectionRepository: collectionRepo,
    bookmarkRepository: bookmarkRepo,
  );
});

/// Provider for [AssignCollectionsToBookmarkUseCase], wired to live repositories.
final Provider<AssignCollectionsToBookmarkUseCase> assignCollectionsUseCaseProvider =
    Provider<AssignCollectionsToBookmarkUseCase>((Ref ref) {
  final BookmarkItemRepository bookmarkRepo = ref.watch(bookmarkRepositoryProvider);
  final CollectionRepository collectionRepo = ref.watch(collectionRepositoryProvider);
  return AssignCollectionsToBookmarkUseCase(
    bookmarkRepository: bookmarkRepo,
    collectionRepository: collectionRepo,
  );
});

// ─── State notifiers ───────────────────────────────────────────────────

/// Notifier that manages the collection list with CRUD operations.
class CollectionManagerNotifier extends StateNotifier<AsyncValue<List<BookmarkCollection>>> {
  /// Creates the notifier and immediately loads the collection list.
  CollectionManagerNotifier({required ManageCollectionsUseCase useCase})
      : _useCase = useCase,
        super(const AsyncValue<List<BookmarkCollection>>.loading()) {
    unawaited(load());
  }

  final ManageCollectionsUseCase _useCase;
  final Logger _logger = Logger();

  /// Reloads the full collection list from the repository.
  Future<void> load() async {
    state = const AsyncValue<List<BookmarkCollection>>.loading();
    try {
      final List<BookmarkCollection> collections = await _useCase.getAll();
      state = AsyncValue<List<BookmarkCollection>>.data(collections);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to load collections', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<BookmarkCollection>>.error(e, stackTrace);
    }
  }

  /// Creates a new collection and refreshes the list.
  Future<void> create(
    String title, {
    String? description,
    String? icon,
    String? accentColor,
    String? coverMode,
    String? coverImageUrl,
    String? coverLocalPath,
    String? sortMode,
  }) async {
    try {
      await _useCase.create(
        title,
        description: description,
        icon: icon,
        accentColor: accentColor,
        coverMode: coverMode,
        coverImageUrl: coverImageUrl,
        coverLocalPath: coverLocalPath,
        sortMode: sortMode,
      );
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to create collection', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<BookmarkCollection>>.error(e, stackTrace);
    }
  }

  /// Updates an existing collection and refreshes the list.
  Future<void> update(BookmarkCollection collection) async {
    try {
      await _useCase.update(collection);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to update collection', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<BookmarkCollection>>.error(e, stackTrace);
    }
  }

  /// Deletes a collection by ID and refreshes the list.
  Future<void> delete(int id) async {
    try {
      await _useCase.delete(id);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to delete collection', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<BookmarkCollection>>.error(e, stackTrace);
    }
  }
}

/// Provider for [CollectionManagerNotifier].
final StateNotifierProvider<CollectionManagerNotifier, AsyncValue<List<BookmarkCollection>>>
    collectionManagerNotifierProvider =
    StateNotifierProvider<CollectionManagerNotifier, AsyncValue<List<BookmarkCollection>>>(
  (Ref ref) => CollectionManagerNotifier(
    useCase: ref.watch(manageCollectionsUseCaseProvider),
  ),
);

/// Notifier that manages collection assignment operations on a single bookmark.
///
/// State is [AsyncValue<void>] because the UI primarily cares about
/// whether an operation is in progress or has failed; the bookmark's
/// collection list is read from the bookmark itself.
class CollectionAssignmentNotifier extends StateNotifier<AsyncValue<void>> {
  /// Creates the notifier in an idle state.
  CollectionAssignmentNotifier({required AssignCollectionsToBookmarkUseCase useCase})
      : _useCase = useCase,
        super(const AsyncValue<void>.data(null));

  final AssignCollectionsToBookmarkUseCase _useCase;
  final Logger _logger = Logger();

  /// Adds [collectionId] to the bookmark with [bookmarkId].
  Future<void> addCollection(int bookmarkId, int collectionId) async {
    state = const AsyncValue<void>.loading();
    try {
      await _useCase.addCollectionToBookmark(bookmarkId, collectionId);
      state = const AsyncValue<void>.data(null);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to add collection to bookmark',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<void>.error(e, stackTrace);
    }
  }

  /// Removes [collectionId] from the bookmark with [bookmarkId].
  Future<void> removeCollection(int bookmarkId, int collectionId) async {
    state = const AsyncValue<void>.loading();
    try {
      await _useCase.removeCollectionFromBookmark(bookmarkId, collectionId);
      state = const AsyncValue<void>.data(null);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to remove collection from bookmark',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<void>.error(e, stackTrace);
    }
  }

  /// Replaces all collections on the bookmark with [bookmarkId] with [collectionIds].
  Future<void> setCollections(int bookmarkId, List<int> collectionIds) async {
    state = const AsyncValue<void>.loading();
    try {
      await _useCase.setCollectionsForBookmark(bookmarkId, collectionIds);
      state = const AsyncValue<void>.data(null);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to set collections for bookmark',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<void>.error(e, stackTrace);
    }
  }
}

/// Provider for [CollectionAssignmentNotifier].
final StateNotifierProvider<CollectionAssignmentNotifier, AsyncValue<void>>
    collectionAssignmentNotifierProvider =
    StateNotifierProvider<CollectionAssignmentNotifier, AsyncValue<void>>(
  (Ref ref) => CollectionAssignmentNotifier(
    useCase: ref.watch(assignCollectionsUseCaseProvider),
  ),
);

// ─── Bookmark by collection provider ───────────────────────────────────

/// Loads all bookmarks belonging to the collection with [collectionId].
final FutureProviderFamily<List<BookmarkItem>, int> bookmarksByCollectionIdProvider =
    FutureProvider.family<List<BookmarkItem>, int>((Ref ref, int collectionId) async {
  final BookmarkItemRepository repository =
      ref.watch(bookmarkRepositoryProvider);
  return repository.getByCollectionId(collectionId);
});
