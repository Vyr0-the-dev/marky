import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/parsers/twitter_parser.dart';

void main() {
  group('TwitterParser.canHandle', () {
    const TwitterParser parser = TwitterParser();

    test('accepts twitter.com, x.com, mobile.twitter.com', () {
      expect(parser.canHandle('https://twitter.com/user/status/123'), isTrue);
      expect(parser.canHandle('https://x.com/user/status/123'), isTrue);
      expect(parser.canHandle('https://mobile.twitter.com/user/status/123'), isTrue);
      expect(parser.canHandle('https://x.com/user/article/1850000000000'), isTrue);
    });

    test('rejects other hosts', () {
      expect(parser.canHandle('https://example.com/user/status/123'), isFalse);
      expect(parser.canHandle('https://not-twitter.com/post'), isFalse);
    });
  });

  group('TwitterParser FxTwitter parsing', () {
    test('parses regular tweet with author, media and text', () async {
      final TwitterParser parser = TwitterParser(
        dio: _dioWithJsonResponse(
          data: <String, dynamic>{
            'code': 200,
            'tweet': <String, dynamic>{
              'id': '123456789',
              'text': 'Flutter 3.29 is out with exciting features!',
              'author': <String, dynamic>{
                'name': 'Flutter Dev',
                'screen_name': 'flutterdev',
                'avatar_url': 'https://pbs.twimg.com/avatar.jpg',
              },
              'media': <String, dynamic>{
                'photos': <dynamic>[
                  <String, dynamic>{'url': 'https://pbs.twimg.com/media1.jpg'},
                ],
              },
            },
          },
        ),
      );

      final MetadataResult result = await parser.parse('https://x.com/flutterdev/status/123456789');

      expect(result.title, 'Flutter 3.29 is out with exciting features!');
      expect(result.author, 'Flutter Dev (@flutterdev)');
      expect(result.heroImageUrl, 'https://pbs.twimg.com/media1.jpg');
      expect(result.siteName, 'X (Twitter)');
      expect(result.publisher, 'X');
    });

    test('parses long-form X Article properly', () async {
      final TwitterParser parser = TwitterParser(
        dio: _dioWithJsonResponse(
          data: <String, dynamic>{
            'code': 200,
            'tweet': <String, dynamic>{
              'id': '18599999999',
              'text': 'Check out my new deep dive article on AI coding agents.',
              'author': <String, dynamic>{
                'name': 'Tech Researcher',
                'screen_name': 'techresearcher',
              },
              'article': <String, dynamic>{
                'title': 'The Architecture of Autonomous Agents in 2026',
                'preview_text': 'A detailed analysis of multi-agent loops and sandboxing...',
                'cover_image': 'https://pbs.twimg.com/article_cover.jpg',
              },
            },
          },
        ),
      );

      final MetadataResult result = await parser.parse('https://x.com/techresearcher/article/18599999999');

      expect(result.title, 'The Architecture of Autonomous Agents in 2026');
      expect(result.author, 'Tech Researcher (@techresearcher)');
      expect(result.heroImageUrl, 'https://pbs.twimg.com/article_cover.jpg');
      expect(result.snippet, contains('A detailed analysis of multi-agent loops'));
    });

    test('includes quote tweet text if present', () async {
      final TwitterParser parser = TwitterParser(
        dio: _dioWithJsonResponse(
          data: <String, dynamic>{
            'code': 200,
            'tweet': <String, dynamic>{
              'id': '987654',
              'text': 'Totally agree with this take!',
              'author': <String, dynamic>{
                'name': 'Dev Lead',
                'screen_name': 'devlead',
              },
              'quote': <String, dynamic>{
                'text': 'Clean code is easier to maintain.',
                'author': <String, dynamic>{'name': 'Architect'},
              },
            },
          },
        ),
      );

      final MetadataResult result = await parser.parse('https://x.com/devlead/status/987654');

      expect(result.snippet, contains('Totally agree with this take!'));
      expect(result.snippet, contains('[Architect: Clean code is easier to maintain.]'));
    });
  });
}

Dio _dioWithJsonResponse({required Map<String, dynamic> data}) {
  final Dio dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        handler.resolve(
          Response<dynamic>(
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
