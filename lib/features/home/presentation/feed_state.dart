import 'package:flutter/foundation.dart';

import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';

/// Presentation state for the home feed screen.
///
/// Tracks the active query, view mode, selection mode,
/// and selected bookmark IDs.
@immutable
class FeedState {
  const FeedState({
    this.query = const BookmarkFeedQuery(),
    this.viewMode = FeedViewMode.list,
    this.selectionMode = false,
    this.selectedIds = const <int>{},
  });

  final BookmarkFeedQuery query;
  final FeedViewMode viewMode;
  final bool selectionMode;
  final Set<int> selectedIds;

  int get selectedCount => selectedIds.length;

  FeedState copyWith({
    BookmarkFeedQuery? query,
    FeedViewMode? viewMode,
    bool? selectionMode,
    Set<int>? selectedIds,
  }) {
    return FeedState(
      query: query ?? this.query,
      viewMode: viewMode ?? this.viewMode,
      selectionMode: selectionMode ?? this.selectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedState &&
        other.query == query &&
        other.viewMode == viewMode &&
        other.selectionMode == selectionMode &&
        setEquals(other.selectedIds, selectedIds);
  }

  @override
  int get hashCode =>
      Object.hash(query, viewMode, selectionMode, selectedIds.length);
}

enum FeedViewMode { list, grid }
