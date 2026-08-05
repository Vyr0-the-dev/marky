import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/core/image/image_cache_config.dart';
import 'package:marky/features/tags/presentation/providers/tag_providers.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/tag.dart';

/// A reusable card widget displaying a bookmark's metadata and action affordances.
///
/// Renders an image area (with graceful fallback), title/domain, date, tags,
/// and favorite/archive/share actions. Designed for use in feed grids and lists.
class BookmarkCard extends ConsumerWidget {
  /// Creates a [BookmarkCard].
  const BookmarkCard({
    required this.bookmark,
    this.onTap,
    this.onFavoriteToggle,
    this.onArchive,
    this.onShare,
    this.onTagTap,
    super.key,
  });

  /// The bookmark to display.
  final BookmarkItem bookmark;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when the favorite icon is tapped.
  /// TODO: Wire to repository via use-case in a later slice.
  final VoidCallback? onFavoriteToggle;

  /// Called when the archive icon is tapped.
  /// TODO: Wire to repository via use-case in a later slice.
  final VoidCallback? onArchive;

  /// Called when the share icon is tapped.
  /// TODO: Wire to repository via use-case in a later slice.
  final VoidCallback? onShare;

  /// Called when a tag chip is tapped.
  final ValueChanged<Tag>? onTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final String favoriteLabel = l10n?.labelFavorite ?? 'Favorite';
    final String archiveLabel = l10n?.actionArchive ?? 'Archive';
    final String shareLabel = l10n?.actionShare ?? 'Share';
    final String domain = _extractDomain(bookmark.originalUrl);

    // Prefer locally cached thumbnail, then remote hero image, then remote thumbnail.
    final String? localPath = bookmark.localThumbnailPath;
    final String? remoteUrl = bookmark.heroImageUrl ?? bookmark.thumbnailUrl;

