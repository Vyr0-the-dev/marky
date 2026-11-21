import 'package:flutter/foundation.dart';

import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';

/// Presentation state for the home feed screen.
///
/// Tracks the active query, optional human-readable filter label (e.g. for
/// smart collections), view mode, selection mode, and selected bookmark IDs.
@immutable
class FeedState {
  const FeedState({
    this.query = const BookmarkFeedQuery(),
    this.activeFilterLabel,
    this.viewMode = FeedViewMode.list,
    this.selectionMode = false,
    this.selectedIds = const <int>{},
  });

  final BookmarkFeedQuery query;
  final String? activeFilterLabel;
  final FeedViewMode viewMode;
  final bool selectionMode;
  final Set<int> selectedIds;

  int get selectedCount => selectedIds.length;

  bool get hasActiveNarrowing =>
      query.tagId != null ||
      query.collectionId != null ||
      query.host != null ||
      query.contentType != null ||
      query.createdAfter != null ||
      query.createdBefore != null ||
      (activeFilterLabel != null && activeFilterLabel!.isNotEmpty);

  FeedState copyWith({
    BookmarkFeedQuery? query,
    String? activeFilterLabel,
    bool clearActiveFilterLabel = false,
    FeedViewMode? viewMode,
    bool? selectionMode,
    Set<int>? selectedIds,
  }) {
    return FeedState(
      query: query ?? this.query,
      activeFilterLabel: clearActiveFilterLabel
          ? null
          : (activeFilterLabel ?? this.activeFilterLabel),
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
        other.activeFilterLabel == activeFilterLabel &&
        other.viewMode == viewMode &&
        other.selectionMode == selectionMode &&
        setEquals(other.selectedIds, selectedIds);
  }

  @override
  int get hashCode => Object.hash(
        query,
        activeFilterLabel,
        viewMode,
        selectionMode,
        selectedIds.length,
      );
}

enum FeedViewMode { list, grid }
