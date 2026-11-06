// ignore_for_file: unnecessary_raw_strings, prefer_const_declarations

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/parsers/reddit_parser.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';

import 'fixtures.dart';

void main() {
  late Dio dio;
  late RedditParser parser;

  setUp(() {
    dio = DioClient.create();
    parser = RedditParser(dio: dio);
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

    test('hosts contains all Reddit variants', () {
      expect(parser.hosts, contains('reddit.com'));
      expect(parser.hosts, contains('www.reddit.com'));
      expect(parser.hosts, contains('old.reddit.com'));
      expect(parser.hosts, contains('np.reddit.com'));
      expect(parser.hosts, contains('redd.it'));
    });

    test('instance singleton returns same object', () {
      final RedditParser a = RedditParser.instance;
      final RedditParser b = RedditParser.instance;
      expect(a, same(b));
    });
  });

  // -----------------------------------------------------------------
  // 2. Happy path
  // -----------------------------------------------------------------
  group('happy path', () {
    test('extracts metadata from reddit .json response', () async {
      const String url =
          'https://www.reddit.com/r/FlutterDev/comments/abc123/my_post/';
      const String jsonBody = r'''
[
  {
    "data": {
      "children": [
        {
          "data": {
            "title": "My Awesome Flutter Post",
            "subreddit_name_prefixed": "r/FlutterDev",
            "author": "flutter_fan",
            "thumbnail": "https://b.thumbs.redditmedia.com/xyz.jpg",
            "selftext": "This is the body of the post.",
            "url": "https://example.com"
          }
        }
      ]
    }
  }
]
''';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(o, body: jsonBody),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'My Awesome Flutter Post');
      expect(result.siteName, 'r/FlutterDev');
      expect(result.author, 'flutter_fan');
      expect(result.thumbnailUrl, 'https://b.thumbs.redditmedia.com/xyz.jpg');
      expect(result.heroImageUrl, result.thumbnailUrl);
      expect(result.description, 'This is the body of the post.');
      expect(result.publisher, 'Reddit');
      expect(result.contentType, 'article');
    });

    test('works with redd.it short links', () async {
      const String url = 'https://redd.it/abc123';
      const String jsonBody = r'''
[
  {
    "data": {
      "children": [
        {
          "data": {
            "title": "Short Link Post",
            "subreddit": "technology",
            "author": "techie",
            "thumbnail": "https://b.thumbs.redditmedia.com/short.jpg",
            "selftext": "",
            "url": "https://example.com"
          }
        }
      ]
    }
  }
]
''';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(o, body: jsonBody),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Short Link Post');
      expect(result.siteName, 'technology');
      expect(result.author, 'techie');
    });

    test('works with old.reddit.com links', () async {
      const String url =
          'https://old.reddit.com/r/programming/comments/xyz789/code/';
      const String jsonBody = r'''
[
  {
    "data": {
      "children": [
        {
          "data": {
            "title": "Old Reddit Post",
            "subreddit_name_prefixed": "r/programming",
            "author": "coder",
            "thumbnail": "https://b.thumbs.redditmedia.com/old.jpg",
            "selftext": "Some text.",
            "url": "https://github.com/example/repo"
          }
        }
      ]
    }
  }
]
''';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(o, body: jsonBody),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Old Reddit Post');
      expect(result.siteName, 'r/programming');
    });

    test('uses image url as heroImageUrl for image posts', () async {
      const String url =
          'https://www.reddit.com/r/pics/comments/abc123/cool_photo/';
      const String jsonBody = r'''
[
  {
    "data": {
      "children": [
        {
          "data": {
            "title": "Cool Photo",
            "subreddit_name_prefixed": "r/pics",
            "author": "photographer",
            "thumbnail": "self",
            "selftext": "",
            "url": "https://i.redd.it/photo.jpg"
          }
        }
      ]
    }
  }
]
''';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(o, body: jsonBody),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Cool Photo');
      expect(result.thumbnailUrl, isNull);
      expect(result.heroImageUrl, 'https://i.redd.it/photo.jpg');
    });

    test('falls back to subreddit when subreddit_name_prefixed missing',
        () async {
      const String url =
          'https://www.reddit.com/r/AskReddit/comments/abc123/question/';
      const String jsonBody = r'''
[
  {
    "data": {
      "children": [
        {
          "data": {
            "title": "A Question",
            "subreddit": "AskReddit",
            "author": "asker",
            "thumbnail": "default",
            "selftext": "What do you think?",
            "url": "https://example.com"
          }
        }
      ]
    }
  }
]
''';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(o, body: jsonBody),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.siteName, 'AskReddit');
    });
  });

  // -----------------------------------------------------------------
  // 3. Error cases
  // -----------------------------------------------------------------
  group('error cases', () {
    test('returns null on DioException (network error)', () async {
      const String url = 'https://www.reddit.com/r/test/comments/abc123/post/';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{},
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on 403 response', () async {
      const String url =
          'https://www.reddit.com/r/private/comments/abc123/post/';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: '{"message": "Forbidden", "error": 403}',
                  statusCode: 403,
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on 404 response', () async {
      const String url =
          'https://www.reddit.com/r/missing/comments/abc123/gone/';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(
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

    test('returns null on non-2xx response (500)', () async {
      const String url =
          'https://www.reddit.com/r/test/comments/abc123/post/';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(
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

    test('returns null on invalid JSON', () async {
      const String url =
          'https://www.reddit.com/r/test/comments/abc123/post/';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: 'this is not json',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null when title is missing in response', () async {
      const String url =
          'https://www.reddit.com/r/test/comments/abc123/post/';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: r'''
[
  {
    "data": {
      "children": [
        {
          "data": {
            "author": "someone"
          }
        }
      ]
    }
  }
]
''',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on timeout', () async {
      const String url =
          'https://www.reddit.com/r/test/comments/abc123/post/';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: r'{"title": "Too Late"}',
                ),
          },
          delayedFixtures: <String, Future<void>>{
            jsonUrl: Future<void>.delayed(const Duration(milliseconds: 200)),
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

    test('returns null for non-Reddit URLs', () async {
      const String url = 'https://news.ycombinator.com/item?id=123';

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

    test('returns null when response body is empty', () async {
      const String url =
          'https://www.reddit.com/r/test/comments/abc123/post/';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: '',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null when response is a JSON object instead of array',
        () async {
      const String url =
          'https://www.reddit.com/r/test/comments/abc123/post/';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: '{"error": "Not an array"}',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null when children array is empty', () async {
      const String url =
          'https://www.reddit.com/r/test/comments/abc123/post/';
      final String jsonUrl = '$url.json';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            jsonUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: r'''
[
  {
    "data": {
      "children": []
    }
  }
]
''',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });
  });
}
