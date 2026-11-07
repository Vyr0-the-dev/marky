import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/library/domain/broken_link_checker_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen allowing users to audit their bookmark library for broken / 404 links.
class BrokenLinksScreen extends ConsumerStatefulWidget {
  const BrokenLinksScreen({super.key});

  @override
  ConsumerState<BrokenLinksScreen> createState() => _BrokenLinksScreenState();
}

class _BrokenLinksScreenState extends ConsumerState<BrokenLinksScreen> {
  bool _isScanning = false;
  bool _hasScanned = false;
  int _scannedCount = 0;
  int _totalCount = 0;
  final List<BrokenLinkReport> _brokenLinks = <BrokenLinkReport>[];
  bool _cancelled = false;

  bool get _isTurkish {
    return Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('tr');
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _hasScanned = true;
      _scannedCount = 0;
      _brokenLinks.clear();
      _cancelled = false;
    });

    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    final BrokenLinkCheckerService checker =
        ref.read(brokenLinkCheckerServiceProvider);

    // Fetch all active (non-archived) bookmarks
    final List<Bookmark> bookmarks = await repo
        .watchFeed(const BookmarkFeedQuery())
        .first;

    if (!mounted) return;
    setState(() {
      _totalCount = bookmarks.length;
    });

    for (final Bookmark bookmark in bookmarks) {
      if (_cancelled || !mounted) break;

      final BrokenLinkReport? report = await checker.checkBookmark(bookmark);
      if (!mounted) break;

      setState(() {
        _scannedCount++;
        if (report != null) {
          _brokenLinks.add(report);
        }
      });
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
    for (final BrokenLinkReport report in _brokenLinks) {
      await repo.save(report.bookmark.copyWith(isArchived: true));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isTurkish
              ? '${_brokenLinks.length} kırık bağlantı arşivlendi.'
              : 'Archived ${_brokenLinks.length} broken links.',
        ),
      ),
    );
    setState(_brokenLinks.clear);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isTurkish ? 'Bağlantı Sağlık Kontrolü' : 'Broken Link Checker',
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
          // ── Status banner ──────────────────────────────────
          _buildHeroCard(theme, colors),

          const SizedBox(height: ReadingRoomSpacing.lg),

          // ── Progress indicator during scan ──────────────────
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
                  _isTurkish
                      ? '$_scannedCount / $_totalCount taranıyor...'
                      : 'Scanning $_scannedCount of $_totalCount...',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _stopScan,
                  child: Text(_isTurkish ? 'Durdur' : 'Stop'),
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
          ],

          // ── Action bar if broken links exist ───────────────
          if (_hasScanned && !_isScanning && _brokenLinks.isNotEmpty) ...<Widget>[
            Row(
              children: <Widget>[
                Text(
                  _isTurkish
                      ? '${_brokenLinks.length} Kırık Bağlantı'
                      : '${_brokenLinks.length} Broken Links',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.archive_outlined, size: 16),
                  label: Text(_isTurkish ? 'Tümünü Arşivle' : 'Archive All'),
                  onPressed: _archiveAll,
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
          ],

          // ── Results list ────────────────────────────────────
          if (_hasScanned && !_isScanning && _brokenLinks.isEmpty) ...<Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: ReadingRoomSpacing.xxl),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 56,
                      color: Colors.green,
                    ),
                    const SizedBox(height: ReadingRoomSpacing.md),
                    Text(
                      _isTurkish
                          ? 'Tüm bağlantılar sağlıklı!'
                          : 'All links are healthy!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ReadingRoomSpacing.xs),
                    Text(
                      _isTurkish
                          ? 'Kütüphanenizde kırık veya 404 veren bağlantı bulunamadı.'
                          : 'No dead or 404 links were found in your library.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
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
                isTurkish: _isTurkish,
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

  Widget _buildHeroCard(ThemeData theme, ColorScheme colors) {
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
                  _isTurkish
                      ? 'Kütüphane Sağlık Denetimi'
                      : 'Library Health Audit',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ReadingRoomSpacing.sm),
          Text(
            _isTurkish
              ? 'Web siteleri zamanla silinebilir veya adresleri değişebilir. Bu araç kütüphanenizdeki bağlantıları hafif sorgularla kontrol ederek artık açılmayan (404, 410, DNS) linkleri listeler.'
              : 'Web links can rot or disappear over time. This tool checks your bookmarks with lightweight requests to uncover dead links (404, 410, DNS errors).',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          if (!_isScanning)
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(
                _hasScanned
                    ? (_isTurkish ? 'Yeniden Tara' : 'Scan Again')
                    : (_isTurkish ? 'Taramayı Başlat' : 'Start Scan'),
              ),
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
    required this.isTurkish,
    required this.onDeleted,
    required this.onArchived,
  });

  final BrokenLinkReport report;
  final bool isTurkish;
  final VoidCallback onDeleted;
  final VoidCallback onArchived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Bookmark bookmark = report.bookmark;

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
            Row(
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
                        bookmark.originalUrl,
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
                    report.reason.getDisplayLabel(isTurkish: isTurkish),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),
            Row(
              children: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.open_in_browser_rounded, size: 14),
                  label: Text(
                    isTurkish ? 'Aç' : 'Open',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onPressed: () => unawaited(
                    launchUrl(
                      Uri.parse(bookmark.originalUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.archive_outlined, size: 14),
                  label: Text(
                    isTurkish ? 'Arşivle' : 'Archive',
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
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: colors.error,
                  ),
                  tooltip: isTurkish ? 'Sil' : 'Delete',
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
