import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Modal bottom sheet displaying clean metadata, metrics, and links for [bookmark].
class BookmarkInfoSheet extends StatelessWidget {
  const BookmarkInfoSheet({
    required this.bookmark,
    super.key,
  });

  final Bookmark bookmark;

  static Future<void> show(BuildContext context, Bookmark bookmark) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (BuildContext ctx) => BookmarkInfoSheet(bookmark: bookmark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final Color surfaceColor = theme.colorScheme.surface;
    final Color outlineColor = theme.colorScheme.outline;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ReadingRoomRadii.sheet),
        ),
        border: Border(
          top: BorderSide(color: outlineColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ReadingRoomSpacing.lg,
            vertical: ReadingRoomSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── Handle bar ──────────────────────────────────
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    l10n?.detailMetadataTitle ?? 'Meta Veri ve Ayrıntılar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: ReadingRoomSpacing.md),

              // ── Quick Stat Chips ────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _buildStatChip(
                      context,
                      icon: Icons.visibility_outlined,
                      label: l10n?.detailOpenedTimes(bookmark.openCount) ??
                          '${bookmark.openCount} görüntülenme',
                    ),
                    const SizedBox(width: ReadingRoomSpacing.sm),
                    _buildStatChip(
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: _formatDate(bookmark.createdAt),
                    ),
                    const SizedBox(width: ReadingRoomSpacing.sm),
                    _buildStatusChip(context, bookmark.scrapingStatus),
                  ],
                ),
              ),
              const SizedBox(height: ReadingRoomSpacing.lg),

              // ── Details Card ────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(ReadingRoomSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius:
                      BorderRadius.circular(ReadingRoomRadii.standard),
                  border: Border.all(color: outlineColor),
                ),
                child: Column(
                  children: <Widget>[
                    if (bookmark.author != null && bookmark.author!.isNotEmpty)
                      _buildInfoRow(
                        context,
                        label: l10n?.detailMetaAuthor ?? 'Author',
                        value: bookmark.author!,
                      ),
                    if (bookmark.siteName != null &&
                        bookmark.siteName!.isNotEmpty)
                      _buildInfoRow(
                        context,
                        label: l10n?.detailMetaSite ?? 'Site',
                        value: bookmark.siteName!,
                      ),
                    if (bookmark.publisher != null &&
                        bookmark.publisher!.isNotEmpty)
                      _buildInfoRow(
                        context,
                        label: l10n?.detailMetaPublisher ?? 'Publisher',
                        value: bookmark.publisher!,
                      ),
                    _buildInfoRow(
                      context,
                      label: l10n?.detailMetaType ?? 'İçerik Türü',
                      value: _formatContentType(bookmark.contentType.name),
                    ),
                    _buildInfoRow(
                      context,
                      label: l10n?.detailMetaSource ?? 'Kaynak',
                      value: _formatSourceType(bookmark.sourceType.name),
                    ),
                    if (bookmark.publishDate != null)
                      _buildInfoRow(
                        context,
                        label: l10n?.detailMetaPublished ?? 'Yayın Tarihi',
                        value: _formatDate(bookmark.publishDate),
                      ),
                    if (bookmark.lastOpenedAt != null)
                      _buildInfoRow(
                        context,
                        label: l10n?.detailMetaLastOpened ?? 'Son Açılma',
                        value: _formatDate(bookmark.lastOpenedAt),
                        isLast: true,
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
              const SizedBox(height: ReadingRoomSpacing.md),

              // ── URL & Canonical with copy ───────────────────
              _buildUrlTile(
                context,
                title: 'URL',
                url: bookmark.originalUrl,
              ),
              if (bookmark.canonicalUrl != null &&
                  bookmark.canonicalUrl != bookmark.originalUrl) ...<Widget>[
                const SizedBox(height: ReadingRoomSpacing.xs),
                _buildUrlTile(
                  context,
                  title: l10n?.detailMetaCanonical ?? 'Canonical URL',
                  url: bookmark.canonicalUrl!,
                ),
              ],

              const SizedBox(height: ReadingRoomSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, BookmarkScrapingStatus status) {
    final ThemeData theme = Theme.of(context);
    final (Color color, IconData icon, String label) = switch (status) {
      BookmarkScrapingStatus.done => (
          Colors.greenAccent.shade700,
          Icons.check_circle_outline,
          'Senkronize Edildi',
        ),
      BookmarkScrapingStatus.failed => (
          theme.colorScheme.error,
          Icons.error_outline,
          'Başarısız',
        ),
      BookmarkScrapingStatus.processing => (
          Colors.orangeAccent,
          Icons.sync,
          'İşleniyor',
        ),
      BookmarkScrapingStatus.pending => (
          Colors.orangeAccent,
          Icons.hourglass_empty_rounded,
          'Bekliyor',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isLast = false,
  }) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : ReadingRoomSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlTile(
    BuildContext context, {
    required String title,
    required String url,
  }) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReadingRoomSpacing.md,
        vertical: ReadingRoomSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.link_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: ReadingRoomSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  url,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16),
            tooltip: 'URL Kopyala',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('URL panoya kopyalandı'),
                    duration: Duration(seconds: 2),
                  ),
                );
            },
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  static String _formatContentType(String name) {
    return switch (name.toLowerCase()) {
      'article' => 'Makale',
      'video' => 'Video',
      'tweet' => 'Gönderi',
      'audio' => 'Ses',
      'document' => 'Belge',
      'image' => 'Görsel',
      'repository' => 'Depo (Repo)',
      _ => 'Bilinmiyor',
    };
  }

  static String _formatSourceType(String name) {
    return switch (name.toLowerCase()) {
      'manual' => 'Manuel',
      'sharetarget' => 'Paylaşım Menüsü',
      'browserextension' => 'Tarayıcı Eklentisi',
      'import' => 'İçe Aktarma',
      _ => name,
    };
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '–';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
