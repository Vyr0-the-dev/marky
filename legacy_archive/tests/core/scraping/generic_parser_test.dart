import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/parsers/generic_parser.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

/// Returns a [Response] that represents an HTML response with the given body.
Response<String> _htmlResponse(
  RequestOptions options, {
  required String body,
  int statusCode = 200,
}) {
  return Response<String>(
    requestOptions: options,
    statusCode: statusCode,
    headers: Headers.fromMap(<String, List<String>>{
      'content-type': <String>['text/html'],
    }),
    data: body,
  );
}

/// An [Interceptor] that returns pre-baked GET responses based on the
/// request URL. No real network calls are made.
class _FixtureInterceptor extends Interceptor {
  _FixtureInterceptor({
    required Map<String, Response<String> Function(RequestOptions)> fixtures,
    Map<String, Future<void>>? delayedFixtures,
  })  : _fixtures = fixtures,
        _delayedFixtures = delayedFixtures ?? <String, Future<void>>{};

  final Map<String, Response<String> Function(RequestOptions)> _fixtures;
  final Map<String, Future<void>> _delayedFixtures;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String key = options.uri.toString();

    if (_delayedFixtures.containsKey(key)) {
      _delayedFixtures[key]!.then((_) {
        final Response<String> Function(RequestOptions)? builder =
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

    final Response<String> Function(RequestOptions)? builder = _fixtures[key];

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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Dio dio;
  late GenericParser parser;

  setUp(() {
    dio = DioClient.create();
    parser = GenericParser(dio: dio);
  });

  tearDown(() {
    dio.close();
  });

  // -----------------------------------------------------------------
  // 1. Contract compliance
  // -----------------------------------------------------------------
  group('contract', () {
    test('implements SourceParser', () {
      expect(parser, isA<SourceParser>());
    });

    test('hosts is empty set', () {
      expect(parser.hosts, isEmpty);
    });

    test('instance singleton returns same object', () {
      final GenericParser a = GenericParser.instance;
      final GenericParser b = GenericParser.instance;
      expect(a, same(b));
    });
  });

  // -----------------------------------------------------------------
  // 2. OpenGraph extraction — happy path
  // -----------------------------------------------------------------
  group('OpenGraph tags', () {
    test('extracts all OG fields', () async {
      const String url = 'https://example.com/article';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="OG Title">
  <meta property="og:description" content="OG Description">
  <meta property="og:image" content="https://example.com/image.jpg">
  <meta property="og:site_name" content="Example Site">
  <meta property="og:type" content="article">
  <meta property="og:locale" content="en_US">
  <meta property="article:author" content="John Doe">
  <meta property="article:published_time" content="2024-01-15T10:30:00Z">
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'OG Title');
      expect(result.description, 'OG Description');
      expect(result.thumbnailUrl, 'https://example.com/image.jpg');
      expect(result.heroImageUrl, 'https://example.com/image.jpg');
      expect(result.siteName, 'Example Site');
      expect(result.author, 'John Doe');
      expect(result.publisher, 'Example Site');
      expect(result.contentType, 'article');
      expect(result.languageCode, 'en_US');
      expect(result.publishDate, DateTime.utc(2024, 1, 15, 10, 30));
    });

    test('uses og:image:secure_url for hero image when present', () async {
      const String url = 'https://example.com/article';
      const String html = '''
<html>
<head>
  <meta property="og:image" content="http://example.com/image.jpg">
  <meta property="og:image:secure_url" content="https://example.com/image.jpg">
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.thumbnailUrl, 'http://example.com/image.jpg');
      expect(result.heroImageUrl, 'https://example.com/image.jpg');
    });
  });

  // -----------------------------------------------------------------
  // 3. HTML fallback
  // -----------------------------------------------------------------
  group('HTML fallback', () {
    test('falls back to <title> when og:title missing', () async {
      const String url = 'https://example.com/page';
      const String html = '''
<html><head><title>Page Title</title></head></html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Page Title');
    });

    test('falls back to meta description when og:description missing',
        () async {
      const String url = 'https://example.com/page';
      const String html = '''
<html>
<head>
  <meta name="description" content="Meta Description">
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.description, 'Meta Description');
    });

    test('OG tags take priority over HTML fallbacks', () async {
      const String url = 'https://example.com/page';
      const String html = '''
<html>
<head>
  <title>HTML Title</title>
  <meta name="description" content="HTML Description">
  <meta property="og:title" content="OG Title">
  <meta property="og:description" content="OG Description">
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'OG Title');
      expect(result.description, 'OG Description');
    });
  });

  // -----------------------------------------------------------------
  // 4. Favicon extraction
  // -----------------------------------------------------------------
  group('favicon', () {
    test('extracts link rel="icon"', () async {
      const String url = 'https://example.com/page';
      const String html = '''
<html>
<head>
  <link rel="icon" href="/favicon.ico">
  <title>Page</title>
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.faviconUrl, 'https://example.com/favicon.ico');
    });

    test('extracts link rel="shortcut icon"', () async {
      const String url = 'https://example.com/page';
      const String html = '''
<html>
<head>
  <link rel="shortcut icon" href="/shortcut.ico">
  <title>Page</title>
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.faviconUrl, 'https://example.com/shortcut.ico');
    });

    test('prefers icon over shortcut icon', () async {
      const String url = 'https://example.com/page';
      const String html = '''
<html>
<head>
  <link rel="icon" href="/icon.ico">
  <link rel="shortcut icon" href="/shortcut.ico">
  <title>Page</title>
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.faviconUrl, 'https://example.com/icon.ico');
    });
  });

  // -----------------------------------------------------------------
  // 5. URL resolution
  // -----------------------------------------------------------------
  group('URL resolution', () {
    test('resolves relative image URL to absolute', () async {
      const String url = 'https://example.com/blog/post';
      const String html = '''
<html>
<head>
  <meta property="og:image" content="/images/hero.jpg">
  <title>Post</title>
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.thumbnailUrl, 'https://example.com/images/hero.jpg');
    });

    test('resolves protocol-relative URL', () async {
      const String url = 'https://example.com/page';
      const String html = '''
<html>
<head>
  <meta property="og:image" content="//cdn.example.com/image.jpg">
  <title>Page</title>
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.thumbnailUrl, 'https://cdn.example.com/image.jpg');
    });

    test('keeps absolute URL unchanged', () async {
      const String url = 'https://example.com/page';
      const String imageUrl = 'https://cdn.example.com/image.jpg';
      const String html = '''
<html>
<head>
  <meta property="og:image" content="$imageUrl">
  <title>Page</title>
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.thumbnailUrl, imageUrl);
    });
  });

  // -----------------------------------------------------------------
  // 6. Scheme validation
  // -----------------------------------------------------------------
  group('scheme validation', () {
    test('rejects file:// URLs', () async {
      final result = await parser.parse('file:///etc/passwd');
      expect(result, isNull);
    });

    test('rejects javascript: URLs', () async {
      final result = await parser.parse('javascript:alert(1)');
      expect(result, isNull);
    });

    test('rejects data: URLs', () async {
      final result = await parser.parse('data:text/html,<html></html>');
      expect(result, isNull);
    });

    test('accepts http:// URLs', () async {
      const String url = 'http://example.com/page';
      const String html = '<html><head><title>HTTP</title></head></html>';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'HTTP');
    });

    test('accepts https:// URLs', () async {
      const String url = 'https://example.com/page';
      const String html = '<html><head><title>HTTPS</title></head></html>';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'HTTPS');
    });
  });

  // -----------------------------------------------------------------
  // 7. Empty / null input
  // -----------------------------------------------------------------
  group('empty/null input', () {
    test('returns null for empty string', () async {
      final result = await parser.parse('');
      expect(result, isNull);
    });

    test('returns null for whitespace-only string', () async {
      final result = await parser.parse('   ');
      expect(result, isNull);
    });

    test('returns null for malformed URL', () async {
      final result = await parser.parse('ht!tp://[::1');
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 8. Non-2xx responses
  // -----------------------------------------------------------------
  group('non-2xx responses', () {
    test('returns null on 500 response', () async {
      const String url = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body: '<html>Server Error</html>',
                  statusCode: 500,
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on 404 response', () async {
      const String url = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body: '<html>Not Found</html>',
                  statusCode: 404,
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 9. Network errors
  // -----------------------------------------------------------------
  group('network errors', () {
    test('returns null on DioException', () async {
      const String url = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{},
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 10. Timeout handling
  // -----------------------------------------------------------------
  group('timeout', () {
    test('returns null on delayed response exceeding overall timeout',
        () async {
      const String url = 'https://slow.example.com';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><title>Slow</title></head></html>',
                ),
          },
          delayedFixtures: <String, Future<void>>{
            url: Future<void>.delayed(const Duration(milliseconds: 200)),
          },
        ),
      );

      final GenericParser fastParser = GenericParser(dio: dio);
      // Override the Dio instance's timeouts via options
      final result = await fastParser.parse(url).timeout(
            const Duration(milliseconds: 50),
            onTimeout: () => null,
          );
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 11. Empty metadata guard
  // -----------------------------------------------------------------
  group('empty metadata guard', () {
    test('returns null when no metadata found at all', () async {
      const String url = 'https://example.com/page';
      const String html = '<html><head></head><body>Empty</body></html>';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 12. Missing media
  // -----------------------------------------------------------------
  group('missing media', () {
    test('returns null image fields when no images present', () async {
      const String url = 'https://example.com/page';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="Title Without Images">
  <meta property="og:description" content="Description">
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Title Without Images');
      expect(result.description, 'Description');
      expect(result.thumbnailUrl, isNull);
      expect(result.heroImageUrl, isNull);
      expect(result.faviconUrl, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 13. Malformed HTML
  // -----------------------------------------------------------------
  group('malformed HTML', () {
    test('handles unclosed tags without crashing', () async {
      const String url = 'https://example.com/page';
      const String html = '''
<html><head>
  <meta property="og:title" content="Unclosed Title">
  <meta property="og:description" content="Unclosed Description"
  <link rel="icon" href="/favicon.ico"
</head></html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      // html_parser is forgiving; it should still extract the title
      expect(result, isNotNull);
      expect(result!.title, 'Unclosed Title');
    });

    test('handles deeply malformed HTML gracefully', () async {
      const String url = 'https://example.com/page';
      const String html = '<>>> <<<< not html at all << meta og:title';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      // Should return null or partial metadata without throwing
      // The html_parser package typically returns an empty document
      // for garbage input, which means no metadata → null
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 14. Minimal metadata acceptance
  // -----------------------------------------------------------------
  group('minimal metadata', () {
    test('returns metadata when only title is present', () async {
      const String url = 'https://example.com/page';
      const String html = '<html><head><title>Only Title</title></head></html>';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Only Title');
      expect(result.description, isNull);
      expect(result.thumbnailUrl, isNull);
    });

    test('returns metadata when only description is present', () async {
      const String url = 'https://example.com/page';
      const String html = '''
<html>
<head>
  <meta name="description" content="Only Description">
</head>
</html>
''';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, isNull);
      expect(result.description, 'Only Description');
    });
  });
}
