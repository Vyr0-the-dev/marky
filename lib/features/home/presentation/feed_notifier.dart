import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/home/presentation/feed_state.dart';

/// Manages [FeedState] — filter chips, sort, view mode, and
/// selection. This is pure presentation logic with no side-effects.
///
/// Bookmark mutation actions (archive, delete, favorite) are handled
/// by the repository and surfaced through the stream; this notifier
/// only manages *which* items are visible and *how* they're shown.
class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(const FeedState());

  // ─── Filter / sort ─────────────────────────────────────────────

  void setFilter(BookmarkFeedFilter filter) {
    state = state.copyWith(
      query: state.query.copyWith(filter: filter),
    );
  }

  void setSort(BookmarkSort sort) {
    state = state.copyWith(
      query: state.query.copyWith(sort: sort),
    );
  }

  void applyQuery(BookmarkFeedQuery query) {
    state = state.copyWith(query: query);
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
        limit: state.query.limit,
        offset: state.query.offset,
      ),
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
        limit: state.query.limit,
        offset: state.query.offset,
      ),
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
        limit: state.query.limit,
        offset: state.query.offset,
      ),
    );
  }

  /// Narrows the feed to a single normalized host (e.g.
  /// `nytimes.com`).  Pass `null` to clear the filter.
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
        limit: state.query.limit,
        offset: state.query.offset,
      ),
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
    // Auto-exit when nothing is selected.
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
