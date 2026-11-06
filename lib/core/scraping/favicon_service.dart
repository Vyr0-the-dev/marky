import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Downloads and locally caches favicons for bookmarks.
///
/// Stored under `<appDir>/favicons/<sha1>.ext`.  The returned path
/// goes into `Bookmark.localFaviconPath`.
class FaviconService {
  FaviconService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              responseType: ResponseType.bytes,
            ));

  final Dio _dio;

  /// Downloads [faviconUrl] and caches locally.
  ///
  /// Returns the local file path on success, `null` on failure.
  /// Returns the cached path when the file already exists.
  Future<String?> download(String faviconUrl) async {
    try {
      final Directory dir = await _faviconDir();
      final String filename = _filename(faviconUrl);
      final File file = File(p.join(dir.path, filename));

      if (file.existsSync()) return file.path;

      final Response<List<int>> response =
          await _dio.get<List<int>>(faviconUrl);
      final List<int>? bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;

      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static String _filename(String url) {
    final String hash = sha1.convert(utf8.encode(url)).toString();
    final String ext = _extensionFromUrl(url);
    return '$hash$ext';
  }

  static String _extensionFromUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return '.ico';
    final String path = uri.path.toLowerCase();
    if (path.endsWith('.png')) return '.png';
    if (path.endsWith('.svg')) return '.svg';
    if (path.endsWith('.ico')) return '.ico';
    return '.ico';
  }

  Future<Directory> _faviconDir() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory favDir = Directory(p.join(appDir.path, 'favicons'));
    if (!favDir.existsSync()) {
      await favDir.create(recursive: true);
    }
    return favDir;
  }
}
