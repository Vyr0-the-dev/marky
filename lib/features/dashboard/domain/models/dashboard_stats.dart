import 'package:equatable/equatable.dart';

/// Immutable aggregate statistics for the Dashboard.
class DashboardStats extends Equatable {
  const DashboardStats({
    this.totalBookmarks = 0,
    this.totalCollections = 0,
    this.totalTags = 0,
    this.readCount = 0,
    this.unreadCount = 0,
    this.favoriteCount = 0,
    this.archivedCount = 0,
    this.vaultCount = 0,
    this.recentlyAdded = const <String>[],
    this.weeklyTrend = const <DailyCount>[],
    this.sourceDistribution = const <String, int>{},
    this.contentTypeDistribution = const <String, int>{},
    this.topTags = const <TagStat>[],
    this.hourlyActivity = const <int>[],
  });

  /// Total number of bookmarks in the database.
  final int totalBookmarks;

  /// Total number of collections.
  final int totalCollections;

  /// Total number of distinct tags.
  final int totalTags;

  /// Number of bookmarks marked as read.
  final int readCount;

  /// Number of bookmarks not yet read.
  final int unreadCount;

  /// Number of bookmarks marked as favorite.
  final int favoriteCount;

  /// Number of archived bookmarks.
  final int archivedCount;

  /// Number of bookmarks stored in vault.
  final int vaultCount;

  /// Titles or URLs of the most recently added bookmarks (e.g. last 5).
  final List<String> recentlyAdded;

  /// Daily bookmark creation counts for the last 7 days.
  final List<DailyCount> weeklyTrend;

  /// How many bookmarks came from each source domain.
  final Map<String, int> sourceDistribution;

  /// How many bookmarks of each content type (article, video, image, etc.).
  final Map<String, int> contentTypeDistribution;

  /// Most frequently used tags with their counts.
  final List<TagStat> topTags;

  /// Bookmark creation activity binned by hour of day (24 bins, 0–23).
  final List<int> hourlyActivity;

  @override
  List<Object?> get props => <Object?>[
        totalBookmarks,
        totalCollections,
        totalTags,
        readCount,
        unreadCount,
        favoriteCount,
        archivedCount,
        vaultCount,
        recentlyAdded,
        weeklyTrend,
        sourceDistribution,
        contentTypeDistribution,
        topTags,
        hourlyActivity,
      ];
}

/// A single day's bookmark count.
class DailyCount extends Equatable {
  const DailyCount({
    required this.date,
    required this.count,
  });

  /// The date (midnight UTC).
  final DateTime date;

  /// Number of bookmarks created on this date.
  final int count;

  @override
  List<Object?> get props => <Object?>[date, count];
}

/// A tag with its usage count and optional display color.
class TagStat extends Equatable {
  const TagStat({
    required this.name,
    required this.count,
    this.color,
  });

  /// Tag name.
  final String name;

  /// How many bookmarks use this tag.
  final int count;

  /// Optional hex color string for chart rendering.
  final String? color;

  @override
  List<Object?> get props => <Object?>[name, count, color];
}
