import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/utils/color_contrast_utils.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';

/// Magazine-grade Dark Editorial grid card for [Bookmark] items.
///
/// Features:
/// - Dark graphite surface (`#161614`) with a `1px` hairline border
///   (`#2A2A28`) and `16px` corner radius (`elevation: 0`).
/// - Edge-to-edge cover image (`cacheWidth: 480`, `gaplessPlayback: true`)
///   with a smooth skeleton placeholder ([EditorialImagePlaceholder]) and
///   deterministic typographic cover fallback ([TypographicEditorialCover]).
/// - Tripartite editorial typography: Source Serif 4 title, Inter 2-line
///   snippet, and JetBrains Mono metadata footer (`domain • Xm`) with
///   status indicators and up to 2 tag pills.
/// - Subtle `0.97` scale-down micro-interaction on press (`110ms`,
///   `Curves.easeOutCubic`).
class EditorialGridCard extends StatefulWidget {
  const EditorialGridCard({
    required this.bookmark,
    required this.isSelected,
    required this.selectionMode,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  static const Color darkSurface = Color(0xFF161614);
  static const Color darkBorder = Color(0xFF2A2A28);
  static const Color snippetColor = Color(0xFFA0A09E);
  static const Color metaColor = Color(0xFF6E6E6C);
  static const double cardRadius = 16;
  static const double mediaTopRadius = 15;
  static const int heroCacheWidth = 480;
  static const Duration pressDuration = Duration(milliseconds: 110);

  final Bookmark bookmark;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<EditorialGridCard> createState() => _EditorialGridCardState();
}

class _EditorialGridCardState extends State<EditorialGridCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    final Bookmark bookmark = widget.bookmark;

    final Color surfaceColor =
        isDark ? EditorialGridCard.darkSurface : ReadingRoomColors.lightSurface;
    final Color defaultBorderColor =
        isDark ? EditorialGridCard.darkBorder : ReadingRoomColors.lightOutline;
    final Color borderColor = widget.selectionMode && widget.isSelected
        ? theme.colorScheme.primary
        : defaultBorderColor;
    final Color titleColor =
        isDark ? const Color(0xFFEDEDEC) : ReadingRoomColors.lightInk;

    final String? rawSnippet = (bookmark.snippet?.trim().isNotEmpty ?? false)
        ? bookmark.snippet!.trim()
        : bookmark.description?.trim();
    final bool hasSnippet = rawSnippet != null && rawSnippet.isNotEmpty;

    final String? heroUrl = bookmark.heroImageUrl?.trim();
    final bool hasHeroImage = heroUrl != null && heroUrl.isNotEmpty;

    return Semantics(
      button: widget.onTap != null || widget.onLongPress != null,
      selected: widget.selectionMode && widget.isSelected,
      label: _semanticsLabel(bookmark),
      child: ExcludeSemantics(
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration:
              reduceMotion ? Duration.zero : EditorialGridCard.pressDuration,
          curve: Curves.easeOutCubic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(
                  EditorialGridCard.cardRadius,
                ),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Stack(
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(
                              EditorialGridCard.mediaTopRadius,
                            ),
                          ),
                          child: hasHeroImage
                              ? AspectRatio(
                                  aspectRatio: 16 / 10,
                                  child: Image.network(
                                    heroUrl,
                                    fit: BoxFit.cover,
                                    cacheWidth:
                                        EditorialGridCard.heroCacheWidth,
                                    gaplessPlayback: true,
                                    filterQuality: FilterQuality.low,
                                    loadingBuilder: (
                                      BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress,
                                    ) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return const EditorialImagePlaceholder();
                                    },
                                    errorBuilder: (_, __, ___) =>
                                        TypographicEditorialCover(
                                      bookmark: bookmark,
                                    ),
                                  ),
                                )
                              : TypographicEditorialCover(bookmark: bookmark),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                bookmark.displayTitle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.sourceSerif4(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.28,
                                  color: titleColor,
                                ),
                              ),
                              if (hasSnippet) ...<Widget>[
                                const SizedBox(height: 6),
                                Text(
                                  rawSnippet,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: EditorialGridCard.snippetColor,
                                    height: 1.38,
                                  ),
                                ),
                              ],
                              if (bookmark.tagIds.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 8),
                                _EditorialGridTagPills(
                                  tagIds: bookmark.tagIds,
                                ),
                              ],
                              const SizedBox(height: 10),
                              _EditorialMetaFooter(bookmark: bookmark),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.selectionMode)
                      Positioned(
                        top: ReadingRoomSpacing.sm,
                        right: ReadingRoomSpacing.sm,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: surfaceColor.withValues(alpha: 0.88),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              widget.isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked,
                              size: 20,
                              color: widget.isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _semanticsLabel(Bookmark bookmark) {
    final String host = _resolveHost(bookmark);
    final List<String> parts = <String>[
      'Bookmark',
      bookmark.displayTitle,
      if (host.isNotEmpty) host,
      if (bookmark.isRead) 'read' else 'unread',
      if (bookmark.isFavorite) 'favorite',
      if (bookmark.isPinned) 'pinned',
      if (bookmark.isArchived) 'archived',
    ];
    return parts.join(', ');
  }
}

