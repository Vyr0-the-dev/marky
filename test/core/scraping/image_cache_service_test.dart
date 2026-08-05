import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/scraping/enums/thumbnail_status.dart';
import 'package:marky/core/scraping/services/image_cache_service.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as path;

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

/// In-memory fake implementation of [BookmarkItemRepository] for testing.
class _FakeBookmarkItemRepository implements BookmarkItemRepository {
  final Map<int, BookmarkItem> _items = <int, BookmarkItem>{};
  int _nextId = 1;

  @override
  Future<BookmarkItem?> getById(Id id) async => _items[id];

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => _items.values.toList();

  @override
  Future<Id> insert(BookmarkItem entity) async {
    final int id = _nextId++;
    entity.id = id;
    _items[id] = entity;
    return id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async {
    _items[entity.id] = entity;
    return entity.id;
  }

  @override
  Future<void> delete(Id id) async {
    _items.remove(id);
  }

  @override
  Future<void> clear() async {
    _items.clear();
    _nextId = 1;
  }

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async => null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

// ---------------------------------------------------------------------------
// Dio fixture helpers
// ---------------------------------------------------------------------------

/// An [Interceptor] that returns pre-baked GET responses based on the
/// request URL. No real network calls are made.
class _FixtureInterceptor extends Interceptor {
  _FixtureInterceptor({
    required Map<String, Response<List<int>> Function(RequestOptions)> fixtures,
    Map<String, Future<void>>? delayedFixtures,
  })  : _fixtures = fixtures,
        _delayedFixtures = delayedFixtures ?? <String, Future<void>>{};

  final Map<String, Response<List<int>> Function(RequestOptions)> _fixtures;
  final Map<String, Future<void>> _delayedFixtures;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String key = options.uri.toString();

    if (_delayedFixtures.containsKey(key)) {
      _delayedFixtures[key]!.then((_) {
        final Response<List<int>> Function(RequestOptions)? builder =
            _fixtures[key];
        if (builder == null) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'No fixture for GET $key',
            ),
          );
          return;
        }
        handler.resolve(builder(options));
      });
      return;
    }

    final Response<List<int>> Function(RequestOptions)? builder =
        _fixtures[key];

    if (builder == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'No fixture for GET $key',
        ),
      );
      return;
    }

    handler.resolve(builder(options));
  }
}

