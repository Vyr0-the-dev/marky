import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/dashboard/data/dashboard_providers.dart';
import 'package:marky/features/dashboard/domain/dashboard_stats.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

Bookmark _bm({
  String url = 'https://a.com',
  String? host = 'a.com',
  bool fav = false,
  bool read = false,
  bool archived = false,
  List<int> tagIds = const <int>[],
  BookmarkSourceType sourceType = BookmarkSourceType.manual,
  DateTime? createdAt,
}) {
  final DateTime now = createdAt ?? DateTime(2026);
  return Bookmark(
    originalUrl: url,
    normalizedHost: host,
    isFavorite: fav,
    isRead: read,
    isArchived: archived,
    tagIds: tagIds,
    contentType: BookmarkContentType.article,
    sourceType: sourceType,
    createdAt: now,
    updatedAt: now,
  );
}

ProviderContainer _container({
  List<Bookmark> active = const <Bookmark>[],
  List<Bookmark> archived = const <Bookmark>[],
  List<Tag> tags = const <Tag>[],
}) {
  return ProviderContainer(
    overrides: <Override>[
      bookmarkRepositoryProvider
          .overrideWithValue(_FakeBookmarkRepo(active, archived)),
      tagRepositoryProvider.overrideWithValue(_FakeTagRepo(tags)),
    ],
  );
}

