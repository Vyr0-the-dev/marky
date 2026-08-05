import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'package:marky/core/scraping/enums/favicon_status.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Downloads remote favicon images, caches them locally, and updates
/// bookmark records with local cache paths.
///
/// Follows the same `initialize() / instance` singleton pattern as
/// [ImageCacheService] and [MetadataScraperService].
class FaviconCacheService {
  FaviconCacheService({
    required BookmarkItemRepository repository,
    Dio? dio,
  })  : _repository = repository,
        _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        followRedirects: false,
      ),
    );
  }

  final BookmarkItemRepository _repository;
  final Dio _dio;
  static final Logger _logger = Logger();

  static FaviconCacheService? _instance;

  /// The globally configured instance.
  ///
  /// Throws [StateError] if accessed before [initialize].
  static FaviconCacheService get instance {
    if (_instance == null) {
      throw StateError(
        'FaviconCacheService has not been initialized. '
        'Call FaviconCacheService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Returns the global instance if initialized, otherwise `null`.
  ///
  /// Safe for use in providers that may be accessed before bootstrap
  /// completes (e.g. during widget tests).
  static FaviconCacheService? get instanceOrNull => _instance;

  /// Creates and registers the global singleton.
  static void initialize({
    required BookmarkItemRepository repository,
    Dio? dio,
    FaviconCacheService? instance,
  }) {
    _instance = instance ??
        FaviconCacheService(
          repository: repository,
          dio: dio,
        );
  }

  /// Resets the global singleton. Useful in tests.
  static void reset() {
    _instance = null;
  }

  /// Active downloads keyed by favicon URL to deduplicate concurrent requests.
  /// The future completes with the downloaded image bytes.
  final Map<String, Future<Uint8List>> _inFlight = <String, Future<Uint8List>>{};

  /// Downloads and caches the favicon for the bookmark with [bookmarkId].
  ///
  /// The bookmark's [BookmarkItem.faviconStatus] transitions through
  /// [FaviconStatus.processing] → [FaviconStatus.done] or
  /// [FaviconStatus.failed].
  ///
  /// All errors are caught and recorded as [FaviconStatus.failed];
  /// no exceptions escape this method.
  Future<void> downloadAndCache(int bookmarkId) async {
    final BookmarkItem? bookmark = await _repository.getById(bookmarkId);
    if (bookmark == null) {
      return;
    }

    final String? faviconUrl = bookmark.faviconUrl;
    if (faviconUrl == null || faviconUrl.isEmpty) {
      await _markFailed(bookmark);
      return;
    }

    // Set processing immediately so status reflects work in progress.
    bookmark
      ..faviconStatus = FaviconStatus.processing
      ..updatedAt = DateTime.now();
    await _repository.update(bookmark);

    // Check for in-flight download and deduplicate.
    final Future<Uint8List>? existing = _inFlight[faviconUrl];
    if (existing != null) {
      try {
        final Uint8List bytes = await existing;
        await _finalizeBookmark(bookmark, faviconUrl, bytes);
      } on Exception {
        await _markFailed(bookmark);
      }
      return;
    }

    final Future<Uint8List> download = _performDownload(faviconUrl);
    _inFlight[faviconUrl] = download;

    try {
      final Uint8List bytes = await download;
      await _finalizeBookmark(bookmark, faviconUrl, bytes);
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'FaviconCacheService: download failed for bookmark ${bookmark.id}',
        error: e,
        stackTrace: stackTrace,
      );
      await _markFailed(bookmark);
    } finally {
      // ignore: unawaited_futures
      _inFlight.remove(faviconUrl);
    }
  }

  /// Performs the actual HTTP download and returns the image bytes.
  Future<Uint8List> _performDownload(String faviconUrl) async {
    final Response<List<int>> response = await _dio.get<List<int>>(
      faviconUrl,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    // Validate content-type header.
    final String? contentType =
        response.headers.value('content-type')?.toLowerCase();
    if (contentType == null || !contentType.startsWith('image/')) {
      _logger.w(
        'FaviconCacheService: rejected non-image content-type '
        '"$contentType" for $faviconUrl',
      );
      throw Exception('Non-image content-type: $contentType');
    }

    return Uint8List.fromList(response.data ?? <int>[]);
  }

  /// Writes the cached file and updates the bookmark to [FaviconStatus.done].
  Future<void> _finalizeBookmark(
    BookmarkItem bookmark,
    String faviconUrl,
    Uint8List bytes,
  ) async {
    final String filePath = await _writeFaviconFile(
      bookmarkId: bookmark.id,
      faviconUrl: faviconUrl,
      bytes: bytes,
    );

    bookmark
      ..localFaviconPath = filePath
      ..faviconStatus = FaviconStatus.done
      ..updatedAt = DateTime.now();
    await _repository.update(bookmark);
  }

  Future<void> _markFailed(BookmarkItem bookmark) async {
    bookmark
      ..faviconStatus = FaviconStatus.failed
      ..updatedAt = DateTime.now();
    await _repository.update(bookmark);
  }

  /// Writes [bytes] to the app documents directory under
  /// `marky_cache/images/favicons/` and returns the absolute path.
  Future<String> _writeFaviconFile({
    required int bookmarkId,
    required String faviconUrl,
    required Uint8List bytes,
  }) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String extension = _extractExtension(faviconUrl);
    final String fileName = '${bookmarkId}_favicon$extension';
    final String dirPath = path.join(
      appDir.path,
      'marky_cache',
      'images',
      'favicons',
    );
    final Directory targetDir = Directory(dirPath);
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }
    final String filePath = path.join(dirPath, fileName);
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  /// Extracts a safe file extension from [faviconUrl].
  ///
  /// Falls back to `.png` when the URL has no recognizable extension.
  String _extractExtension(String faviconUrl) {
    try {
      final Uri uri = Uri.parse(faviconUrl);
      final String pathSegment = uri.path;
      final String ext = path.extension(pathSegment).toLowerCase();
      if (ext.isNotEmpty &&
          <String>[
            '.jpg',
            '.jpeg',
            '.png',
            '.gif',
            '.webp',
            '.bmp',
            '.svg',
            '.ico',
          ].contains(ext)) {
        return ext;
      }
    } on Exception {
      // Malformed URL — fall through to default.
    }
    return '.png';
  }
}
