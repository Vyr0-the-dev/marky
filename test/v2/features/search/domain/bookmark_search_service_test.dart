import 'package:flutter_test/flutter_test.dart';

import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/search/domain/bookmark_search_service.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

void main() {
  late _FakeBookmarkRepository bookmarkRepository;
  late _FakeTagRepository tagRepository;
  late BookmarkSearchService service;

  setUp(() {
    bookmarkRepository = _FakeBookmarkRepository();
    tagRepository = _FakeTagRepository(<Tag>[
      _tag(id: 7, name: 'Dart'),
      _tag(id: 8, name: 'Reading List'),
    ]);
    service = BookmarkSearchService(
      bookmarkRepository: bookmarkRepository,
      tagRepository: tagRepository,
    );
  });

  test(
      'filters ranked text search results with tag/domain/status/date operators',
      () async {
    final DateTime after = DateTime(2026, 4);
    bookmarkRepository.searchResults = <Bookmark>[
      _bookmark(
        id: 1,
        title: 'Flutter async',
        tagIds: <int>[7],
        host: 'flutter.dev',
        favorite: true,
        createdAt: after.add(const Duration(days: 10)),
      ),
      _bookmark(
        id: 2,
        title: 'Flutter wrong tag',
        tagIds: <int>[8],
        host: 'flutter.dev',
        favorite: true,
        createdAt: after.add(const Duration(days: 10)),
      ),
      _bookmark(
        id: 3,
        title: 'Flutter old',
        tagIds: <int>[7],
        host: 'flutter.dev',
        favorite: true,
        createdAt: DateTime(2026, 3),
      ),
      _bookmark(
        id: 4,
        title: 'Flutter not favorite',
        tagIds: <int>[7],
        host: 'flutter.dev',
        createdAt: after.add(const Duration(days: 10)),
      ),
    ];

    final List<Bookmark> results = await service.search(
      'flutter tag:dart domain:flutter.dev is:favorite after:2026-04-01',
    );

    expect(results.map((Bookmark b) => b.id), <int?>[1]);
    expect(bookmarkRepository.lastSearchQuery, 'flutter');
    expect(bookmarkRepository.feedCalls, isEmpty);
  });

  test('uses feed query when query contains only operators', () async {
    bookmarkRepository.feedResults = <Bookmark>[
      _bookmark(id: 1, tagIds: <int>[7], host: 'flutter.dev', favorite: true),
    ];

    final List<Bookmark> results = await service.search(
      'tag:dart domain:flutter.dev is:favorite before:2026-04-25',
    );

    expect(results.map((Bookmark b) => b.id), <int?>[1]);
    expect(bookmarkRepository.searchCalls, isEmpty);
    final BookmarkFeedQuery query = bookmarkRepository.feedCalls.single;
    expect(query.filter, BookmarkFeedFilter.favorites);
    expect(query.tagId, 7);
    expect(query.host, 'flutter.dev');
    expect(query.createdBefore, DateTime(2026, 4, 25, 23, 59, 59, 999, 999));
  });

  test('unknown tag operator returns no results without repository search',
      () async {
    final List<Bookmark> results = await service.search('tag:missing flutter');

    expect(results, isEmpty);
    expect(bookmarkRepository.searchCalls, isEmpty);
    expect(bookmarkRepository.feedCalls, isEmpty);
  });
}

Tag _tag({required int id, required String name}) {
  final DateTime now = DateTime(2026);
  return Tag(
    id: id,
    name: name,
    slug: Tag.slugify(name),
    createdAt: now,
    updatedAt: now,
  );
}

Bookmark _bookmark({
  required int id,
  String title = 'Bookmark',
  List<int> tagIds = const <int>[],
  String host = 'example.com',
  bool favorite = false,
  bool archived = false,
  bool read = false,
  DateTime? createdAt,
}) {
  final DateTime at = createdAt ?? DateTime(2026, 4, 20);
  return Bookmark(
    id: id,
    originalUrl: 'https://$host/$id',
    title: title,
    normalizedHost: host,
    tagIds: tagIds,
    isFavorite: favorite,
    isArchived: archived,
    isRead: read,
    createdAt: at,
    updatedAt: at,
  );
}

class _FakeBookmarkRepository implements BookmarkRepository {
  List<Bookmark> searchResults = <Bookmark>[];
  List<Bookmark> feedResults = <Bookmark>[];
  final List<String> searchCalls = <String>[];
  final List<BookmarkFeedQuery> feedCalls = <BookmarkFeedQuery>[];

  String? get lastSearchQuery => searchCalls.isEmpty ? null : searchCalls.last;

  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async {
    searchCalls.add(query);
    return searchResults.take(limit).toList(growable: false);
  }

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async {
    feedCalls.add(query);
    return feedResults.take(query.limit).toList(growable: false);
  }

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
}

class _FakeTagRepository implements TagRepository {
  _FakeTagRepository(Iterable<Tag> tags)
      : _tagsBySlug = <String, Tag>{for (final Tag tag in tags) tag.slug: tag};

  final Map<String, Tag> _tagsBySlug;

  @override
  Future<Tag?> findBySlug(String slug) async => _tagsBySlug[slug];

  @override
  Future<Tag> save(Tag tag) => throw UnimplementedError();
  @override
  Future<Tag> createFromName(String name, {int? colorArgb, String? icon}) =>
      throw UnimplementedError();
  @override
  Future<Tag?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<Tag>> getAll() => throw UnimplementedError();
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
