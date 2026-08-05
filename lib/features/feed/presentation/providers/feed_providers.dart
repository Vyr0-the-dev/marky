import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/ai/domain/services/related_items_service.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ─── Paginated feed state ──────────────────────────────────────────────

/// Immutable state for the paginated bookmark feed.
class PaginatedFeedState {
  const PaginatedFeedState({
    this.items = const <BookmarkItem>[],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.error,
  });

  final List<BookmarkItem> items;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? error;

  /// Returns a copy with selected fields replaced.
  PaginatedFeedState copyWith({
    List<BookmarkItem>? items,
    bool? hasMore,
    bool? isLoadingMore,
    Object? error,
  }) {
    return PaginatedFeedState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error is! _Undefined ? error : this.error,
    );
  }

  @override
  String toString() =>
      'PaginatedFeedState(items: ${items.length}, hasMore: $hasMore, '
      'isLoadingMore: $isLoadingMore, error: $error)';
}

// Sentinel used by [copyWith] to distinguish "not provided" from `null`.
class _Undefined {
  const _Undefined();
}

// ─── Paginated feed notifier ───────────────────────────────────────────

/// Notifier that drives the paginated bookmark feed.
///
/// Loads the first page (24 items) on init and exposes [loadMore] to
/// append subsequent pages while [PaginatedFeedState.hasMore] is true.
class PaginatedFeedNotifier extends StateNotifier<PaginatedFeedState> {
  PaginatedFeedNotifier({required BookmarkItemRepository repository})
      : _repository = repository,
        _logger = Logger(),
        super(const PaginatedFeedState(isLoadingMore: true)) {
    unawaited(_loadInitial());
  }

  final BookmarkItemRepository _repository;
  final Logger _logger;

  static const int _pageSize = 24;

  /// Loads the first page of bookmarks.
  Future<void> _loadInitial() async {
    _logger.i('PaginatedFeedNotifier: loading initial page');
    try {
      final List<BookmarkItem> items = await _repository.getAll(
        offset: 0,
        limit: _pageSize,
      );
      state = PaginatedFeedState(
        items: items,
        hasMore: items.length == _pageSize,
        isLoadingMore: false,
      );
      _logger.i(
        'PaginatedFeedNotifier: loaded ${items.length} items, '
        'hasMore=${items.length == _pageSize}',
      );
    } on Object catch (e, stackTrace) {
      _logger.e(
        'PaginatedFeedNotifier: failed to load initial page',
        error: e,
        stackTrace: stackTrace,
      );
      state = PaginatedFeedState(
        error: e,
        isLoadingMore: false,
        hasMore: true,
      );
    }
  }

  /// Loads the next page and appends it to the current items.
  ///
  /// No-op when [state.hasMore] is false or [state.isLoadingMore] is true.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) {
      _logger.d(
        'PaginatedFeedNotifier: loadMore skipped — '
        'hasMore=${state.hasMore}, isLoadingMore=${state.isLoadingMore}',
      );
      return;
    }

    _logger.i('PaginatedFeedNotifier: loading more (offset=${state.items.length})');
    state = state.copyWith(isLoadingMore: true);

    try {
      final List<BookmarkItem> newItems = await _repository.getAll(
        offset: state.items.length,
        limit: _pageSize,
      );

      final List<BookmarkItem> merged = <BookmarkItem>[
        ...state.items,
        ...newItems,
      ];

      state = state.copyWith(
        items: merged,
        hasMore: newItems.length == _pageSize,
        isLoadingMore: false,
      );
      _logger.i(
        'PaginatedFeedNotifier: loaded ${newItems.length} more items, '
        'total=${merged.length}, hasMore=${newItems.length == _pageSize}',
      );
    } on Object catch (e, stackTrace) {
      _logger.e(
        'PaginatedFeedNotifier: failed to load more',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isLoadingMore: false,
        error: e,
      );
    }
  }

  /// Refreshes the feed by reloading from the first page.
  ///
  /// Preserves the current item list until the refresh completes to
  /// avoid jarring UI flashes.
  Future<void> refresh() async {
    _logger.i('PaginatedFeedNotifier: refreshing');
    state = state.copyWith(isLoadingMore: true);

    try {
      final List<BookmarkItem> items = await _repository.getAll(
        offset: 0,
        limit: _pageSize,
      );
      state = PaginatedFeedState(
        items: items,
        hasMore: items.length == _pageSize,
        isLoadingMore: false,
      );
      _logger.i(
        'PaginatedFeedNotifier: refreshed with ${items.length} items',
      );
    } on Object catch (e, stackTrace) {
      _logger.e(
        'PaginatedFeedNotifier: refresh failed',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isLoadingMore: false,
        error: e,
      );
    }
  }
}

// ─── Feed providers ────────────────────────────────────────────────────

/// Provider that exposes the paginated bookmark feed state and notifier.
///
/// Replaces the previous [FutureProvider] with incremental loading via
/// [PaginatedFeedNotifier.loadMore].
final StateNotifierProvider<PaginatedFeedNotifier, PaginatedFeedState>
    bookmarkListProvider =
    StateNotifierProvider<PaginatedFeedNotifier, PaginatedFeedState>(
  (Ref ref) {
    final BookmarkItemRepository repository =
        ref.watch(bookmarkRepositoryProvider);
    return PaginatedFeedNotifier(repository: repository);
  },
);

/// Provider that looks up a single bookmark by its ID.
///
/// Returns a [Future] that resolves to the bookmark if found, or `null`
/// if no bookmark exists with the given ID. Widgets should handle loading,
/// error, and data (including `null`) states via [AsyncValue].
final FutureProviderFamily<BookmarkItem?, int> bookmarkByIdProvider =
    FutureProvider.family<BookmarkItem?, int>((Ref ref, int id) async {
  final BookmarkItemRepository repository = ref.watch(bookmarkRepositoryProvider);
  return repository.getById(id);
});

// ─── Related items providers ───────────────────────────────────────────

/// Provider for [RelatedItemsService], wired to the live repository.
final Provider<RelatedItemsService> relatedItemsServiceProvider =
    Provider<RelatedItemsService>((Ref ref) {
  return HeuristicRelatedItemsService(
    repository: ref.watch(bookmarkRepositoryProvider),
  );
});

/// Provider that finds bookmarks related to the one identified by [bookmarkId].
///
/// Returns a [Future] that resolves to a list of related bookmarks,
/// sorted by relevance. Returns an empty list when the source bookmark
/// is not found or when no related items exist.
final FutureProviderFamily<List<BookmarkItem>, int> relatedItemsProvider =
    FutureProvider.family<List<BookmarkItem>, int>((Ref ref, int bookmarkId) async {
  final service = ref.watch(relatedItemsServiceProvider);
  final bookmark = await ref.watch(bookmarkByIdProvider(bookmarkId).future);
  if (bookmark == null) return [];
  return service.findRelated(bookmark);
});