/// Smooth skeleton placeholder shown while the hero cover image loads.
class EditorialImagePlaceholder extends StatelessWidget {
  const EditorialImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color baseColor =
        isDark ? const Color(0xFF1E1E1B) : const Color(0xFFECEAE4);
    final Color highlightColor =
        isDark ? const Color(0xFF282824) : const Color(0xFFF5F4F0);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[baseColor, highlightColor, baseColor],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 20,
          color: isDark
              ? const Color(0xFF4A4A46)
              : ReadingRoomColors.lightMuted.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// Deterministic typographic cover fallback when a bookmark has no hero
/// preview image or the image fails to load.
///
/// Renders a warm monochrome/tinted surface seeded from the domain host
/// hash with an oversized Source Serif 4 watermark monogram and a subtle
/// monospace domain badge.
class TypographicEditorialCover extends StatelessWidget {
  const TypographicEditorialCover({
    required this.bookmark,
    super.key,
  });

  final Bookmark bookmark;

  static const List<Color> _darkSurfaces = <Color>[
    Color(0xFF1D1B18),
    Color(0xFF191C1B),
    Color(0xFF1F1A1B),
    Color(0xFF1A1B20),
    Color(0xFF1E1C17),
    Color(0xFF1B1B19),
  ];

  static const List<Color> _lightSurfaces = <Color>[
    Color(0xFFF2EFE9),
    Color(0xFFECEFE9),
    Color(0xFFF3ECEB),
    Color(0xFFECEEF2),
    Color(0xFFF2EFE6),
    Color(0xFFEEEEEC),
  ];

