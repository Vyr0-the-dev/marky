
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/features/capture/domain/services/redirect_resolver_service.dart';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

/// Returns a [Response] that represents a 3xx redirect.
Response<dynamic> _redirectResponse(
  RequestOptions options,
  int statusCode,
  String location,
) {
  return Response<dynamic>(
    requestOptions: options,
    statusCode: statusCode,
    headers: Headers.fromMap(<String, List<String>>{
      'location': <String>[location],
    }),
    data: '',
  );
}

/// Returns a [Response] that represents a final 200 OK.
Response<dynamic> _okResponse(RequestOptions options) {
  return Response<dynamic>(
    requestOptions: options,
    statusCode: 200,
    headers: Headers.fromMap(<String, List<String>>{
      'content-type': <String>['text/html'],
    }),
    data: '<html></html>',
  );
}

/// Returns a [Response] that represents a HEAD-not-supported status.
Response<dynamic> _headNotAllowedResponse(
  RequestOptions options,
  int statusCode,
) {
  return Response<dynamic>(
    requestOptions: options,
    statusCode: statusCode,
    data: '',
  );
}

/// An [Interceptor] that returns pre-baked responses based on the
/// request URL and HTTP method. No real network calls are made.
class _FixtureInterceptor extends Interceptor {
  _FixtureInterceptor({
    required Map<String, Response<dynamic> Function(RequestOptions)> headFixtures,
    required Map<String, Response<dynamic> Function(RequestOptions)> getFixtures,
    Map<String, Future<void>>? delayedHeadFixtures,
    Map<String, Future<void>>? delayedGetFixtures,
  })  : _headFixtures = headFixtures,
        _getFixtures = getFixtures,
        _delayedHeadFixtures = delayedHeadFixtures ?? <String, Future<void>>{},
        _delayedGetFixtures = delayedGetFixtures ?? <String, Future<void>>{};

  final Map<String, Response<dynamic> Function(RequestOptions)> _headFixtures;
  final Map<String, Response<dynamic> Function(RequestOptions)> _getFixtures;
  final Map<String, Future<void>> _delayedHeadFixtures;
  final Map<String, Future<void>> _delayedGetFixtures;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String key = options.uri.toString();
    final bool isHead = options.method == 'HEAD';

    final Map<String, Future<void>> delayed =
        isHead ? _delayedHeadFixtures : _delayedGetFixtures;

