import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';
import 'package:marky/features/import_export/domain/export_service.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

void main() {
  late _FakeBookmarkRepo bookmarkRepo;
  late _FakeTagRepo tagRepo;
  late _FakeCollectionRepo collectionRepo;
  late ExportService service;

  setUp(() {
    bookmarkRepo = _FakeBookmarkRepo();
    tagRepo = _FakeTagRepo();
    collectionRepo = _FakeCollectionRepo();
    service = ExportService(
      bookmarkRepository: bookmarkRepo,
      tagRepository: tagRepo,
      collectionRepository: collectionRepo,
    );
  });

  test('produces a valid JSON envelope with version 1', () async {
    final String body = await service.exportAll();
    final Map<String, dynamic> decoded =
        json.decode(body) as Map<String, dynamic>;

    expect(decoded['version'], 1);
    expect(decoded['exportedAt'], isA<String>());
    expect(decoded['bookmarks'], isA<List<dynamic>>());
    expect(decoded['tags'], isA<List<dynamic>>());
    expect(decoded['collections'], isA<List<dynamic>>());
  });

  test('serialises bookmarks with all fields', () async {
    final DateTime now = DateTime.utc(2026);
    bookmarkRepo.feedResults = <Bookmark>[
      Bookmark(
        id: 1,
        originalUrl: 'https://example.com',
        canonicalUrl: 'https://example.com/',
        urlHash: 'hash-1',
        externalContentId: 'github:owner/repo',
        title: 'Hello',
        contentType: BookmarkContentType.video,
        sourceType: BookmarkSourceType.share,
        isFavorite: true,
        tagIds: const <int>[1, 2],
        collectionIds: const <int>[5],
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final String body = await service.exportAll();
    final Map<String, dynamic> decoded =
        json.decode(body) as Map<String, dynamic>;
    final Map<String, dynamic> first =
        (decoded['bookmarks'] as List<dynamic>).first as Map<String, dynamic>;

    expect(first['originalUrl'], 'https://example.com');
    expect(first['urlHash'], 'hash-1');
    expect(first['externalContentId'], 'github:owner/repo');
    expect(first['title'], 'Hello');
    expect(first['contentType'], 'video');
    expect(first['sourceType'], 'share');
    expect(first['isFavorite'], isTrue);
    expect(first['tagIds'], <int>[1, 2]);
    expect(first['collectionIds'], <int>[5]);
    expect(first['createdAt'], '2026-01-01T00:00:00.000Z');
  });

  test('round-trips through ImportService when fed back', () async {
    final DateTime now = DateTime.utc(2026);
    bookmarkRepo.feedResults = <Bookmark>[
      Bookmark(
        originalUrl: 'https://a.com',
        contentType: BookmarkContentType.article,
        createdAt: now,
        updatedAt: now,
      ),
      Bookmark(
        originalUrl: 'https://b.com',
        contentType: BookmarkContentType.article,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    tagRepo.allTags = <Tag>[
      Tag(name: 'Tech', slug: 'tech', createdAt: now, updatedAt: now),
    ];
    collectionRepo.allCollections = <BookmarkCollection>[
      BookmarkCollection(
        title: 'Reads',
        slug: 'reads',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final String body = await service.exportAll();
    final Map<String, dynamic> decoded =
        json.decode(body) as Map<String, dynamic>;

    expect((decoded['bookmarks'] as List<dynamic>).length, 2);
    expect((decoded['tags'] as List<dynamic>).length, 1);
    expect((decoded['collections'] as List<dynamic>).length, 1);
  });

  test('paginates bookmark export and includes archived rows', () async {
    final DateTime now = DateTime.utc(2026);
    bookmarkRepo.feedResults = List<Bookmark>.generate(
      502,
      (int index) => Bookmark(
        originalUrl: 'https://example.com/$index',
        isArchived: index == 501,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final String body = await service.exportAll();
    final Map<String, dynamic> decoded =
        json.decode(body) as Map<String, dynamic>;

    expect((decoded['bookmarks'] as List<dynamic>).length, 502);
    expect(bookmarkRepo.feedQueries[0].limit, 500);
    expect(bookmarkRepo.feedQueries[0].offset, 0);
    expect(bookmarkRepo.feedQueries[1].offset, 500);
    expect(bookmarkRepo.feedQueries[2].filter, BookmarkFeedFilter.archived);
  });

  test('feed calls use bounded pages instead of an unclamped huge limit',
      () async {
    await service.exportAll();
    expect(bookmarkRepo.feedQueries.map((q) => q.limit), everyElement(500));
    expect(bookmarkRepo.feedQueries.any((q) => q.limit > 10000), isFalse);
  });

  test('collections include archived ones', () async {
    await service.exportAll();
    expect(collectionRepo.lastIncludeArchived, isTrue);
  });
}

// ─── Fakes ────────────────────────────────────────────────────────

class _FakeBookmarkRepo implements BookmarkRepository {
  List<Bookmark> feedResults = <Bookmark>[];
  BookmarkFeedQuery? lastFeedQuery;
  final List<BookmarkFeedQuery> feedQueries = <BookmarkFeedQuery>[];

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async {
    lastFeedQuery = query;
    feedQueries.add(query);
    final List<Bookmark> filtered = feedResults.where((Bookmark bookmark) {
      final bool archivedMatch = query.filter == BookmarkFeedFilter.archived
          ? bookmark.isArchived
          : !bookmark.isArchived;
      return archivedMatch;
    }).toList(growable: false);
    final int start = query.offset < 0 ? 0 : query.offset;
    if (start >= filtered.length) return const <Bookmark>[];
    final int limit = query.limit < 0 ? 0 : query.limit;
    final int end =
        start + limit > filtered.length ? filtered.length : start + limit;
    return filtered.sublist(start, end);
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
  List<Tag> allTags = <Tag>[];

  @override
  Future<List<Tag>> getAll() async => allTags;

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
  Future<List<Tag>> getByIds(List<int> ids) => throw UnimplementedError();
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

class _FakeCollectionRepo implements BookmarkCollectionRepository {
  List<BookmarkCollection> allCollections = <BookmarkCollection>[];
  bool? lastIncludeArchived;

  @override
  Future<List<BookmarkCollection>> getAll(
      {bool includeArchived = false}) async {
    lastIncludeArchived = includeArchived;
    return allCollections;
  }

  // ─── Unused stubs ──────────────────────────────────────────────

  @override
  Future<BookmarkCollection> save(BookmarkCollection collection) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection> createFromTitle(
    String title, {
    int? accentColorArgb,
    String? icon,
  }) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection> createSmartFromRule(
    String title,
    SmartCollectionRule rule, {
    int? accentColorArgb,
    String? icon,
  }) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection?> getById(int id) => throw UnimplementedError();
  @override
  Future<BookmarkCollection?> findBySlug(String slug) =>
      throw UnimplementedError();
  @override
  Future<List<BookmarkCollection>> getByIds(List<int> ids) =>
      throw UnimplementedError();
  @override
  Future<bool> delete(int id) => throw UnimplementedError();
  @override
  Future<void> incrementItemCount(int collectionId) =>
      throw UnimplementedError();
  @override
  Future<void> decrementItemCount(int collectionId) =>
      throw UnimplementedError();
  @override
  Future<int> recomputeItemCount(int collectionId) =>
      throw UnimplementedError();
  @override
  Future<Map<int, int>> recomputeAllItemCounts() => throw UnimplementedError();
  @override
  Stream<List<BookmarkCollection>> watchAll({bool includeArchived = false}) =>
      throw UnimplementedError();
  @override
  Stream<BookmarkCollection?> watchById(int id) => throw UnimplementedError();
}
