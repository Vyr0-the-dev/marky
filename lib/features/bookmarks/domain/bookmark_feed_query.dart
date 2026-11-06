import 'package:flutter/foundation.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';

/// Top-level visibility filter for the feed.
///
/// These are mutually exclusive — pick one. Tag/collection narrowing
/// is layered on top via [BookmarkFeedQuery.tagId] /
/// [BookmarkFeedQuery.collectionId]. Search keyword narrowing comes
/// in Faz 7.
enum BookmarkFeedFilter {
  /// All bookmarks except archived. The default landing view.
  all,

  /// `isFavorite == true` (still excluding archived).
  favorites,

  /// `isRead == false` (still excluding archived). The classic "to
  /// read" inbox.
  unread,

  /// `isArchived == true`. Inverts the default — the only filter
  /// where archived items are visible.
  archived,
}

/// Sort order for the feed list. The repository's Isar query selects
/// the right index for each (so sorting is always O(n) on the matched
/// rows, not on all rows).
enum BookmarkSort {
  /// `createdAt DESC` — newest captures first. Default.
  newestFirst,

  /// `createdAt ASC` — oldest first. Useful in archive triage.
  oldestFirst,

  /// `lastInteractionAt DESC NULLS LAST`. The "I just touched this"
  /// view powers the dashboard "recent" card.
  recentlyOpened,

  /// `title ASC`, ties broken by `createdAt DESC`. Pinned-first
  /// override is applied above this in the repository.
  titleAscending,
}

/// Value object describing a feed query.
///
/// Immutable + equatable, so Riverpod's `select` works cleanly: a
/// widget watching the feed for `BookmarkFeedQuery(all, newestFirst)`
/// won't rebuild when an unrelated filter chip is in flight.
@immutable
class BookmarkFeedQuery {
  const BookmarkFeedQuery({
    this.filter = BookmarkFeedFilter.all,
    this.sort = BookmarkSort.newestFirst,
    this.tagId,
    this.collectionId,
    this.contentType,
    this.host,
    this.createdAfter,
    this.createdBefore,
    this.limit = 100,
    this.offset = 0,
  });

  final BookmarkFeedFilter filter;
  final BookmarkSort sort;

  /// When set, only bookmarks whose `tagIds` contains this id are
  /// returned. Layered on top of [filter].
  final int? tagId;

  /// Same as [tagId] but for collections.
  final int? collectionId;

  /// Optional content-type narrowing (Library "Videos" / "Articles"
  /// chips, Faz 8).
  final BookmarkContentType? contentType;

  /// Exact match against `normalizedHost`. Used by the dashboard's
  /// "see all from youtube.com" deep link.
  final String? host;

  /// Inclusive lower/upper bounds for `createdAt`. Smart collections
  /// use [createdAfter] for "this week"; search operators use both.
  final DateTime? createdAfter;
  final DateTime? createdBefore;

  /// Page size. Default 100 is a sensible bulk fetch for the feed
  /// scroll; pagination is folded in via [offset].
  final int limit;

  final int offset;

  BookmarkFeedQuery copyWith({
    BookmarkFeedFilter? filter,
    BookmarkSort? sort,
    int? tagId,
    int? collectionId,
    BookmarkContentType? contentType,
    String? host,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int? limit,
    int? offset,
  }) {
    return BookmarkFeedQuery(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      tagId: tagId ?? this.tagId,
      collectionId: collectionId ?? this.collectionId,
      contentType: contentType ?? this.contentType,
      host: host ?? this.host,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookmarkFeedQuery &&
        other.filter == filter &&
        other.sort == sort &&
        other.tagId == tagId &&
        other.collectionId == collectionId &&
        other.contentType == contentType &&
        other.host == host &&
        other.createdAfter == createdAfter &&
        other.createdBefore == createdBefore &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(
        filter,
        sort,
        tagId,
        collectionId,
        contentType,
        host,
        createdAfter,
        createdBefore,
        limit,
        offset,
      );

  @override
  String toString() => 'BookmarkFeedQuery($filter, $sort, tagId=$tagId, '
      'collectionId=$collectionId, type=$contentType, host=$host, '
      'limit=$limit, offset=$offset)';
}