void main() {
  test('returns zeros when vault is empty', () async {
    final ProviderContainer c = _container();
    addTearDown(c.dispose);

    final DashboardStats stats = await c.read(dashboardStatsProvider.future);

    expect(stats.totalBookmarks, 0);
    expect(stats.unreadCount, 0);
    expect(stats.favoritesCount, 0);
    expect(stats.archivedCount, 0);
    expect(stats.addedThisWeek, 0);
    expect(stats.topHosts, isEmpty);
    expect(stats.topTags, isEmpty);
  });

  test('counts total = active + archived', () async {
    final ProviderContainer c = _container(
      active: <Bookmark>[_bm(), _bm(), _bm()],
      archived: <Bookmark>[_bm(archived: true), _bm(archived: true)],
    );
    addTearDown(c.dispose);

    final DashboardStats stats = await c.read(dashboardStatsProvider.future);

    expect(stats.totalBookmarks, 5);
    expect(stats.archivedCount, 2);
  });

  test('unread counts only items with isRead=false', () async {
    final ProviderContainer c = _container(
      active: <Bookmark>[
        _bm(),
        _bm(read: true),
        _bm(),
      ],
    );
    addTearDown(c.dispose);

    final DashboardStats stats = await c.read(dashboardStatsProvider.future);

    expect(stats.unreadCount, 2);
  });

  test('favorites counts only items with isFavorite=true', () async {
    final ProviderContainer c = _container(
      active: <Bookmark>[
        _bm(fav: true),
        _bm(),
        _bm(fav: true),
      ],
    );
    addTearDown(c.dispose);

    final DashboardStats stats = await c.read(dashboardStatsProvider.future);

    expect(stats.favoritesCount, 2);
  });

  test('addedThisWeek excludes items older than 7 days', () async {
    final DateTime now = DateTime.now();
    final ProviderContainer c = _container(
      active: <Bookmark>[
        _bm(createdAt: now.subtract(const Duration(days: 1))),
        _bm(createdAt: now.subtract(const Duration(days: 6))),
        _bm(createdAt: now.subtract(const Duration(days: 30))),
      ],
    );
    addTearDown(c.dispose);

    final DashboardStats stats = await c.read(dashboardStatsProvider.future);

    expect(stats.addedThisWeek, 2);
  });

  test('topHosts ranks by frequency descending and caps at 5', () async {
    final ProviderContainer c = _container(
      active: <Bookmark>[
        _bm(),
        _bm(),
        _bm(),
        _bm(host: 'b.com'),
        _bm(host: 'b.com'),
        _bm(host: 'c.com'),
        _bm(host: 'd.com'),
        _bm(host: 'e.com'),
        _bm(host: 'f.com'),
        _bm(host: 'g.com'),
      ],
    );
    addTearDown(c.dispose);

    final DashboardStats stats = await c.read(dashboardStatsProvider.future);

    expect(stats.topHosts.length, 5);
    expect(stats.topHosts.first.host, 'a.com');
    expect(stats.topHosts.first.count, 3);
    expect(stats.topHosts[1].host, 'b.com');
    expect(stats.topHosts[1].count, 2);
  });

  test('null host falls under "unknown"', () async {
    final ProviderContainer c = _container(
      active: <Bookmark>[_bm(host: null), _bm(host: null)],
    );
    addTearDown(c.dispose);

    final DashboardStats stats = await c.read(dashboardStatsProvider.future);

    expect(stats.topHosts.first.host, 'unknown');
    expect(stats.topHosts.first.count, 2);
  });

  test('topTags ranks by visible bookmark tag references', () async {
    final DateTime now = DateTime(2026);
    final ProviderContainer c = _container(
      active: <Bookmark>[
        _bm(tagIds: const <int>[1, 2]),
        _bm(tagIds: const <int>[1]),
        _bm(tagIds: const <int>[1]),
      ],
      tags: <Tag>[
        Tag(
          id: 1,
          name: 'design',
          slug: 'design',
          usageCount: 99,
          createdAt: now,
          updatedAt: now,
        ),
        Tag(
          id: 2,
          name: 'tech',
          slug: 'tech',
          usageCount: 99,
          createdAt: now,
          updatedAt: now,
        ),
        Tag(
          id: 3,
          name: 'unused',
          slug: 'unused',
          usageCount: 99,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );
    addTearDown(c.dispose);

    final DashboardStats stats = await c.read(dashboardStatsProvider.future);

    expect(stats.topTags.length, 2);
    expect(stats.topTags.first.tagName, 'design');
    expect(stats.topTags.first.count, 3);
    expect(stats.topTags[1].tagName, 'tech');
  });

  test('sourceBreakdown ranks sources by count', () async {
    final ProviderContainer c = _container(
      active: <Bookmark>[
        _bm(sourceType: BookmarkSourceType.share),
        _bm(sourceType: BookmarkSourceType.share),
        _bm(sourceType: BookmarkSourceType.clipboard),
      ],
    );
    addTearDown(c.dispose);

    final DashboardStats stats = await c.read(dashboardStatsProvider.future);

    expect(stats.sourceBreakdown.first.sourceType, BookmarkSourceType.share);
    expect(stats.sourceBreakdown.first.count, 2);
    expect(stats.sourceBreakdown[1].sourceType, BookmarkSourceType.clipboard);
  });

  test('timeline returns seven day buckets ending today', () async {
    final DateTime now = DateTime.now();
    final ProviderContainer c = _container(
      active: <Bookmark>[
        _bm(createdAt: now),
        _bm(createdAt: now.subtract(const Duration(days: 1))),
        _bm(createdAt: now.subtract(const Duration(days: 1))),
        _bm(createdAt: now.subtract(const Duration(days: 8))),
      ],
    );
    addTearDown(c.dispose);

    final DashboardStats stats = await c.read(dashboardStatsProvider.future);

    expect(stats.timeline.length, 7);
    expect(stats.timeline.last.count, 1);
    expect(stats.timeline[5].count, 2);
    expect(stats.timeline.first.count, 0);
  });

  test('DashboardStats.favoriteRatio handles zero division', () {
    const DashboardStats empty = DashboardStats();
    expect(empty.favoriteRatio, 0);
    expect(empty.readRatio, 0);
  });

  test('DashboardStats.readRatio computes correctly', () {
    const DashboardStats stats = DashboardStats(
      totalBookmarks: 10,
      unreadCount: 3,
    );
    expect(stats.readRatio, closeTo(0.7, 0.001));
  });
}

// ─── Fakes ────────────────────────────────────────────────────────

class _FakeBookmarkRepo implements BookmarkRepository {
  _FakeBookmarkRepo(this._active, this._archived);
  final List<Bookmark> _active;
  final List<Bookmark> _archived;

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async {
    final List<Bookmark> source =
        query.filter == BookmarkFeedFilter.archived ? _archived : _active;
    return source;
  }

  // ─── Unused stubs ──────────────────────────────────────────────

  @override
  Future<Bookmark> save(Bookmark bookmark) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) =>
      throw UnimplementedError();
  @override
  Future<Bookmark?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> getByIds(List<int> ids) => throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<int> deleteAll(List<int> ids) => throw UnimplementedError();
  @override
  Future<Bookmark?> findByUrlHash(String urlHash) => throw UnimplementedError();
  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) =>
      throw UnimplementedError();
  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) =>
      throw UnimplementedError();
  @override
  Future<int> countAll() => throw UnimplementedError();
  @override
  Future<int> count(BookmarkFeedQuery query) => throw UnimplementedError();
  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      throw UnimplementedError();
  @override
  Stream<Bookmark?> watchById(int id) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) =>
      throw UnimplementedError();
}

class _FakeTagRepo implements TagRepository {
  _FakeTagRepo(this._tags);
  final List<Tag> _tags;

  @override
  Future<List<Tag>> getAll() async => _tags;

  // ─── Unused stubs ──────────────────────────────────────────────

  @override
  Future<Tag> save(Tag tag) => throw UnimplementedError();
  @override
  Future<Tag> createFromName(String name, {int? colorArgb, String? icon}) =>
      throw UnimplementedError();
  @override
  Future<Tag?> getById(int id) => throw UnimplementedError();
  @override
  Future<Tag?> findBySlug(String slug) => throw UnimplementedError();
  @override
  Future<List<Tag>> getByIds(List<int> ids) async {
    final Set<int> idSet = ids.toSet();
    return _tags
        .where((Tag tag) => tag.id != null && idSet.contains(tag.id))
        .toList();
  }

  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<void> incrementUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<void> decrementUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<int> recomputeUsageCount(int tagId) => throw UnimplementedError();
  @override
  Future<Map<int, int>> recomputeAllUsageCounts() => throw UnimplementedError();
  @override
  Stream<List<Tag>> watchAll() => throw UnimplementedError();
  @override
  Stream<Tag?> watchById(int id) => throw UnimplementedError();
}
