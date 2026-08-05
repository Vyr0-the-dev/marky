import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/dashboard/domain/services/dashboard_statistics_service.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/tag.dart';

void main() {
  group('DashboardStatisticsService', () {
    late Directory tempDir;
    late Isar isar;
    late DashboardStatisticsService service;

    BookmarkItem makeBookmark({
      required String url,
      String? title,
      bool isRead = false,
      bool isFavorite = false,
      bool isArchived = false,
      bool isDeleted = false,
      bool isInVault = false,
      String? sourceType,
      String? contentType,
      List<int>? tagIds,
      DateTime? createdAt,
    }) {
      final now = createdAt ?? DateTime.now().toUtc();
      return BookmarkItem(
        originalUrl: url,
        title: title,
        isRead: isRead,
        isFavorite: isFavorite,
        isArchived: isArchived,
        isDeleted: isDeleted,
        isInVault: isInVault,
        sourceType: sourceType,
        contentType: contentType,
        tagIds: tagIds,
        createdAt: now,
        updatedAt: now,
      );
    }

    Tag makeTag({
      required String name,
      required String slug,
      String? color,
    }) {
      final now = DateTime.now().toUtc();
      return Tag(
        name: name,
        slug: slug,
        color: color,
        createdAt: now,
        updatedAt: now,
      );
    }

    BookmarkCollection makeCollection({
      required String title,
      required String slug,
    }) {
      final now = DateTime.now().toUtc();
      return BookmarkCollection(
        title: title,
        slug: slug,
        createdAt: now,
        updatedAt: now,
      );
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('dashboard_test_');

      isar = await Isar.open(
        [BookmarkItemSchema, TagSchema, BookmarkCollectionSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      service = DashboardStatisticsService(isar: isar);
    });

    tearDown(() async {
      if (isar.isOpen) {
        await isar.close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    // ─── a. Empty database ──────────────────────────────────────────────

    test('computeStats returns all zeros for empty database', () async {
      final stats = await service.computeStats();

      expect(stats.totalBookmarks, 0);
      expect(stats.totalCollections, 0);
      expect(stats.totalTags, 0);
      expect(stats.readCount, 0);
      expect(stats.unreadCount, 0);
      expect(stats.favoriteCount, 0);
      expect(stats.archivedCount, 0);
      expect(stats.vaultCount, 0);
      expect(stats.recentlyAdded, isEmpty);
      expect(stats.weeklyTrend, hasLength(7));
      expect(stats.weeklyTrend.every((d) => d.count == 0), isTrue);
      expect(stats.sourceDistribution['manual'], 0);
      expect(stats.sourceDistribution['share_sheet'], 0);
      expect(stats.sourceDistribution['clipboard'], 0);
      expect(stats.sourceDistribution['import'], 0);
      expect(stats.sourceDistribution['other'], 0);
      expect(stats.contentTypeDistribution['article'], 0);
      expect(stats.contentTypeDistribution['video'], 0);
      expect(stats.topTags, isEmpty);
      expect(stats.hourlyActivity, hasLength(24));
      expect(stats.hourlyActivity.every((c) => c == 0), isTrue);
    });

    // ─── b. Counts total, read, unread, favorite correctly ──────────────

    test('computeStats counts total, read, unread, favorite correctly',
        () async {
      final bookmarks = <BookmarkItem>[
        makeBookmark(url: 'https://a.com', isRead: true, isFavorite: true),
        makeBookmark(url: 'https://b.com', isRead: true),
        makeBookmark(url: 'https://c.com'),
        makeBookmark(url: 'https://d.com'),
      ];

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.totalBookmarks, 4);
      expect(stats.readCount, 2);
      expect(stats.unreadCount, 2);
      expect(stats.favoriteCount, 1);
    });

    // ─── c. Vault items excluded from main stats ────────────────────────

    test('computeStats excludes vault items from main stats', () async {
      final bookmarks = <BookmarkItem>[
        makeBookmark(url: 'https://a.com'),
        makeBookmark(url: 'https://b.com', isInVault: true),
        makeBookmark(url: 'https://c.com'),
      ];

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.totalBookmarks, 2); // vault excluded
      expect(stats.vaultCount, 1);
      expect(stats.readCount, 0);
    });

    // ─── d. Vault items counted separately ──────────────────────────────

    test('computeStats counts vault items separately', () async {
      final bookmarks = <BookmarkItem>[
        makeBookmark(url: 'https://a.com', isInVault: true),
        makeBookmark(url: 'https://b.com', isInVault: true),
        makeBookmark(url: 'https://c.com'),
      ];

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.totalBookmarks, 1);
      expect(stats.vaultCount, 2);
    });

    // ─── e. Weekly trend for last 7 days ────────────────────────────────

    test('computeStats computes weekly trend for last 7 days', () async {
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final bookmarks = <BookmarkItem>[
        makeBookmark(
          url: 'https://today1.com',
          createdAt: today.add(const Duration(hours: 10)),
        ),
        makeBookmark(
          url: 'https://today2.com',
          createdAt: today.add(const Duration(hours: 14)),
        ),
        makeBookmark(
          url: 'https://yesterday.com',
          createdAt: yesterday.add(const Duration(hours: 8)),
        ),
        makeBookmark(
          url: 'https://old.com',
          createdAt: today.subtract(const Duration(days: 10, hours: 5)),
        ),
      ];

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.weeklyTrend, hasLength(7));

      final todayCount = stats.weeklyTrend
          .firstWhere((d) => d.date.isAtSameMomentAs(today))
          .count;
      final yesterdayCount = stats.weeklyTrend
          .firstWhere((d) => d.date.isAtSameMomentAs(yesterday))
          .count;
      final twoDaysAgoCount = stats.weeklyTrend
          .firstWhere((d) => d.date.isAtSameMomentAs(twoDaysAgo))
          .count;

      expect(todayCount, 2);
      expect(yesterdayCount, 1);
      expect(twoDaysAgoCount, 0);
    });

    // ─── f. Source distribution ─────────────────────────────────────────

    test('computeStats computes source distribution', () async {
      final bookmarks = <BookmarkItem>[
        makeBookmark(url: 'https://a.com', sourceType: 'manual'),
        makeBookmark(url: 'https://b.com', sourceType: 'manual'),
        makeBookmark(url: 'https://c.com', sourceType: 'share_sheet'),
        makeBookmark(url: 'https://d.com', sourceType: 'clipboard'),
        makeBookmark(url: 'https://e.com'),
      ];

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.sourceDistribution['manual'], 2);
      expect(stats.sourceDistribution['share_sheet'], 1);
      expect(stats.sourceDistribution['clipboard'], 1);
      expect(stats.sourceDistribution['other'],
          1); // null sourceType counted as other
      expect(stats.sourceDistribution['import'], 0);
    });

    // ─── g. Top tags from bookmark tagIds ───────────────────────────────

    test('computeStats computes top tags from bookmark tagIds', () async {
      final tags = <Tag>[
        makeTag(name: 'Flutter', slug: 'flutter', color: '#02569B'),
        makeTag(name: 'Dart', slug: 'dart', color: '#0175C2'),
        makeTag(name: 'AI', slug: 'ai'),
      ];

      late List<int> tagIds;
      await isar.writeTxn(() async {
        tagIds = await isar.tags.putAll(tags);
      });

      final bookmarks = <BookmarkItem>[
        makeBookmark(url: 'https://a.com', tagIds: [tagIds[0], tagIds[1]]),
        makeBookmark(url: 'https://b.com', tagIds: [tagIds[0]]),
        makeBookmark(url: 'https://c.com', tagIds: [tagIds[1]]),
        makeBookmark(url: 'https://d.com'),
      ];

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.topTags, hasLength(2));
      expect(stats.topTags[0].name, 'Flutter');
      expect(stats.topTags[0].count, 2);
      expect(stats.topTags[0].color, '#02569B');
      expect(stats.topTags[1].name, 'Dart');
      expect(stats.topTags[1].count, 2);
    });

    // ─── h. Hourly activity buckets ─────────────────────────────────────

    test('computeStats computes hourly activity buckets', () async {
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);

      final bookmarks = <BookmarkItem>[
        makeBookmark(
          url: 'https://morning.com',
          createdAt: today.add(const Duration(hours: 9)),
        ),
        makeBookmark(
          url: 'https://noon.com',
          createdAt: today.add(const Duration(hours: 12)),
        ),
        makeBookmark(
          url: 'https://evening.com',
          createdAt: today.add(const Duration(hours: 18)),
        ),
        makeBookmark(
          url: 'https://old.com',
          createdAt: today.subtract(const Duration(days: 31)),
        ),
      ];

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.hourlyActivity, hasLength(24));
      expect(stats.hourlyActivity[9], 1);
      expect(stats.hourlyActivity[12], 1);
      expect(stats.hourlyActivity[18], 1);
      expect(stats.hourlyActivity[10], 0);
    });

    // ─── i. Handles all archived items ──────────────────────────────────

    test('computeStats handles all archived items', () async {
      final bookmarks = <BookmarkItem>[
        makeBookmark(url: 'https://a.com'),
        makeBookmark(url: 'https://b.com', isArchived: true),
        makeBookmark(url: 'https://c.com', isArchived: true),
      ];

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.totalBookmarks, 3);
      expect(stats.archivedCount, 2);
    });

    // ─── Extra: deleted items excluded from all stats ───────────────────

    test('computeStats excludes deleted items from all stats', () async {
      final bookmarks = <BookmarkItem>[
        makeBookmark(url: 'https://a.com'),
        makeBookmark(url: 'https://b.com', isDeleted: true),
        makeBookmark(
          url: 'https://c.com',
          isDeleted: true,
          isInVault: true,
        ),
      ];

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.totalBookmarks, 1);
      expect(stats.vaultCount, 0); // deleted vault items excluded
    });

    // ─── Extra: collections and tags counted ────────────────────────────

    test('computeStats counts collections and tags', () async {
      final collections = <BookmarkCollection>[
        makeCollection(title: 'Work', slug: 'work'),
        makeCollection(title: 'Personal', slug: 'personal'),
      ];
      final tags = <Tag>[
        makeTag(name: 'Flutter', slug: 'flutter'),
        makeTag(name: 'Dart', slug: 'dart'),
        makeTag(name: 'AI', slug: 'ai'),
      ];

      await isar.writeTxn(() async {
        await isar.bookmarkCollections.putAll(collections);
        await isar.tags.putAll(tags);
      });

      final stats = await service.computeStats();

      expect(stats.totalCollections, 2);
      expect(stats.totalTags, 3);
    });

    // ─── Extra: content type distribution ───────────────────────────────

    test('computeStats computes content type distribution', () async {
      final bookmarks = <BookmarkItem>[
        makeBookmark(url: 'https://a.com', contentType: 'article'),
        makeBookmark(url: 'https://b.com', contentType: 'article'),
        makeBookmark(url: 'https://c.com', contentType: 'video'),
        makeBookmark(url: 'https://d.com'),
      ];

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.contentTypeDistribution['article'], 2);
      expect(stats.contentTypeDistribution['video'], 1);
      expect(stats.contentTypeDistribution['other'], 1); // null
    });

    // ─── Performance: bounded top-tags with large dataset ───────────────

    test('computeStats topTags respects 1000-item bound', () async {
      final tagA = makeTag(name: 'Alpha', slug: 'alpha');
      final tagB = makeTag(name: 'Beta', slug: 'beta');
      late List<int> tagIds;
      await isar.writeTxn(() async {
        tagIds = await isar.tags.putAll(<Tag>[tagA, tagB]);
      });

      final now = DateTime.now().toUtc();
      final bookmarks = <BookmarkItem>[];
      // 1200 bookmarks with tag A — only first 1000 should be sampled.
      for (var i = 0; i < 1200; i++) {
        bookmarks.add(makeBookmark(
          url: 'https://a$i.com',
          tagIds: <int>[tagIds[0]],
          createdAt: now.subtract(Duration(minutes: i)),
        ));
      }
      // 300 bookmarks with tag B — should not appear in top tags because
      // the limit(1000) query stops before them.
      for (var i = 0; i < 300; i++) {
        bookmarks.add(makeBookmark(
          url: 'https://b$i.com',
          tagIds: <int>[tagIds[1]],
          createdAt: now.subtract(Duration(minutes: 1200 + i)),
        ));
      }

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.topTags, hasLength(1));
      expect(stats.topTags.first.name, 'Alpha');
      expect(stats.topTags.first.count, 1000);
    });

    // ─── Performance: bounded hourly activity with large dataset ────────

    test('computeStats hourlyActivity respects 2000-item bound', () async {
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final bookmarks = <BookmarkItem>[];

      // 2500 bookmarks created at hour 14 within the last 30 days.
      for (var i = 0; i < 2500; i++) {
        bookmarks.add(makeBookmark(
          url: 'https://h$i.com',
          createdAt: today.add(const Duration(hours: 14)),
        ));
      }

      await isar.writeTxn(() async {
        for (final bm in bookmarks) {
          await isar.bookmarkItems.put(bm);
        }
      });

      final stats = await service.computeStats();

      expect(stats.hourlyActivity[14], 2000);
    });
  });
}
