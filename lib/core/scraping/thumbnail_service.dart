import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Downloads and locally caches hero images (thumbnails) for bookmarks.
///
/// Images are stored under `<appDir>/thumbnails/<sha1>.ext` so
/// the feed can display them without re-fetching.  The returned
/// path is what goes into `Bookmark.heroImageLocalPath`.
class ThumbnailService {
  ThumbnailService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              responseType: ResponseType.bytes,
            ));

  final Dio _dio;

  /// Downloads [imageUrl] and saves it locally.
  ///
  /// Returns the local file path on success, `null` on failure.
  /// If the file already exists locally, returns the cached path
  /// without re-downloading.
  Future<String?> download(String imageUrl) async {
    try {
      final Directory dir = await _thumbnailDir();
      final String filename = _filename(imageUrl);
      final File file = File(p.join(dir.path, filename));

      if (file.existsSync()) return file.path;

      final Response<List<int>> response = await _dio.get<List<int>>(imageUrl);
      final List<int>? bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;

      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Generates a stable filename from the URL.
  static String _filename(String url) {
    final String hash = sha1.convert(utf8.encode(url)).toString();
    final String ext = _extensionFromUrl(url);
    return '$hash$ext';
  }

  static String _extensionFromUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return '.jpg';
    final String path = uri.path.toLowerCase();
    if (path.endsWith('.png')) return '.png';
    if (path.endsWith('.webp')) return '.webp';
    if (path.endsWith('.gif')) return '.gif';
    if (path.endsWith('.svg')) return '.svg';
    return '.jpg';
  }

  Future<Directory> _thumbnailDir() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory thumbDir = Directory(p.join(appDir.path, 'thumbnails'));
    if (!thumbDir.existsSync()) {
      await thumbDir.create(recursive: true);
    }
    return thumbDir;
  }
}
