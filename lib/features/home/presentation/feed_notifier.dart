import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/home/presentation/feed_state.dart';

/// Manages [FeedState] — filter chips, sort, pagination, view mode, and
/// selection. This is pure presentation logic with no side-effects.
class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(const FeedState());

  static const int pageSize = 100;

  // ─── Filter / sort / pagination ────────────────────────────────

  void setFilter(BookmarkFeedFilter filter) {
    state = state.copyWith(
      query: state.query.copyWith(filter: filter, limit: pageSize),
    );
  }

  void setSort(BookmarkSort sort) {
    state = state.copyWith(
      query: state.query.copyWith(sort: sort, limit: pageSize),
    );
  }

  void applyQuery(BookmarkFeedQuery query, {String? filterLabel}) {
    state = state.copyWith(
      query: query.copyWith(limit: pageSize),
      activeFilterLabel: filterLabel,
      clearActiveFilterLabel: filterLabel == null,
    );
  }

  /// Increases the query limit by [pageSize] so scrolling past 100 bookmarks
  /// seamlessly reveals the rest of the library.
  void loadMore() {
    state = state.copyWith(
      query: state.query.copyWith(limit: state.query.limit + pageSize),
    );
  }

  /// Clears all narrowing criteria (tag, collection, host, content type,
  /// date range, smart collection label) while preserving top-level filter
  /// and sort order.
  void clearNarrowing() {
    state = state.copyWith(
      query: BookmarkFeedQuery(
        filter: state.query.filter,
        sort: state.query.sort,
      ),
      clearActiveFilterLabel: true,
    );
  }

  void setTagId(int? tagId) {
    state = state.copyWith(
      query: BookmarkFeedQuery(
        filter: state.query.filter,
        sort: state.query.sort,
        tagId: tagId,
        collectionId: state.query.collectionId,
        contentType: state.query.contentType,
        host: state.query.host,
        createdAfter: state.query.createdAfter,
        createdBefore: state.query.createdBefore,
        offset: state.query.offset,
      ),
      clearActiveFilterLabel: tagId == null,
    );
  }

  void setCollectionId(int? collectionId) {
    state = state.copyWith(
      query: BookmarkFeedQuery(
        filter: state.query.filter,
        sort: state.query.sort,
        tagId: state.query.tagId,
        collectionId: collectionId,
        contentType: state.query.contentType,
        host: state.query.host,
        createdAfter: state.query.createdAfter,
        createdBefore: state.query.createdBefore,
        offset: state.query.offset,
      ),
      clearActiveFilterLabel: collectionId == null,
    );
  }

  void setContentType(BookmarkContentType? type) {
    state = state.copyWith(
      query: BookmarkFeedQuery(
        filter: state.query.filter,
        sort: state.query.sort,
        tagId: state.query.tagId,
        collectionId: state.query.collectionId,
        contentType: type,
        host: state.query.host,
        createdAfter: state.query.createdAfter,
        createdBefore: state.query.createdBefore,
        offset: state.query.offset,
      ),
      clearActiveFilterLabel: type == null,
    );
  }

  /// Narrows the feed to a single normalized host (e.g. `nytimes.com`).
  /// Pass `null` to clear the filter.
  void setHost(String? host) {
    state = state.copyWith(
      query: BookmarkFeedQuery(
        filter: state.query.filter,
        sort: state.query.sort,
        tagId: state.query.tagId,
        collectionId: state.query.collectionId,
        contentType: state.query.contentType,
        host: host,
        createdAfter: state.query.createdAfter,
        createdBefore: state.query.createdBefore,
        offset: state.query.offset,
      ),
      clearActiveFilterLabel: host == null,
    );
  }

  // ─── View mode ─────────────────────────────────────────────────

  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == FeedViewMode.list
          ? FeedViewMode.grid
          : FeedViewMode.list,
    );
  }

  // ─── Selection ─────────────────────────────────────────────────

  void enterSelectionMode(int firstId) {
    state = state.copyWith(
      selectionMode: true,
      selectedIds: <int>{firstId},
    );
  }

  void exitSelectionMode() {
    state = state.copyWith(
      selectionMode: false,
      selectedIds: const <int>{},
    );
  }

  void toggleSelection(int id) {
    final Set<int> updated = Set<int>.of(state.selectedIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    if (updated.isEmpty) {
      exitSelectionMode();
      return;
    }
    state = state.copyWith(selectedIds: updated);
  }

  void selectAll(List<int> ids) {
    state = state.copyWith(
      selectionMode: true,
      selectedIds: ids.toSet(),
    );
  }
}

/// Riverpod provider for [FeedNotifier].
final StateNotifierProvider<FeedNotifier, FeedState> feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((Ref ref) {
  return FeedNotifier();
});
