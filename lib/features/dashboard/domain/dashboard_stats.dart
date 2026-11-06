import 'package:flutter/foundation.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';

/// Snapshot of vault-level analytics for the dashboard.
@immutable
class DashboardStats {
  const DashboardStats({
    this.totalBookmarks = 0,
    this.unreadCount = 0,
    this.favoritesCount = 0,
    this.archivedCount = 0,
    this.addedThisWeek = 0,
    this.topHosts = const <HostCount>[],
    this.topTags = const <TagCount>[],
    this.sourceBreakdown = const <SourceTypeCount>[],
    this.timeline = const <TimelineBucket>[],
  });

  final int totalBookmarks;
  final int unreadCount;
  final int favoritesCount;
  final int archivedCount;
  final int addedThisWeek;
  final List<HostCount> topHosts;
  final List<TagCount> topTags;
  final List<SourceTypeCount> sourceBreakdown;
  final List<TimelineBucket> timeline;

  double get favoriteRatio =>
      totalBookmarks == 0 ? 0 : favoritesCount / totalBookmarks;

  double get readRatio =>
      totalBookmarks == 0 ? 0 : (totalBookmarks - unreadCount) / totalBookmarks;
}

@immutable
class HostCount {
  const HostCount(this.host, this.count);
  final String host;
  final int count;
}

@immutable
class TagCount {
  const TagCount(this.tagName, this.count);
  final String tagName;
  final int count;
}

@immutable
class SourceTypeCount {
  const SourceTypeCount(this.sourceType, this.count);
  final BookmarkSourceType sourceType;
  final int count;

  String get label => switch (sourceType) {
        BookmarkSourceType.manual => 'Manual',
        BookmarkSourceType.share => 'Share',
        BookmarkSourceType.clipboard => 'Clipboard',
        BookmarkSourceType.import => 'Import',
        BookmarkSourceType.automation => 'Automation',
      };
}

@immutable
class TimelineBucket {
  const TimelineBucket(this.day, this.count);
  final DateTime day;
  final int count;

  String get shortLabel => '${day.month}/${day.day}';
}
