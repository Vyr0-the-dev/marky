import 'dart:async';

import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';

/// Cooperative cancellation token for [BulkMetadataRefetchService.runBatch].
class BulkRefetchCancellationToken {
  bool _isCancelled = false;
  final List<void Function()> _listeners = <void Function()>[];

  bool get isCancelled => _isCancelled;

  void addListener(void Function() listener) {
    if (_isCancelled) {
      listener();
      return;
    }
    _listeners.add(listener);
  }

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final void Function() listener in List<void Function()>.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }
}

/// Live progress snapshot emitted during a bulk metadata refetch.
class BulkRefetchProgress {
  const BulkRefetchProgress({
    required this.total,
    required this.processed,
    required this.succeeded,
    required this.failed,
    this.currentHost,
  });

  final int total;
  final int processed;
  final int succeeded;
  final int failed;
  final String? currentHost;

  double get fraction => total <= 0 ? 1.0 : (processed / total).clamp(0.0, 1.0);
}

/// Final summary returned by [BulkMetadataRefetchService.runBatch].
class BulkRefetchResult {
  const BulkRefetchResult({
    required this.total,
    required this.processed,
    required this.succeeded,
    required this.failed,
    required this.cancelled,
  });

  final int total;
  final int processed;
  final int succeeded;
  final int failed;
  final bool cancelled;
}

/// Discovers bookmarks with incomplete metadata and refetches them in bounded,
/// cancellable, host-polite waves without overwriting user-edited fields.
class BulkMetadataRefetchService {
  BulkMetadataRefetchService({
    required BookmarkRepository bookmarkRepository,
    required ScrapingOrchestrator scrapingOrchestrator,
  })  : _bookmarkRepo = bookmarkRepository,
        _orchestrator = scrapingOrchestrator;

  static const int defaultConcurrency = 3;
  static const Duration defaultSameHostSpacing = Duration(milliseconds: 600);
  static const int _scanPageSize = 500;

  final BookmarkRepository _bookmarkRepo;
  final ScrapingOrchestrator _orchestrator;

