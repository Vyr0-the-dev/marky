import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/features/tags/domain/use_cases/assign_tags_to_bookmark_use_case.dart';
import 'package:marky/features/tags/domain/use_cases/manage_tags_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/tag.dart';

// ─── Simple future providers ───────────────────────────────────────────

/// Loads all tags from the repository.
final FutureProvider<List<Tag>> tagListProvider =
    FutureProvider<List<Tag>>((Ref ref) async {
  final TagRepository repository = ref.watch(tagRepositoryProvider);
  return repository.getAll();
});

/// O(1) lookup map derived from [tagListProvider].
///
/// Eliminates the O(N) linear scan inside list-building widgets (e.g.
/// [BookmarkCard]) when resolving tag names from bookmark tag IDs.
final Provider<AsyncValue<Map<int, Tag>>> tagMapProvider =
    Provider<AsyncValue<Map<int, Tag>>>((Ref ref) {
  final AsyncValue<List<Tag>> tagsAsync = ref.watch(tagListProvider);
  return tagsAsync.when(
    data: (List<Tag> tags) =>
        AsyncValue<Map<int, Tag>>.data(<int, Tag>{
      for (final Tag t in tags) t.id: t,
    }),
    loading: () => const AsyncValue<Map<int, Tag>>.loading(),
    error: (Object e, StackTrace st) =>
        AsyncValue<Map<int, Tag>>.error(e, st),
  );
});

/// Looks up a single tag by its ID.
final FutureProviderFamily<Tag?, int> tagByIdProvider =
    FutureProvider.family<Tag?, int>((Ref ref, int id) async {
  final TagRepository repository = ref.watch(tagRepositoryProvider);
  return repository.getById(id);
});

// ─── Use-case providers ────────────────────────────────────────────────

/// Provider for [ManageTagsUseCase], wired to live repositories.
final Provider<ManageTagsUseCase> manageTagsUseCaseProvider =
    Provider<ManageTagsUseCase>((Ref ref) {
  final TagRepository tagRepo = ref.watch(tagRepositoryProvider);
  final bookmarkRepo = ref.watch(bookmarkRepositoryProvider);
  return ManageTagsUseCase(
    tagRepository: tagRepo,
    bookmarkRepository: bookmarkRepo,
  );
});

/// Provider for [AssignTagsToBookmarkUseCase], wired to live repositories.
final Provider<AssignTagsToBookmarkUseCase> assignTagsUseCaseProvider =
    Provider<AssignTagsToBookmarkUseCase>((Ref ref) {
  final bookmarkRepo = ref.watch(bookmarkRepositoryProvider);
  final tagRepo = ref.watch(tagRepositoryProvider);
  return AssignTagsToBookmarkUseCase(
    bookmarkRepository: bookmarkRepo,
    tagRepository: tagRepo,
  );
});

// ─── State notifiers ───────────────────────────────────────────────────

/// Notifier that manages the tag list with CRUD operations.
class TagManagerNotifier extends StateNotifier<AsyncValue<List<Tag>>> {
  /// Creates the notifier and immediately loads the tag list.
  TagManagerNotifier({required ManageTagsUseCase useCase})
      : _useCase = useCase,
        super(const AsyncValue<List<Tag>>.loading()) {
    unawaited(load());
  }

  final ManageTagsUseCase _useCase;
  final Logger _logger = Logger();

  /// Reloads the full tag list from the repository.
  Future<void> load() async {
    state = const AsyncValue<List<Tag>>.loading();
    try {
      final List<Tag> tags = await _useCase.getAll();
      state = AsyncValue<List<Tag>>.data(tags);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to load tags', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Tag>>.error(e, stackTrace);
    }
  }

  /// Creates a new tag and refreshes the list.
  Future<void> create(
    String name, {
    String? color,
    String? icon,
  }) async {
    try {
      await _useCase.create(name, color: color, icon: icon);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to create tag', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Tag>>.error(e, stackTrace);
    }
  }

  /// Updates an existing tag and refreshes the list.
  Future<void> update(Tag tag) async {
    try {
      await _useCase.update(tag);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to update tag', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Tag>>.error(e, stackTrace);
    }
  }

  /// Deletes a tag by ID and refreshes the list.
  Future<void> delete(int id) async {
    try {
      await _useCase.delete(id);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to delete tag', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Tag>>.error(e, stackTrace);
    }
  }
}

/// Provider for [TagManagerNotifier].
final StateNotifierProvider<TagManagerNotifier, AsyncValue<List<Tag>>>
    tagManagerNotifierProvider =
    StateNotifierProvider<TagManagerNotifier, AsyncValue<List<Tag>>>(
  (Ref ref) => TagManagerNotifier(
    useCase: ref.watch(manageTagsUseCaseProvider),
  ),
);

/// Notifier that manages tag assignment operations on a single bookmark.
///
/// State is [AsyncValue<void>] because the UI primarily cares about
/// whether an operation is in progress or has failed; the bookmark's
/// tag list is read from the bookmark itself.
class TagAssignmentNotifier extends StateNotifier<AsyncValue<void>> {
  /// Creates the notifier in an idle state.
  TagAssignmentNotifier({required AssignTagsToBookmarkUseCase useCase})
      : _useCase = useCase,
        super(const AsyncValue<void>.data(null));

  final AssignTagsToBookmarkUseCase _useCase;
  final Logger _logger = Logger();

  /// Adds [tagId] to the bookmark with [bookmarkId].
  Future<void> addTag(int bookmarkId, int tagId) async {
    state = const AsyncValue<void>.loading();
    try {
      await _useCase.addTagToBookmark(bookmarkId, tagId);
      state = const AsyncValue<void>.data(null);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to add tag to bookmark',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<void>.error(e, stackTrace);
    }
  }

  /// Removes [tagId] from the bookmark with [bookmarkId].
  Future<void> removeTag(int bookmarkId, int tagId) async {
    state = const AsyncValue<void>.loading();
    try {
      await _useCase.removeTagFromBookmark(bookmarkId, tagId);
      state = const AsyncValue<void>.data(null);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to remove tag from bookmark',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<void>.error(e, stackTrace);
    }
  }

  /// Replaces all tags on the bookmark with [bookmarkId] with [tagIds].
  Future<void> setTags(int bookmarkId, List<int> tagIds) async {
    state = const AsyncValue<void>.loading();
    try {
      await _useCase.setTagsForBookmark(bookmarkId, tagIds);
      state = const AsyncValue<void>.data(null);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to set tags for bookmark',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<void>.error(e, stackTrace);
    }
  }
}

/// Provider for [TagAssignmentNotifier].
final StateNotifierProvider<TagAssignmentNotifier, AsyncValue<void>>
    tagAssignmentNotifierProvider =
    StateNotifierProvider<TagAssignmentNotifier, AsyncValue<void>>(
  (Ref ref) => TagAssignmentNotifier(
    useCase: ref.watch(assignTagsUseCaseProvider),
  ),
);

// ─── Bookmark by tag provider ────────────────────────────────────────

/// Loads all bookmarks tagged with the tag having [tagId].
final FutureProviderFamily<List<BookmarkItem>, int> bookmarksByTagIdProvider =
    FutureProvider.family<List<BookmarkItem>, int>((Ref ref, int tagId) async {
  final BookmarkItemRepository repository =
      ref.watch(bookmarkRepositoryProvider);
  return repository.getByTagId(tagId);
});
