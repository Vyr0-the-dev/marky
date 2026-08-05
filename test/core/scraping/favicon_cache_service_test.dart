import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/scraping/enums/favicon_status.dart';
import 'package:marky/core/scraping/services/favicon_cache_service.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';
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
  String contentType = 'image/png',
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
  late FaviconCacheService service;
  late Directory tempDir;

  setUp(() async {
    repository = _FakeBookmarkItemRepository();
    dio = Dio();

    // Create a temp directory to act as app documents.
    tempDir = Directory.systemTemp.createTempSync('marky_favicon_cache_test_');

    // Mock path_provider channel.
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });

    service = FaviconCacheService(repository: repository, dio: dio);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    FaviconCacheService.reset();

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
      FaviconCacheService.reset();
      expect(() => FaviconCacheService.instance, throwsStateError);
    });

    test('initialize wires instance', () {
      FaviconCacheService.reset();
      FaviconCacheService.initialize(repository: repository);
      expect(FaviconCacheService.instance, isA<FaviconCacheService>());
    });

    test('instanceOrNull returns null when not initialized', () {
      FaviconCacheService.reset();
      expect(FaviconCacheService.instanceOrNull, isNull);
    });

    test('reset clears instance', () {
      FaviconCacheService.initialize(repository: repository);
      expect(FaviconCacheService.instanceOrNull, isNotNull);
      FaviconCacheService.reset();
      expect(FaviconCacheService.instanceOrNull, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 2. Success path
  // -----------------------------------------------------------------
  group('success path', () {
    test('downloads favicon, writes file, and updates bookmark', () async {
      const String faviconUrl = 'https://example.com/favicon.ico';
      final List<int> imageBytes = <int>[0x00, 0x00, 0x01, 0x00]; // ICO header-ish

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        faviconUrl: faviconUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            faviconUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: imageBytes,
                  contentType: 'image/x-icon',
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(updated, isNotNull);
      expect(updated!.faviconStatus, FaviconStatus.done);
      expect(updated.localFaviconPath, isNotNull);
      expect(updated.localFaviconPath, contains('marky_cache'));
      expect(updated.localFaviconPath, contains('favicons'));

      // Verify file was written.
      final File cachedFile = File(updated.localFaviconPath!);
      expect(cachedFile.existsSync(), isTrue);
      expect(await cachedFile.readAsBytes(), Uint8List.fromList(imageBytes));
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

    test('sets failed when faviconUrl is null', () async {
      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(updated!.faviconStatus, FaviconStatus.failed);
    });

    test('sets failed when faviconUrl is empty', () async {
      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        faviconUrl: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(updated!.faviconStatus, FaviconStatus.failed);
    });

    test('sets failed on 404 response', () async {
      const String faviconUrl = 'https://example.com/missing.ico';

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        faviconUrl: faviconUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            faviconUrl: (RequestOptions o) => _imageResponse(
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
      expect(updated!.faviconStatus, FaviconStatus.failed);
    });

    test('sets failed on non-image content-type', () async {
      const String faviconUrl = 'https://example.com/fake.ico';

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        faviconUrl: faviconUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            faviconUrl: (RequestOptions o) => Response<List<int>>(
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
      expect(updated!.faviconStatus, FaviconStatus.failed);
    });

    test('sets failed on network error (DioException)', () async {
      const String faviconUrl = 'https://example.com/favicon.ico';

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        faviconUrl: faviconUrl,
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
      expect(updated!.faviconStatus, FaviconStatus.failed);
    });

    test('sets failed on timeout', () async {
      const String faviconUrl = 'https://slow.example.com/favicon.ico';

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        faviconUrl: faviconUrl,
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
      expect(updated!.faviconStatus, FaviconStatus.failed);
    });
  });

  // -----------------------------------------------------------------
  // 4. In-flight deduplication
  // -----------------------------------------------------------------
  group('deduplication', () {
    test('two concurrent calls for same URL share one download', () async {
      const String faviconUrl = 'https://example.com/favicon.ico';
      final List<int> imageBytes = <int>[0x00, 0x00, 0x01, 0x00];
      int downloadCount = 0;

      final BookmarkItem bookmark1 = BookmarkItem(
        originalUrl: 'https://example.com/article1',
        faviconUrl: faviconUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final BookmarkItem bookmark2 = BookmarkItem(
        originalUrl: 'https://example.com/article2',
        faviconUrl: faviconUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark1);
      await repository.insert(bookmark2);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            faviconUrl: (RequestOptions o) {
              downloadCount++;
              return _imageResponse(
                o,
                bytes: imageBytes,
                contentType: 'image/x-icon',
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
      expect(updated1!.faviconStatus, FaviconStatus.done);
      expect(updated2!.faviconStatus, FaviconStatus.done);
      expect(updated1.localFaviconPath, isNotNull);
      expect(updated2.localFaviconPath, isNotNull);
    });
  });

  // -----------------------------------------------------------------
  // 5. Filename generation
  // -----------------------------------------------------------------
  group('filename generation', () {
    test('uses .ico extension from URL', () async {
      const String faviconUrl = 'https://example.com/favicon.ico';
      final List<int> imageBytes = <int>[0x00, 0x00, 0x01, 0x00];

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        faviconUrl: faviconUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            faviconUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: imageBytes,
                  contentType: 'image/x-icon',
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(path.extension(updated!.localFaviconPath!), '.ico');
    });

    test('uses .png extension from URL', () async {
      const String faviconUrl = 'https://example.com/favicon.png';
      final List<int> imageBytes = <int>[0x89, 0x50, 0x4E, 0x47];

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        faviconUrl: faviconUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            faviconUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: imageBytes,
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(path.extension(updated!.localFaviconPath!), '.png');
    });

    test('falls back to .png for URL without extension', () async {
      const String faviconUrl = 'https://example.com/favicon';
      final List<int> imageBytes = <int>[0x89, 0x50, 0x4E, 0x47];

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        faviconUrl: faviconUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            faviconUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: imageBytes,
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(path.extension(updated!.localFaviconPath!), '.png');
    });

    test('falls back to .png for unrecognizable extension', () async {
      const String faviconUrl = 'https://example.com/favicon.xyz';
      final List<int> imageBytes = <int>[0x89, 0x50, 0x4E, 0x47];

      final BookmarkItem bookmark = BookmarkItem(
        originalUrl: 'https://example.com/article',
        faviconUrl: faviconUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.insert(bookmark);

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<List<int>> Function(RequestOptions)>{
            faviconUrl: (RequestOptions o) => _imageResponse(
                  o,
                  bytes: imageBytes,
                ),
          },
        ),
      );

      await service.downloadAndCache(bookmark.id);

      final BookmarkItem? updated = await repository.getById(bookmark.id);
      expect(path.extension(updated!.localFaviconPath!), '.png');
    });
  });
}
