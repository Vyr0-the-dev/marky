import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/library/domain/broken_link_checker_service.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen allowing users to audit their entire active bookmark library for
/// broken / 404 links with bounded concurrency and 1-tap Wayback Machine recovery.
class BrokenLinksScreen extends ConsumerStatefulWidget {
  const BrokenLinksScreen({super.key});

  @override
  ConsumerState<BrokenLinksScreen> createState() => _BrokenLinksScreenState();
}

class _BrokenLinksScreenState extends ConsumerState<BrokenLinksScreen> {
  static const int _pageSize = 500;
  static const int _maxConcurrency = 6;

  bool _isScanning = false;
  bool _hasScanned = false;
  int _scannedCount = 0;
  int _totalCount = 0;
  final List<BrokenLinkReport> _brokenLinks = <BrokenLinkReport>[];
  bool _cancelled = false;

  Future<List<Bookmark>> _loadAllActiveBookmarks(
    BookmarkRepository repo,
  ) async {
    final List<Bookmark> all = <Bookmark>[];
    int offset = 0;
    while (true) {
      final List<Bookmark> page = await repo.feed(
        BookmarkFeedQuery(limit: _pageSize, offset: offset),
      );
      all.addAll(page);
      if (page.length < _pageSize) break;
      offset += _pageSize;
    }
    return all;
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _hasScanned = true;
      _scannedCount = 0;
      _totalCount = 0;
      _brokenLinks.clear();
      _cancelled = false;
    });

    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    final BrokenLinkCheckerService checker =
        ref.read(brokenLinkCheckerServiceProvider);

    final List<Bookmark> bookmarks = await _loadAllActiveBookmarks(repo);
    if (!mounted) return;
    setState(() {
      _totalCount = bookmarks.length;
    });

    if (bookmarks.isNotEmpty) {
      int nextIndex = 0;
      final int workerCount = math.min(_maxConcurrency, bookmarks.length);

      Future<void> runWorker() async {
        while (!_cancelled && mounted) {
          final int index = nextIndex;
          if (index >= bookmarks.length) break;
          nextIndex++;

          final BrokenLinkReport? report =
              await checker.checkBookmark(bookmarks[index]);
          if (!mounted) break;

          setState(() {
            _scannedCount++;
            if (report != null) {
              _brokenLinks.add(report);
            }
          });
        }
      }

      await Future.wait<void>(
        List<Future<void>>.generate(workerCount, (_) => runWorker()),
      );
    }

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _stopScan() {
    setState(() {
      _cancelled = true;
      _isScanning = false;
    });
  }

  Future<void> _archiveAll() async {
    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    final int archivedCount = _brokenLinks.length;
    final List<Bookmark> updated = _brokenLinks
        .map((BrokenLinkReport r) => r.bookmark.copyWith(isArchived: true))
        .toList(growable: false);
    await repo.saveAll(updated);
    if (!mounted) return;
    final AppLocalizations? l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n?.brokenLinksArchivedCount(archivedCount) ??
                'Archived $archivedCount broken links.',
          ),
        ),
      );
    setState(_brokenLinks.clear);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.brokenLinksTitle ?? 'Broken Link Checker',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.lg,
          vertical: ReadingRoomSpacing.md,
        ),
        children: <Widget>[
          _buildHeroCard(theme, colors, l10n),
          const SizedBox(height: ReadingRoomSpacing.lg),
          if (_isScanning) ...<Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: _totalCount > 0 ? _scannedCount / _totalCount : null,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),
            Row(
              children: <Widget>[
                Text(
                  l10n?.brokenLinksScanning(_scannedCount, _totalCount) ??
                      'Scanning $_scannedCount / $_totalCount...',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _stopScan,
                  child: Text(l10n?.brokenLinksStopScan ?? 'Stop'),
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
          ],
          if (_hasScanned &&
              !_isScanning &&
              _brokenLinks.isNotEmpty) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${_brokenLinks.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.archive_outlined, size: 16),
                  label: Text(
                    l10n?.brokenLinksArchiveAll(_brokenLinks.length) ??
                        'Archive all (${_brokenLinks.length})',
                  ),
                  onPressed: _archiveAll,
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
          ],
          if (_hasScanned && !_isScanning && _brokenLinks.isEmpty) ...<Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: ReadingRoomSpacing.xxl,
                ),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 56,
                      color: Colors.green,
                    ),
                    const SizedBox(height: ReadingRoomSpacing.md),
                    Text(
                      l10n?.brokenLinksAllHealthy ?? 'All links look healthy!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...<Widget>[
            for (final BrokenLinkReport report in _brokenLinks)
              _BrokenLinkTile(
                report: report,
                onDeleted: () {
                  setState(() {
                    _brokenLinks.remove(report);
                  });
                },
                onArchived: () {
                  setState(() {
                    _brokenLinks.remove(report);
                  });
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    ThemeData theme,
    ColorScheme colors,
    AppLocalizations? l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.health_and_safety_outlined, color: colors.primary),
              const SizedBox(width: ReadingRoomSpacing.sm),
              Expanded(
                child: Text(
                  l10n?.brokenLinksTitle ?? 'Broken Link Checker',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ReadingRoomSpacing.sm),
          Text(
            l10n?.brokenLinksSubtitle ??
                'Audit and clean up 404/dead links',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          if (!_isScanning)
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(l10n?.brokenLinksStartScan ?? 'Start scan'),
              onPressed: _startScan,
            ),
        ],
      ),
    );
  }
}

