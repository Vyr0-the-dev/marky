import 'package:isar/isar.dart';
import 'package:marky/features/dashboard/domain/models/dashboard_stats.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/tag.dart';

/// Computes aggregate dashboard statistics from the Isar database.
///
/// All date arithmetic is performed in UTC to avoid midnight edge cases.
/// Deleted items are excluded from every metric. Vault items are counted
/// separately and excluded from the main bookmark stats.
class DashboardStatisticsService {
  DashboardStatisticsService({required Isar isar}) : _isar = isar;

  final Isar _isar;

  /// Known source types to bucket in the source distribution chart.
  static const List<String> _knownSourceTypes = <String>[
    'manual',
    'share_sheet',
    'clipboard',
    'import',
    'other',
  ];

  /// Known content types to bucket in the content type distribution chart.
  static const List<String> _knownContentTypes = <String>[
    'article',
    'video',
    'image',
    'product',
    'repository',
    'audio',
    'document',
    'other',
  ];

  /// Computes every metric required by the dashboard.
  Future<DashboardStats> computeStats() async {
    final now = DateTime.now().toUtc();
    final todayMidnight = DateTime.utc(now.year, now.month, now.day);

    // ─── Parallel independent count queries ─────────────────────────────
    final results = await Future.wait(<Future<int>>[
      // totalBookmarks (non-deleted, non-vault)
      _isar.bookmarkItems
          .filter()
          .isDeletedEqualTo(false)
          .isInVaultEqualTo(false)
          .count(),
      // readCount
      _isar.bookmarkItems
          .filter()
          .isDeletedEqualTo(false)
          .isInVaultEqualTo(false)
          .isReadEqualTo(true)
          .count(),
      // unreadCount
      _isar.bookmarkItems
          .filter()
          .isDeletedEqualTo(false)
          .isInVaultEqualTo(false)
          .isReadEqualTo(false)
          .count(),
      // favoriteCount
      _isar.bookmarkItems
          .filter()
          .isDeletedEqualTo(false)
          .isInVaultEqualTo(false)
          .isFavoriteEqualTo(true)
          .count(),
      // archivedCount — filter() per composite-index gotcha MEM034
      _isar.bookmarkItems
          .filter()
          .isDeletedEqualTo(false)
          .isInVaultEqualTo(false)
          .isArchivedEqualTo(true)
          .count(),
      // vaultCount
      _isar.bookmarkItems
          .filter()
          .isDeletedEqualTo(false)
          .isInVaultEqualTo(true)
          .count(),
      // totalCollections
      _isar.bookmarkCollections.where().count(),
      // totalTags
      _isar.tags.where().count(),
    ]);

    final totalBookmarks = results[0];
    final readCount = results[1];
    final unreadCount = results[2];
    final favoriteCount = results[3];
    final archivedCount = results[4];
    final vaultCount = results[5];
    final totalCollections = results[6];
    final totalTags = results[7];

    // ─── Weekly trend (last 7 days) ─────────────────────────────────────
    final weeklyTrend = await _computeWeeklyTrend(todayMidnight);

    // ─── Source distribution ────────────────────────────────────────────
    final sourceDistribution = await _computeSourceDistribution();

    // ─── Content type distribution ──────────────────────────────────────
    final contentTypeDistribution = await _computeContentTypeDistribution();

    // ─── Top tags (in-memory aggregation) ───────────────────────────────
    final topTags = await _computeTopTags();

    // ─── Hourly activity (in-memory aggregation) ────────────────────────
    final hourlyActivity = await _computeHourlyActivity(todayMidnight);

    // ─── Recently added titles ──────────────────────────────────────────
    final recentTitles = await _recentTitles(todayMidnight);

    return DashboardStats(
      totalBookmarks: totalBookmarks,
      totalCollections: totalCollections,
      totalTags: totalTags,
      readCount: readCount,
      unreadCount: unreadCount,
      favoriteCount: favoriteCount,
      archivedCount: archivedCount,
      vaultCount: vaultCount,
      recentlyAdded: recentTitles,
      weeklyTrend: weeklyTrend,
      sourceDistribution: sourceDistribution,
      contentTypeDistribution: contentTypeDistribution,
      topTags: topTags,
      hourlyActivity: hourlyActivity,
    );
  }

