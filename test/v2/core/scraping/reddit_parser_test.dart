import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/parsers/reddit_parser.dart';

void main() {
  group('RedditParser.canHandle', () {
    test('accepts reddit hosts and short links', () {
      final RedditParser parser = RedditParser();

      expect(parser.canHandle('https://www.reddit.com/r/flutter'), isTrue);
      expect(parser.canHandle('https://old.reddit.com/r/flutter'), isTrue);
      expect(parser.canHandle('https://redd.it/abc123'), isTrue);
    });

    test('rejects non-reddit hosts', () {
      final RedditParser parser = RedditParser();

      expect(parser.canHandle('https://example.com/r/flutter'), isFalse);
      expect(
          parser.canHandle('https://reddit.com.evil.test/r/flutter'), isFalse);
    });
  });

  group('RedditParser JSON endpoint', () {
    test('appends .json to the path without losing query parameters', () async {
      final List<Uri> requestedUris = <Uri>[];
      final RedditParser parser = RedditParser(
        dio: _dioWithJsonResponse(
          requestedUris: requestedUris,
          data: _commentsJsonData(),
        ),
      );

      final MetadataResult result = await parser.parse(
        'https://www.reddit.com/r/flutter/comments/abc/title/?utm_source=share#comment',
      );

      expect(requestedUris, hasLength(1));
      expect(requestedUris.single.path, '/r/flutter/comments/abc/title.json');
      expect(requestedUris.single.fragment, isEmpty);
      expect(requestedUris.single.queryParameters['utm_source'], 'share');
      expect(requestedUris.single.queryParameters['limit'], '1');
      expect(requestedUris.single.queryParameters['raw_json'], '1');
      expect(result.title, 'Flutter post title');
      expect(result.siteName, 'r/flutterdev');
      expect(result.publisher, 'Reddit');
      expect(result.author, 'marky_user');
      expect(
          result.canonicalUrl, contains('/r/flutterdev/comments/abc/title/'));
      expect(result.heroImageUrl, 'https://i.redd.it/hero.jpg');
      expect(result.faviconUrl, 'https://www.reddit.com/favicon.ico');
      expect(
          result.publishDate,
          DateTime.fromMillisecondsSinceEpoch(
            1710000000 * 1000,
            isUtc: true,
          ));
    });

    test('parses domain listing JSON object shape', () async {
      final RedditParser parser = RedditParser(
        dio: _dioWithJsonResponse(data: _listingJsonData()),
      );

      final MetadataResult result = await parser.parse(
        'https://www.reddit.com/domain/example.com/new/',
      );

      expect(result.title, 'Example domain post');
      expect(result.siteName, 'r/programming');
      expect(result.publisher, 'Reddit');
      expect(result.heroImageUrl,
          'https://preview.redd.it/domain.png?width=640&crop=smart');
      expect(result.canonicalUrl,
          contains('/r/programming/comments/domain/example/'));
    });
  });
}

Dio _dioWithJsonResponse({
  List<Uri>? requestedUris,
  required Object data,
}) {
  final Dio dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        requestedUris?.add(options.uri);
        handler.resolve(
          Response<Object>(
            requestOptions: options,
            statusCode: 200,
            data: data,
          ),
        );
      },
    ),
  );
  return dio;
}

List<Object> _commentsJsonData() {
  return <Object>[
    <String, Object?>{
      'kind': 'Listing',
      'data': <String, Object?>{
        'children': <Object>[
          <String, Object?>{
            'kind': 't3',
            'data': <String, Object?>{
              'title': 'Flutter post title',
              'subreddit': 'flutterdev',
              'subreddit_name_prefixed': 'r/flutterdev',
              'author': 'marky_user',
              'selftext': 'A short Reddit self post body.',
              'url_overridden_by_dest': 'https://i.redd.it/hero.jpg',
              'thumbnail': 'self',
              'permalink': '/r/flutterdev/comments/abc/title/',
              'created_utc': 1710000000,
            },
          },
        ],
      },
    },
    <String, Object?>{
      'kind': 'Listing',
      'data': <String, Object?>{
        'children': <Object>[],
      },
    },
  ];
}

Map<String, Object?> _listingJsonData() {
  return <String, Object?>{
    'kind': 'Listing',
    'data': <String, Object?>{
      'children': <Object>[
        <String, Object?>{
          'kind': 't3',
          'data': <String, Object?>{
            'title': 'Example domain post',
            'subreddit': 'programming',
            'subreddit_name_prefixed': 'r/programming',
            'author': 'domain_user',
            'selftext': '',
            'url': 'https://example.com/story',
            'thumbnail': 'default',
            'permalink': '/r/programming/comments/domain/example/',
            'created_utc': 1710000010.0,
            'preview': <String, Object?>{
              'images': <Object>[
                <String, Object?>{
                  'source': <String, Object?>{
                    'url':
                        'https://preview.redd.it/domain.png?width=640&amp;crop=smart',
                  },
                },
              ],
            },
          },
        },
      ],
    },
  };
}
