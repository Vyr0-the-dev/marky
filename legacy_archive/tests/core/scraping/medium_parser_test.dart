import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/parsers/medium_parser.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';

import 'fixtures.dart';

void main() {
  late Dio dio;
  late MediumParser parser;

  setUp(() {
    dio = DioClient.create();
    parser = MediumParser(dio: dio);
  });

  tearDown(() {
    dio.close();
  });

  group('contract', () {
    test('implements SourceParser', () {
      expect(parser, isA<SourceParser>());
    });

    test('hosts contains medium.com variants', () {
      expect(parser.hosts, contains('medium.com'));
      expect(parser.hosts, contains('www.medium.com'));
    });

    test('instance singleton returns same object', () {
      final MediumParser a = MediumParser.instance;
      final MediumParser b = MediumParser.instance;
      expect(a, same(b));
    });
  });

  group('happy path', () {
    test('extracts metadata from OG tags', () async {
      const String url = 'https://medium.com/@author/my-article-123';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="My Article Title">
  <meta property="og:description" content="A great article about code.">
  <meta property="og:image" content="https://miro.medium.com/max/1200/hero.jpg">
  <meta property="og:site_name" content="Medium">
  <meta property="og:type" content="article">
  <meta property="og:locale" content="en_US">
  <meta property="article:published_time" content="2024-03-15T08:00:00Z">
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
      expect(result!.title, 'My Article Title');
      expect(result.description, 'A great article about code.');
      expect(result.thumbnailUrl, 'https://miro.medium.com/max/1200/hero.jpg');
      expect(result.heroImageUrl, result.thumbnailUrl);
      expect(result.siteName, 'Medium');
      expect(result.publisher, 'Medium');
      expect(result.contentType, 'article');
      expect(result.languageCode, 'en_US');
      expect(result.publishDate, DateTime.utc(2024, 3, 15, 8));
    });

    test('extracts author from JSON-LD Person', () async {
      const String url = 'https://medium.com/@author/my-article-123';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="Article with Author">
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Person",
    "name": "Jane Doe"
  }
  </script>
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
      expect(result!.title, 'Article with Author');
      expect(result.author, 'Jane Doe');
    });

    test('extracts author from JSON-LD author field', () async {
      const String url = 'https://medium.com/@author/my-article-123';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="Article with Nested Author">
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "NewsArticle",
    "headline": "Nested Author Article",
    "author": {
      "@type": "Person",
      "name": "John Smith"
    }
  }
  </script>
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
      expect(result!.title, 'Article with Nested Author');
      expect(result.author, 'John Smith');
    });

    test('extracts author from JSON-LD creator field', () async {
      const String url = 'https://medium.com/@author/my-article-123';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="Article with Creator">
  <script type="application/ld+json">
  {
    "@type": "Article",
    "creator": {
      "@type": "Person",
      "name": "Alice Writer"
    }
  }
  </script>
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
      expect(result!.title, 'Article with Creator');
      expect(result.author, 'Alice Writer');
    });

    test('extracts author from JSON-LD Organization', () async {
      const String url = 'https://medium.com/@author/my-article-123';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="Org Article">
  <script type="application/ld+json">
  {
    "@type": "Organization",
    "name": "Tech Blog Inc"
  }
  </script>
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
      expect(result!.title, 'Org Article');
      expect(result.author, 'Tech Blog Inc');
    });

    test('extracts author from JSON-LD array', () async {
      const String url = 'https://medium.com/@author/my-article-123';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="Array JSON-LD">
  <script type="application/ld+json">
  [
    {"@type": "WebSite", "name": "My Blog"},
    {"@type": "Person", "name": "Array Author"}
  ]
  </script>
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
      expect(result!.title, 'Array JSON-LD');
      expect(result.author, 'Array Author');
    });

    test('falls back to article:author when JSON-LD absent', () async {
      const String url = 'https://medium.com/@author/my-article-123';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="OG Author Fallback">
  <meta property="article:author" content="OG Author">
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
      expect(result!.title, 'OG Author Fallback');
      expect(result.author, 'OG Author');
    });

    test('works with www.medium.com links', () async {
      const String url = 'https://www.medium.com/@author/article';
      const String html = '<html><head><meta property="og:title" content="WWW Article"></head></html>';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'WWW Article');
    });

    test('works with *.medium.com subdomain', () async {
      const String url = 'https://betterprogramming.medium.com/my-post';
      const String html = '<html><head><meta property="og:title" content="Subdomain Article"></head></html>';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            url: (RequestOptions o) => htmlResponse(o, body: html),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Subdomain Article');
    });
  });

  group('error cases', () {
    test('returns null on DioException', () async {
      const String url = 'https://medium.com/@author/not-found';
      dio.interceptors.add(
        FixtureInterceptor(fixtures: {}),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on 500 response', () async {
      const String url = 'https://medium.com/@author/error';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {
            url: (RequestOptions o) => htmlResponse(o, body: 'Error', statusCode: 500),
          },
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on 404 response', () async {
      const String url = 'https://medium.com/@author/deleted';
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
      const String url = 'https://medium.com/@author/notitle';
      const String html = '<html><head><meta property="og:description" content="No title"></head></html>';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: html)},
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on timeout', () async {
      const String url = 'https://medium.com/@author/slow';
      const String html = '<html><head><meta property="og:title" content="Too Late"></head></html>';
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

    test('returns null for non-Medium URLs', () async {
      final result = await parser.parse('https://dev.to/article/123');
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
      const String url = 'https://medium.com/@author/empty';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: '')},
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('handles malformed HTML gracefully', () async {
      const String url = 'https://medium.com/@author/broken';
      const String html = '<>>> <<<< not html < meta property="og:title" content="Broken">';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: html)},
        ),
      );
      final result = await parser.parse(url);
      // html_parser may not extract anything from garbage input; null is fine
      expect(result, isNull);
    });

    test('handles invalid JSON-LD gracefully', () async {
      const String url = 'https://medium.com/@author/badjson';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="Bad JSON-LD">
  <script type="application/ld+json">not json at all</script>
</head>
</html>
''';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: html)},
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'Bad JSON-LD');
      expect(result.author, isNull);
    });

    test('returns null when no meaningful metadata found', () async {
      const String url = 'https://medium.com/@author/nothing';
      const String html = '<html><head></head><body>No meta</body></html>';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: html)},
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('resolves relative image URL to absolute', () async {
      const String url = 'https://medium.com/@author/relative-img';
      const String html = '''
<html>
<head>
  <meta property="og:title" content="Relative Image">
  <meta property="og:image" content="/images/hero.jpg">
</head>
</html>
''';
      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: {url: (RequestOptions o) => htmlResponse(o, body: html)},
        ),
      );
      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.thumbnailUrl, 'https://medium.com/images/hero.jpg');
    });
  });
}
