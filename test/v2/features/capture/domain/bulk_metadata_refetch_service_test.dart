import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/domain/bulk_metadata_refetch_service.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';

void main() {
  final DateTime now = DateTime(2026, 11, 22);

  Bookmark makeBookmark({
    required int id,
    String? title = 'Example Article',
    String? description = 'Summary text',
    String? heroImageUrl = 'https://example.com/hero.jpg',
    String? faviconUrl = 'https://example.com/favicon.ico',
    String host = 'example.com',
    BookmarkScrapingStatus status = BookmarkScrapingStatus.done,
  }) {
    return Bookmark(
      id: id,
      originalUrl: 'https://$host/post/$id',
      normalizedHost: host,
      title: title,
      description: description,
      heroImageUrl: heroImageUrl,
      faviconUrl: faviconUrl,
      scrapingStatus: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('BulkMetadataRefetchService.needsMetadataEnrichment', () {
    test('returns false for complete bookmark with real title and hero', () {
      expect(
        BulkMetadataRefetchService.needsMetadataEnrichment(
          makeBookmark(id: 1),
        ),
        isFalse,
      );
    });

    test('returns true when scrapingStatus is pending or failed', () {
      expect(
        BulkMetadataRefetchService.needsMetadataEnrichment(
          makeBookmark(id: 1, status: BookmarkScrapingStatus.pending),
        ),
        isTrue,
      );
      expect(
        BulkMetadataRefetchService.needsMetadataEnrichment(
          makeBookmark(id: 2, status: BookmarkScrapingStatus.failed),
        ),
        isTrue,
      );
    });

    test('returns true when title is still a raw URL', () {
      expect(
        BulkMetadataRefetchService.needsMetadataEnrichment(
          makeBookmark(
            id: 3,
            title: 'https://tr.wikipedia.org/wiki/Yapay_zek%C3%A2',
          ),
        ),
        isTrue,
      );
    });

    test('returns true when both real hero and description are missing', () {
      expect(
        BulkMetadataRefetchService.needsMetadataEnrichment(
          makeBookmark(
            id: 4,
            description: null,
            heroImageUrl: 'https://example.com/favicon.ico',
          ),
        ),
        isTrue,
      );
    });
  });

  group('BulkMetadataRefetchService batch execution', () {
    test(
        'findIncompleteBookmarkIds paginates and filters only incomplete items',
        () async {
      final _InMemoryBookmarkRepo repo = _InMemoryBookmarkRepo(<Bookmark>[
        makeBookmark(id: 1),
        makeBookmark(id: 2, status: BookmarkScrapingStatus.pending),
        makeBookmark(id: 3, title: 'https://example.com/raw'),
        makeBookmark(id: 4, description: null, heroImageUrl: null),
      ]);
      final _FakeOrchestrator orchestrator = _FakeOrchestrator(repo);
      final BulkMetadataRefetchService service = BulkMetadataRefetchService(
        bookmarkRepository: repo,
        scrapingOrchestrator: orchestrator,
      );

      final List<int> ids = await service.findIncompleteBookmarkIds();
      expect(ids, <int>[2, 3, 4]);
    });

    test('runBatch reports progress and tallies succeeded vs failed', () async {
      final _InMemoryBookmarkRepo repo = _InMemoryBookmarkRepo(<Bookmark>[
        makeBookmark(
          id: 10,
          host: 'a.com',
          status: BookmarkScrapingStatus.pending,
        ),
        makeBookmark(
          id: 11,
          host: 'b.com',
          status: BookmarkScrapingStatus.pending,
        ),
        makeBookmark(
          id: 12,
          host: 'c.com',
          status: BookmarkScrapingStatus.pending,
        ),
      ]);
      final _FakeOrchestrator orchestrator = _FakeOrchestrator(
        repo,
        failIds: <int>{11},
      );
      final BulkMetadataRefetchService service = BulkMetadataRefetchService(
        bookmarkRepository: repo,
        scrapingOrchestrator: orchestrator,
      );

      final List<BulkRefetchProgress> snapshots = <BulkRefetchProgress>[];
      final BulkRefetchResult result = await service.runBatch(
        bookmarkIds: <int>[10, 11, 12],
        sameHostSpacing: Duration.zero,
        onProgress: snapshots.add,
      );

      expect(result.total, 3);
      expect(result.processed, 3);
      expect(result.succeeded, 2);
      expect(result.failed, 1);
      expect(result.cancelled, isFalse);
      expect(snapshots.length, 3);
      expect(snapshots.last.fraction, 1.0);
    });

    test('runBatch stops promptly and cancels active work on cancellation',
        () async {
      final _InMemoryBookmarkRepo repo = _InMemoryBookmarkRepo(<Bookmark>[
        makeBookmark(
          id: 20,
          host: 'a.com',
          status: BookmarkScrapingStatus.pending,
        ),
        makeBookmark(
          id: 21,
          host: 'b.com',
          status: BookmarkScrapingStatus.pending,
        ),
        makeBookmark(
          id: 22,
          host: 'c.com',
          status: BookmarkScrapingStatus.pending,
        ),
      ]);
      final Completer<void> blocker = Completer<void>();
      final _FakeOrchestrator orchestrator = _FakeOrchestrator(
        repo,
        blockOnId: 20,
        blocker: blocker,
      );
      final BulkMetadataRefetchService service = BulkMetadataRefetchService(
        bookmarkRepository: repo,
        scrapingOrchestrator: orchestrator,
      );
      final BulkRefetchCancellationToken token = BulkRefetchCancellationToken();

      final Future<BulkRefetchResult> future = service.runBatch(
        bookmarkIds: <int>[20, 21, 22],
        cancelToken: token,
        concurrency: 1,
        sameHostSpacing: Duration.zero,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      token.cancel();
      blocker.complete();

      final BulkRefetchResult result = await future;
      expect(result.cancelled, isTrue);
      expect(result.processed, 0);
      expect(orchestrator.cancelledIds, contains(20));
      expect(orchestrator.enrichedIds, <int>[20]);
    });
  });
}

class _FakeOrchestrator implements ScrapingOrchestrator {
  _FakeOrchestrator(
    this._repo, {
    this.failIds = const <int>{},
    this.blockOnId,
    this.blocker,
  });

  final _InMemoryBookmarkRepo _repo;
  final Set<int> failIds;
  final int? blockOnId;
  final Completer<void>? blocker;
  final List<int> enrichedIds = <int>[];
  final List<int> cancelledIds = <int>[];

  @override
  Future<void> enrich(int bookmarkId) async {
    enrichedIds.add(bookmarkId);
    if (bookmarkId == blockOnId && blocker != null) {
      await blocker!.future;
      return;
    }
    final Bookmark? current = await _repo.getById(bookmarkId);
    if (current == null) return;
    if (failIds.contains(bookmarkId)) {
      await _repo.save(
        current.copyWith(scrapingStatus: BookmarkScrapingStatus.failed),
      );
      return;
    }
    await _repo.save(
      current.copyWith(
        title: 'Enriched #$bookmarkId',
        description: 'Fresh summary',
        scrapingStatus: BookmarkScrapingStatus.done,
      ),
    );
  }

  @override
  void cancel(int bookmarkId) {
    cancelledIds.add(bookmarkId);
  }

  @override
  Future<void> enrichIncomplete({int limit = 3}) async {}
}

class _InMemoryBookmarkRepo implements BookmarkRepository {
  _InMemoryBookmarkRepo(List<Bookmark> initial) {
    for (final Bookmark b in initial) {
      if (b.id != null) {
        _store[b.id!] = b;
      }
    }
  }

  final Map<int, Bookmark> _store = <int, Bookmark>{};

  @override
  Future<Bookmark> save(Bookmark bookmark) async {
    if (bookmark.id != null) {
      _store[bookmark.id!] = bookmark;
    }
    return bookmark;
  }

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) async {
    for (final Bookmark b in bookmarks) {
      await save(b);
    }
    return bookmarks;
  }

  @override
  Future<Bookmark?> getById(int id) async => _store[id];

  @override
  Future<List<Bookmark>> getByIds(List<int> ids) async =>
      ids.map((int id) => _store[id]).whereType<Bookmark>().toList();

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async {
    return _store.values
        .skip(query.offset)
        .take(query.limit)
        .toList(growable: false);
  }

  @override
  Future<bool> delete(int id) async => _store.remove(id) != null;

  @override
  Future<int> deleteAll(List<int> ids) async {
    int count = 0;
    for (final int id in ids) {
      if (_store.remove(id) != null) count++;
    }
    return count;
  }

  @override
  Future<Bookmark?> findByUrlHash(String urlHash) async => null;

  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) async =>
      null;

  @override
  Future<int> countAll() async => _store.length;

  @override
  Future<int> count(BookmarkFeedQuery query) async => _store.length;

  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      Stream<List<Bookmark>>.value(_store.values.toList(growable: false));

  @override
  Stream<Bookmark?> watchById(int id) => Stream<Bookmark?>.value(_store[id]);

  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async =>
      <Bookmark>[];
}
