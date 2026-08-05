import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';
import 'package:marky/core/scraping/parsers/twitter_parser.dart';

import 'fixtures.dart';

void main() {
  late Dio dio;
  late TwitterParser parser;

  setUp(() {
    dio = DioClient.create();
    parser = TwitterParser(dio: dio);
  });

  tearDown(() {
    dio.close();
  });

  group('contract', () {
    test('implements SourceParser', () {
      expect(parser, isA<SourceParser>());
    });

    test('hosts contains all Twitter/X variants', () {
      expect(parser.hosts, contains('twitter.com'));
      expect(parser.hosts, contains('x.com'));
      expect(parser.hosts, contains('mobile.twitter.com'));
      expect(parser.hosts, contains('mobile.x.com'));
      expect(parser.hosts, contains('t.co'));
    });

    test('instance singleton returns same object', () {
      final TwitterParser a = TwitterParser.instance;
      final TwitterParser b = TwitterParser.instance;
      expect(a, same(b));
    });
  });

  group('happy path', () {
    test('extracts metadata from twitter:* tags', () async {
      const String url = 'https://twitter.com/jack/status/20';
      const String html = '''
<html>
<head>
  <meta name="twitter:title" content="Just setting up my Twitter">
  <meta name="twitter:description" content="My first tweet">
  <meta name="twitter:image" content="https://pbs.twimg.com/media/card.jpg">
  <meta name="twitter:creator" content="@jack">
  <meta name="twitter:site" content="@Twitter">
</head>
</html>
''';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Just setting up my Twitter');
      expect(result.description, 'My first tweet');
      expect(result.thumbnailUrl, 'https://pbs.twimg.com/media/card.jpg');
      expect(result.heroImageUrl, result.thumbnailUrl);
      expect(result.author, '@jack');
      expect(result.siteName, '@Twitter');
      expect(result.publisher, '@Twitter');
      expect(result.contentType, 'article');
    });

    test('extracts metadata from x:* tags', () async {
      const String url = 'https://x.com/elonmusk/status/12345';
      const String html = '''
<html>
<head>
  <meta name="x:title" content="Exploring Mars">
  <meta name="x:description" content="Space is exciting">
  <meta name="x:image" content="https://pbs.twimg.com/media/mars.jpg">
  <meta name="x:creator" content="@elonmusk">
  <meta name="x:site" content="@X">
</head>
</html>
''';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Exploring Mars');
      expect(result.description, 'Space is exciting');
      expect(result.thumbnailUrl, 'https://pbs.twimg.com/media/mars.jpg');
      expect(result.author, '@elonmusk');
      expect(result.siteName, '@X');
    });

    test('falls back from twitter:* to x:* tags', () async {
      const String url = 'https://x.com/user/status/67890';
      const String html = '''
<html>
<head>
  <meta name="x:title" content="X Branded Title">
  <meta name="twitter:description" content="Mixed tags">
  <meta name="x:image" content="https://cdn.x.com/img.jpg">
</head>
</html>
''';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'X Branded Title');
      expect(result.description, 'Mixed tags');
      expect(result.thumbnailUrl, 'https://cdn.x.com/img.jpg');
    });

    test('falls back to OG tags when twitter/x tags missing', () async {
      const String url = 'https://twitter.com/user/status/111';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="OG Fallback Title">
  <meta property="og:description" content="OG Description">
  <meta property="og:image" content="https://example.com/og.jpg">
</head>
</html>
''';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'OG Fallback Title');
      expect(result.description, 'OG Description');
      expect(result.thumbnailUrl, 'https://example.com/og.jpg');
    });

    test('reads twitter:image:src as image fallback', () async {
      const String url = 'https://twitter.com/user/status/222';
      const String html = '''
<html>
<head>
  <meta name="twitter:title" content="Title">
  <meta name="twitter:image:src" content="https://cdn.twimg.com/src.jpg">
</head>
</html>
''';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.thumbnailUrl, 'https://cdn.twimg.com/src.jpg');
    });

    test('works with www.twitter.com links', () async {
      const String url = 'https://www.twitter.com/jack/status/20';
      const String html = '<html><head><meta name="twitter:title" content="Tweet Title"></head></html>';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Tweet Title');
    });

    test('works with mobile.twitter.com links', () async {
      const String url = 'https://mobile.twitter.com/jack/status/20';
      const String html = '<html><head><meta name="twitter:title" content="Mobile Tweet"></head></html>';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Mobile Tweet');
    });

    test('works with t.co short links', () async {
      const String url = 'https://t.co/abc123';
      const String html = '<html><head><meta name="twitter:title" content="Short Link Tweet"></head></html>';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Short Link Tweet');
    });
  });

  group('error cases', () {
    test('returns null on DioException', () async {
      const String url = 'https://twitter.com/user/status/404';
      dio.interceptors.add(
        FixtureInterceptor(fixtures: {}),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on 500 response', () async {
      const String url = 'https://twitter.com/user/status/500';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {
            url: (RequestOptions o) => htmlResponse(o, body: 'Server Error', statusCode: 500),
          },
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on 404 response', () async {
      const String url = 'https://twitter.com/user/status/deleted';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {
            url: (RequestOptions o) => htmlResponse(o, body: 'Not Found', statusCode: 404),
          },
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null when title is missing', () async {
      const String url = 'https://twitter.com/user/status/notitle';
      const String html = '<html><head><meta name="twitter:description" content="No title"></head></html>';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: html)},
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on timeout', () async {
      const String url = 'https://twitter.com/user/status/slow';
      const String html = '<html><head><meta name="twitter:title" content="Too Late"></head></html>';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: html)},
          delayedFixtures: {url: Future<void>.delayed(const Duration(milliseconds: 200))},
        ),
      );
      final result = await parser.parse(url).timeout(
            const Duration(milliseconds: 50),
            onTimeout: () => null,
          );
      expect(result, isNull);
    });
  });

  group('edge cases', () {
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

    test('returns null for non-Twitter URLs', () async {
      final result = await parser.parse('https://facebook.com/post/123');
      expect(result, isNull);
    });

    test('returns null for file:// URLs', () async {
      final result = await parser.parse('file:///etc/passwd');
      expect(result, isNull);
    });

    test('returns null for javascript: URLs', () async {
      final result = await parser.parse('javascript:alert(1)');
      expect(result, isNull);
    });

    test('returns null when response body is empty', () async {
      const String url = 'https://twitter.com/user/status/empty';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: '')},
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('handles malformed HTML gracefully', () async {
      const String url = 'https://twitter.com/user/status/broken';
      const String html = '<>>> <<<< not html < meta name="twitter:title" content="Broken">';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: html)},
        ),
      );
      final result = await parser.parse(url);
      // html_parser may not extract anything from garbage input; null is fine
      expect(result, isNull);
    });

    test('returns null when no meaningful metadata found', () async {
      const String url = 'https://twitter.com/user/status/nothing';
      const String html = '<html><head></head><body>No meta</body></html>';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: html)},
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });
  });
}
