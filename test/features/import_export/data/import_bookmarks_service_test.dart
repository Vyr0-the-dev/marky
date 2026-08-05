import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/models/save_bookmark_params.dart';
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/import_export/data/services/import_bookmarks_service.dart';
import 'package:marky/features/import_export/domain/models/import_result.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';

// ─── Fakes ─────────────────────────────────────────────────────────────

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
  Future<void> delete(Id id) async {
    _collections.remove(id);
  }

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
/// constructor but not used in these focused service tests).
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
    this.throwOnCall = false,
  });

  final _FakeBehavior behavior;
  final bool throwOnCall;

  final List<_SaveCall> calls = <_SaveCall>[];

  @override
  Future<SaveResult> execute(String rawUrl, {SaveBookmarkParams? params}) async {
    calls.add(_SaveCall(rawUrl: rawUrl, params: params));

    if (throwOnCall) {
      throw Exception('SaveBookmarkUseCase threw');
    }

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
      case _FakeBehavior.alternateSuccessDuplicate:
        // ignore: use_is_even_rather_than_modulo
        final bool isSuccess = _callCount++ % 2 == 0;
        if (isSuccess) {
          return SaveSuccess(_nextSuccessId++);
        }
        return SaveDuplicate(
          BookmarkItem(
            originalUrl: rawUrl,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    }
  }

  static int _nextSuccessId = 1000;
  static int _callCount = 0;

  static void resetCounters() {
    _nextSuccessId = 1000;
    _callCount = 0;
  }
}

enum _FakeBehavior {
  alwaysSuccess,
  alwaysDuplicate,
  alwaysInvalid,
  alternateSuccessDuplicate,
}

class _SaveCall {
  const _SaveCall({required this.rawUrl, this.params});

  final String rawUrl;
  final SaveBookmarkParams? params;
}

// ─── Test constants ────────────────────────────────────────────────────

const String _kChromeHtml = '''
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
    <DT><H3 ADD_DATE="1609459200">Bookmarks Bar</H3>
    <DL><p>
        <DT><A HREF="https://github.com" ADD_DATE="1609459201">GitHub</A>
        <DT><A HREF="https://stackoverflow.com" ADD_DATE="1609459202">Stack Overflow</A>
    </DL><p>
    <DT><H3 ADD_DATE="1609459200">Other Bookmarks</H3>
    <DL><p>
        <DT><A HREF="https://news.ycombinator.com" ADD_DATE="1609459203">Hacker News</A>
    </DL><p>
</DL><p>
''';

const String _kFlatHtml = '''
<DL><p>
    <DT><A HREF="https://a.com" ADD_DATE="1">A</A>
    <DT><A HREF="https://b.com" ADD_DATE="2">B</A>
</DL><p>
''';

const String _kNestedFolderHtml = '''
<DL><p>
    <DT><H3 ADD_DATE="1">Dev</H3>
    <DL><p>
        <DT><H3 ADD_DATE="2">Mobile</H3>
        <DL><p>
            <DT><A HREF="https://flutter.dev" ADD_DATE="3">Flutter</A>
        </DL><p>
    </DL><p>
</DL><p>
''';