  /// Returns `true` when [title] is blank or still holds a raw `http(s)://` URL.
  static bool isRawUrlTitle(String? title) {
    final String? trimmed = title?.trim();
    if (trimmed == null || trimmed.isEmpty) return true;
    final String lower = trimmed.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  /// Returns `true` when [bookmark] is missing key metadata (unfinished scrape,
  /// raw URL title, or missing both a distinct hero cover and a description).
  static bool needsMetadataEnrichment(Bookmark bookmark) {
    if (bookmark.scrapingStatus != BookmarkScrapingStatus.done) {
      return true;
    }
    if (isRawUrlTitle(bookmark.title)) {
      return true;
    }
    final String? hero = bookmark.heroImageUrl?.trim();
    final String? favicon = bookmark.faviconUrl?.trim();
    final bool hasRealHero =
        hero != null && hero.isNotEmpty && hero != favicon;
    final bool hasDescription =
        (bookmark.description?.trim().isNotEmpty ?? false) ||
            (bookmark.snippet?.trim().isNotEmpty ?? false);
    return !hasRealHero && !hasDescription;
  }

  /// Paginates through all active (non-archived) bookmarks and collects IDs
  /// that match [needsMetadataEnrichment].
  Future<List<int>> findIncompleteBookmarkIds() async {
    final List<int> ids = <int>[];
    int offset = 0;
    while (true) {
      final List<Bookmark> page = await _bookmarkRepo.feed(
        BookmarkFeedQuery(
          limit: _scanPageSize,
          offset: offset,
        ),
      );
      if (page.isEmpty) break;
      for (final Bookmark bookmark in page) {
        final int? id = bookmark.id;
        if (id != null && needsMetadataEnrichment(bookmark)) {
          ids.add(id);
        }
      }
      if (page.length < _scanPageSize) break;
      offset += page.length;
    }
    return ids;
  }

  /// Refetches metadata for [bookmarkIds] using bounded worker concurrency and
  /// per-host spacing to avoid triggering rate-limits (HTTP 429).
  Future<BulkRefetchResult> runBatch({
    required List<int> bookmarkIds,
    BulkRefetchCancellationToken? cancelToken,
    void Function(BulkRefetchProgress progress)? onProgress,
    int concurrency = defaultConcurrency,
    Duration sameHostSpacing = defaultSameHostSpacing,
  }) async {
    final List<int> uniqueIds = bookmarkIds.toSet().toList(growable: false);
    final int total = uniqueIds.length;
    if (total == 0) {
      return const BulkRefetchResult(
        total: 0,
        processed: 0,
        succeeded: 0,
        failed: 0,
        cancelled: false,
      );
    }

    int cursor = 0;
    int processed = 0;
    int succeeded = 0;
    int failed = 0;
    final Set<int> inFlightIds = <int>{};
    final Map<String, DateTime> lastHostRequestAt = <String, DateTime>{};

    cancelToken?.addListener(() {
      for (final int activeId in List<int>.of(inFlightIds)) {
        _orchestrator.cancel(activeId);
      }
    });

    Future<void> waitForHostSlot(String host) async {
      if (host.isEmpty || sameHostSpacing <= Duration.zero) return;
      final DateTime now = DateTime.now();
      final DateTime? previous = lastHostRequestAt[host];
      if (previous != null) {
        final DateTime earliest = previous.add(sameHostSpacing);
        if (earliest.isAfter(now)) {
          lastHostRequestAt[host] = earliest;
          await Future<void>.delayed(earliest.difference(now));
          return;
        }
      }
      lastHostRequestAt[host] = now;
    }

    Future<void> worker() async {
      while (true) {
        if (cancelToken?.isCancelled ?? false) return;
        if (cursor >= total) return;
        final int id = uniqueIds[cursor++];

        final Bookmark? before = await _bookmarkRepo.getById(id);
        if (before == null) {
          processed++;
          failed++;
          onProgress?.call(
            BulkRefetchProgress(
              total: total,
              processed: processed,
              succeeded: succeeded,
              failed: failed,
            ),
          );
          continue;
        }

        final String host = before.normalizedHost ?? '';
        await waitForHostSlot(host);
        if (cancelToken?.isCancelled ?? false) return;

        inFlightIds.add(id);
        try {
          await _orchestrator.enrich(id);
        } on Object {
          // Best-effort; individual failures must not halt the batch.
        } finally {
          inFlightIds.remove(id);
        }

        if (cancelToken?.isCancelled ?? false) return;

        final Bookmark? after = await _bookmarkRepo.getById(id);
        final bool improved = after != null && _wasEnriched(before, after);
        processed++;
        if (improved) {
          succeeded++;
        } else {
          failed++;
        }
        onProgress?.call(
          BulkRefetchProgress(
            total: total,
            processed: processed,
            succeeded: succeeded,
            failed: failed,
            currentHost: host.isNotEmpty ? host : null,
          ),
        );
      }
    }

    final int effectiveWorkers =
        concurrency < 1 ? 1 : (concurrency > total ? total : concurrency);
    await Future.wait<void>(
      List<Future<void>>.generate(effectiveWorkers, (_) => worker()),
    );

    return BulkRefetchResult(
      total: total,
      processed: processed,
      succeeded: succeeded,
      failed: failed,
      cancelled: cancelToken?.isCancelled ?? false,
    );
  }

  static bool _wasEnriched(Bookmark before, Bookmark after) {
    if (after.scrapingStatus == BookmarkScrapingStatus.done) {
      return true;
    }
    return after.title != before.title ||
        after.description != before.description ||
        after.heroImageUrl != before.heroImageUrl ||
        after.faviconUrl != before.faviconUrl ||
        after.readingTimeMinutes != before.readingTimeMinutes;
  }
}
