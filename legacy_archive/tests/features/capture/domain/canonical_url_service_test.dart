import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/canonical_extraction_result.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/html_canonical_extractor.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/platform_canonical_extractor.dart';
import 'package:marky/features/capture/domain/services/canonical_url_service.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class _FakePlatformExtractor implements PlatformCanonicalExtractor {
  CanonicalExtractionResult? result;
  String? lastExtractUrl;

  @override
  CanonicalExtractionResult? extract(String rawUrl) {
    lastExtractUrl = rawUrl;
    return result;
  }
}

class _FakeHtmlExtractor implements HtmlCanonicalExtractor {
  CanonicalExtractionResult? result;
  String? lastExtractUrl;

  @override
  Future<CanonicalExtractionResult?> extract(String url) async {
    lastExtractUrl = url;
    return result;
  }

  @override
  Dio get dio => throw UnimplementedError();

  @override
  Duration get overallTimeout => throw UnimplementedError();

  @override
  Duration get requestTimeout => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakePlatformExtractor platform;
  late _FakeHtmlExtractor html;
  late CanonicalUrlService service;

  setUp(() {
    platform = _FakePlatformExtractor();
    html = _FakeHtmlExtractor();
    service = CanonicalUrlService(
      platformExtractor: platform as PlatformCanonicalExtractor,
      htmlExtractor: html as HtmlCanonicalExtractor,
    );
  });

  group('priority ordering', () {
    test('platform returns result → html is not called', () async {
      const result = CanonicalExtractionResult(
        canonicalUrl: 'https://youtube.com/watch?v=abc',
        externalContentId: 'abc',
      );
      platform.result = result;

      final actual = await service.extract('https://youtu.be/abc');

      expect(actual, same(result));
      expect(platform.lastExtractUrl, 'https://youtu.be/abc');
      expect(html.lastExtractUrl, isNull);
    });

    test('platform returns null → html is called and returns result', () async {
      const result = CanonicalExtractionResult(
        canonicalUrl: 'https://example.com/page',
        externalContentId: '',
      );
      platform.result = null;
      html.result = result;

      final actual = await service.extract('https://example.com/page');

      expect(actual, same(result));
      expect(platform.lastExtractUrl, 'https://example.com/page');
      expect(html.lastExtractUrl, 'https://example.com/page');
    });

    test('both return null → service returns null', () async {
      platform.result = null;
      html.result = null;

      final actual = await service.extract('https://example.com/page');

      expect(actual, isNull);
      expect(platform.lastExtractUrl, 'https://example.com/page');
      expect(html.lastExtractUrl, 'https://example.com/page');
    });
  });

  group('input validation', () {
    test('null input → returns null without calling extractors', () async {
      final actual = await service.extract(null);

      expect(actual, isNull);
      expect(platform.lastExtractUrl, isNull);
      expect(html.lastExtractUrl, isNull);
    });

    test('empty string input → returns null without calling extractors',
        () async {
      final actual = await service.extract('');

      expect(actual, isNull);
      expect(platform.lastExtractUrl, isNull);
      expect(html.lastExtractUrl, isNull);
    });

    test('whitespace-only input → returns null', () async {
      final actual = await service.extract('   ');

      expect(actual, isNull);
      // Platform extractor handles trimming internally, so it may be called.
      // The contract is: empty/null inputs return null.
    });
  });

  group('singleton instance', () {
    test('instance is lazily created and stable', () {
      final a = CanonicalUrlService.instance;
      final b = CanonicalUrlService.instance;
      expect(a, same(b));
    });

    test('instance uses real extractors', () {
      final svc = CanonicalUrlService.instance;
      expect(svc.platformExtractor, same(PlatformCanonicalExtractor.instance));
      expect(svc.htmlExtractor, same(HtmlCanonicalExtractor.instance));
    });
  });
}