    if (delayed.containsKey(key)) {
      delayed[key]!.then((_) {
        final Map<String, Response<dynamic> Function(RequestOptions)> fixtures =
            isHead ? _headFixtures : _getFixtures;
        final Response<dynamic> Function(RequestOptions)? builder =
            fixtures[key];
        if (builder == null) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'No fixture for ${options.method} $key',
            ),
          );
          return;
        }
        handler.resolve(builder(options));
      });
      return;
    }

    final Map<String, Response<dynamic> Function(RequestOptions)> fixtures =
        isHead ? _headFixtures : _getFixtures;
    final Response<dynamic> Function(RequestOptions)? builder = fixtures[key];

    if (builder == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'No fixture for ${options.method} $key',
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
  group('RedirectResolverService', () {
    late Dio dio;
    late RedirectResolverService service;

    setUp(() {
      dio = DioClient.create();
      service = RedirectResolverService(dio: dio);
    });

    tearDown(() {
      dio.close();
    });

    // -----------------------------------------------------------------
    // 1. Basic resolution — single 302 → final URL.
    // -----------------------------------------------------------------
    group('basic resolution', () {
      test('single 302 redirect resolves to final URL', () async {
        const String shortUrl = 'https://bit.ly/abc123';
        const String finalUrl = 'https://example.com/article';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              shortUrl: (RequestOptions o) => _redirectResponse(o, 302, finalUrl),
              finalUrl: _okResponse,
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final String? result = await service.resolve(shortUrl);
        expect(result, finalUrl);
      });
    });

    // -----------------------------------------------------------------
    // 2. Multi-hop chains — 2-3 sequential redirects.
    // -----------------------------------------------------------------
    group('multi-hop chains', () {
      test('follows a 3-hop redirect chain', () async {
        const String url1 = 'https://t.co/xyz';
        const String url2 = 'https://bit.ly/abc';
        const String url3 = 'https://example.com/final';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              url1: (RequestOptions o) => _redirectResponse(o, 302, url2),
              url2: (RequestOptions o) => _redirectResponse(o, 307, url3),
              url3: _okResponse,
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final String? result = await service.resolve(url1);
        expect(result, url3);
      });
    });

    // -----------------------------------------------------------------
    // 3. Loop detection — A→B→A triggers null return.
    // -----------------------------------------------------------------
    group('loop detection', () {
      test('A→B→A returns null', () async {
        const String urlA = 'https://a.com';
        const String urlB = 'https://b.com';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              urlA: (RequestOptions o) => _redirectResponse(o, 302, urlB),
              urlB: (RequestOptions o) => _redirectResponse(o, 302, urlA),
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final String? result = await service.resolve(urlA);
        expect(result, isNull);
      });
    });

    // -----------------------------------------------------------------
    // 4. Max hop limit — 6 hops triggers null return.
    // -----------------------------------------------------------------
    group('max hop limit', () {
      test('exceeding default max hops (5) returns null', () async {
        const String base = 'https://chain.com';
        final Map<String, Response<dynamic> Function(RequestOptions)>
            headFixtures = <String, Response<dynamic> Function(RequestOptions)>{};

        // 6 redirects → hop 0..5 all redirect, hop 6 would be 200.
        for (int i = 0; i < 6; i++) {
          headFixtures['$base/$i'] =
              (RequestOptions o) => _redirectResponse(o, 301, '$base/${i + 1}');
        }
        headFixtures['$base/6'] = _okResponse;

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: headFixtures,
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final String? result = await service.resolve('$base/0');
        expect(result, isNull);
      });
    });

    // -----------------------------------------------------------------
    // 5. HEAD unsupported fallback — 405 on HEAD, 200 on GET.
    // -----------------------------------------------------------------
    group('HEAD unsupported fallback', () {
      test('405 on HEAD falls back to GET and returns original URL', () async {
        const String url = 'https://example.com/page';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              url: (RequestOptions o) => _headNotAllowedResponse(o, 405),
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              url: _okResponse,
            },
          ),
        );

        final String? result = await service.resolve(url);
        expect(result, url);
      });

      test('follows redirect after GET fallback', () async {
        const String shortUrl = 'https://bit.ly/abc';
        const String finalUrl = 'https://example.com/final';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              shortUrl: (RequestOptions o) => _headNotAllowedResponse(o, 405),
              finalUrl: _okResponse,
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              shortUrl: (RequestOptions o) =>
                  _redirectResponse(o, 302, finalUrl),
            },
          ),
        );

        final String? result = await service.resolve(shortUrl);
        expect(result, finalUrl);
      });
    });

    // -----------------------------------------------------------------
    // 6. Timeout — simulated delayed response triggers null.
    // -----------------------------------------------------------------
    group('timeout', () {
      test('simulated delayed response triggers null', () async {
        const String url = 'https://slow.example.com';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              url: _okResponse,
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
            delayedHeadFixtures: <String, Future<void>>{
              url: Future<void>.delayed(const Duration(milliseconds: 200)),
            },
          ),
        );

        final RedirectResolverService fastTimeoutService =
            RedirectResolverService(
          dio: dio,
          requestTimeout: const Duration(milliseconds: 50),
          overallTimeout: const Duration(milliseconds: 500),
        );

        final String? result = await fastTimeoutService.resolve(url);
        expect(result, isNull);
      });
    });

    // -----------------------------------------------------------------
    // 7. Malformed Location — missing/invalid Location header returns null.
    // -----------------------------------------------------------------
    group('malformed Location', () {
      test('missing Location header on 301 returns null', () async {
        const String url = 'https://example.com/page';

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  statusCode: 301,
                  data: '',
                ),
              );
            },
          ),
        );

        final String? result = await service.resolve(url);
        expect(result, isNull);
      });
    });

    // -----------------------------------------------------------------
    // 8. Relative Location — /path and //host.com/path resolve correctly.
    // -----------------------------------------------------------------
    group('relative Location', () {
      test('resolves /path relative to host', () async {
        const String shortUrl = 'https://bit.ly/abc';
        const String relative = '/article';
        const String expected = 'https://bit.ly/article';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              shortUrl: (RequestOptions o) =>
                  _redirectResponse(o, 301, relative),
              expected: _okResponse,
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final String? result = await service.resolve(shortUrl);
        expect(result, expected);
      });

      test('resolves //host.com/path scheme-relative', () async {
        const String shortUrl = 'https://bit.ly/abc';
        const String relative = '//example.com/page';
        const String expected = 'https://example.com/page';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              shortUrl: (RequestOptions o) =>
                  _redirectResponse(o, 301, relative),
              expected: _okResponse,
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final String? result = await service.resolve(shortUrl);
        expect(result, expected);
      });
    });

    // -----------------------------------------------------------------
    // 9. Null/empty input — returns null.
    // -----------------------------------------------------------------
    group('null/empty input', () {
      test('returns null for null input', () async {
        final String? result = await service.resolve(null);
        expect(result, isNull);
      });

      test('returns null for empty string', () async {
        final String? result = await service.resolve('');
        expect(result, isNull);
      });

      test('returns null for whitespace-only string', () async {
        final String? result = await service.resolve('   ');
        expect(result, isNull);
      });
    });

    // -----------------------------------------------------------------
    // 10. Non-redirect status — 200 returns original URL.
    // -----------------------------------------------------------------
    group('non-redirect status', () {
      test('200 returns original URL', () async {
        const String url = 'https://example.com/page';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              url: _okResponse,
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final String? result = await service.resolve(url);
        expect(result, url);
      });
    });

    // -----------------------------------------------------------------
    // Additional edge cases
    // -----------------------------------------------------------------
    group('additional edge cases', () {
      test('handles 308 Permanent Redirect', () async {
        const String shortUrl = 'https://bit.ly/abc';
        const String finalUrl = 'https://example.com/final';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              shortUrl: (RequestOptions o) =>
                  _redirectResponse(o, 308, finalUrl),
              finalUrl: _okResponse,
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final String? result = await service.resolve(shortUrl);
        expect(result, finalUrl);
      });

      test('handles 307 Temporary Redirect', () async {
        const String shortUrl = 'https://bit.ly/abc';
        const String finalUrl = 'https://example.com/final';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              shortUrl: (RequestOptions o) =>
                  _redirectResponse(o, 307, finalUrl),
              finalUrl: _okResponse,
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final String? result = await service.resolve(shortUrl);
        expect(result, finalUrl);
      });

      test('returns null on network error (no fixture)', () async {
        const String url = 'https://example.com/page';
        // No interceptors registered → real network would fail,
        // but in tests without fixtures the default adapter throws.
        // We intentionally add an interceptor that has no fixture for this URL.
        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final String? result = await service.resolve(url);
        expect(result, isNull);
      });

      test('501 on HEAD falls back to GET', () async {
        const String url = 'https://example.com/page';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              url: (RequestOptions o) => _headNotAllowedResponse(o, 501),
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              url: _okResponse,
            },
          ),
        );

        final String? result = await service.resolve(url);
        expect(result, url);
      });

      test('403 on HEAD falls back to GET', () async {
        const String url = 'https://example.com/page';

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              url: (RequestOptions o) => _headNotAllowedResponse(o, 403),
            },
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{
              url: _okResponse,
            },
          ),
        );

        final String? result = await service.resolve(url);
        expect(result, url);
      });

      test('respects custom max hops', () async {
        const String base = 'https://chain.com';
        final Map<String, Response<dynamic> Function(RequestOptions)>
            headFixtures = <String, Response<dynamic> Function(RequestOptions)>{};

        for (int i = 0; i < 3; i++) {
          headFixtures['$base/$i'] =
              (RequestOptions o) => _redirectResponse(o, 301, '$base/${i + 1}');
        }
        headFixtures['$base/3'] = _okResponse;

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: headFixtures,
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final RedirectResolverService customService = RedirectResolverService(
          dio: dio,
          maxHops: 2,
        );

        final String? result = await customService.resolve('$base/0');
        expect(result, isNull);
      });

      test('resolves within custom max hops', () async {
        const String base = 'https://chain.com';
        final Map<String, Response<dynamic> Function(RequestOptions)>
            headFixtures = <String, Response<dynamic> Function(RequestOptions)>{};

        for (int i = 0; i < 2; i++) {
          headFixtures['$base/$i'] =
              (RequestOptions o) => _redirectResponse(o, 301, '$base/${i + 1}');
        }
        headFixtures['$base/2'] = _okResponse;

        dio.interceptors.add(
          _FixtureInterceptor(
            headFixtures: headFixtures,
            getFixtures: <String, Response<dynamic> Function(RequestOptions)>{},
          ),
        );

        final RedirectResolverService customService = RedirectResolverService(
          dio: dio,
          maxHops: 3,
        );

        final String? result = await customService.resolve('$base/0');
        expect(result, '$base/2');
      });
    });
  });
}
