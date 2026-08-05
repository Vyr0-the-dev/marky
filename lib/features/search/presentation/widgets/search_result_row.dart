import 'dart:io';

import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Compact row widget for displaying a single bookmark search result.
///
/// Shows title (fallback to domain), domain pill, favicon thumbnail,
/// and a favorite star indicator. Designed for use in search result lists.
class SearchResultRow extends StatelessWidget {
  /// Creates a [SearchResultRow].
  const SearchResultRow({
    required this.bookmark,
    this.onTap,
    super.key,
  });

  /// The bookmark to display.
  final BookmarkItem bookmark;

  /// Called when the row is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String domain = _extractDomain(bookmark.originalUrl);
    final String displayTitle = bookmark.title?.trim().isNotEmpty ?? false
        ? bookmark.title!
        : domain;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(
        Radius.circular(AppShapes.radiusStandard),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppShapes.screenPadding,
          vertical: 12,
        ),
        child: Row(
          children: <Widget>[
            // ── Favicon / Domain monogram ─────────────────────────────
            _buildLeadingIcon(domain),
            const SizedBox(width: 12),

            // ── Title & domain ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    displayTitle,
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _DomainPill(domain: domain),
                ],
              ),
            ),

            // ── Favorite star ─────────────────────────────────────────
            if (bookmark.isFavorite)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.star,
                  color: AppColors.accentPrimary,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(String domain) {
    final String? localPath = bookmark.localFaviconPath;
    final String? remoteUrl = bookmark.faviconUrl;

    // Skip SVG favicons.
    if (remoteUrl != null && remoteUrl.toLowerCase().endsWith('.svg')) {
      return _DomainMonogram(domain: domain);
    }

    if (localPath != null && localPath.isNotEmpty) {
      return _LocalFavicon(path: localPath);
    }

    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return _RemoteFavicon(url: remoteUrl, domain: domain);
    }

    return _DomainMonogram(domain: domain);
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
}

/// A small circular monogram derived from the first letter of the domain.
class _DomainMonogram extends StatelessWidget {
  const _DomainMonogram({required this.domain});

  final String domain;

  @override
  Widget build(BuildContext context) {
    final String letter = domain.isNotEmpty ? domain[0].toUpperCase() : '?';

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.surface3,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          height: 1,
        ),
      ),
    );
  }
}

/// Renders a locally cached favicon file.
class _LocalFavicon extends StatelessWidget {
  const _LocalFavicon({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.file(
        File(path),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _FallbackFavicon(),
      ),
    );
  }
}

/// Renders a remote favicon via network with fallback.
class _RemoteFavicon extends StatelessWidget {
  const _RemoteFavicon({required this.url, required this.domain});

  final String url;
  final String domain;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _DomainMonogram(domain: domain),
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) return child;
          return const _FallbackFavicon();
        },
      ),
    );
  }
}

/// Default fallback when no favicon is available.
class _FallbackFavicon extends StatelessWidget {
  const _FallbackFavicon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.surface3,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.link,
        color: AppColors.textTertiary,
        size: 20,
      ),
    );
  }
}

/// Compact pill showing the domain name.
class _DomainPill extends StatelessWidget {
  const _DomainPill({required this.domain});

  final String domain;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
      ),
      child: Text(
        domain,
        style: AppTypography.metadata.copyWith(
          color: AppColors.textTertiary,
          fontSize: 11,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