  static int hostSeed(String host) {
    var hash = 0;
    for (final int codeUnit in host.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  static String monogramFor(Bookmark bookmark) {
    final String title = (bookmark.title ?? '').trim();
    final String source = title.isNotEmpty ? title : _resolveHost(bookmark);
    for (final int rune in source.runes) {
      final String ch = String.fromCharCode(rune);
      if (RegExp('[A-Za-z0-9]').hasMatch(ch)) {
        return ch.toUpperCase();
      }
    }
    return 'M';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String host = _resolveHost(bookmark);
    final int seed = hostSeed(host);
    final List<Color> palette = isDark ? _darkSurfaces : _lightSurfaces;
    final Color surfaceColor = palette[seed % palette.length];
    final Color borderDivider =
        isDark ? const Color(0xFF252522) : ReadingRoomColors.lightOutline;
    final Color watermarkColor = isDark
        ? const Color(0xFFEDEDEC).withValues(alpha: 0.14)
        : ReadingRoomColors.lightInk.withValues(alpha: 0.12);
    final Color badgeBg = isDark
        ? const Color(0xFF121210).withValues(alpha: 0.72)
        : ReadingRoomColors.lightSurfaceRaised.withValues(alpha: 0.85);
    final Color badgeBorder =
        isDark ? const Color(0xFF2E2E2B) : ReadingRoomColors.lightOutline;
    final Color badgeText =
        isDark ? const Color(0xFFA0A09E) : ReadingRoomColors.lightMuted;

    final String monogram = monogramFor(bookmark);

    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          bottom: BorderSide(color: borderDivider),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            right: 10,
            bottom: -10,
            child: Text(
              monogram,
              style: GoogleFonts.sourceSerif4(
                fontSize: 64,
                fontWeight: FontWeight.w600,
                height: 1,
                color: watermarkColor,
              ),
            ),
          ),
          if (host.isNotEmpty)
            Positioned(
              left: 10,
              bottom: 10,
              right: 48,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: badgeBorder, width: 0.8),
                  ),
                  child: Text(
                    host,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: badgeText,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditorialMetaFooter extends StatelessWidget {
  const _EditorialMetaFooter({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final String host = _resolveHost(bookmark);
    final int? minutes = bookmark.readingTimeMinutes;
    final String metaText = minutes != null && minutes > 0
        ? (host.isNotEmpty ? '$host • ${minutes}m' : '${minutes}m')
        : host;

    return Row(
      children: <Widget>[
        if (!bookmark.isRead) ...<Widget>[
          Container(
            key: const ValueKey<String>('editorial_unread_dot'),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFEDEDEC),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
        ],
        if (bookmark.contentType != BookmarkContentType.unknown &&
            bookmark.contentType != BookmarkContentType.article) ...<Widget>[
          Icon(
            _contentTypeIcon(bookmark.contentType),
            size: 11,
            color: EditorialGridCard.metaColor,
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            metaText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10.5,
              color: EditorialGridCard.metaColor,
              height: 1.2,
            ),
          ),
        ),
        if (bookmark.isPinned) ...<Widget>[
          const SizedBox(width: 4),
          const Icon(
            Icons.push_pin_outlined,
            size: 12,
            color: EditorialGridCard.metaColor,
          ),
        ],
        if (bookmark.isFavorite) ...<Widget>[
          const SizedBox(width: 4),
          const Icon(
            Icons.favorite_rounded,
            size: 12,
            color: EditorialGridCard.metaColor,
          ),
        ],
      ],
    );
  }

  static IconData _contentTypeIcon(BookmarkContentType type) {
    switch (type) {
      case BookmarkContentType.video:
        return Icons.play_circle_outline_rounded;
      case BookmarkContentType.code:
        return Icons.code_rounded;
      case BookmarkContentType.discussion:
        return Icons.forum_outlined;
      case BookmarkContentType.document:
        return Icons.description_outlined;
      case BookmarkContentType.audio:
        return Icons.headphones_outlined;
      case BookmarkContentType.product:
        return Icons.shopping_bag_outlined;
      case BookmarkContentType.image:
        return Icons.image_outlined;
      default:
        return Icons.article_outlined;
    }
  }
}

class _EditorialGridTagPills extends ConsumerWidget {
  const _EditorialGridTagPills({
    required this.tagIds,
  });

  final List<int> tagIds;
  static const int _maxTags = 2;

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

        final List<Tag> visible =
            resolved.take(_maxTags).toList(growable: false);
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: <Widget>[
            for (final Tag tag in visible) _buildPill(context, tag),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPill(BuildContext context, Tag tag) {
    final TagColorStyle tagStyle = ColorContrastUtils.resolveTagStyle(
      colorArgb: tag.colorArgb,
      context: context,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: tagStyle.textColor,
          height: 1.2,
        ),
      ),
    );
  }
}

String _resolveHost(Bookmark bookmark) {
  final String? normalized = bookmark.normalizedHost?.trim();
  if (normalized != null && normalized.isNotEmpty) {
    return normalized;
  }
  final Uri? uri = Uri.tryParse(bookmark.originalUrl);
  if (uri == null || uri.host.isEmpty) return '';
  final String host = uri.host;
  return host.startsWith('www.') ? host.substring(4) : host;
}
