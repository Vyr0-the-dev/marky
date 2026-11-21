import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Displays a bookmark image with local offline-first priority.
///
/// Prefers [localPath] on disk when present and valid; otherwise falls back to
/// [imageUrl] via [CachedNetworkImage]. Never throws if a local file was
/// deleted externally (falls back cleanly to network or [errorBuilder]).
class BookmarkImage extends StatelessWidget {
  const BookmarkImage({
    this.localPath,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cacheWidth,
    this.cacheHeight,
    this.semanticLabel,
    this.placeholder,
    this.errorBuilder,
    super.key,
  });

  final String? localPath;
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;
  final String? semanticLabel;
  final WidgetBuilder? placeholder;
  final WidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final String? trimmedLocal = localPath?.trim();
    if (trimmedLocal != null && trimmedLocal.isNotEmpty) {
      final File file = File(trimmedLocal);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          gaplessPlayback: true,
          semanticLabel: semanticLabel,
          errorBuilder: (_, __, ___) => _buildNetworkOrError(context),
        );
      }
    }
    return _buildNetworkOrError(context);
  }

  Widget _buildNetworkOrError(BuildContext context) {
    final String? trimmedUrl = imageUrl?.trim();
    if (trimmedUrl == null || trimmedUrl.isEmpty) {
      return errorBuilder?.call(context) ?? const SizedBox.shrink();
    }

    return CachedNetworkImage(
      imageUrl: trimmedUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: placeholder != null
          ? (BuildContext ctx, _) => placeholder!(ctx)
          : null,
      errorWidget: (BuildContext ctx, _, __) =>
          errorBuilder?.call(ctx) ?? const SizedBox.shrink(),
    );
  }
}
