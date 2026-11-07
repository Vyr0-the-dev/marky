import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/core/utils/color_contrast_utils.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';

/// A single bookmark row in the feed.
///
/// Layout (list mode):
/// ```
///  ┌──────┐  Title (2 lines max)
///  │ hero │  domain · 2h ago
///  │  img │  ♥ 📌 📖
///  └──────┘
/// ```
///
/// Grid mode uses a taller thumbnail with text below — a separate
/// widget composition is added in Tur 4 on top of the same
/// building blocks.
class BookmarkCard extends StatelessWidget {
  const BookmarkCard({
    required this.bookmark,
    this.isSelected = false,
    this.selectionMode = false,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final Bookmark bookmark;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Semantics(
      button: onTap != null || onLongPress != null,
      selected: selectionMode && isSelected,
      label: _semanticsLabel(bookmark),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: ReadingRoomSpacing.lg,
              vertical: ReadingRoomSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ── Selection checkbox (only in selection mode) ───
                if (selectionMode) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      right: ReadingRoomSpacing.md,
                      top: ReadingRoomSpacing.xs,
                    ),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 22,
                      color:
                          isSelected ? colors.primary : colors.onSurfaceVariant,
                    ),
                  ),
                ],

                // ── Thumbnail ─────────────────────────────────────
                _Thumbnail(bookmark: bookmark),

                const SizedBox(width: ReadingRoomSpacing.md),

                // ── Text block ────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Title
                      Text(
                        bookmark.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),

                      const SizedBox(height: ReadingRoomSpacing.xs),

                      // Domain · time ago
                      Text(
                        _subtitle(bookmark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ReadingRoomTextStyles.metadata(context),
                      ),

                      const SizedBox(height: ReadingRoomSpacing.xs),

                      // Status badges
                      _StatusRow(bookmark: bookmark),

                      // Tag chips
                      if (bookmark.tagIds.isNotEmpty) ...<Widget>[
                        const SizedBox(height: ReadingRoomSpacing.xs),
                        TagChipsRow(tagIds: bookmark.tagIds),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _subtitle(Bookmark b) {
    final String domain = b.normalizedHost ?? _domainFromUrl(b.originalUrl);
    final String timeAgo = _relativeTime(b.createdAt);
    return '$domain · $timeAgo';
  }

  static String _semanticsLabel(Bookmark b) {
    final List<String> parts = <String>[
      'Bookmark',
      b.displayTitle,
      _subtitle(b),
      if (b.isRead) 'read' else 'unread',
      if (b.isFavorite) 'favorite',
      if (b.isPinned) 'pinned',
      if (b.isArchived) 'archived',
    ];
    return parts.join(', ');
  }

  static String _domainFromUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url;
    String host = uri.host;
    if (host.startsWith('www.')) host = host.substring(4);
    return host;
  }

  static String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7}w';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30}mo';
    return '${diff.inDays ~/ 365}y';
  }
}

// ─── Thumbnail ──────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.bookmark});

  final Bookmark bookmark;

  static const double _size = 64;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = bookmark.heroImageUrl ?? bookmark.faviconUrl;
    final int cacheSize =
        (_size * MediaQuery.devicePixelRatioOf(context)).round();

    final bool isLoading =
        bookmark.scrapingStatus == BookmarkScrapingStatus.pending ||
            bookmark.scrapingStatus == BookmarkScrapingStatus.processing;

    return ClipRRect(
      borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
      child: SizedBox(
        width: _size,
        height: _size,
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                cacheWidth: cacheSize,
                cacheHeight: cacheSize,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, __, ___) =>
                    _Placeholder(bookmark: bookmark, isLoading: isLoading),
              )
            : _Placeholder(bookmark: bookmark, isLoading: isLoading),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.bookmark, this.isLoading = false});

  final Bookmark bookmark;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (isLoading) {
      return ColoredBox(
        color: theme.colorScheme.outlineVariant,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Domain monogram fallback
    final String domain = bookmark.normalizedHost ?? bookmark.originalUrl;
    final String letter = domain.isNotEmpty ? domain[0].toUpperCase() : '?';

    return ColoredBox(
      color: theme.colorScheme.outlineVariant,
      child: Center(
        child: Text(
          letter,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─── Status row ─────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    const double iconSize = 14;

    final List<Widget> badges = <Widget>[];

    if (bookmark.isFavorite) {
      badges.add(Icon(Icons.favorite, size: iconSize, color: muted));
    }
    if (bookmark.isPinned) {
      badges.add(Icon(Icons.push_pin, size: iconSize, color: muted));
    }
    if (bookmark.isRead) {
      badges
          .add(Icon(Icons.check_circle_outline, size: iconSize, color: muted));
    }
    if (bookmark.isArchived) {
      badges.add(Icon(Icons.archive_outlined, size: iconSize, color: muted));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: ReadingRoomSpacing.sm,
      children: badges,
    );
  }
}

// ─── Tag chips row ──────────────────────────────────────────────

class TagChipsRow extends ConsumerWidget {
  const TagChipsRow({required this.tagIds, this.maxLines, super.key});

  final List<int> tagIds;
  final int? maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tag>> allTagsAsync = ref.watch(tagsProvider);
    return allTagsAsync.when(
      data: (List<Tag> allTags) {
        final Map<int, Tag> tagMap = <int, Tag>{
          for (final Tag t in allTags)
            if (t.id != null) t.id!: t,
        };
        final List<Tag> resolved = <Tag>[
          for (final int id in tagIds)
            if (tagMap.containsKey(id)) tagMap[id]!,
        ];
        if (resolved.isEmpty) return const SizedBox.shrink();
        final List<Widget> chips = resolved.map((Tag tag) {
          final TagColorStyle tagStyle = ColorContrastUtils.resolveTagStyle(
            colorArgb: tag.colorArgb,
            context: context,
          );
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: tagStyle.backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: tagStyle.borderColor,
                width: 0.5,
              ),
            ),
            child: Text(
              tag.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tagStyle.textColor,
                    fontSize: 10,
                  ),
            ),
          );
        }).toList();

        if (maxLines != null) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: chips),
          );
        }
        return Wrap(
          spacing: ReadingRoomSpacing.xs,
          runSpacing: ReadingRoomSpacing.xs,
          children: chips,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
