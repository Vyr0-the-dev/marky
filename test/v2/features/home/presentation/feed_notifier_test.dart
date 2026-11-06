import 'package:flutter_test/flutter_test.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/home/presentation/feed_notifier.dart';
import 'package:marky/features/home/presentation/feed_state.dart';

void main() {
  late FeedNotifier notifier;

  setUp(() {
    notifier = FeedNotifier();
  });

  // ─── Initial state ─────────────────────────────────────────────

  test('initial state has sane defaults', () {
    final FeedState state = notifier.state;
    expect(state.query.filter, BookmarkFeedFilter.all);
    expect(state.query.sort, BookmarkSort.newestFirst);
    expect(state.viewMode, FeedViewMode.list);
    expect(state.selectionMode, isFalse);
    expect(state.selectedIds, isEmpty);
  });

  // ─── Filter / sort ─────────────────────────────────────────────

  group('filter & sort', () {
    test('setFilter updates query filter', () {
      notifier.setFilter(BookmarkFeedFilter.favorites);
      expect(notifier.state.query.filter, BookmarkFeedFilter.favorites);
    });

    test('setSort updates query sort', () {
      notifier.setSort(BookmarkSort.oldestFirst);
      expect(notifier.state.query.sort, BookmarkSort.oldestFirst);
    });

    test('setContentType updates query and can clear', () {
      notifier.setContentType(BookmarkContentType.video);
      expect(notifier.state.query.contentType, BookmarkContentType.video);

      notifier.setContentType(null);
      expect(notifier.state.query.contentType, isNull);
    });

    test('setTagId narrows feed and can clear', () {
      notifier.setTagId(42);
      expect(notifier.state.query.tagId, 42);

      notifier.setTagId(null);
      expect(notifier.state.query.tagId, isNull);
    });

    test('setHost narrows feed and can clear', () {
      notifier.setHost('example.com');
      expect(notifier.state.query.host, 'example.com');

      notifier.setHost(null);
      expect(notifier.state.query.host, isNull);
    });

    test('setHost preserves other query fields', () {
      notifier.setFilter(BookmarkFeedFilter.unread);
      notifier.setSort(BookmarkSort.oldestFirst);
      notifier.setTagId(11);
      notifier.setCollectionId(22);

      notifier.setHost('nytimes.com');

      expect(notifier.state.query.filter, BookmarkFeedFilter.unread);
      expect(notifier.state.query.sort, BookmarkSort.oldestFirst);
      expect(notifier.state.query.tagId, 11);
      expect(notifier.state.query.collectionId, 22);
      expect(notifier.state.query.host, 'nytimes.com');
    });

    test('setCollectionId narrows feed and can clear', () {
      notifier.setCollectionId(7);
      expect(notifier.state.query.collectionId, 7);

      notifier.setCollectionId(null);
      expect(notifier.state.query.collectionId, isNull);
    });

    test('setTagId preserves other query fields', () {
      notifier.setFilter(BookmarkFeedFilter.favorites);
      notifier.setSort(BookmarkSort.oldestFirst);
      notifier.setTagId(99);

      expect(notifier.state.query.filter, BookmarkFeedFilter.favorites);
      expect(notifier.state.query.sort, BookmarkSort.oldestFirst);
      expect(notifier.state.query.tagId, 99);
    });
  });

  // ─── View mode ─────────────────────────────────────────────────

  group('view mode', () {
    test('toggleViewMode switches list ↔ grid', () {
      expect(notifier.state.viewMode, FeedViewMode.list);

      notifier.toggleViewMode();
      expect(notifier.state.viewMode, FeedViewMode.grid);

      notifier.toggleViewMode();
      expect(notifier.state.viewMode, FeedViewMode.list);
    });
  });

  // ─── Selection mode ────────────────────────────────────────────

  group('selection mode', () {
    test('enterSelectionMode activates with first item', () {
      notifier.enterSelectionMode(42);

      expect(notifier.state.selectionMode, isTrue);
      expect(notifier.state.selectedIds, <int>{42});
    });

    test('toggleSelection adds and removes', () {
      notifier.enterSelectionMode(1);

      notifier.toggleSelection(2);
      expect(notifier.state.selectedIds, <int>{1, 2});

      notifier.toggleSelection(1);
      expect(notifier.state.selectedIds, <int>{2});
    });

    test('toggleSelection auto-exits when last item deselected', () {
      notifier.enterSelectionMode(1);
      notifier.toggleSelection(1);

      expect(notifier.state.selectionMode, isFalse);
      expect(notifier.state.selectedIds, isEmpty);
    });

    test('exitSelectionMode clears everything', () {
      notifier.enterSelectionMode(1);
      notifier.toggleSelection(2);
      notifier.exitSelectionMode();

      expect(notifier.state.selectionMode, isFalse);
      expect(notifier.state.selectedIds, isEmpty);
    });

    test('selectAll replaces current selection', () {
      notifier.enterSelectionMode(1);
      notifier.selectAll(<int>[10, 20, 30]);

      expect(notifier.state.selectionMode, isTrue);
      expect(notifier.state.selectedIds, <int>{10, 20, 30});
    });

    test('selectedCount reflects current set size', () {
      notifier.enterSelectionMode(1);
      notifier.toggleSelection(2);
      notifier.toggleSelection(3);

      expect(notifier.state.selectedCount, 3);
    });
  });

  // ─── FeedState equality ────────────────────────────────────────

  group('FeedState equality', () {
    test('identical states are equal', () {
      const FeedState a = FeedState();
      const FeedState b = FeedState();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different filters are not equal', () {
      const FeedState a = FeedState();
      final FeedState b = a.copyWith(
        query: a.query.copyWith(filter: BookmarkFeedFilter.favorites),
      );
      expect(a, isNot(b));
    });
  });
}
