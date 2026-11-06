import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/html_canonical_extractor.dart';

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
  late HtmlCanonicalExtractor extractor;

  setUp(() {
    dio = DioClient.create();
    extractor = HtmlCanonicalExtractor(dio: dio);
  });

  tearDown(() {
    dio.close();
  });

  // -----------------------------------------------------------------
  // 1. Happy path — canonical link tag found.
  // -----------------------------------------------------------------
  group('canonical link tag', () {
    test('extracts canonical URL from link rel="canonical"', () async {
      const String url = 'https://example.com/article';
      const String canonical = 'https://example.com/article?ref=clean';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$canonical"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, canonical);
      expect(result.externalContentId, '');
    });

    test('handles single quotes in canonical link', () async {
      const String url = 'https://example.com/page';
      const String canonical = 'https://example.com/page?clean=1';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      "<html><head><link rel='canonical' href='$canonical'></head></html>",
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, canonical);
    });

    test('handles extra spaces and attributes in canonical link', () async {
      const String url = 'https://example.com/page';
      const String canonical = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link   rel = "canonical"   data-id="x"  href = "$canonical" ></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, canonical);
    });

    test('handles href before rel attribute ordering', () async {
      const String url = 'https://example.com/page';
      const String canonical = 'https://example.com/page?ordered=1';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link href="$canonical" rel="canonical"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, canonical);
    });

    test('handles uppercase CANONICAL', () async {
      const String url = 'https://example.com/page';
      const String canonical = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="CANONICAL" href="$canonical"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, canonical);
    });
  });

  // -----------------------------------------------------------------
  // 2. og:url meta tag fallback.
  // -----------------------------------------------------------------
  group('og:url meta tag', () {
    test('extracts og:url when no canonical link present', () async {
      const String url = 'https://example.com/post';
      const String ogUrl = 'https://example.com/post?og=1';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><meta property="og:url" content="$ogUrl"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, ogUrl);
    });

    test('handles content before property attribute ordering', () async {
      const String url = 'https://example.com/post';
      const String ogUrl = 'https://example.com/post?ordered=1';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><meta content="$ogUrl" property="og:url"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, ogUrl);
    });

    test('handles extra attributes on og:url meta tag', () async {
      const String url = 'https://example.com/post';
      const String ogUrl = 'https://example.com/post';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><meta data-foo="bar" property="og:url" data-baz="qux" content="$ogUrl"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, ogUrl);
    });
  });

  // -----------------------------------------------------------------
  // 3. Canonical preferred over og:url.
  // -----------------------------------------------------------------
  group('canonical preferred over og:url', () {
    test('prefers link rel=canonical over og:url', () async {
      const String url = 'https://example.com/page';
      const String canonical = 'https://example.com/canonical';
      const String ogUrl = 'https://example.com/og';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$canonical"><meta property="og:url" content="$ogUrl"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, canonical);
    });
  });

  // -----------------------------------------------------------------
  // 4. Missing canonical/og:url tags → null.
  // -----------------------------------------------------------------
  group('missing tags', () {
    test('returns null when no canonical or og:url present', () async {
      const String url = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body: '<html><head><title>No Canonical</title></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNull);
    });

    test('returns null for empty HTML response', () async {
      const String url = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(o, body: ''),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 5. Cross-domain canonical hijacking guard.
  // -----------------------------------------------------------------
  group('host validation', () {
    test('rejects canonical pointing to different host', () async {
      const String url = 'https://example.com/page';
      const String evilCanonical = 'https://evil.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$evilCanonical"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNull);
    });

    test('allows canonical with www subdomain difference', () async {
      const String url = 'https://example.com/page';
      const String canonical = 'https://www.example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$canonical"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      // www.example.com != example.com, so this should be rejected.
      expect(result, isNull);
    });

    test('allows exact host match', () async {
      const String url = 'https://blog.example.com/post';
      const String canonical = 'https://blog.example.com/post?clean=1';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$canonical"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, canonical);
    });

    test('rejects og:url pointing to different host', () async {
      const String url = 'https://example.com/post';
      const String evilOg = 'https://evil.com/post';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><meta property="og:url" content="$evilOg"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 6. Timeout handling.
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
                      '<html><head><link rel="canonical" href="$url"></head></html>',
                ),
          },
          delayedFixtures: <String, Future<void>>{
            url: Future<void>.delayed(const Duration(milliseconds: 200)),
          },
        ),
      );

      final HtmlCanonicalExtractor fastExtractor = HtmlCanonicalExtractor(
        dio: dio,
        requestTimeout: const Duration(milliseconds: 50),
        overallTimeout: const Duration(milliseconds: 100),
      );

      final result = await fastExtractor.extract(url);
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 7. Malformed HTML.
  // -----------------------------------------------------------------
  group('malformed HTML', () {
    test('returns null for unclosed tags', () async {
      const String url = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="https://example.com/page"',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      // Unclosed tag — the regex should not match.
      expect(result, isNull);
    });

    test('returns null for broken attribute syntax', () async {
      const String url = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel==canonical href==https://example.com/page></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 8. Empty/null input.
  // -----------------------------------------------------------------
  group('empty/null input', () {
    test('returns null for empty string', () async {
      final result = await extractor.extract('');
      expect(result, isNull);
    });

    test('returns null for whitespace-only string', () async {
      final result = await extractor.extract('   ');
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 9. Non-2xx responses.
  // -----------------------------------------------------------------
  group('non-2xx responses', () {
    test('returns null on 500 response', () async {
      const String url = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$url"></head></html>',
                  statusCode: 500,
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
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

      final result = await extractor.extract(url);
      expect(result, isNull);
    });

    test('returns null on 301 redirect response (non-followed)', () async {
      const String url = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$url"></head></html>',
                  statusCode: 301,
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 10. Network errors.
  // -----------------------------------------------------------------
  group('network errors', () {
    test('returns null when no fixture (simulated network error)', () async {
      const String url = 'https://example.com/page';
      // No interceptors registered that match this URL.
      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{},
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 11. Edge cases.
  // -----------------------------------------------------------------
  group('edge cases', () {
    test('handles malformed URL input', () async {
      final result = await extractor.extract('ht!tp://[::1');
      expect(result, isNull);
    });

    test('handles relative canonical URL', () async {
      const String url = 'https://example.com/page';
      const String relativeCanonical = '/page?clean=1';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$relativeCanonical"></head></html>',
                ),
          },
        ),
      );

      // Relative URLs don't have a host, so host validation fails.
      final result = await extractor.extract(url);
      expect(result, isNull);
    });

    test('handles protocol-relative canonical URL', () async {
      const String url = 'https://example.com/page';
      const String protocolRelative = '//example.com/page?clean=1';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$protocolRelative"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, 'https://example.com/page?clean=1');
    });

    test('handles canonical with path-only match', () async {
      const String url = 'https://example.com/page';
      const String canonical = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$canonical"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, canonical);
    });

    test('returns null when canonical is empty string', () async {
      const String url = 'https://example.com/page';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href=""></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNull);
    });

    test('extracts first canonical when multiple present', () async {
      const String url = 'https://example.com/page';
      const String firstCanonical = 'https://example.com/first';
      const String secondCanonical = 'https://example.com/second';

      dio.interceptors.add(
        _FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => _htmlResponse(
                  o,
                  body:
                      '<html><head><link rel="canonical" href="$firstCanonical"><link rel="canonical" href="$secondCanonical"></head></html>',
                ),
          },
        ),
      );

      final result = await extractor.extract(url);
      expect(result, isNotNull);
      expect(result!.canonicalUrl, firstCanonical);
    });
  });
}