  /// Counts bookmarks per day for the last 7 days (inclusive of today).
  Future<List<DailyCount>> _computeWeeklyTrend(DateTime todayMidnight) async {
    final counts = <DailyCount>[];
    for (var i = 6; i >= 0; i--) {
      final dayStart = todayMidnight.subtract(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final count = await _isar.bookmarkItems
          .filter()
          .isDeletedEqualTo(false)
          .isInVaultEqualTo(false)
          .createdAtGreaterThan(dayStart)
          .createdAtLessThan(dayEnd)
          .count();
      counts.add(DailyCount(date: dayStart, count: count));
    }
    return counts;
  }

  /// Counts bookmarks per known source type.
  /// Null source types are counted under the key `'other'`.
  Future<Map<String, int>> _computeSourceDistribution() async {
    final distribution = <String, int>{};
    final futures = <Future<void>>[];

    for (final type in _knownSourceTypes) {
      if (type == 'other') continue; // handled separately for nulls
      futures.add(
        _isar.bookmarkItems
            .filter()
            .isDeletedEqualTo(false)
            .isInVaultEqualTo(false)
            .sourceTypeEqualTo(type)
            .count()
            .then((count) {
          distribution[type] = count;
        }),
      );
    }

    // Count items with null sourceType under 'other'.
    futures.add(
      _isar.bookmarkItems
          .filter()
          .isDeletedEqualTo(false)
          .isInVaultEqualTo(false)
          .sourceTypeIsNull()
          .count()
          .then((nullCount) {
        distribution['other'] = (distribution['other'] ?? 0) + nullCount;
      }),
    );

    await Future.wait(futures);
    return distribution;
  }

  /// Counts bookmarks per known content type.
  /// Null content types are counted under the key `'other'`.
  Future<Map<String, int>> _computeContentTypeDistribution() async {
    final distribution = <String, int>{};
    final futures = <Future<void>>[];

    for (final type in _knownContentTypes) {
      if (type == 'other') continue;
      futures.add(
        _isar.bookmarkItems
            .filter()
            .isDeletedEqualTo(false)
            .isInVaultEqualTo(false)
            .contentTypeEqualTo(type)
            .count()
            .then((count) {
          distribution[type] = count;
        }),
      );
    }

    // Count items with null contentType under 'other'.
    futures.add(
      _isar.bookmarkItems
          .filter()
          .isDeletedEqualTo(false)
          .isInVaultEqualTo(false)
          .contentTypeIsNull()
          .count()
          .then((nullCount) {
        distribution['other'] = (distribution['other'] ?? 0) + nullCount;
      }),
    );

    await Future.wait(futures);
    return distribution;
  }

  /// Aggregates tag frequencies from bookmark tagIds, resolves names, and
  /// returns the top 10 tags sorted by descending count.
  ///
  /// Bounded to the most recent 1000 bookmarks with tags to avoid OOM on
  /// very large datasets.
  Future<List<TagStat>> _computeTopTags() async {
    final bookmarks = await _isar.bookmarkItems
        .filter()
        .isDeletedEqualTo(false)
        .isInVaultEqualTo(false)
        .tagIdsIsNotNull()
        .sortByCreatedAtDesc()
        .limit(1000)
        .findAll();

    final tagFrequency = <int, int>{};
    for (final bm in bookmarks) {
      final ids = bm.tagIds;
      if (ids == null || ids.isEmpty) continue;
      for (final tagId in ids) {
        tagFrequency[tagId] = (tagFrequency[tagId] ?? 0) + 1;
      }
    }

    if (tagFrequency.isEmpty) return const <TagStat>[];

    // Resolve tag names and colors.
    final tagIds = tagFrequency.keys.toList();
    final tags = await _isar.tags.getAll(tagIds);

    final stats = <TagStat>[];
    for (var i = 0; i < tags.length; i++) {
      final tag = tags[i];
      if (tag == null) continue;
      final count = tagFrequency[tag.id] ?? 0;
      if (count == 0) continue;
      stats.add(TagStat(
        name: tag.name,
        count: count,
        color: tag.color,
      ));
    }

    stats.sort((a, b) => b.count.compareTo(a.count));
    return stats.take(10).toList();
  }

  /// Buckets bookmark creation times by hour of day (0–23) for the last
  /// 30 days.
  ///
  /// Bounded to the most recent 2000 bookmarks to avoid OOM on very large
  /// datasets.
  Future<List<int>> _computeHourlyActivity(DateTime todayMidnight) async {
    final thirtyDaysAgo = todayMidnight.subtract(const Duration(days: 30));
    final bookmarks = await _isar.bookmarkItems
        .filter()
        .isDeletedEqualTo(false)
        .isInVaultEqualTo(false)
        .createdAtGreaterThan(thirtyDaysAgo)
        .limit(2000)
        .findAll();

    final buckets = List<int>.filled(24, 0);
    for (final bm in bookmarks) {
      final hour = bm.createdAt.toUtc().hour;
      buckets[hour] = buckets[hour] + 1;
    }
    return buckets;
  }

  /// Returns titles of the 5 most recently added non-deleted bookmarks.
  Future<List<String>> _recentTitles(DateTime todayMidnight) async {
    final recent = await _isar.bookmarkItems
        .filter()
        .isDeletedEqualTo(false)
        .isInVaultEqualTo(false)
        .createdAtGreaterThan(
          todayMidnight.subtract(const Duration(days: 7)),
        )
        .sortByCreatedAtDesc()
        .limit(5)
        .findAll();

    return recent
        .map((bm) => (bm.title?.isNotEmpty ?? false) ? bm.title! : bm.originalUrl)
        .toList();
  }
}
