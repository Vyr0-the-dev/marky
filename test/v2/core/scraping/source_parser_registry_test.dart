import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/scraping/parsers/generic_html_parser.dart';
import 'package:marky/core/scraping/parsers/github_parser.dart';
import 'package:marky/core/scraping/parsers/reddit_parser.dart';
import 'package:marky/core/scraping/parsers/twitter_parser.dart';
import 'package:marky/core/scraping/parsers/youtube_parser.dart';
import 'package:marky/core/scraping/source_parser.dart';
import 'package:marky/core/scraping/source_parser_registry.dart';

void main() {
  late SourceParserRegistry registry;
  late YouTubeParser ytParser;
  late RedditParser redditParser;
  late TwitterParser twitterParser;
  late GitHubParser ghParser;
  late GenericHtmlParser genericParser;

  setUp(() {
    ytParser = YouTubeParser();
    redditParser = RedditParser();
    twitterParser = const TwitterParser();
    ghParser = GitHubParser();
    genericParser = GenericHtmlParser();

    registry = SourceParserRegistry(<SourceParser>[
      ytParser,
      redditParser,
      twitterParser,
      ghParser,
      genericParser, // must be last
    ]);
  });

  // ─── canHandle ─────────────────────────────────────────────────

  group('YouTubeParser.canHandle', () {
    test('youtube.com', () {
      expect(ytParser.canHandle('https://youtube.com/watch?v=abc'), isTrue);
    });
    test('www.youtube.com', () {
      expect(ytParser.canHandle('https://www.youtube.com/watch?v=abc'), isTrue);
    });
    test('youtu.be', () {
      expect(ytParser.canHandle('https://youtu.be/abc'), isTrue);
    });
    test('m.youtube.com', () {
      expect(ytParser.canHandle('https://m.youtube.com/watch?v=abc'), isTrue);
    });
    test('rejects non-youtube', () {
      expect(ytParser.canHandle('https://example.com'), isFalse);
    });
  });

  group('RedditParser.canHandle', () {
    test('reddit.com', () {
      expect(redditParser.canHandle('https://reddit.com/r/flutter'), isTrue);
    });
    test('www.reddit.com', () {
      expect(
        redditParser.canHandle('https://www.reddit.com/r/flutter'),
        isTrue,
      );
    });
    test('old.reddit.com', () {
      expect(
        redditParser.canHandle('https://old.reddit.com/r/flutter'),
        isTrue,
      );
    });
    test('rejects non-reddit', () {
      expect(redditParser.canHandle('https://example.com'), isFalse);
    });
  });

  group('TwitterParser.canHandle', () {
    test('twitter.com', () {
      expect(
        twitterParser.canHandle('https://twitter.com/user/status/123'),
        isTrue,
      );
    });
    test('x.com', () {
      expect(
        twitterParser.canHandle('https://x.com/user/status/123'),
        isTrue,
      );
    });
    test('rejects non-twitter', () {
      expect(twitterParser.canHandle('https://example.com'), isFalse);
    });
  });

  group('GitHubParser.canHandle', () {
    test('github.com', () {
      expect(ghParser.canHandle('https://github.com/flutter/flutter'), isTrue);
    });
    test('www.github.com', () {
      expect(
        ghParser.canHandle('https://www.github.com/flutter/flutter'),
        isTrue,
      );
    });
    test('rejects non-github', () {
      expect(ghParser.canHandle('https://gitlab.com/foo/bar'), isFalse);
    });
  });

  // ─── Registry routing ─────────────────────────────────────────

  group('SourceParserRegistry.resolve', () {
    test('routes YouTube URLs to YouTubeParser', () {
      final SourceParser? parser =
          registry.resolve('https://youtube.com/watch?v=abc');
      expect(parser, same(ytParser));
    });

    test('routes Reddit URLs to RedditParser', () {
      final SourceParser? parser =
          registry.resolve('https://reddit.com/r/flutter/comments/abc/title');
      expect(parser, same(redditParser));
    });

    test('routes Twitter URLs to TwitterParser', () {
      final SourceParser? parser =
          registry.resolve('https://x.com/user/status/123');
      expect(parser, same(twitterParser));
    });

    test('routes GitHub URLs to GitHubParser', () {
      final SourceParser? parser =
          registry.resolve('https://github.com/flutter/flutter');
      expect(parser, same(ghParser));
    });

    test('routes unknown URLs to GenericHtmlParser', () {
      final SourceParser? parser =
          registry.resolve('https://example.com/article');
      expect(parser, same(genericParser));
    });

    test('returns null for empty registry', () {
      final SourceParserRegistry empty =
          SourceParserRegistry(const <SourceParser>[]);
      expect(empty.resolve('https://example.com'), isNull);
    });
  });
}
