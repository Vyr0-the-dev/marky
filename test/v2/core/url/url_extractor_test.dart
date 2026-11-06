import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/url/url_extractor.dart';

void main() {
  const UrlExtractor extractor = UrlExtractor();

  group('extractAll', () {
    test('returns empty for blank text', () {
      expect(extractor.extractAll(''), isEmpty);
      expect(extractor.extractAll('   '), isEmpty);
    });

    test('returns empty for text without URLs', () {
      expect(extractor.extractAll('just some random text'), isEmpty);
    });

    test('extracts a single URL', () {
      expect(
        extractor.extractAll('https://example.com/page'),
        <String>['https://example.com/page'],
      );
    });

    test('extracts URL from surrounding text', () {
      expect(
        extractor.extractAll(
          'Check this out: https://example.com/article - amazing!',
        ),
        <String>['https://example.com/article'],
      );
    });

    test('extracts multiple URLs', () {
      expect(
        extractor.extractAll(
          'Link 1: https://example.com/a and link 2: https://example.com/b',
        ),
        <String>['https://example.com/a', 'https://example.com/b'],
      );
    });

    test('strips trailing period', () {
      expect(
        extractor.extractAll('Visit https://example.com/page.'),
        <String>['https://example.com/page'],
      );
    });

    test('strips trailing comma', () {
      expect(
        extractor.extractAll('https://example.com/page, and more'),
        <String>['https://example.com/page'],
      );
    });

    test('strips trailing exclamation mark', () {
      expect(
        extractor.extractAll('Look at https://example.com/page!'),
        <String>['https://example.com/page'],
      );
    });

    test('handles URL in parentheses', () {
      expect(
        extractor.extractAll('(see https://example.com/page)'),
        <String>['https://example.com/page'],
      );
    });

    test('preserves Wikipedia-style parentheses in path', () {
      expect(
        extractor.extractAll(
          'https://en.wikipedia.org/wiki/Dart_(programming_language)',
        ),
        <String>['https://en.wikipedia.org/wiki/Dart_(programming_language)'],
      );
    });

    test('handles YouTube URL with query params', () {
      expect(
        extractor.extractAll(
          'Watch this: https://www.youtube.com/watch?v=dQw4w9WgXcQ&si=xyz',
        ),
        <String>['https://www.youtube.com/watch?v=dQw4w9WgXcQ&si=xyz'],
      );
    });

    test('handles http:// URLs', () {
      expect(
        extractor.extractAll('http://example.com/old-page'),
        <String>['http://example.com/old-page'],
      );
    });

    test('handles case-insensitive scheme', () {
      expect(
        extractor.extractAll('HTTPS://EXAMPLE.COM/PAGE'),
        <String>['HTTPS://EXAMPLE.COM/PAGE'],
      );
    });

    test('extracts URL from multi-line text', () {
      expect(
        extractor.extractAll('''
Title: Great Article
URL: https://example.com/article
Source: Reddit
'''),
        <String>['https://example.com/article'],
      );
    });

    test('real-world: Twitter share format', () {
      expect(
        extractor.extractAll(
          '"Interesting thread about Flutter" https://x.com/user/status/1234567890',
        ),
        <String>['https://x.com/user/status/1234567890'],
      );
    });

    test('real-world: Reddit share format', () {
      expect(
        extractor.extractAll(
          'My post on Reddit: https://www.reddit.com/r/flutter/comments/abc/title/?utm_source=share',
        ),
        <String>[
          'https://www.reddit.com/r/flutter/comments/abc/title/?utm_source=share'
        ],
      );
    });
  });

  group('extractFirst', () {
    test('returns first URL', () {
      expect(
        extractor.extractFirst(
          'https://a.com and https://b.com',
        ),
        'https://a.com',
      );
    });

    test('returns null when no URL', () {
      expect(extractor.extractFirst('no url here'), isNull);
    });
  });
}
