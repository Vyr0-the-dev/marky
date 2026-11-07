import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';

/// Immutable state for the daily reading queue.
class DailyQueueState {
  const DailyQueueState({
    required this.items,
    required this.dateString,
    this.isDismissed = true,
    this.isHidden = false,
  });

  final List<Bookmark> items;
  final String dateString;
  final bool isDismissed;
  final bool isHidden;

  int get completedCount => items.where((Bookmark b) => b.isRead).length;
  int get totalCount => items.length;
  bool get isAllCompleted => totalCount > 0 && completedCount == totalCount;

  DailyQueueState copyWith({
    List<Bookmark>? items,
    String? dateString,
    bool? isDismissed,
    bool? isHidden,
  }) {
    return DailyQueueState(
      items: items ?? this.items,
      dateString: dateString ?? this.dateString,
      isDismissed: isDismissed ?? this.isDismissed,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}

/// Computes a stable, daily-seeded reading queue from unread bookmarks.
class DailyQueueNotifier extends Notifier<DailyQueueState> {
  static const int defaultTargetCount = 3;

  @override
  DailyQueueState build() {
    final DateTime now = DateTime.now();
    final String today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Watch unread bookmarks reactively
    final AsyncValue<List<Bookmark>> unreadAsync = ref.watch(
      bookmarkFeedProvider(
        const BookmarkFeedQuery(filter: BookmarkFeedFilter.unread),
      ),
    );

    final List<Bookmark> unread = unreadAsync.valueOrNull ?? <Bookmark>[];
    if (unread.isEmpty) {
      return DailyQueueState(
        items: const <Bookmark>[],
        dateString: today,
      );
    }

    // Deterministic selection based on date seed
    final int seed = today.codeUnits.fold<int>(0, (int a, int b) => a * 31 + b);
    final Random random = Random(seed);

    final List<Bookmark> pool = List<Bookmark>.of(unread);
    pool.shuffle(random);

    final List<Bookmark> selected = pool.take(defaultTargetCount).toList();

    return DailyQueueState(
      items: selected,
      dateString: today,
    );
  }

  void toggleDismissed() {
    state = state.copyWith(isDismissed: !state.isDismissed);
  }

  void hide() {
    state = state.copyWith(isHidden: true);
  }

  void show() {
    state = state.copyWith(isHidden: false);
  }
}

final NotifierProvider<DailyQueueNotifier, DailyQueueState> dailyQueueProvider =
    NotifierProvider<DailyQueueNotifier, DailyQueueState>(
  DailyQueueNotifier.new,
);
