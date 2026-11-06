import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/dashboard/domain/dashboard_stats.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

class DashboardAnalyticsService {
  const DashboardAnalyticsService({
    required BookmarkRepository bookmarkRepository,
    required TagRepository tagRepository,
    DateTime Function()? now,
  })  : _bookmarks = bookmarkRepository,
        _tags = tagRepository,
        _now = now;

  final BookmarkRepository _bookmarks;
  final TagRepository _tags;
  final DateTime Function()? _now;

  Future<DashboardStats> compute() async {
    final List<Bookmark> active = await _bookmarks.feed(
      const BookmarkFeedQuery(limit: 100000),
    );
    final List<Bookmark> archived = await _bookmarks.feed(
      const BookmarkFeedQuery(
        filter: BookmarkFeedFilter.archived,
        limit: 100000,
      ),
    );
    final List<Bookmark> combined = <Bookmark>[...active, ...archived];
    final DateTime now = _now?.call() ?? DateTime.now();

    return DashboardStats(
      totalBookmarks: combined.length,
      unreadCount: combined.where((Bookmark b) => !b.isRead).length,
      favoritesCount: combined.where((Bookmark b) => b.isFavorite).length,
      archivedCount: archived.length,
      addedThisWeek: _countAddedThisWeek(combined, now),
      topHosts: _topHosts(combined).take(5).toList(),
      topTags: (await _topTags(combined)).take(5).toList(),
      sourceBreakdown: _sourceBreakdown(combined),
      timeline: _timeline(combined, now),
    );
  }

  int _countAddedThisWeek(List<Bookmark> bookmarks, DateTime now) {
    final DateTime weekAgo = now.subtract(const Duration(days: 7));
    return bookmarks.where((Bookmark b) => b.createdAt.isAfter(weekAgo)).length;
  }

  List<HostCount> _topHosts(List<Bookmark> bookmarks) {
    final Map<String, int> counts = <String, int>{};
    for (final Bookmark bookmark in bookmarks) {
      final String host = _hostLabel(bookmark.normalizedHost);
      counts[host] = (counts[host] ?? 0) + 1;
    }
    return counts.entries
        .map((MapEntry<String, int> e) => HostCount(e.key, e.value))
        .toList()
      ..sort((HostCount a, HostCount b) => _compareCountLabel(
            a.count,
            a.host,
            b.count,
            b.host,
          ));
  }

  Future<List<TagCount>> _topTags(List<Bookmark> bookmarks) async {
    final Map<int, int> counts = <int, int>{};
    for (final Bookmark bookmark in bookmarks) {
      for (final int tagId in bookmark.tagIds.toSet()) {
        counts[tagId] = (counts[tagId] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return const <TagCount>[];

    final List<Tag> tags = await _tags.getByIds(counts.keys.toList());
    final Map<int, String> namesById = <int, String>{
      for (final Tag tag in tags)
        if (tag.id != null) tag.id!: tag.name,
    };

    return counts.entries
        .map((MapEntry<int, int> e) => TagCount(
              namesById[e.key] ?? '#${e.key}',
              e.value,
            ))
        .toList()
      ..sort((TagCount a, TagCount b) => _compareCountLabel(
            a.count,
            a.tagName,
            b.count,
            b.tagName,
          ));
  }

  List<SourceTypeCount> _sourceBreakdown(List<Bookmark> bookmarks) {
    final Map<BookmarkSourceType, int> counts = <BookmarkSourceType, int>{};
    for (final Bookmark bookmark in bookmarks) {
      counts[bookmark.sourceType] = (counts[bookmark.sourceType] ?? 0) + 1;
    }
    return counts.entries
        .map((MapEntry<BookmarkSourceType, int> e) => SourceTypeCount(
              e.key,
              e.value,
            ))
        .toList()
      ..sort((SourceTypeCount a, SourceTypeCount b) => _compareCountLabel(
            a.count,
            a.sourceType.name,
            b.count,
            b.sourceType.name,
          ));
  }

  List<TimelineBucket> _timeline(List<Bookmark> bookmarks, DateTime now) {
    final DateTime today = _startOfDay(now);
    final DateTime firstDay = today.subtract(const Duration(days: 6));
    final Map<DateTime, int> counts = <DateTime, int>{
      for (int i = 0; i < 7; i++) firstDay.add(Duration(days: i)): 0,
    };

    for (final Bookmark bookmark in bookmarks) {
      final DateTime day = _startOfDay(bookmark.createdAt);
      if (day.isBefore(firstDay) || day.isAfter(today)) continue;
      counts[day] = (counts[day] ?? 0) + 1;
    }

    return counts.entries
        .map((MapEntry<DateTime, int> e) => TimelineBucket(e.key, e.value))
        .toList();
  }

  static int _compareCountLabel(
    int countA,
    String labelA,
    int countB,
    String labelB,
  ) {
    final int countCompare = countB.compareTo(countA);
    if (countCompare != 0) return countCompare;
    return labelA.compareTo(labelB);
  }

  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _hostLabel(String? host) {
    final String? trimmed = host?.trim();
    return trimmed == null || trimmed.isEmpty ? 'unknown' : trimmed;
  }
}