Response<List<int>> _imageResponse(
  RequestOptions options, {
  required List<int> bytes,
  int statusCode = 200,
  String contentType = 'image/jpeg',
}) {
  return Response<List<int>>(
    requestOptions: options,
    statusCode: statusCode,
    headers: Headers.fromMap(<String, List<String>>{
      'content-type': <String>[contentType],
    }),
    data: bytes,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeBookmarkItemRepository repository;
  late Dio dio;
  late ImageCacheService service;
  late Directory tempDir;

  setUp(() async {
    repository = _FakeBookmarkItemRepository();
    dio = Dio();

    // Create a temp directory to act as app documents.
    tempDir = Directory.systemTemp.createTempSync('marky_image_cache_test_');

    // Mock path_provider channel.
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });

    service = ImageCacheService(
      repository: repository,
      dio: dio,
      paletteGeneratorFactory: (ImageProvider provider, {Size? size}) async {
        return PaletteGenerator.fromColors(
          <PaletteColor>[
            PaletteColor(Colors.blue, 1),
          ],
        );
      },
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    ImageCacheService.reset();

    // Clean up temp directory.
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  // -----------------------------------------------------------------
  // 1. Singleton pattern
  // -----------------------------------------------------------------
  group('singleton', () {
    test('instance throws before initialize', () {
      ImageCacheService.reset();
      expect(() => ImageCacheService.instance, throwsStateError);
    });

    test('initialize wires instance', () {
      ImageCacheService.reset();
      ImageCacheService.initialize(repository: repository);
      expect(ImageCacheService.instance, isA<ImageCacheService>());
    });

    test('instanceOrNull returns null when not initialized', () {
      ImageCacheService.reset();
      expect(ImageCacheService.instanceOrNull, isNull);
    });

    test('reset clears instance', () {
      ImageCacheService.initialize(repository: repository);
      expect(ImageCacheService.instanceOrNull, isNotNull);
      ImageCacheService.reset();
      expect(ImageCacheService.instanceOrNull, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 2. Success path
  // -----------------------------------------------------------------
  group('success path', () {
    test('downloads image, writes file, and updates bookmark', () async {
      const String imageUrl = 'https://example.com/image.jpg';
      final List<int> imageBytes = <int>[0xFF, 0xD8, 0xFF]; // JPEG header

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        thumbnailUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            imageUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: imageBytes,
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(updated, isNotNull);
      expect(updated!.thumbnailStatus, ThumbnailStatus.done);
      expect(updated.localThumbnailPath, isNotNull);
      expect(updated.localThumbnailPath, contains('marky_cache'));
      expect(updated.localThumbnailPath, contains('thumbnails'));

      // Verify file was written.
      final File cachedFile = File(updated.localThumbnailPath!);
      expect(cachedFile.existsSync(), isTrue);
      expect(await cachedFile.readAsBytes(), Uint8List.fromList(imageBytes));
    });

    test('falls back to heroImageUrl when thumbnailUrl is null', () async {
      const String heroUrl = 'https://example.com/hero.png';
      final List<int> imageBytes = <int>[0x89, 0x50, 0x4E, 0x47]; // PNG header

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        heroImageUrl: heroUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            heroUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: imageBytes,
                  contentType: 'image/png',
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(updated!.thumbnailStatus, ThumbnailStatus.done);
      expect(updated.localThumbnailPath, isNotNull);
      expect(path.extension(updated.localThumbnailPath!), '.png');
    });
  });

  // -----------------------------------------------------------------
  // 3. Error paths
  // -----------------------------------------------------------------
  group('error paths', () {
    test('sets failed when bookmark not found', () async {
      await service.downloadAndCache(999);
      // No crash, no bookmark to check.
      expect(await repository.getById(999), isNull);
    });

    test('sets failed when both thumbnailUrl and heroImageUrl are null',
        () async {
      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(updated!.thumbnailStatus, ThumbnailStatus.failed);
    });

    test('sets failed on 404 response', () async {
      const String imageUrl = 'https://example.com/missing.jpg';

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        thumbnailUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            imageUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: <int>[],
                  statusCode: 404,
                  contentType: 'text/html',
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(updated!.thumbnailStatus, ThumbnailStatus.failed);
    });

    test('sets failed on non-image content-type', () async {
      const String imageUrl = 'https://example.com/fake.jpg';

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        thumbnailUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            imageUrl: (RequestOptions o) => Response<List<int>>(
                  requestOptions: o,
                  statusCode: 200,
                  headers: Headers.fromMap(<String, List<String>>{
                    'content-type': <String>['text/html'],
                  }),
                  data: <int>[1, 2, 3],
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(updated!.thumbnailStatus, ThumbnailStatus.failed);
    });

    test('sets failed on network error (DioException)', () async {
      const String imageUrl = 'https://example.com/image.jpg';

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        thumbnailUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{},
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(updated!.thumbnailStatus, ThumbnailStatus.failed);
    });

    test('sets failed on timeout', () async {
      const String imageUrl = 'https://slow.example.com/image.jpg';

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        thumbnailUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.receiveTimeout,
                error: 'Receive timeout',
              ),
            );
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(updated!.thumbnailStatus, ThumbnailStatus.failed);
    });
  });

  // -----------------------------------------------------------------
  // 4. In-flight deduplication
  // -----------------------------------------------------------------
  group('deduplication', () {
    test('two concurrent calls for same URL share one download', () async {
      const String imageUrl = 'https://example.com/image.jpg';
      final List<int> imageBytes = <int>[0xFF, 0xD8, 0xFF];
      int downloadCount = 0;

      final BookmarkItem bookmark1 = BookmarkItem(
        originalUrl: 'https://example.com/article1',
        thumbnailUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final BookmarkItem bookmark2 = BookmarkItem(
        originalUrl: 'https://example.com/article2',
        thumbnailUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark1);
      await repository.insert(bookmark2);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            imageUrl: (RequestOptions o) {
              downloadCount++;
              return _imageResponse(
                o,
                bytes: imageBytes,
              );
            },
          },
        ),
      );

      // Launch both concurrently.
      await Future.wait(<Future<void>>[
        service.downloadAndCache(bookmark1.id),
        service.downloadAndCache(bookmark2.id),
      ]);

      expect(downloadCount, 1);

      final BookmarkItem? updated1 = await repository.getById(bookmark1.id);
      final BookmarkItem? updated2 = await repository.getById(bookmark2.id);
      expect(updated1!.thumbnailStatus, ThumbnailStatus.done);
      expect(updated2!.thumbnailStatus, ThumbnailStatus.done);
      expect(updated1.localThumbnailPath, isNotNull);
      expect(updated2.localThumbnailPath, isNotNull);
    });
  });

  // -----------------------------------------------------------------
  // 5. Filename generation
  // -----------------------------------------------------------------
  group('filename generation', () {
    test('uses correct extension from URL', () async {
      const String imageUrl = 'https://example.com/image.webp';
      final List<int> imageBytes = <int>[0x52, 0x49, 0x46, 0x46]; // WebP-ish

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        thumbnailUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            imageUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: imageBytes,
                  contentType: 'image/webp',
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(path.extension(updated!.localThumbnailPath!), '.webp');
    });

    test('falls back to .jpg for URL without extension', () async {
      const String imageUrl = 'https://example.com/image';
      final List<int> imageBytes = <int>[0xFF, 0xD8, 0xFF];

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        thumbnailUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            imageUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: imageBytes,
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(path.extension(updated!.localThumbnailPath!), '.jpg');
    });

    test('falls back to .jpg for unrecognizable extension', () async {
      const String imageUrl = 'https://example.com/image.xyz';
      final List<int> imageBytes = <int>[0xFF, 0xD8, 0xFF];

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        thumbnailUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            imageUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: imageBytes,
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(path.extension(updated!.localThumbnailPath!), '.jpg');
    });
  });
}