void main() {
  group('ImportBookmarksService', () {
    late _FakeCollectionRepository collectionRepo;
    late _FakeBookmarkRepository bookmarkRepo;
    late _FakeSaveBookmarkUseCase saveUseCase;
    late ImportBookmarksService service;

    setUp(() {
      collectionRepo = _FakeCollectionRepository();
      bookmarkRepo = _FakeBookmarkRepository();
      _FakeSaveBookmarkUseCase.resetCounters();
      saveUseCase = _FakeSaveBookmarkUseCase(repository: bookmarkRepo);
      service = ImportBookmarksService(
        saveBookmarkUseCase: saveUseCase,
        collectionRepository: collectionRepo,
      );
    });

    // ─── Happy path ────────────────────────────────────────────────────

    test('imports all flat bookmarks without collections', () async {
      final ImportResult result = await service.importFromHtml(
        htmlContent: _kFlatHtml,
        importSource: 'test',
      );

      expect(result.totalFound, 2);
      expect(result.imported, 2);
      expect(result.duplicatesSkipped, 0);
      expect(result.failed, 0);
      expect(saveUseCase.calls.length, 2);
    });

    test('creates collections from top-level folders', () async {
      final ImportResult result = await service.importFromHtml(
        htmlContent: _kChromeHtml,
        importSource: 'chrome',
      );

      expect(result.totalFound, 3);
      expect(result.imported, 3);

      final List<BookmarkCollection> collections =
          await collectionRepo.getAll();
      expect(collections.length, 2);
      expect(collections.map((c) => c.title), contains('Bookmarks Bar'));
      expect(collections.map((c) => c.title), contains('Other Bookmarks'));
    });

    test('assigns correct collection to each bookmark', () async {
      await service.importFromHtml(
        htmlContent: _kChromeHtml,
        importSource: 'chrome',
      );

      final BookmarkCollection? bar =
          await collectionRepo.getBySlug('bookmarks-bar');
      final BookmarkCollection? other =
          await collectionRepo.getBySlug('other-bookmarks');

      expect(bar, isNotNull);
      expect(other, isNotNull);

      // First two bookmarks belong to Bookmarks Bar.
      expect(
        saveUseCase.calls[0].params?.collectionIds,
        <int>[bar!.id],
      );
      expect(
        saveUseCase.calls[1].params?.collectionIds,
        <int>[bar.id],
      );

      // Third bookmark belongs to Other Bookmarks.
      expect(
        saveUseCase.calls[2].params?.collectionIds,
        <int>[other!.id],
      );
    });

    test('passes sourceType and importSource to save use case', () async {
      await service.importFromHtml(
        htmlContent: _kFlatHtml,
        importSource: 'firefox',
      );

      for (final _SaveCall call in saveUseCase.calls) {
        expect(call.params?.sourceType, 'import');
        expect(call.params?.importSource, 'firefox');
      }
    });

    test('uses only top-level folder, ignoring nested ones', () async {
      await service.importFromHtml(
        htmlContent: _kNestedFolderHtml,
        importSource: 'chrome',
      );

      final List<BookmarkCollection> collections =
          await collectionRepo.getAll();
      expect(collections.length, 1);
      expect(collections.first.title, 'Dev');
      expect(collections.first.slug, 'dev');

      // Bookmark should be assigned to Dev, not Mobile.
      expect(
        saveUseCase.calls.first.params?.collectionIds,
        <int>[collections.first.id],
      );
    });

    test('reuses existing collection when slug matches', () async {
      // Pre-create a collection.
      final BookmarkCollection existing = BookmarkCollection(
        title: 'Bookmarks Bar',
        slug: 'bookmarks-bar',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await collectionRepo.insert(existing);

      await service.importFromHtml(
        htmlContent: _kChromeHtml,
        importSource: 'chrome',
      );

      final List<BookmarkCollection> collections =
          await collectionRepo.getAll();
      expect(collections.length, 2); // Existing + Other Bookmarks.

      // Should use the existing collection ID.
      expect(
        saveUseCase.calls[0].params?.collectionIds,
        <int>[existing.id],
      );
    });

    test('creates new collection with correct slug when none exists', () async {
      const String html = '''
<DL><p>
    <DT><H3 ADD_DATE="1">Dev</H3>
    <DL><p>
        <DT><A HREF="https://a.com" ADD_DATE="2">A</A>
    </DL><p>
</DL><p>
''';

      await service.importFromHtml(
        htmlContent: html,
        importSource: 'chrome',
      );

      final List<BookmarkCollection> collections =
          await collectionRepo.getAll();
      expect(collections.length, 1);
      expect(collections.first.title, 'Dev');
      expect(collections.first.slug, 'dev');
    });

    test('reuses existing collection with matching slug instead of creating new',
        () async {
      // Pre-create a collection.
      final BookmarkCollection existing = BookmarkCollection(
        title: 'Dev',
        slug: 'dev',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await collectionRepo.insert(existing);

      const String html = '''
<DL><p>
    <DT><H3 ADD_DATE="1">Dev</H3>
    <DL><p>
        <DT><A HREF="https://a.com" ADD_DATE="2">A</A>
    </DL><p>
</DL><p>
''';

      await service.importFromHtml(
        htmlContent: html,
        importSource: 'chrome',
      );

      final List<BookmarkCollection> collections =
          await collectionRepo.getAll();
      expect(collections.length, 1);
      expect(collections.first.id, existing.id);
      expect(collections.first.slug, 'dev');
    });

    test('reports progress via onProgress callback', () async {
      final List<(int, int)> progressEvents = <(int, int)>[];

      await service.importFromHtml(
        htmlContent: _kChromeHtml,
        importSource: 'chrome',
        onProgress: (int current, int total) {
          progressEvents.add((current, total));
        },
      );

      expect(progressEvents.length, 3);
      expect(progressEvents[0], (1, 3));
      expect(progressEvents[1], (2, 3));
      expect(progressEvents[2], (3, 3));
    });

    // ─── Empty / malformed input ───────────────────────────────────────

    test('returns zero counts for empty HTML', () async {
      final ImportResult result = await service.importFromHtml(
        htmlContent: '',
        importSource: 'test',
      );

      expect(result.totalFound, 0);
      expect(result.imported, 0);
      expect(result.duplicatesSkipped, 0);
      expect(result.failed, 0);
      expect(saveUseCase.calls, isEmpty);
    });

    test('returns zero counts for HTML with no bookmarks', () async {
      const String html = '<html><body><h1>No bookmarks</h1></body></html>';
      final ImportResult result = await service.importFromHtml(
        htmlContent: html,
        importSource: 'test',
      );

      expect(result.totalFound, 0);
      expect(result.elapsed, isNotNull);
    });

    // ─── Duplicate handling ────────────────────────────────────────────

    test('counts duplicates correctly', () async {
      saveUseCase = _FakeSaveBookmarkUseCase(
        repository: bookmarkRepo,
        behavior: _FakeBehavior.alwaysDuplicate,
      );
      service = ImportBookmarksService(
        saveBookmarkUseCase: saveUseCase,
        collectionRepository: collectionRepo,
      );

      final ImportResult result = await service.importFromHtml(
        htmlContent: _kFlatHtml,
        importSource: 'test',
      );

      expect(result.totalFound, 2);
      expect(result.imported, 0);
      expect(result.duplicatesSkipped, 2);
      expect(result.failed, 0);
    });

    // ─── Invalid handling ──────────────────────────────────────────────

    test('counts invalid saves correctly', () async {
      saveUseCase = _FakeSaveBookmarkUseCase(
        repository: bookmarkRepo,
        behavior: _FakeBehavior.alwaysInvalid,
      );
      service = ImportBookmarksService(
        saveBookmarkUseCase: saveUseCase,
        collectionRepository: collectionRepo,
      );

      final ImportResult result = await service.importFromHtml(
        htmlContent: _kFlatHtml,
        importSource: 'test',
      );

      expect(result.totalFound, 2);
      expect(result.imported, 0);
      expect(result.duplicatesSkipped, 0);
      expect(result.failed, 2);
      expect(result.failureReasons.length, 2);
    });

    // ─── Mixed outcomes ────────────────────────────────────────────────

    test('mixed success and duplicate counts sum to total', () async {
      saveUseCase = _FakeSaveBookmarkUseCase(
        repository: bookmarkRepo,
        behavior: _FakeBehavior.alternateSuccessDuplicate,
      );
      service = ImportBookmarksService(
        saveBookmarkUseCase: saveUseCase,
        collectionRepository: collectionRepo,
      );

      final ImportResult result = await service.importFromHtml(
        htmlContent: _kFlatHtml,
        importSource: 'test',
      );

      expect(result.totalFound, 2);
      expect(result.imported + result.duplicatesSkipped + result.failed, 2);
    });

    // ─── Error paths ───────────────────────────────────────────────────

    test('counts as failed when SaveBookmarkUseCase throws', () async {
      saveUseCase = _FakeSaveBookmarkUseCase(
        repository: bookmarkRepo,
        throwOnCall: true,
      );
      service = ImportBookmarksService(
        saveBookmarkUseCase: saveUseCase,
        collectionRepository: collectionRepo,
      );

      final ImportResult result = await service.importFromHtml(
        htmlContent: _kFlatHtml,
        importSource: 'test',
      );

      expect(result.totalFound, 2);
      expect(result.imported, 0);
      expect(result.duplicatesSkipped, 0);
      expect(result.failed, 2);
      expect(result.failureReasons.length, 2);
    });

    test('counts as failed when CollectionRepository throws', () async {
      final _ThrowingCollectionRepository throwingRepo =
          _ThrowingCollectionRepository();
      service = ImportBookmarksService(
        saveBookmarkUseCase: saveUseCase,
        collectionRepository: throwingRepo,
      );

      const String html = '''
<DL><p>
    <DT><H3 ADD_DATE="1">Dev</H3>
    <DL><p>
        <DT><A HREF="https://a.com" ADD_DATE="2">A</A>
    </DL><p>
</DL><p>
''';

      final ImportResult result = await service.importFromHtml(
        htmlContent: html,
        importSource: 'test',
      );

      expect(result.totalFound, 1);
      expect(result.imported, 0);
      expect(result.duplicatesSkipped, 0);
      expect(result.failed, 1);
      expect(result.failureReasons.length, 1);
    });

    // ─── Boundary: bookmarks without folders ───────────────────────────

    test('bookmarks outside folders get no collectionIds', () async {
      const String html = '''
<DL><p>
    <DT><A HREF="https://root.com" ADD_DATE="1">Root</A>
</DL><p>
''';

      await service.importFromHtml(
        htmlContent: html,
        importSource: 'test',
      );

      expect(saveUseCase.calls.length, 1);
      expect(saveUseCase.calls.first.params?.collectionIds, isNull);
    });

    // ─── Elapsed time ──────────────────────────────────────────────────

    test('elapsed duration is non-negative', () async {
      final ImportResult result = await service.importFromHtml(
        htmlContent: _kFlatHtml,
        importSource: 'test',
      );

      expect(result.elapsed, isNotNull);
      expect(result.elapsed.inMilliseconds, greaterThanOrEqualTo(0));
    });
  });
}

/// A [CollectionRepository] that always throws on [getBySlug].
class _ThrowingCollectionRepository implements CollectionRepository {
  @override
  Future<BookmarkCollection?> getBySlug(String slug) async {
    throw Exception('DB error');
  }

  @override
  Future<BookmarkCollection?> getById(Id id) async => null;

  @override
  Future<List<BookmarkCollection>> getAll() async => [];

  @override
  Future<Id> insert(BookmarkCollection entity) async {
    throw Exception('DB error');
  }

  @override
  Future<Id> update(BookmarkCollection entity) async {
    throw Exception('DB error');
  }

  @override
  Future<void> delete(Id id) async {
    throw Exception('DB error');
  }

  @override
  Future<void> clear() async {
    throw Exception('DB error');
  }
}
