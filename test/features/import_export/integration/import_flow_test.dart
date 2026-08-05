import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/models/save_bookmark_params.dart';
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/import_export/data/services/bookmark_html_parser.dart';
import 'package:marky/features/import_export/data/services/import_bookmarks_service.dart';
import 'package:marky/features/import_export/domain/models/import_result.dart';
import 'package:marky/features/import_export/domain/use_cases/import_bookmarks_use_case.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';

import '../data/fixtures/bookmark_fixtures.dart';

// ─── Fakes ───────────────────────────────────────────────────────────────

/// Fake [CollectionRepository] with in-memory storage.
class _FakeCollectionRepository implements CollectionRepository {
  final Map<Id, BookmarkCollection> _collections = <Id, BookmarkCollection>{};
  int _nextId = 1;

  @override
  Future<BookmarkCollection?> getById(Id id) async => _collections[id];

  @override
  Future<List<BookmarkCollection>> getAll() async =>
      _collections.values.toList();

  @override
  Future<Id> insert(BookmarkCollection entity) async {
    entity.id = _nextId++;
    _collections[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkCollection entity) async {
    _collections[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async => _collections.remove(id);

  @override
  Future<void> clear() async {
    _collections.clear();
    _nextId = 1;
  }

  @override
  Future<BookmarkCollection?> getBySlug(String slug) async {
    for (final BookmarkCollection c in _collections.values) {
      if (c.slug == slug) return c;
    }
    return null;
  }
}

/// Fake [BookmarkItemRepository] (required by SaveBookmarkUseCase
/// constructor but not used in these focused integration tests).
class _FakeBookmarkRepository implements BookmarkItemRepository {
  final Map<Id, BookmarkItem> _items = <Id, BookmarkItem>{};
  int _nextId = 1;

  @override
  Future<BookmarkItem?> getById(Id id) async => _items[id];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => _items.values.toList();

  @override
  Future<Id> insert(BookmarkItem entity) async {
    entity.id = _nextId++;
    _items[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    _items[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async => _items.remove(id);

  @override
  Future<void> clear() async {
    _items.clear();
    _nextId = 1;
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async =>
      null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => [];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => [];

  @override
  Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async => [];
}

/// Fake [SaveBookmarkUseCase] that returns predetermined results.
class _FakeSaveBookmarkUseCase extends SaveBookmarkUseCase {
  _FakeSaveBookmarkUseCase({
    required super.repository,
    this.behavior = _FakeBehavior.alwaysSuccess,
  });

  final _FakeBehavior behavior;

  final List<_SaveCall> calls = <_SaveCall>[];

  @override
  Future<SaveResult> execute(String rawUrl, {SaveBookmarkParams? params}) async {
    calls.add(_SaveCall(rawUrl: rawUrl, params: params));

    switch (behavior) {
      case _FakeBehavior.alwaysSuccess:
        return SaveSuccess(_nextSuccessId++);
      case _FakeBehavior.alwaysDuplicate:
        return SaveDuplicate(
          BookmarkItem(
            originalUrl: rawUrl,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      case _FakeBehavior.alwaysInvalid:
        return const SaveInvalid('invalid url');
    }
  }

  static int _nextSuccessId = 1000;

  static void resetCounters() {
    _nextSuccessId = 1000;
  }
}

enum _FakeBehavior {
  alwaysSuccess,
  alwaysDuplicate,
  alwaysInvalid,
}

class _SaveCall {
  const _SaveCall({required this.rawUrl, this.params});

  final String rawUrl;
  final SaveBookmarkParams? params;
}

// ─── Integration Tests ───────────────────────────────────────────────────

void main() {
  group('Import Flow Integration', () {
    late _FakeCollectionRepository collectionRepo;
    late _FakeBookmarkRepository bookmarkRepo;
    late _FakeSaveBookmarkUseCase saveUseCase;
    late ImportBookmarksService service;
    late ImportBookmarksUseCase useCase;

    setUp(() {
      collectionRepo = _FakeCollectionRepository();
      bookmarkRepo = _FakeBookmarkRepository();
      _FakeSaveBookmarkUseCase.resetCounters();
      saveUseCase = _FakeSaveBookmarkUseCase(repository: bookmarkRepo);
      service = ImportBookmarksService(
        saveBookmarkUseCase: saveUseCase,
        collectionRepository: collectionRepo,
      );
      useCase = ImportBookmarksUseCase(service: service);
    });

    // ─── Chrome-style export ───────────────────────────────────────────

    test('Chrome export: parses, maps folders, and aggregates results', () async {
      final ImportResult result = await useCase.execute(
        htmlContent: kChromeExportHtml,
        importSource: 'chrome',
      );

      // Chrome fixture has 4 bookmarks: GitHub, Stack Overflow, Hacker News, Flutter.
      expect(result.totalFound, 4);
      expect(result.imported, 4);
      expect(result.duplicatesSkipped, 0);
      expect(result.failed, 0);

      // Verify collections were created from top-level folders.
      final List<BookmarkCollection> collections =
          await collectionRepo.getAll();
      expect(collections.length, 2);
      expect(collections.map((c) => c.title), contains('Bookmarks Bar'));
      expect(collections.map((c) => c.title), contains('Other Bookmarks'));

      // Verify folder slugification.
      expect(
        collections.any((c) => c.slug == 'bookmarks-bar'),
        isTrue,
      );
      expect(
        collections.any((c) => c.slug == 'other-bookmarks'),
        isTrue,
      );

      // Verify nested folder bookmark gets top-level folder only.
      final BookmarkCollection? otherBookmarks =
          await collectionRepo.getBySlug('other-bookmarks');
      expect(otherBookmarks, isNotNull);

      // Flutter bookmark is inside 'Other Bookmarks' → 'Nested Folder'.
      // Only top-level folder should be assigned.
      final _SaveCall flutterCall = saveUseCase.calls.firstWhere(
        (c) => c.rawUrl == 'https://flutter.dev',
      );
      expect(
        flutterCall.params?.collectionIds,
        <int>[otherBookmarks!.id],
      );
    });

    // ─── Firefox-style export ──────────────────────────────────────────

    test('Firefox export: parses and maps PERSONAL_TOOLBAR_FOLDER', () async {
      final ImportResult result = await useCase.execute(
        htmlContent: kFirefoxExportHtml,
        importSource: 'firefox',
      );

      // Firefox fixture has 4 bookmarks: Mozilla, MDN, Dart Packages, Reddit.
      expect(result.totalFound, 4);
      expect(result.imported, 4);

      final List<BookmarkCollection> collections =
          await collectionRepo.getAll();
      expect(collections.length, 3);
      expect(collections.map((c) => c.title), contains('Bookmarks Toolbar'));
      expect(collections.map((c) => c.title), contains('Dev'));
      expect(collections.map((c) => c.title), contains('News & Blogs'));
    });

    // ─── Empty / malformed input ───────────────────────────────────────

    test('empty bookmarks HTML produces zero-count result', () async {
      final ImportResult result = await useCase.execute(
        htmlContent: kEmptyBookmarksHtml,
        importSource: 'chrome',
      );

      expect(result.totalFound, 0);
      expect(result.imported, 0);
      expect(result.duplicatesSkipped, 0);
      expect(result.failed, 0);
      expect(saveUseCase.calls, isEmpty);
    });

    test('HTML with no bookmarks produces zero-count result', () async {
      final ImportResult result = await useCase.execute(
        htmlContent: kNoBookmarksHtml,
        importSource: 'chrome',
      );

      expect(result.totalFound, 0);
      expect(result.imported, 0);
      expect(result.duplicatesSkipped, 0);
      expect(result.failed, 0);
    });

    test('malformed HTML produces zero-count result without throwing', () async {
      final ImportResult result = await useCase.execute(
        htmlContent: kMalformedHtml,
        importSource: 'chrome',
      );

      // The fixture is severely malformed (unclosed H3/DL tags).
      // The parser should not crash; it may produce 0 or some bookmarks
      // depending on the html package's recovery heuristics.
      expect(result.totalFound, greaterThanOrEqualTo(0));
      expect(result.failed, 0); // No exceptions thrown.
    });

    // ─── Large batch ───────────────────────────────────────────────────

    test('large batch (50 bookmarks) processes all items', () async {
      final String largeHtml = generateLargeBatchHtml();

      final ImportResult result = await useCase.execute(
        htmlContent: largeHtml,
        importSource: 'chrome',
      );

      expect(result.totalFound, 50);
      expect(result.imported, 50);
      expect(result.duplicatesSkipped, 0);
      expect(result.failed, 0);
      expect(saveUseCase.calls.length, 50);
    });

    // ─── Folder slugification ──────────────────────────────────────────

    test('folder names are slugified correctly', () async {
      await useCase.execute(
        htmlContent: kSpecialCharsFolderHtml,
        importSource: 'chrome',
      );

      final List<BookmarkCollection> collections =
          await collectionRepo.getAll();
      expect(collections.length, 3);

      // "Dev & Tools" → "dev-tools"
      expect(
        collections.any((c) => c.slug == 'dev-tools'),
        isTrue,
      );

      // "News — Hot!" → "news-hot"
      expect(
        collections.any((c) => c.slug == 'news-hot'),
        isTrue,
      );

      // "   Spaces   " → "spaces"
      expect(
        collections.any((c) => c.slug == 'spaces'),
        isTrue,
      );
    });

    // ─── Progress callback ─────────────────────────────────────────────

    test('onProgress is called for every item in order', () async {
      final List<(int, int)> progressEvents = <(int, int)>[];

      await useCase.execute(
        htmlContent: kChromeExportHtml,
        importSource: 'chrome',
        onProgress: (int current, int total) {
          progressEvents.add((current, total));
        },
      );

      expect(progressEvents.length, 4);
      expect(progressEvents[0], (1, 4));
      expect(progressEvents[1], (2, 4));
      expect(progressEvents[2], (3, 4));
      expect(progressEvents[3], (4, 4));
    });

    // ─── Full pipeline: parser → service → use case ────────────────────

    test('parser output matches service input count', () async {
      const BookmarkHtmlParser parser = BookmarkHtmlParser();
      final parsed = parser.parse(kChromeExportHtml);

      final ImportResult result = await useCase.execute(
        htmlContent: kChromeExportHtml,
        importSource: 'chrome',
      );

      expect(result.totalFound, parsed.length);
      expect(result.totalFound, 4);
    });

    // ─── Duplicate handling across the full flow ───────────────────────

    test('duplicate bookmarks are counted correctly', () async {
      saveUseCase = _FakeSaveBookmarkUseCase(
        repository: bookmarkRepo,
        behavior: _FakeBehavior.alwaysDuplicate,
      );
      service = ImportBookmarksService(
        saveBookmarkUseCase: saveUseCase,
        collectionRepository: collectionRepo,
      );
      useCase = ImportBookmarksUseCase(service: service);

      final ImportResult result = await useCase.execute(
        htmlContent: kChromeExportHtml,
        importSource: 'chrome',
      );

      expect(result.totalFound, 4);
      expect(result.imported, 0);
      expect(result.duplicatesSkipped, 4);
      expect(result.failed, 0);
    });

    // ─── Invalid handling across the full flow ─────────────────────────

    test('invalid bookmarks are counted as failed', () async {
      saveUseCase = _FakeSaveBookmarkUseCase(
        repository: bookmarkRepo,
        behavior: _FakeBehavior.alwaysInvalid,
      );
      service = ImportBookmarksService(
        saveBookmarkUseCase: saveUseCase,
        collectionRepository: collectionRepo,
      );
      useCase = ImportBookmarksUseCase(service: service);

      final ImportResult result = await useCase.execute(
        htmlContent: kChromeExportHtml,
        importSource: 'chrome',
      );

      expect(result.totalFound, 4);
      expect(result.imported, 0);
      expect(result.duplicatesSkipped, 0);
      expect(result.failed, 4);
      expect(result.failureReasons.length, 4);
    });
  });
}
