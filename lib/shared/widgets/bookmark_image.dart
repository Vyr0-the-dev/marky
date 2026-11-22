import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Displays a bookmark image with local offline-first priority.
///
/// Resolution order:
/// 1. [localPath] on disk when present and valid.
/// 2. [imageUrl] — supports both `data:image/...;base64,...` URIs (common in
///    Firefox/Chrome HTML bookmark exports) and `http(s)://` URLs via
///    [CachedNetworkImage].
/// 3. Optional [fallbackImageUrl] (e.g., high-resolution domain favicon PNG)
///    when [imageUrl] is missing, unrenderable, or fails to load.
/// 4. [errorBuilder] when all sources fail.
class BookmarkImage extends StatelessWidget {
  const BookmarkImage({
    this.localPath,
    this.imageUrl,
    this.fallbackImageUrl,
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
  final String? fallbackImageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;
  final String? semanticLabel;
  final WidgetBuilder? placeholder;
  final WidgetBuilder? errorBuilder;

  static const int _maxDataUriCacheEntries = 256;
  static const int _maxDataUriChars = 512 * 1024;
  static final LinkedHashMap<String, Uint8List?> _decodedDataUriCache =
      LinkedHashMap<String, Uint8List?>();

  /// Returns a crisp 128px PNG favicon URL for [hostOrUrl], or `null` when
  /// the host is empty or local-only.
  static String? faviconFallbackUrlForHost(String? hostOrUrl) {
    final String? raw = hostOrUrl?.trim();
    if (raw == null || raw.isEmpty) return null;

    String host = raw;
    if (raw.contains('://')) {
      final Uri? parsed = Uri.tryParse(raw);
      if (parsed == null || parsed.host.isEmpty) return null;
      host = parsed.host;
    } else if (raw.contains('/')) {
      host = raw.split('/').first;
    }

    host = host.trim().toLowerCase();
    if (host.isEmpty ||
        !host.contains('.') ||
        host == 'localhost' ||
        host.endsWith('.local')) {
      return null;
    }

    final String encoded = Uri.encodeQueryComponent('https://$host');
    return 'https://www.google.com/s2/favicons?domain_url=$encoded&sz=128';
  }

  /// Returns true when [url] is an inline `data:` image URI.
  static bool isDataImageUri(String? url) {
    if (url == null) return false;
    return url.trimLeft().toLowerCase().startsWith('data:image/');
  }

  /// Decodes a `data:image/...;base64,...` URI into bytes with LRU caching.
  /// Returns `null` for unsupported formats (e.g. SVG) or invalid base64.
  static Uint8List? decodeDataImageUri(String uri) {
    final String trimmed = uri.trim();
    if (_decodedDataUriCache.containsKey(trimmed)) {
      final Uint8List? cached = _decodedDataUriCache.remove(trimmed);
      _decodedDataUriCache[trimmed] = cached;
      return cached;
    }

    Uint8List? decoded;
    if (trimmed.length <= _maxDataUriChars) {
      final int commaIndex = trimmed.indexOf(',');
      if (commaIndex > 0 && commaIndex < trimmed.length - 1) {
        final String header = trimmed.substring(0, commaIndex).toLowerCase();
        // Flutter's Image.memory handles PNG/JPG/WebP/GIF/BMP/ICO, not SVG.
        final bool isRasterBase64 = header.startsWith('data:image/') &&
            header.contains(';base64') &&
            !header.contains('svg');
        if (isRasterBase64) {
          try {
            final String payload =
                trimmed.substring(commaIndex + 1).replaceAll(RegExp(r'\s+'), '');
            final Uint8List bytes = base64Decode(payload);
            if (bytes.isNotEmpty) {
              decoded = bytes;
            }
          } on FormatException {
            decoded = null;
          }
        }
      }
    }

    if (_decodedDataUriCache.length >= _maxDataUriCacheEntries) {
      _decodedDataUriCache.remove(_decodedDataUriCache.keys.first);
    }
    _decodedDataUriCache[trimmed] = decoded;
    return decoded;
  }

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
          errorBuilder: (_, __, ___) => _buildPrimaryOrFallback(context),
        );
      }
    }
    return _buildPrimaryOrFallback(context);
  }

  Widget _buildPrimaryOrFallback(BuildContext context) {
    final String? primary = imageUrl?.trim();
    final String? fallback = fallbackImageUrl?.trim();
    final String? distinctFallback =
        (fallback != null && fallback.isNotEmpty && fallback != primary)
            ? fallback
            : null;

    if (primary == null || primary.isEmpty) {
      return _buildUrlWidget(context, distinctFallback, nextFallback: null);
    }

    return _buildUrlWidget(context, primary, nextFallback: distinctFallback);
  }

  Widget _buildUrlWidget(
    BuildContext context,
    String? url, {
    required String? nextFallback,
  }) {
    if (url == null || url.isEmpty) {
      return errorBuilder?.call(context) ?? const SizedBox.shrink();
    }

    if (isDataImageUri(url)) {
      final Uint8List? bytes = decodeDataImageUri(url);
      if (bytes != null) {
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          gaplessPlayback: true,
          semanticLabel: semanticLabel,
          errorBuilder: (BuildContext ctx, _, __) =>
              _buildUrlWidget(ctx, nextFallback, nextFallback: null),
        );
      }
      return _buildUrlWidget(context, nextFallback, nextFallback: null);
    }

    final Uri? parsed = Uri.tryParse(url);
    final bool isHttp = parsed != null &&
        (parsed.scheme == 'http' || parsed.scheme == 'https') &&
        parsed.host.isNotEmpty;
    if (!isHttp) {
      return _buildUrlWidget(context, nextFallback, nextFallback: null);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: placeholder != null
          ? (BuildContext ctx, _) => placeholder!(ctx)
          : null,
      errorWidget: (BuildContext ctx, _, __) =>
          _buildUrlWidget(ctx, nextFallback, nextFallback: null),
    );
  }
}
