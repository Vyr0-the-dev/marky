import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/url/url_normalizer.dart';

void main() {
  const UrlNormalizer normalizer = UrlNormalizer();

  // ─── Scheme normalisation ──────────────────────────────────────

  group('scheme', () {
    test('upgrades http to https', () {
      expect(
        normalizer.normalize('http://example.com/page'),
        'https://example.com/page',
      );
    });

    test('keeps https as-is', () {
      expect(
        normalizer.normalize('https://example.com/page'),
        'https://example.com/page',
      );
    });

    test('adds https to bare domain', () {
      expect(
        normalizer.normalize('example.com/page'),
        'https://example.com/page',
      );
    });

    test('rejects non-http schemes', () {
      expect(normalizer.normalize('ftp://files.example.com'), isNull);
    });

    test('rejects empty input', () {
      expect(normalizer.normalize(''), isNull);
      expect(normalizer.normalize('   '), isNull);
    });

    test('rejects text without dots', () {
      expect(normalizer.normalize('notaurl'), isNull);
    });

    test('returns null instead of throwing for malformed port', () {
      expect(normalizer.normalize('https://example.com:bad/path'), isNull);
      expect(
        normalizer.extractNormalizedHost('https://example.com:bad/path'),
        isNull,
      );
    });
  });

  // ─── Host normalisation ────────────────────────────────────────

  group('host', () {
    test('lowercases host', () {
      expect(
        normalizer.normalize('https://EXAMPLE.COM/Page'),
        'https://example.com/Page',
      );
    });

    test('strips www prefix', () {
      expect(
        normalizer.normalize('https://www.example.com/path'),
        'https://example.com/path',
      );
    });

    test('strips m prefix', () {
      expect(
        normalizer.normalize('https://m.youtube.com/watch?v=abc'),
        'https://youtube.com/watch?v=abc',
      );
    });

    test('strips mobile prefix', () {
      expect(
        normalizer.normalize('https://mobile.twitter.com/user/status/123'),
        'https://twitter.com/user/status/123',
      );
    });

    test('strips only one prefix layer', () {
      // www.m.example.com → m.example.com (only www removed)
      expect(
        normalizer.normalize('https://www.m.example.com'),
        'https://m.example.com/',
      );
    });
  });

  // ─── Port normalisation ────────────────────────────────────────

  group('port', () {
    test('drops default port 443', () {
      expect(
        normalizer.normalize('https://example.com:443/page'),
        'https://example.com/page',
      );
    });

    test('drops default port 80', () {
      expect(
        normalizer.normalize('http://example.com:80/page'),
        'https://example.com/page',
      );
    });

    test('keeps non-default port', () {
      expect(
        normalizer.normalize('https://example.com:8080/page'),
        'https://example.com:8080/page',
      );
    });
  });

  // ─── Path normalisation ────────────────────────────────────────

  group('path', () {
    test('removes trailing slash', () {
      expect(
        normalizer.normalize('https://example.com/page/'),
        'https://example.com/page',
      );
    });

    test('keeps root slash', () {
      expect(
        normalizer.normalize('https://example.com/'),
        'https://example.com/',
      );
    });

    test('keeps root slash for bare domain', () {
      expect(
        normalizer.normalize('https://example.com'),
        'https://example.com/',
      );
    });

    test('collapses common AMP path variants', () {
      expect(
        normalizer.normalize('https://www.example.com/amp/article/'),
        'https://example.com/article',
      );
      expect(
        normalizer.normalize('https://example.com/article/amp/'),
        'https://example.com/article',
      );
    });
  });

  // ─── Fragment removal ──────────────────────────────────────────

  group('fragment', () {
    test('removes fragment', () {
      expect(
        normalizer.normalize('https://example.com/page#section'),
        'https://example.com/page',
      );
    });
  });

  // ─── Tracking-param removal ────────────────────────────────────

  group('tracking params', () {
    test('removes utm_* params', () {
      expect(
        normalizer.normalize(
          'https://example.com/page?utm_source=twitter&utm_medium=social&id=5',
        ),
        'https://example.com/page?id=5',
      );
    });

    test('removes fbclid', () {
      expect(
        normalizer.normalize(
          'https://example.com/page?fbclid=abc123&id=5',
        ),
        'https://example.com/page?id=5',
      );
    });

    test('removes gclid', () {
      expect(
        normalizer.normalize(
          'https://example.com/page?gclid=xyz&id=5',
        ),
        'https://example.com/page?id=5',
      );
    });

    test('removes igshid', () {
      expect(
        normalizer.normalize(
          'https://instagram.com/p/abc?igshid=xyz',
        ),
        'https://instagram.com/p/abc',
      );
    });

    test('removes si parameter', () {
      expect(
        normalizer.normalize(
          'https://youtube.com/watch?v=abc&si=xyz',
        ),
        'https://youtube.com/watch?v=abc',
      );
    });

    test('removes ref parameter', () {
      expect(
        normalizer.normalize(
          'https://example.com/page?ref=header&id=5',
        ),
        'https://example.com/page?id=5',
      );
    });

    test('removes _branch params', () {
      expect(
        normalizer.normalize(
          'https://example.com/page?_branch_match_id=x&_branch_referrer=y&id=1',
        ),
        'https://example.com/page?id=1',
      );
    });

    test('drops query entirely when only trackers present', () {
      expect(
        normalizer.normalize(
          'https://example.com/page?utm_source=x&fbclid=y',
        ),
        'https://example.com/page',
      );
    });

    test('sorts remaining query params', () {
      expect(
        normalizer.normalize(
          'https://example.com/page?z=3&a=1&m=2',
        ),
        'https://example.com/page?a=1&m=2&z=3',
      );
    });
  });

  // ─── extractNormalizedHost ─────────────────────────────────────

  group('extractNormalizedHost', () {
    test('extracts and normalises host', () {
      expect(
        normalizer.extractNormalizedHost('https://www.GitHub.com/user/repo'),
        'github.com',
      );
    });

    test('strips m prefix', () {
      expect(
        normalizer.extractNormalizedHost('https://m.youtube.com/watch?v=x'),
        'youtube.com',
      );
    });

    test('returns null for invalid input', () {
      expect(normalizer.extractNormalizedHost('not a url'), isNull);
    });
  });

  // ─── Real-world URL fixtures ───────────────────────────────────

  group('real-world URLs', () {
    test('YouTube with tracking', () {
      expect(
        normalizer.normalize(
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ&si=xyz&feature=share',
        ),
        'https://youtube.com/watch?v=dQw4w9WgXcQ',
      );
    });

    test('YouTube short link', () {
      expect(
        normalizer.normalize('https://youtu.be/dQw4w9WgXcQ?si=abc'),
        'https://youtu.be/dQw4w9WgXcQ',
      );
    });

    test('Twitter/X status', () {
      expect(
        normalizer.normalize(
          'https://mobile.twitter.com/user/status/1234567890?ref_src=twsrc',
        ),
        'https://twitter.com/user/status/1234567890',
      );
    });

    test('Reddit post with tracking', () {
      expect(
        normalizer.normalize(
          'https://www.reddit.com/r/flutter/comments/abc123/my_post/?utm_source=share&utm_medium=web3x',
        ),
        'https://reddit.com/r/flutter/comments/abc123/my_post',
      );
    });

    test('Medium article', () {
      expect(
        normalizer.normalize(
          'https://medium.com/@author/some-article-abc123?source=social',
        ),
        'https://medium.com/@author/some-article-abc123',
      );
    });

    test('GitHub repo', () {
      expect(
        normalizer.normalize('https://www.github.com/flutter/flutter'),
        'https://github.com/flutter/flutter',
      );
    });

    test('Amazon product with trackers', () {
      expect(
        normalizer.normalize(
          'https://www.amazon.com/dp/B08N5WRWNW?ref=some_ref&camp=xyz',
        ),
        'https://amazon.com/dp/B08N5WRWNW',
      );
    });

    test('Instagram post', () {
      expect(
        normalizer.normalize(
          'https://www.instagram.com/p/CxYz123/?igshid=abc',
        ),
        'https://instagram.com/p/CxYz123',
      );
    });
  });
}
