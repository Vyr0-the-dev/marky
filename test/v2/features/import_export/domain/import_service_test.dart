import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:marky/core/url/url_hasher.dart';
import 'package:marky/core/url/url_normalizer.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/data/default_upsert_merge_service.dart';
import 'package:marky/features/capture/domain/duplicate_check_result.dart';
import 'package:marky/features/capture/domain/duplicate_detector.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';
import 'package:marky/features/import_export/domain/import_service.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

String _hash(String url) {
  const UrlNormalizer n = UrlNormalizer();
  const UrlHasher h = UrlHasher();
  return h.hash(n.normalize(url) ?? url);
}

void main() {
  late _FakeBookmarkRepo bookmarkRepo;
  late _FakeTagRepo tagRepo;
  late _FakeCollectionRepo collectionRepo;
  late _FakeDuplicateDetector duplicateDetector;
  late ImportService service;

  setUp(() {
    bookmarkRepo = _FakeBookmarkRepo();
    tagRepo = _FakeTagRepo();
    collectionRepo = _FakeCollectionRepo();
    duplicateDetector = _FakeDuplicateDetector();
    service = ImportService(
      bookmarkRepository: bookmarkRepo,
      tagRepository: tagRepo,
      collectionRepository: collectionRepo,
      duplicateDetector: duplicateDetector,
      mergeService: const DefaultUpsertMergeService(),
    );
  });

  // ─── Version gate ─────────────────────────────────────────────

  test('throws on unsupported version', () async {
    final String body = json.encode(<String, dynamic>{'version': 99});
    expect(
      () => service.importAll(body),
      throwsA(isA<FormatException>()),
    );
  });

  // ─── Tags ─────────────────────────────────────────────────────

  group('tags', () {
    test('imports new tag', () async {
      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'tags': <Map<String, dynamic>>[
          <String, dynamic>{'name': 'Design'},
        ],
      });

      final ImportResult result = await service.importAll(body);

      expect(result.tagsImported, 1);
      expect(tagRepo.created.first.name, 'Design');
    });

    test('skips existing tag (slug match)', () async {
      tagRepo.existingSlugs.add('design');

      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'tags': <Map<String, dynamic>>[
          <String, dynamic>{'name': 'Design'},
        ],
      });

      final ImportResult result = await service.importAll(body);

      expect(result.tagsImported, 0);
      expect(tagRepo.created, isEmpty);
    });

    test('skips empty-name tags', () async {
      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'tags': <Map<String, dynamic>>[
          <String, dynamic>{'name': ''},
          <String, dynamic>{},
        ],
      });

      final ImportResult result = await service.importAll(body);

      expect(result.tagsImported, 0);
    });
  });

  // ─── Collections ──────────────────────────────────────────────

  group('collections', () {
    test('imports new collection with accent color', () async {
      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'collections': <Map<String, dynamic>>[
          <String, dynamic>{
            'title': 'Reading List',
            'accentColorArgb': 0xFF112233,
          },
        ],
      });

      final ImportResult result = await service.importAll(body);

      expect(result.collectionsImported, 1);
      expect(collectionRepo.created.first.title, 'Reading List');
      expect(collectionRepo.created.first.accentColorArgb, 0xFF112233);
    });

    test('skips existing collection (slug match)', () async {
      collectionRepo.existingSlugs.add('reading-list');

      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'collections': <Map<String, dynamic>>[
          <String, dynamic>{'title': 'Reading List'},
        ],
      });

      final ImportResult result = await service.importAll(body);

      expect(result.collectionsImported, 0);
    });
  });

  // ─── Bookmarks ────────────────────────────────────────────────

  group('bookmarks', () {
    test('imports new bookmark with all fields', () async {
      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'bookmarks': <Map<String, dynamic>>[
          <String, dynamic>{
            'originalUrl': 'https://example.com',
            'title': 'Hello',
            'isFavorite': true,
            'tagIds': <int>[1, 2],
            'collectionIds': <int>[5],
          },
        ],
      });

      final ImportResult result = await service.importAll(body);

      expect(result.bookmarksImported, 1);
      expect(result.bookmarksSkipped, 0);
      expect(bookmarkRepo.saved.first.originalUrl, 'https://example.com');
      expect(bookmarkRepo.saved.first.title, 'Hello');
      expect(bookmarkRepo.saved.first.isFavorite, isTrue);
      expect(bookmarkRepo.saved.first.tagIds, <int>[1, 2]);
      expect(bookmarkRepo.saved.first.collectionIds, <int>[5]);
    });

    test('merges bookmark whose URL hash already exists', () async {
      final DateTime now = DateTime(2026);
      duplicateDetector.byHash[_hash('https://example.com')] = Bookmark(
        id: 42,
        originalUrl: 'https://example.com',
        urlHash: _hash('https://example.com'),
        tagIds: const <int>[1],
        createdAt: now,
        updatedAt: now,
      );

      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'bookmarks': <Map<String, dynamic>>[
          <String, dynamic>{
            'originalUrl': 'https://example.com',
            'title': 'Imported title',
            'tagIds': <int>[2],
          },
        ],
      });

      final ImportResult result = await service.importAll(body);

      expect(result.bookmarksImported, 0);
      expect(result.bookmarksMerged, 1);
      expect(result.bookmarksSkipped, 0);
      expect(bookmarkRepo.saved.single.id, 42);
      expect(bookmarkRepo.saved.single.title, 'Imported title');
      expect(bookmarkRepo.saved.single.tagIds, <int>[1, 2]);
    });

    test('merge preserves local user fields instead of blind overwrite',
        () async {
      final DateTime now = DateTime(2026);
      duplicateDetector.byHash[_hash('https://example.com')] = Bookmark(
        id: 42,
        originalUrl: 'https://example.com',
        urlHash: _hash('https://example.com'),
        title: 'Local title',
        inlineNotes: 'Local notes',
        isRead: true,
        tagIds: const <int>[1],
        createdAt: now,
        updatedAt: now,
      );

      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'bookmarks': <Map<String, dynamic>>[
          <String, dynamic>{
            'originalUrl': 'https://example.com',
            'title': 'Backup title',
            'inlineNotes': 'Backup notes',
            'isFavorite': true,
            'isRead': false,
            'tagIds': <int>[2],
          },
        ],
      });

      final ImportResult result = await service.importAll(body);

      expect(result.bookmarksMerged, 1);
      expect(bookmarkRepo.saved.single.id, 42);
      expect(bookmarkRepo.saved.single.title, 'Local title');
      expect(bookmarkRepo.saved.single.inlineNotes, 'Local notes');
      expect(bookmarkRepo.saved.single.isFavorite, isFalse);
      expect(bookmarkRepo.saved.single.isRead, isTrue);
      expect(bookmarkRepo.saved.single.tagIds, <int>[1, 2]);
    });

    test('uses external content IDs for cross-variant duplicate merge',
        () async {
      final DateTime now = DateTime(2026);
      duplicateDetector.byExternalContentId['youtube:dQw4w9WgXcQ'] = Bookmark(
        id: 7,
        originalUrl: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
        externalContentId: 'youtube:dQw4w9WgXcQ',
        createdAt: now,
        updatedAt: now,
      );

      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'bookmarks': <Map<String, dynamic>>[
          <String, dynamic>{'originalUrl': 'https://youtu.be/dQw4w9WgXcQ'},
        ],
      });

      final ImportResult result = await service.importAll(body);

      expect(result.bookmarksMerged, 1);
      expect(bookmarkRepo.saved.single.id, 7);
      expect(duplicateDetector.lastExternalContentId, 'youtube:dQw4w9WgXcQ');
    });

    test('skips bookmarks with empty URLs', () async {
      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'bookmarks': <Map<String, dynamic>>[
          <String, dynamic>{'originalUrl': ''},
          <String, dynamic>{},
        ],
      });

      final ImportResult result = await service.importAll(body);

      expect(result.bookmarksImported, 0);
      expect(result.bookmarksSkipped, 0);
    });

    test('parses ISO 8601 createdAt', () async {
      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'bookmarks': <Map<String, dynamic>>[
          <String, dynamic>{
            'originalUrl': 'https://example.com',
            'createdAt': '2024-06-15T12:30:00.000Z',
          },
        ],
      });

      await service.importAll(body);

      expect(
        bookmarkRepo.saved.first.createdAt.toUtc(),
        DateTime.utc(2024, 6, 15, 12, 30),
      );
    });

    test('falls back to article on unknown contentType', () async {
      final String body = json.encode(<String, dynamic>{
        'version': 1,
        'bookmarks': <Map<String, dynamic>>[
          <String, dynamic>{
            'originalUrl': 'https://example.com',
            'contentType': 'banana',
          },
        ],
      });

      await service.importAll(body);

      expect(bookmarkRepo.saved.first.contentType.name, 'article');
    });
  });

  // ─── Mixed ────────────────────────────────────────────────────

  test('handles full envelope (tags + collections + bookmarks)', () async {
    final String body = json.encode(<String, dynamic>{
      'version': 1,
      'tags': <Map<String, dynamic>>[
        <String, dynamic>{'name': 'Tech'},
      ],
      'collections': <Map<String, dynamic>>[
        <String, dynamic>{'title': 'Reads'},
      ],
      'bookmarks': <Map<String, dynamic>>[
        <String, dynamic>{'originalUrl': 'https://a.com'},
        <String, dynamic>{'originalUrl': 'https://b.com'},
      ],
    });

    final ImportResult result = await service.importAll(body);

    expect(result.tagsImported, 1);
    expect(result.collectionsImported, 1);
    expect(result.bookmarksImported, 2);
  });
}

