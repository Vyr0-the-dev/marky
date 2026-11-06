import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';

void main() {
  group('UrlNormalizationService', () {
    late UrlNormalizationService service;

    setUp(() {
      service = UrlNormalizationService.instance;
    });

    group('normalizeUrl — basic normalization', () {
      test('returns null for empty string', () {
        expect(service.normalizeUrl(''), isNull);
      });

      test('returns null for whitespace-only string', () {
        expect(service.normalizeUrl('   '), isNull);
      });

      test('normalizes a basic HTTPS URL', () {
        const String raw = 'https://example.com/path';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/path');
      });

      test('prepends https:// when scheme is missing', () {
        const String raw = 'example.com/path';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/path');
      });

      test('lowercases the host', () {
        const String raw = 'https://EXAMPLE.COM/path';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/path');
      });

      test('preserves the path', () {
        const String raw = 'https://example.com/some/deep/path';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/some/deep/path');
      });

      test('preserves meaningful query parameters', () {
        const String raw = 'https://example.com/?id=123&sort=asc';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=123&sort=asc');
      });

      test('strips fragment', () {
        const String raw = 'https://example.com/path#section';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/path');
      });

      test('strips default port for https', () {
        const String raw = 'https://example.com:443/path';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/path');
      });

      test('strips default port for http', () {
        const String raw = 'http://example.com:80/path';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'http://example.com/path');
      });

      test('preserves non-default port', () {
        const String raw = 'https://example.com:8080/path';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com:8080/path');
      });

      test('handles complex URL with multiple tracking params', () {
        const String raw =
            'https://example.com/article?utm_source=email&utm_campaign=spring&fbclid=abc123&id=42&gclid=xyz';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/article?id=42');
      });

      test('returns null for malformed URL', () {
        expect(service.normalizeUrl('ht!tp://[::1'), isNull);
      });
    });

    group('normalizeUrl — individual tracking parameter stripping', () {
      test('strips utm_source tracking parameter', () {
        const String raw = 'https://example.com/?utm_source=email&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips utm_medium tracking parameter', () {
        const String raw = 'https://example.com/?utm_medium=social&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips utm_campaign tracking parameter', () {
        const String raw = 'https://example.com/?utm_campaign=spring&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips utm_term tracking parameter', () {
        const String raw = 'https://example.com/?utm_term=shoes&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips utm_content tracking parameter', () {
        const String raw = 'https://example.com/?utm_content=banner&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips fbclid tracking parameter', () {
        const String raw = 'https://example.com/path?fbclid=IwAR123&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/path?id=1');
      });

      test('strips gclid tracking parameter', () {
        const String raw = 'https://example.com/?gclid=abc123&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips dclid tracking parameter', () {
        const String raw = 'https://example.com/?dclid=abc123&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips ref tracking parameter', () {
        const String raw = 'https://example.com/?ref=homepage&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips ref_src tracking parameter', () {
        const String raw = 'https://example.com/?ref_src=twsrc&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips source tracking parameter', () {
        const String raw = 'https://example.com/?source=newsletter&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips camp tracking parameter', () {
        const String raw = 'https://example.com/?camp=spring_sale&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips mc_cid tracking parameter', () {
        const String raw = 'https://example.com/?mc_cid=12345&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips mc_eid tracking parameter', () {
        const String raw = 'https://example.com/?mc_eid=abcde&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips igshid tracking parameter', () {
        const String raw = 'https://instagram.com/p/abc/?igshid=xyz&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://instagram.com/p/abc/?id=1');
      });

      test('strips igsh tracking parameter', () {
        const String raw = 'https://instagram.com/p/abc/?igsh=xyz&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://instagram.com/p/abc/?id=1');
      });

      test('strips si tracking parameter', () {
        const String raw = 'https://youtube.com/watch?v=abc123&si=xyz';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://youtube.com/watch?v=abc123');
      });

      test('strips feature tracking parameter', () {
        const String raw = 'https://youtube.com/watch?v=abc123&feature=share';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://youtube.com/watch?v=abc123');
      });

      test('strips spm tracking parameter', () {
        const String raw = 'https://example.com/?spm=a21bo&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips mkt_tok tracking parameter', () {
        const String raw = 'https://example.com/?mkt_tok=abc123&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips _branch_match_id tracking parameter', () {
        const String raw = 'https://example.com/?_branch_match_id=12345&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });

      test('strips _branch_referrer tracking parameter', () {
        const String raw = 'https://example.com/?_branch_referrer=abc&id=1';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?id=1');
      });
    });

    group('normalizeUrl — platform URL variants', () {
      test('handles YouTube watch URL with tracking params', () {
        const String raw =
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ&feature=share&si=abc123';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
      });

      test('handles YouTube short link youtu.be', () {
        const String raw = 'https://youtu.be/dQw4w9WgXcQ?si=abc123';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://youtu.be/dQw4w9WgXcQ');
      });

      test('handles Reddit old subdomain', () {
        const String raw =
            'https://old.reddit.com/r/flutterdev/comments/abc123/title/?utm_source=share';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://old.reddit.com/r/flutterdev/comments/abc123/title/');
      });

      test('handles Reddit mobile subdomain', () {
        const String raw =
            'https://mobile.reddit.com/r/flutterdev/comments/abc123/title';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://mobile.reddit.com/r/flutterdev/comments/abc123/title');
      });

      test('handles X (Twitter) URL with known tracking params', () {
        const String raw =
            'https://x.com/elonmusk/status/123456?ref_src=twsrc&s=19';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://x.com/elonmusk/status/123456?s=19');
      });

      test('handles Twitter URL with ref_src tracking param', () {
        const String raw =
            'https://twitter.com/elonmusk/status/123456?ref_src=twsrc';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://twitter.com/elonmusk/status/123456');
      });

      test('handles Medium URL with source param', () {
        const String raw =
            'https://medium.com/@user/article-title-123?source=email-abc123';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://medium.com/@user/article-title-123');
      });

      test('handles Amazon URL with source tracking param', () {
        const String raw =
            'https://www.amazon.com/dp/B08N5WRWNW?source=email';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://www.amazon.com/dp/B08N5WRWNW');
      });

      test('handles GitHub URL with line highlight fragment', () {
        const String raw =
            'https://github.com/owner/repo/blob/main/lib/main.dart#L42-L50';
        final String? result = service.normalizeUrl(raw);
        expect(result,
            'https://github.com/owner/repo/blob/main/lib/main.dart');
      });

      test('handles Instagram share URL with igshid', () {
        const String raw =
            'https://www.instagram.com/p/ABC123/?igshid=YmMyMTA2M2Y=';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://www.instagram.com/p/ABC123/');
      });
    });

    group('normalizeUrl — edge cases', () {
      test('handles percent-encoded query parameters', () {
        const String raw =
            'https://example.com/?q=hello%20world&id=1';
        final String? result = service.normalizeUrl(raw);
        // Dart Uri normalizes %20 to + in query strings.
        expect(result, 'https://example.com/?id=1&q=hello+world');
      });

      test('handles empty query parameter values', () {
        const String raw = 'https://example.com/?key=&other=value';
        final String? result = service.normalizeUrl(raw);
        // Dart Uri omits = when a query param has an empty value.
        expect(result, 'https://example.com/?key&other=value');
      });

      test('handles query parameter with no value', () {
        const String raw = 'https://example.com/?flag&other=value';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?flag&other=value');
      });

      test('sorts query parameters alphabetically for hash stability', () {
        const String raw = 'https://example.com/?z=last&a=first&m=middle';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?a=first&m=middle&z=last');
      });

      test('normalization is stable regardless of query param order', () {
        const String raw1 = 'https://example.com/?b=2&a=1';
        const String raw2 = 'https://example.com/?a=1&b=2';
        final String? result1 = service.normalizeUrl(raw1);
        final String? result2 = service.normalizeUrl(raw2);
        expect(result1, result2);
        expect(result1, 'https://example.com/?a=1&b=2');
      });

      test('preserves trailing slash in path', () {
        const String raw = 'https://example.com/path/';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/path/');
      });

      test('preserves www prefix', () {
        const String raw = 'https://www.example.com/path';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://www.example.com/path');
      });

      test('handles URL with double slashes in path', () {
        const String raw = 'https://example.com//path//to//resource';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com//path//to//resource');
      });

      test('handles IDN (unicode) host', () {
        const String raw = 'https://münchen.example/path';
        final String? result = service.normalizeUrl(raw);
        // Dart Uri preserves unicode host and percent-encodes in output.
        expect(result, 'https://m%C3%BCnchen.example/path');
      });

      test('handles URL with auth info (user:pass) — Dart strips it', () {
        const String raw = 'https://user:pass@example.com/path';
        final String? result = service.normalizeUrl(raw);
        // Dart Uri removes userInfo when rebuilding the URI.
        expect(result, 'https://example.com/path');
      });

      test('handles mixed-case query parameter keys', () {
        const String raw = 'https://example.com/?ID=123&Sort=asc';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/?ID=123&Sort=asc');
      });

      test('handles URL with only tracking params', () {
        const String raw = 'https://example.com/?utm_source=email&fbclid=abc';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/');
      });

      test('handles URL with whitespace around it', () {
        const String raw = '  https://example.com/path  ';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'https://example.com/path');
      });

      test('handles URL with many query parameters', () {
        const String raw =
            'https://example.com/?z=9&a=1&b=2&c=3&d=4&e=5&f=6&g=7&h=8';
        final String? result = service.normalizeUrl(raw);
        expect(result,
            'https://example.com/?a=1&b=2&c=3&d=4&e=5&f=6&g=7&h=8&z=9');
      });

      test('handles path with special characters', () {
        const String raw =
            'https://example.com/path/with%20spaces/file%2Bname';
        final String? result = service.normalizeUrl(raw);
        expect(result,
            'https://example.com/path/with%20spaces/file%2Bname');
      });

      test('handles ftp scheme without changing it', () {
        const String raw = 'ftp://files.example.com/document.pdf';
        final String? result = service.normalizeUrl(raw);
        expect(result, 'ftp://files.example.com/document.pdf');
      });
    });

    group('normalizeUrl — hash stability', () {
      test('same URL produces same normalized output', () {
        const String raw = 'https://example.com/path?b=2&a=1';
        final String? result1 = service.normalizeUrl(raw);
        final String? result2 = service.normalizeUrl(raw);
        expect(result1, result2);
      });

      test('different param order produces identical normalized URL', () {
        const String raw1 =
            'https://example.com/article?id=42&sort=asc&page=2';
        const String raw2 =
            'https://example.com/article?page=2&id=42&sort=asc';
        final String? result1 = service.normalizeUrl(raw1);
        final String? result2 = service.normalizeUrl(raw2);
        expect(result1, result2);
        expect(result1,
            'https://example.com/article?id=42&page=2&sort=asc');
      });

      test('mixed tracking and meaningful params still stable', () {
        const String raw1 =
            'https://example.com/item?id=7&utm_source=x&price=10';
        const String raw2 =
            'https://example.com/item?price=10&id=7&utm_campaign=y';
        final String? result1 = service.normalizeUrl(raw1);
        final String? result2 = service.normalizeUrl(raw2);
        expect(result1, result2);
        expect(result1, 'https://example.com/item?id=7&price=10');
      });
    });

    group('computeUrlHash', () {
      test('produces stable hash for same URL', () {
        const String url = 'https://example.com/path';
        final String hash1 = service.computeUrlHash(url);
        final String hash2 = service.computeUrlHash(url);
        expect(hash1, hash2);
      });

      test('produces different hashes for different URLs', () {
        final String hash1 = service.computeUrlHash('https://example.com/a');
        final String hash2 = service.computeUrlHash('https://example.com/b');
        expect(hash1, isNot(hash2));
      });

      test('produces 64-character hex string', () {
        const String url = 'https://example.com';
        final String hash = service.computeUrlHash(url);
        expect(hash.length, 64);
        expect(RegExp(r'^[a-f0-9]+$').hasMatch(hash), isTrue);
      });

      test('hash is identical for URLs differing only in param order', () {
        const String url1 = 'https://example.com/?b=2&a=1';
        const String url2 = 'https://example.com/?a=1&b=2';
        final String hash1 = service.computeUrlHash(
          service.normalizeUrl(url1)!,
        );
        final String hash2 = service.computeUrlHash(
          service.normalizeUrl(url2)!,
        );
        expect(hash1, hash2);
      });

      test('hash differs for URLs with different hosts', () {
        final String hash1 =
            service.computeUrlHash('https://example.com/path');
        final String hash2 =
            service.computeUrlHash('https://other.com/path');
        expect(hash1, isNot(hash2));
      });
    });
  });
}