    return InkWell(
      onTap: onTap,
      child: Card(
        shape: AppShapes.standardShape,
        color: AppColors.surface2,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              // ── Image area ──────────────────────────────────────────────
              AspectRatio(
                aspectRatio: 16 / 9,
                child: localPath != null && localPath.isNotEmpty
                    ? _LocalImageFadeIn(path: localPath)
                    : remoteUrl != null && remoteUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: remoteUrl,
                            cacheManager: markyImageCacheManager,
                            fit: BoxFit.cover,
                            placeholder: (BuildContext context, String url) =>
                                const _ImagePlaceholder(),
                            errorWidget: (BuildContext context, String url,
                                    Object error) =>
                                const _ImagePlaceholder(),
                          )
                        : const _ImagePlaceholder(),
              ),

              // ── Text content ────────────────────────────────────────────
              Padding(
                padding: AppShapes.cardPaddingInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      bookmark.title ?? domain,
                      style: AppTypography.cardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        _buildFavicon(bookmark, domain),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            domain,
                            style: AppTypography.metadata,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat.yMMMd().format(bookmark.createdAt),
                          style: AppTypography.metadata,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── Note badge ────────────────────────────────────────
                    if (bookmark.noteIds != null) _buildNoteBadge(),
                    if (bookmark.noteIds != null) const SizedBox(height: 8),

                    // ── Tags ──────────────────────────────────────────────
                    _buildTagChips(ref),
                    const SizedBox(height: 8),

                    // ── Action row ────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _buildActionButton(
                          label: favoriteLabel,
                          icon: Icon(
                            bookmark.isFavorite ? Icons.star : Icons.star_border,
                            color: bookmark.isFavorite
                                ? AppColors.accentPrimary
                                : AppColors.textTertiary,
                          ),
                          onPressed: onFavoriteToggle ?? () {},
                          toggled: bookmark.isFavorite,
                        ),
                        _buildActionButton(
                          label: archiveLabel,
                          icon: const Icon(
                            Icons.archive_outlined,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: onArchive ?? () {},
                        ),
                        _buildActionButton(
                          label: shareLabel,
                          icon: const Icon(
                            Icons.share_outlined,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: onShare ?? () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  String _extractDomain(String url) {
    try {
      final Uri uri = Uri.parse(url);
      if (uri.host.isNotEmpty) {
        return uri.host;
      }
    } catch (_) {
      // Fallback to raw URL on parse failure.
    }
    return url;
  }

  Widget _buildActionButton({
    required String label,
    required Widget icon,
    required VoidCallback onPressed,
    bool? toggled,
  }) {
    return Semantics(
      button: true,
      label: label,
      toggled: toggled,
      child: ExcludeSemantics(
        child: IconButton(
          icon: icon,
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          onPressed: onPressed,
          tooltip: label,
        ),
      ),
    );
  }

  Widget _buildTagChips(WidgetRef ref) {
    final List<int> tagIds = bookmark.tagIds ?? <int>[];
    if (tagIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final AsyncValue<Map<int, Tag>> tagMapAsync = ref.watch(tagMapProvider);

    return tagMapAsync.when(
      data: (Map<int, Tag> tagMap) {
        final List<Tag> matched = <Tag>[
          for (final int id in tagIds)
            if (tagMap.containsKey(id)) tagMap[id]!,
        ];

        if (matched.isEmpty) {
          return const SizedBox.shrink();
        }

        const int maxVisible = 3;
        final List<Tag> visible = matched.take(maxVisible).toList();
        final int overflow = matched.length - maxVisible;

        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            ...visible.map((Tag tag) {
              return _CompactTagChip(
                tag: tag,
                onTap: onTagTap != null ? () => onTagTap!(tag) : null,
              );
            }),
            if (overflow > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
                ),
                child: Text(
                  '+$overflow',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildNoteBadge() {
    final int count = bookmark.noteIds!.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(
          Icons.note,
          size: 14,
          color: AppColors.textTertiary,
        ),
        if (count > 1) ...<Widget>[
          const SizedBox(width: 4),
          Text(
            '$count',
            style: AppTypography.metadata,
          ),
        ],
      ],
    );
  }

  Widget _buildFavicon(BookmarkItem bookmark, String domain) {
    final String? localPath = bookmark.localFaviconPath;
    final String? remoteUrl = bookmark.faviconUrl;

    // Skip SVG favicons — fall through to monogram.
    if (remoteUrl != null && remoteUrl.toLowerCase().endsWith('.svg')) {
      return _DomainMonogram(domain: domain);
    }

    if (localPath != null && localPath.isNotEmpty) {
      return _LocalFaviconFadeIn(path: localPath);
    }

    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: remoteUrl,
        cacheManager: markyImageCacheManager,
        width: 20,
        height: 20,
        placeholder: (BuildContext context, String url) =>
            _DomainMonogram(domain: domain),
        errorWidget: (BuildContext context, String url, Object error) =>
            _DomainMonogram(domain: domain),
      );
    }

    return _DomainMonogram(domain: domain);
  }
}

/// Placeholder shown while an image loads or when no image URL is available.
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surface3,
      child: Center(
        child: Icon(
          Icons.image,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

/// Renders a local image file with a smooth fade-in animation.
class _LocalImageFadeIn extends StatelessWidget {
  const _LocalImageFadeIn({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        final bool isLoaded = wasSynchronouslyLoaded || frame != null;
        return AnimatedOpacity(
          opacity: isLoaded ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }
}

/// Renders a small circular monogram from the first letter of the domain.
class _DomainMonogram extends StatelessWidget {
  const _DomainMonogram({required this.domain});

  final String domain;

  @override
  Widget build(BuildContext context) {
    final String letter = domain.isNotEmpty ? domain[0].toUpperCase() : '?';
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: AppColors.surface3,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          height: 1,
        ),
      ),
    );
  }
}

/// Renders a local favicon file with a smooth fade-in animation.
class _LocalFaviconFadeIn extends StatelessWidget {
  const _LocalFaviconFadeIn({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      width: 20,
      height: 20,
      fit: BoxFit.cover,
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        final bool isLoaded = wasSynchronouslyLoaded || frame != null;
        return AnimatedOpacity(
          opacity: isLoaded ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }
}

/// A compact tag chip for use inside bookmark cards.
class _CompactTagChip extends StatelessWidget {
  const _CompactTagChip({
    required this.tag,
    this.onTap,
  });

  final Tag tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color tagColor = _resolveColor(tag.color);

    return Material(
      color: tagColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: tagColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                tag.name,
                style: AppTypography.metadata.copyWith(
                  color: tagColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _resolveColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return AppColors.accentPrimary;
    }
    try {
      final String sanitized = hex.replaceAll('#', '');
      if (sanitized.length == 6) {
        return Color(int.parse('FF$sanitized', radix: 16));
      }
      if (sanitized.length == 8) {
        return Color(int.parse(sanitized, radix: 16));
      }
    } catch (_) {
      // Fall through to default.
    }
    return AppColors.accentPrimary;
  }
}
