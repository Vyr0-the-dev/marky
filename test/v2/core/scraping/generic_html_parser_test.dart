import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/parsers/generic_html_parser.dart';

void main() {
  final GenericHtmlParser parser = GenericHtmlParser();

  // ─── canHandle ─────────────────────────────────────────────────

  test('canHandle returns true for any URL', () {
    expect(parser.canHandle('https://example.com'), isTrue);
    expect(parser.canHandle('https://youtube.com/watch?v=abc'), isTrue);
  });

  // ─── Full OG page ─────────────────────────────────────────────

  group('full OG page', () {
    const String html = '''
<!DOCTYPE html>
<html lang="en-US">
<head>
  <title>Fallback Title</title>
  <meta property="og:title" content="OG Title">
  <meta property="og:description" content="OG Description">
  <meta property="og:image" content="https://img.com/hero.jpg">
  <meta property="og:site_name" content="Example Site">
  <meta property="og:url" content="https://example.com/canonical">
  <meta name="author" content="John Doe">
  <meta property="article:published_time" content="2024-06-15T10:00:00Z">
  <link rel="canonical" href="https://example.com/canonical-link">
  <link rel="icon" href="/favicon.png">
</head>
<body>
  <article>
    <p>Too short.</p>
    <p>This is a longer paragraph that serves as the snippet for this article. It contains enough text to pass the minimum length threshold for extraction by the generic parser.</p>
  </article>
</body>
</html>
''';

    late MetadataResult result;

    setUpAll(() async {
      result = await parser.parse(
        'https://example.com/page',
        html: html,
      );
    });

    test('extracts OG title over <title>', () {
      expect(result.title, 'OG Title');
    });

    test('extracts OG description', () {
      expect(result.description, 'OG Description');
    });

    test('extracts canonical from <link rel="canonical">', () {
      expect(result.canonicalUrl, 'https://example.com/canonical-link');
    });

    test('extracts author', () {
      expect(result.author, 'John Doe');
    });

    test('extracts site name', () {
      expect(result.siteName, 'Example Site');
    });

    test('extracts publish date', () {
      expect(result.publishDate, DateTime.utc(2024, 6, 15, 10));
    });

    test('extracts language code', () {
      expect(result.languageCode, 'en');
    });

    test('extracts hero image', () {
      expect(result.heroImageUrl, 'https://img.com/hero.jpg');
    });

    test('extracts favicon with absolute resolution', () {
      expect(result.faviconUrl, 'https://example.com/favicon.png');
    });

    test('extracts snippet from <p>', () {
      expect(result.snippet, isNotNull);
      expect(result.snippet, contains('longer paragraph'));
    });
  });

  // ─── Minimal page ─────────────────────────────────────────────

  group('minimal page', () {
    const String html = '''
<html>
<head><title>Simple Page</title></head>
<body><p>Short.</p></body>
</html>
''';

    test('falls back to <title> when no OG tags', () async {
      final MetadataResult result = await parser.parse(
        'https://example.com/simple',
        html: html,
      );
      expect(result.title, 'Simple Page');
    });

    test('description is null when not present', () async {
      final MetadataResult result = await parser.parse(
        'https://example.com/simple',
        html: html,
      );
      expect(result.description, isNull);
    });

    test('generates default favicon from domain', () async {
      final MetadataResult result = await parser.parse(
        'https://example.com/simple',
        html: html,
      );
      expect(result.faviconUrl, 'https://example.com/favicon.ico');
    });
  });

  group('challenge pages', () {
    test('filters Cloudflare verification title', () async {
      const String html = '''
<html>
<head>
  <title>Reddit - Please wait for verification</title>
  <meta name="description" content="Cloudflare verification page">
</head>
<body></body>
</html>
''';

      final MetadataResult result = await parser.parse(
        'https://www.reddit.com/r/flutter/comments/abc/post/',
        html: html,
      );

      expect(result.title, isNull);
      expect(result.description, isNull);
      expect(result.faviconUrl, 'https://www.reddit.com/favicon.ico');
    });
  });

  // ─── Twitter card tags ─────────────────────────────────────────

  group('Twitter card tags', () {
    const String html = '''
<html>
<head>
  <meta name="twitter:title" content="Tweet Title">
  <meta name="twitter:description" content="Tweet Desc">
  <meta name="twitter:image" content="https://img.com/twitter.jpg">
</head>
<body></body>
</html>
''';

    test('falls back to twitter:title', () async {
      final MetadataResult result = await parser.parse(
        'https://example.com/tw',
        html: html,
      );
      expect(result.title, 'Tweet Title');
    });

    test('falls back to twitter:description', () async {
      final MetadataResult result = await parser.parse(
        'https://example.com/tw',
        html: html,
      );
      expect(result.description, 'Tweet Desc');
    });

    test('falls back to twitter:image', () async {
      final MetadataResult result = await parser.parse(
        'https://example.com/tw',
        html: html,
      );
      expect(result.heroImageUrl, 'https://img.com/twitter.jpg');
    });
  });

  // ─── Canonical fallback to og:url ──────────────────────────────

  group('canonical fallback', () {
    const String html = '''
<html>
<head>
  <meta property="og:url" content="https://example.com/og-canonical">
</head>
<body></body>
</html>
''';

    test('uses og:url when no <link rel="canonical">', () async {
      final MetadataResult result = await parser.parse(
        'https://example.com/page',
        html: html,
      );
      expect(result.canonicalUrl, 'https://example.com/og-canonical');
    });
  });

  // ─── Relative image URL resolution ─────────────────────────────

  group('relative URL resolution', () {
    const String html = '''
<html>
<head>
  <meta property="og:image" content="/images/hero.jpg">
  <link rel="icon" href="/static/fav.ico">
</head>
<body></body>
</html>
''';

    test('resolves relative og:image', () async {
      final MetadataResult result = await parser.parse(
        'https://example.com/article',
        html: html,
      );
      expect(result.heroImageUrl, 'https://example.com/images/hero.jpg');
    });

    test('resolves relative favicon', () async {
      final MetadataResult result = await parser.parse(
        'https://example.com/article',
        html: html,
      );
      expect(result.faviconUrl, 'https://example.com/static/fav.ico');
    });
  });

  // ─── Empty/broken HTML ─────────────────────────────────────────

  group('edge cases', () {
    test('returns empty result for empty HTML', () async {
      final MetadataResult result = await parser.parse(
        'https://example.com',
        html: '',
      );
      expect(result.title, isNull);
      expect(result.description, isNull);
    });

    test('returns empty result for null HTML (simulated fetch failure)',
        () async {
      // Passing html: null forces a fetch; without a mock Dio it
      // will fail and return empty MetadataResult.
      final MetadataResult result = await parser.parse(
        'https://definitely-not-a-real-host-12345.invalid',
      );
      expect(result.isEmpty, isTrue);
    });
  });

  // ─── MetadataResult.mergeWith ──────────────────────────────────

  group('MetadataResult.mergeWith', () {
    test('primary takes priority over secondary', () {
      const MetadataResult primary = MetadataResult(title: 'A');
      const MetadataResult secondary = MetadataResult(
        title: 'B',
        description: 'Desc',
      );

      final MetadataResult merged = primary.mergeWith(secondary);
      expect(merged.title, 'A');
      expect(merged.description, 'Desc');
    });

    test('isEmpty returns true for default constructor', () {
      expect(const MetadataResult().isEmpty, isTrue);
    });

    test('isEmpty returns false when any field is set', () {
      expect(const MetadataResult(title: 'T').isEmpty, isFalse);
    });
  });
}