// ─── Fakes ────────────────────────────────────────────────────────

class _FakeTagRepo implements TagRepository {
  final Set<String> existingSlugs = <String>{};
  final List<Tag> created = <Tag>[];

  @override
  Future<Tag?> findBySlug(String slug) async {
    if (!existingSlugs.contains(slug)) return null;
    final DateTime now = DateTime(2026);
    return Tag(name: slug, slug: slug, createdAt: now, updatedAt: now);
  }

  @override
  Future<Tag> createFromName(String name,
      {int? colorArgb, String? icon}) async {
    final DateTime now = DateTime(2026);
    final Tag t = Tag(
      id: created.length + 1,
      name: name,
      slug: Tag.slugify(name),
      colorArgb: colorArgb,
      icon: icon,
      createdAt: now,
      updatedAt: now,
    );
    created.add(t);
    return t;
  }

  // ─── Unused stubs ──────────────────────────────────────────────

  @override
  Future<Tag> save(Tag tag) => throw UnimplementedError();
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

class _FakeCollectionRepo implements BookmarkCollectionRepository {
  final Set<String> existingSlugs = <String>{};
  final List<BookmarkCollection> created = <BookmarkCollection>[];

  @override
  Future<BookmarkCollection?> findBySlug(String slug) async {
    if (!existingSlugs.contains(slug)) return null;
    final DateTime now = DateTime(2026);
    return BookmarkCollection(
      title: slug,
      slug: slug,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<BookmarkCollection> createFromTitle(
    String title, {
    int? accentColorArgb,
    String? icon,
  }) async {
    final DateTime now = DateTime(2026);
    final BookmarkCollection c = BookmarkCollection(
      id: created.length + 1,
      title: title,
      slug: BookmarkCollection.slugify(title),
      accentColorArgb: accentColorArgb,
      icon: icon,
      createdAt: now,
      updatedAt: now,
    );
    created.add(c);
    return c;
  }

  @override
  Future<BookmarkCollection> createSmartFromRule(
    String title,
    SmartCollectionRule rule, {
    int? accentColorArgb,
    String? icon,
  }) =>
      throw UnimplementedError();

  // ─── Unused stubs ──────────────────────────────────────────────

  @override
  Future<BookmarkCollection> save(BookmarkCollection collection) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection?> getById(int id) => throw UnimplementedError();
  @override
  Future<List<BookmarkCollection>> getAll({bool includeArchived = false}) =>
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

class _FakeDuplicateDetector implements DuplicateDetector {
  final Map<String, Bookmark> byHash = <String, Bookmark>{};
  final Map<String, Bookmark> byCanonicalUrl = <String, Bookmark>{};
  final Map<String, Bookmark> byExternalContentId = <String, Bookmark>{};
  String? lastExternalContentId;

  @override
  Future<DuplicateCheckResult> check({
    required String urlHash,
    required String canonicalUrl,
    String? externalContentId,
  }) async {
    lastExternalContentId = externalContentId;
    final Bookmark? hashMatch = byHash[urlHash];
    if (hashMatch != null) {
      return DuplicateCheckResult.duplicate(
        hashMatch,
        DuplicateMatchLevel.urlHash,
      );
    }
    final Bookmark? canonicalMatch = byCanonicalUrl[canonicalUrl];
    if (canonicalMatch != null) {
      return DuplicateCheckResult.duplicate(
        canonicalMatch,
        DuplicateMatchLevel.canonicalUrl,
      );
    }
    final Bookmark? externalMatch = externalContentId == null
        ? null
        : byExternalContentId[externalContentId];
    if (externalMatch != null) {
      return DuplicateCheckResult.duplicate(
        externalMatch,
        DuplicateMatchLevel.externalContentId,
      );
    }
    return const DuplicateCheckResult.fresh();
  }
}

class _FakeBookmarkRepo implements BookmarkRepository {
  final Set<String> existingHashes = <String>{};
  final List<Bookmark> saved = <Bookmark>[];

  @override
  Future<Bookmark?> findByUrlHash(String urlHash) async {
    if (!existingHashes.contains(urlHash)) return null;
    final DateTime now = DateTime(2026);
    return Bookmark(
      originalUrl: 'placeholder',
      urlHash: urlHash,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<Bookmark> save(Bookmark bookmark) async {
    saved.add(bookmark);
    return bookmark;
  }

  // ─── Unused stubs ──────────────────────────────────────────────

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
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) =>
      throw UnimplementedError();
  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      throw UnimplementedError();
  @override
  Stream<Bookmark?> watchById(int id) => throw UnimplementedError();
  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) =>
      throw UnimplementedError();
}
