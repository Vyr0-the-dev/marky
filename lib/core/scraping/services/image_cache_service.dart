import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:marky/core/scraping/enums/thumbnail_status.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Factory signature for creating a [PaletteGenerator] from an image provider.
///
/// Defaults to [PaletteGenerator.fromImageProvider] in production. Tests can
/// inject a fast fake to avoid timeouts when feeding fake image bytes.
typedef PaletteGeneratorFactory = Future<PaletteGenerator> Function(
  ImageProvider imageProvider, {
  Size? size,
});

/// Downloads remote thumbnail images, caches them locally, and updates
/// bookmark records with cache paths.
///
/// Follows the same `initialize() / instance` singleton pattern as
/// [MetadataScraperService] and [DuplicateDetectionService].
class ImageCacheService {
  ImageCacheService({
    required BookmarkItemRepository repository,
    Dio? dio,
    PaletteGeneratorFactory? paletteGeneratorFactory,
  })  : _repository = repository,
        _dio = dio ?? _createDefaultDio(),
        _paletteGeneratorFactory =
            paletteGeneratorFactory ?? PaletteGenerator.fromImageProvider;

  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: false,
      ),
    );
  }

  final BookmarkItemRepository _repository;
  final Dio _dio;
  final PaletteGeneratorFactory _paletteGeneratorFactory;
  static final Logger _logger = Logger();

  static ImageCacheService? _instance;

  /// The globally configured instance.
  ///
  /// Throws [StateError] if accessed before [initialize].
  static ImageCacheService get instance {
    if (_instance == null) {
      throw StateError(
        'ImageCacheService has not been initialized. '
        'Call ImageCacheService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Returns the global instance if initialized, otherwise `null`.
  ///
  /// Safe for use in providers that may be accessed before bootstrap
  /// completes (e.g. during widget tests).
  static ImageCacheService? get instanceOrNull => _instance;

  /// Creates and registers the global singleton.
  static void initialize({
    required BookmarkItemRepository repository,
    Dio? dio,
    ImageCacheService? instance,
    PaletteGeneratorFactory? paletteGeneratorFactory,
  }) {
    _instance = instance ??
        ImageCacheService(
          repository: repository,
          dio: dio,
          paletteGeneratorFactory: paletteGeneratorFactory,
        );
  }

  /// Resets the global singleton. Useful in tests.
  static void reset() {
    _instance = null;
  }

  /// Active downloads keyed by image URL to deduplicate concurrent requests.
  /// The future completes with the downloaded image bytes.
  final Map<String, Future<Uint8List>> _inFlight = <String, Future<Uint8List>>{};

  /// Downloads and caches the thumbnail for the bookmark with [bookmarkId].
  ///
  /// The bookmark's [BookmarkItem.thumbnailStatus] transitions through
  /// [ThumbnailStatus.processing] → [ThumbnailStatus.done] or
  /// [ThumbnailStatus.failed].
  ///
  /// All errors are caught and recorded as [ThumbnailStatus.failed];
  /// no exceptions escape this method.
  Future<void> downloadAndCache(int bookmarkId) async {
    final BookmarkItem? bookmark = await _repository.getById(bookmarkId);
    if (bookmark == null) {
      return;
    }

    final String? imageUrl = bookmark.thumbnailUrl ?? bookmark.heroImageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      await _markFailed(bookmark);
      return;
    }

    // Set processing immediately so status reflects work in progress.
    bookmark
      ..thumbnailStatus = ThumbnailStatus.processing
      ..updatedAt = DateTime.now();
    await _repository.update(bookmark);

    // Check for in-flight download and deduplicate.
    final Future<Uint8List>? existing = _inFlight[imageUrl];
    if (existing != null) {
      try {
        final Uint8List bytes = await existing;
        await _finalizeBookmark(bookmark, imageUrl, bytes);
      } on Exception {
        await _markFailed(bookmark);
      }
      return;
    }

    final Future<Uint8List> download = _performDownload(imageUrl);
    _inFlight[imageUrl] = download;

    try {
      final Uint8List bytes = await download;
      await _finalizeBookmark(bookmark, imageUrl, bytes);
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'ImageCacheService: download failed for bookmark ${bookmark.id}',
        error: e,
        stackTrace: stackTrace,
      );
      await _markFailed(bookmark);
    } finally {
      // ignore: unawaited_futures
      _inFlight.remove(imageUrl);
    }
  }

  /// Performs the actual HTTP download and returns the image bytes.
  Future<Uint8List> _performDownload(String imageUrl) async {
    final Response<List<int>> response = await _dio.get<List<int>>(
      imageUrl,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    // Validate content-type header.
    final String? contentType =
        response.headers.value('content-type')?.toLowerCase();
    if (contentType == null || !contentType.startsWith('image/')) {
      _logger.w(
        'ImageCacheService: rejected non-image content-type '
        '"$contentType" for $imageUrl',
      );
      throw Exception('Non-image content-type: $contentType');
    }

    return Uint8List.fromList(response.data ?? <int>[]);
  }

  /// Writes the cached file, extracts the dominant color, and updates the
  /// bookmark to [ThumbnailStatus.done].
  Future<void> _finalizeBookmark(
    BookmarkItem bookmark,
    String imageUrl,
    Uint8List bytes,
  ) async {
    final String filePath = await _writeImageFile(
      bookmarkId: bookmark.id,
      imageUrl: imageUrl,
      bytes: bytes,
    );

    String? dominantColorHex;
    try {
      final PaletteGenerator palette =
          await _paletteGeneratorFactory(
        FileImage(File(filePath)),
        size: const Size(100, 100),
      );
      final Color? dominantColor = palette.dominantColor?.color;
      if (dominantColor != null) {
        dominantColorHex =
            '#${dominantColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      }
    } on Exception catch (e, stackTrace) {
      _logger.w(
        'ImageCacheService: dominant color extraction failed for bookmark ${bookmark.id}',
        error: e,
        stackTrace: stackTrace,
      );
      // Non-fatal: leave dominantColorHex as null.
    }

    bookmark
      ..localThumbnailPath = filePath
      ..dominantColorHex = dominantColorHex
      ..thumbnailStatus = ThumbnailStatus.done
      ..updatedAt = DateTime.now();
    await _repository.update(bookmark);
  }

  Future<void> _markFailed(BookmarkItem bookmark) async {
    bookmark
      ..thumbnailStatus = ThumbnailStatus.failed
      ..updatedAt = DateTime.now();
    await _repository.update(bookmark);
  }

  /// Writes [bytes] to the app documents directory under
  /// `marky_cache/images/thumbnails/` and returns the absolute path.
  Future<String> _writeImageFile({
    required int bookmarkId,
    required String imageUrl,
    required Uint8List bytes,
  }) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String extension = _extractExtension(imageUrl);
    final String fileName = '${bookmarkId}_thumbnail$extension';
    final String dirPath = path.join(
      appDir.path,
      'marky_cache',
      'images',
      'thumbnails',
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

  /// Extracts a safe file extension from [imageUrl].
  ///
  /// Falls back to `.jpg` when the URL has no recognizable extension.
  String _extractExtension(String imageUrl) {
    try {
      final Uri uri = Uri.parse(imageUrl);
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
          ].contains(ext)) {
        return ext;
      }
    } on Exception {
      // Malformed URL — fall through to default.
    }
    return '.jpg';
  }
}