class _BrokenLinkTile extends ConsumerWidget {
  const _BrokenLinkTile({
    required this.report,
    required this.onDeleted,
    required this.onArchived,
  });

  final BrokenLinkReport report;
  final VoidCallback onDeleted;
  final VoidCallback onArchived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final Bookmark bookmark = report.bookmark;
    final String targetUrl = bookmark.canonicalUrl ?? bookmark.originalUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(ReadingRoomSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          border: Border.all(
            color: colors.error.withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: bookmark.id == null
                  ? null
                  : () => context.push(Routes.bookmarkDetailPath(bookmark.id!)),
              borderRadius: BorderRadius.circular(6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          bookmark.displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          targetUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: ReadingRoomSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(ReadingRoomRadii.chip),
                      border: Border.all(
                        color: colors.error.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      report.reason.localizedLabel(l10n),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),
            Wrap(
              spacing: ReadingRoomSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.history_rounded, size: 15),
                  label: Text(
                    l10n?.brokenLinksOpenWayback ?? 'Wayback Machine',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onPressed: () {
                    final Uri? waybackUri = Uri.tryParse(
                      BrokenLinkCheckerService.waybackUrlFor(targetUrl),
                    );
                    if (waybackUri != null) {
                      unawaited(
                        launchUrl(
                          waybackUri,
                          mode: LaunchMode.externalApplication,
                        ),
                      );
                    }
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_browser_rounded, size: 14),
                  label: Text(
                    l10n?.actionOpen ?? 'Open',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onPressed: () {
                    final Uri? uri = Uri.tryParse(targetUrl);
                    if (uri != null) {
                      unawaited(
                        launchUrl(uri, mode: LaunchMode.externalApplication),
                      );
                    }
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.archive_outlined, size: 14),
                  label: Text(
                    l10n?.actionArchive ?? 'Archive',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onPressed: () async {
                    unawaited(HapticFeedback.lightImpact());
                    await ref
                        .read(bookmarkRepositoryProvider)
                        .save(bookmark.copyWith(isArchived: true));
                    onArchived();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: colors.error,
                  ),
                  tooltip: l10n?.actionDelete ?? 'Delete',
                  onPressed: () async {
                    unawaited(HapticFeedback.mediumImpact());
                    if (bookmark.id != null) {
                      await ref
                          .read(bookmarkRepositoryProvider)
                          .delete(bookmark.id!);
                    }
                    onDeleted();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
