import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';
import 'package:marky/core/scraping/parsers/youtube_parser.dart';

import 'fixtures.dart';

void main() {
  late Dio dio;
  late YouTubeParser parser;

  setUp(() {
    dio = DioClient.create();
    parser = YouTubeParser(dio: dio);
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

    test('hosts contains all YouTube variants', () {
      expect(parser.hosts, contains('youtube.com'));
      expect(parser.hosts, contains('youtu.be'));
      expect(parser.hosts, contains('m.youtube.com'));
      expect(parser.hosts, contains('music.youtube.com'));
    });

    test('instance singleton returns same object', () {
      final YouTubeParser a = YouTubeParser.instance;
      final YouTubeParser b = YouTubeParser.instance;
      expect(a, same(b));
    });
  });

  // -----------------------------------------------------------------
  // 2. Happy path
  // -----------------------------------------------------------------
  group('happy path', () {
    test('extracts metadata from oEmbed JSON response', () async {
      const String url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      const String oEmbedJson = '''
{
  "title": "Rick Astley - Never Gonna Give You Up (Official Video)",
  "author_name": "Rick Astley",
  "author_url": "https://www.youtube.com/@RickAstley",
  "type": "video",
  "height": 113,
  "width": 200,
  "version": "1.0",
  "provider_name": "YouTube",
  "provider_url": "https://www.youtube.com/",
  "thumbnail_height": 360,
  "thumbnail_width": 480,
  "thumbnail_url": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
  "html": "<iframe>...</iframe>"
}
''';

      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(o, body: oEmbedJson),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Rick Astley - Never Gonna Give You Up (Official Video)');
      expect(result.author, 'Rick Astley');
      expect(result.publisher, 'YouTube');
      expect(result.siteName, 'YouTube');
      expect(result.contentType, 'video');
      expect(
        result.thumbnailUrl,
        'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
      );
      expect(result.heroImageUrl, result.thumbnailUrl);
      expect(result.description, isNull);
    });

    test('works with youtu.be short links', () async {
      const String url = 'https://youtu.be/dQw4w9WgXcQ';
      const String oEmbedJson = '''
{
  "title": "Rick Astley - Never Gonna Give You Up",
  "author_name": "Rick Astley",
  "thumbnail_url": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
}
''';

      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(o, body: oEmbedJson),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Rick Astley - Never Gonna Give You Up');
    });

    test('works with m.youtube.com links', () async {
      const String url = 'https://m.youtube.com/watch?v=dQw4w9WgXcQ';
      const String oEmbedJson = '''
{
  "title": "Rick Astley - Never Gonna Give You Up",
  "author_name": "Rick Astley",
  "thumbnail_url": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
}
''';

      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(o, body: oEmbedJson),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Rick Astley - Never Gonna Give You Up');
    });

    test('works with music.youtube.com links', () async {
      const String url = 'https://music.youtube.com/watch?v=dQw4w9WgXcQ';
      const String oEmbedJson = '''
{
  "title": "Rick Astley - Never Gonna Give You Up",
  "author_name": "Rick Astley",
  "thumbnail_url": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
}
''';

      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(o, body: oEmbedJson),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Rick Astley - Never Gonna Give You Up');
    });
  });

  // -----------------------------------------------------------------
  // 3. Error cases
  // -----------------------------------------------------------------
  group('error cases', () {
    test('returns null on DioException (network error)', () async {
      const String url = 'https://www.youtube.com/watch?v=abc123';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{},
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on non-2xx response (500)', () async {
      const String url = 'https://www.youtube.com/watch?v=abc123';
      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: '{"error": "Internal Server Error"}',
                  statusCode: 500,
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on non-2xx response (404)', () async {
      const String url = 'https://www.youtube.com/watch?v=NONEXISTENT';
      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: 'Not Found',
                  statusCode: 404,
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on invalid JSON', () async {
      const String url = 'https://www.youtube.com/watch?v=abc123';
      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: 'this is not json',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null when title is missing in oEmbed response', () async {
      const String url = 'https://www.youtube.com/watch?v=abc123';
      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: '{"author_name": "Someone"}',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on timeout', () async {
      const String url = 'https://www.youtube.com/watch?v=abc123';
      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: '{"title": "Too Late"}',
                ),
          },
          delayedFixtures: <String, Future<void>>{
            oEmbedUrl: Future<void>.delayed(const Duration(milliseconds: 200)),
          },
        ),
      );

      final result = await parser.parse(url).timeout(
            const Duration(milliseconds: 50),
            onTimeout: () => null,
          );
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 4. Edge cases
  // -----------------------------------------------------------------
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

    test('returns null for non-YouTube URLs', () async {
      const String url = 'https://vimeo.com/123456';

      // No fixture needed — the parser should reject before making a request.
      final result = await parser.parse(url);
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

    test('returns null when oEmbed response body is empty', () async {
      const String url = 'https://www.youtube.com/watch?v=abc123';
      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: '',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null when oEmbed response is a JSON array', () async {
      const String url = 'https://www.youtube.com/watch?v=abc123';
      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            oEmbedUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: '[1, 2, 3]',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });
  });
}
