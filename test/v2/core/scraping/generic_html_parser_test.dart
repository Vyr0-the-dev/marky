import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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

  // ─── Rich image & icon fallbacks ───────────────────────────────

  group('rich image & icon fallbacks', () {
    test('extracts og:image:secure_url and twitter:image:src', () async {
      const String html = '''
<html>
<head>
  <meta property="og:image:secure_url" content="https://img.com/secure.jpg">
</head>
<body></body>
</html>
''';
      final MetadataResult result = await parser.parse(
        'https://example.com/sec',
        html: html,
      );
      expect(result.heroImageUrl, 'https://img.com/secure.jpg');
    });

    test('extracts <link rel="image_src">', () async {
      const String html = '''
<html>
<head>
  <link rel="image_src" href="/assets/preview.png">
</head>
<body></body>
</html>
''';
      final MetadataResult result = await parser.parse(
        'https://example.com/post',
        html: html,
      );
      expect(result.heroImageUrl, 'https://example.com/assets/preview.png');
    });

    test('extracts image from JSON-LD structured data', () async {
      const String html = '''
<html>
<head>
  <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "NewsArticle",
      "headline": "JSON-LD Article",
      "image": {
        "@type": "ImageObject",
        "url": "https://img.com/jsonld-hero.webp"
      }
    }
  </script>
</head>
<body></body>
</html>
''';
      final MetadataResult result = await parser.parse(
        'https://example.com/news',
        html: html,
      );
      expect(result.heroImageUrl, 'https://img.com/jsonld-hero.webp');
    });

    test('falls back to first valid article <img> and skips 1x1 trackers',
        () async {
      const String html = '''
<html>
<head><title>Article With Inline Image</title></head>
<body>
  <article>
    <img src="https://tracker.com/pixel.gif" width="1" height="1">
    <img src="/uploads/article-cover.jpg" width="800" height="450">
  </article>
</body>
</html>
''';
      final MetadataResult result = await parser.parse(
        'https://example.com/blog',
        html: html,
      );
      expect(result.heroImageUrl, 'https://example.com/uploads/article-cover.jpg');
    });

    test(
        'falls back to apple-touch-icon for hero image and favicon when no og:image or rel="icon"',
        () async {
      const String html = '''
<html>
<head>
  <link rel="apple-touch-icon" href="/apple-touch-icon.png">
</head>
<body></body>
</html>
''';
      final MetadataResult result = await parser.parse(
        'https://example.com/app',
        html: html,
      );
      expect(result.heroImageUrl, 'https://example.com/apple-touch-icon.png');
      expect(result.faviconUrl, 'https://example.com/apple-touch-icon.png');
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

  // ─── Tier 1: JSON-LD & Schema.org ─────────────────────────────

  group('Tier 1: JSON-LD extraction', () {
    test('extracts NewsArticle with @graph, author list, publisher, and image',
        () async {
      const String jsonLdHtml = '''
<!DOCTYPE html>
<html lang="tr">
<head>
  <title>Site Tagline</title>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        "name": "Anadolu Tech Press"
      },
      {
        "@type": "NewsArticle",
        "headline": "JSON-LD Headline Beats Generic Title",
        "description": "Structured JSON-LD summary for the article.",
        "author": [
          {"@type": "Person", "name": "Ayşe Yılmaz"},
          {"@type": "Person", "name": "Mehmet Kaya"}
        ],
        "datePublished": "2026-04-12T08:30:00Z",
        "publisher": {
          "@type": "Organization",
          "name": "Anadolu Tech Press"
        },
        "image": {
          "@type": "ImageObject",
          "url": "/media/jsonld-cover.webp"
        },
        "wordCount": 820
      }
    ]
  }
  </script>
</head>
<body>
  <p>Short fallback body.</p>
</body>
</html>
''';

      final MetadataResult result = await parser.parse(
        'https://press.example.com/news/json-ld-test',
        html: jsonLdHtml,
      );

      expect(result.title, 'JSON-LD Headline Beats Generic Title');
      expect(result.description, 'Structured JSON-LD summary for the article.');
      expect(result.author, 'Ayşe Yılmaz, Mehmet Kaya');
      expect(result.siteName, 'Anadolu Tech Press');
      expect(result.publisher, 'Anadolu Tech Press');
      expect(result.publishDate, DateTime.utc(2026, 4, 12, 8, 30));
      expect(
        result.heroImageUrl,
        'https://press.example.com/media/jsonld-cover.webp',
      );
      expect(result.readingTimeMinutes, 5);
    });
  });

  // ─── Tier 3: DOM Readability & Reading Time ────────────────────

  group('Tier 3: DOM Readability scoring and readingTimeMinutes', () {
    test(
        'strips nav/footer/cookie noise, scores main article container, and computes readingTimeMinutes',
        () async {
      final String articleParagraph = List<String>.filled(
        25,
        'Flutter isolates allow heavy HTML parsing, DOM scoring, and character decoding to run off the main UI thread without dropping frames.',
      ).join(' ');

      final String readabilityHtml = '''
<!DOCTYPE html>
<html>
<head><title>Readability Test</title></head>
<body>
  <nav class="navbar">
    <p>Menu item one, menu item two, navigation links and header items that should be stripped completely from the DOM before scoring.</p>
  </nav>
  <div id="cookie-banner" class="cookie-consent">
    <p>We use cookies to personalize content and analyze traffic. Please accept our cookie policy before continuing to browse this website.</p>
  </div>
  <div class="content-wrapper">
    <figure><img src="/assets/editorial-diagram.png" width="800" height="450"></figure>
    <p>This opening lead paragraph introduces the architectural deep dive into resilient multi-tiered metadata extraction and background isolate execution.</p>
    <p>$articleParagraph</p>
  </div>
  <aside class="sidebar-widget">
    <p>Sponsored sidebar promotion that should never be chosen as the primary snippet.</p>
  </aside>
  <footer>
    <p>Copyright 2026 Example Corp. All rights reserved.</p>
  </footer>
</body>
</html>
''';

      final MetadataResult result = await parser.parse(
        'https://engineering.example.com/posts/readability-scoring',
        html: readabilityHtml,
      );

      expect(result.title, 'Readability Test');
      expect(
        result.snippet,
        startsWith(
          'This opening lead paragraph introduces the architectural deep dive',
        ),
      );
      expect(result.snippet, isNot(contains('cookies')));
      expect(
        result.heroImageUrl,
        'https://engineering.example.com/assets/editorial-diagram.png',
      );
      expect(result.readingTimeMinutes, greaterThanOrEqualTo(3));
    });
  });

  // ─── Turkish Charset & Byte Decoding ───────────────────────────

  group('Charset & Turkish character decoding', () {
    const String turkishTitle = 'Çağdaş Türkçe İletişim: Şeker, Gül, Öykü ve Işık';

    test('decodes UTF-8 bytes with Turkish characters cleanly', () async {
      const String html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta property="og:title" content="$turkishTitle">
</head>
<body></body>
</html>
''';
      final List<int> utf8Bytes = utf8.encode(html);
      final MetadataResult result = await parser.parseBytes(
        'https://turkce.example.com/yazi',
        utf8Bytes,
        contentTypeHeader: 'text/html; charset=utf-8',
      );

      expect(result.title, turkishTitle);
    });

    test('decodes Windows-1254 / ISO-8859-9 bytes with Turkish characters',
        () async {
      // Encode a string containing all Turkish-specific characters in Windows-1254 / ISO-8859-9:
      // Ç(0xC7) ğ(0xF0) ı(0xFD) İ(0xDD) ö(0xF6) Ö(0xD6) ş(0xFE) Ş(0xDE) ü(0xFC) Ü(0xDC)
      const String prefix =
          '<html><head><meta http-equiv="Content-Type" content="text/html; charset=windows-1254"><title>';
      const String suffix = '</title></head><body></body></html>';
      final List<int> bytes = <int>[
        ...ascii.encode(prefix),
        0xC7, // Ç
        0x61, // a
        0xF0, // ğ
        0xFD, // ı
        0xDD, // İ
        0xF6, // ö
        0xD6, // Ö
        0xFE, // ş
        0xDE, // Ş
        0xFC, // ü
        0xDC, // Ü
        ...ascii.encode(suffix),
      ];

      final MetadataResult result = await parser.parseBytes(
        'https://legacy-tr.example.com/haber',
        bytes,
        contentTypeHeader: 'text/html; charset=windows-1254',
      );

      expect(result.title, 'ÇağıİöÖşŞüÜ');
    });
  });

  // ─── Tier 4: 403/503 Graceful Fallback & Slug Synthesis ────────

  group('Tier 4: HTTP 403/503 graceful fallback & slug humanization', () {
    test('synthesizes clean title and siteName from Medium/news URL on HTTP 403',
        () async {
      final Dio blockedDio = Dio();
      blockedDio.httpClientAdapter = _Blocking403Adapter();
      final GenericHtmlParser blockedParser = GenericHtmlParser(dio: blockedDio);

      final MetadataResult mediumResult = await blockedParser.parse(
        'https://medium.com/@author/building-resilient-scrapers-a1b2c3d4e5f6',
      );
      expect(mediumResult.title, 'Building Resilient Scrapers');
      expect(mediumResult.siteName, 'Medium');

      final MetadataResult newsResult = await blockedParser.parse(
        'https://news.example.com/2026/my-article-title-slug.html',
      );
      expect(newsResult.title, 'My Article Title Slug');
      expect(newsResult.siteName, 'Example');
    });
  });
}

class _Blocking403Adapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromBytes(
      utf8.encode('<html><head><title>Just a moment...</title></head></html>'),
      403,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['text/html; charset=utf-8'],
      },
    );
  }
}
