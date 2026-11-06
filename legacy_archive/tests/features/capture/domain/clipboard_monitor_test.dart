import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/capture/domain/services/clipboard_monitor.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';

void main() {
  group('ClipboardMonitor', () {
    late UrlNormalizationService urlNormalizationService;
    late ClipboardMonitor monitor;
    ClipboardData? mockClipboardData;

    Future<ClipboardData?> mockReader() async => mockClipboardData;

    setUp(() {
      urlNormalizationService = UrlNormalizationService.instance;
      mockClipboardData = null;
      monitor = ClipboardMonitor(
        urlNormalizationService: urlNormalizationService,
        clipboardReader: mockReader,
      );
    });

    group('ClipboardCheckResult', () {
      test('fields are accessible', () {
        const ClipboardCheckResult result = ClipboardCheckResult(
          url: 'https://a.com',
          hash: 'abc',
        );

        expect(result.url, 'https://a.com');
        expect(result.hash, 'abc');
      });

      test('toString includes url and hash', () {
        const ClipboardCheckResult result = ClipboardCheckResult(
          url: 'https://a.com',
          hash: 'abc',
        );

        expect(result.toString(), contains('https://a.com'));
        expect(result.toString(), contains('abc'));
      });
    });

    group('checkClipboard', () {
      test('returns result with correct URL and hash for valid URL', () async {
        const String rawUrl = 'https://example.com/article';
        mockClipboardData = const ClipboardData(text: rawUrl);

        final ClipboardCheckResult? result = await monitor.checkClipboard();

        expect(result, isNotNull);
        expect(result!.url, 'https://example.com/article');
        expect(
          result.hash,
          urlNormalizationService.computeUrlHash('https://example.com/article'),
        );
      });

      test('normalizes URL before returning', () async {
        mockClipboardData = const ClipboardData(
          text: 'example.com/path?utm_source=email',
        );

        final ClipboardCheckResult? result = await monitor.checkClipboard();

        expect(result, isNotNull);
        expect(result!.url, 'https://example.com/path');
      });

      test('returns null for text that cannot be parsed as a URL', () async {
        // A string that Uri.tryParse rejects even after https:// prepend
        mockClipboardData = const ClipboardData(text: 'ht!tp://[::1');

        final ClipboardCheckResult? result = await monitor.checkClipboard();

        expect(result, isNull);
      });

      test('returns null when clipboard data is null', () async {
        mockClipboardData = null;

        final ClipboardCheckResult? result = await monitor.checkClipboard();

        expect(result, isNull);
      });

      test('returns null when clipboard text is empty', () async {
        mockClipboardData = const ClipboardData(text: '');

        final ClipboardCheckResult? result = await monitor.checkClipboard();

        expect(result, isNull);
      });

      test('returns null when clipboard text is whitespace-only', () async {
        mockClipboardData = const ClipboardData(text: '   ');

        final ClipboardCheckResult? result = await monitor.checkClipboard();

        expect(result, isNull);
      });

      test('returns null when clipboard read throws', () async {
        final ClipboardMonitor throwingMonitor = ClipboardMonitor(
          urlNormalizationService: urlNormalizationService,
          clipboardReader: () async => throw Exception('Clipboard access denied'),
        );

        final ClipboardCheckResult? result =
            await throwingMonitor.checkClipboard();

        expect(result, isNull);
      });

      test('handles URL with tracking params', () async {
        mockClipboardData = const ClipboardData(
          text: 'https://example.com?utm_source=email&fbclid=abc&id=42',
        );

        final ClipboardCheckResult? result = await monitor.checkClipboard();

        expect(result, isNotNull);
        expect(result!.url, 'https://example.com?id=42');
        expect(
          result.hash,
          urlNormalizationService.computeUrlHash('https://example.com?id=42'),
        );
      });

      test('handles very long text that is a valid URL', () async {
        // A very long but still valid URL path
        final String longPath = 'x' * 2000;
        mockClipboardData = ClipboardData(text: 'https://example.com/$longPath');

        final ClipboardCheckResult? result = await monitor.checkClipboard();

        expect(result, isNotNull);
        expect(result!.url, 'https://example.com/$longPath');
      });

      test('handles text with newline after URL', () async {
        mockClipboardData = const ClipboardData(
          text: 'https://example.com/article\nSome extra text',
        );

        final ClipboardCheckResult? result = await monitor.checkClipboard();

        // Uri.tryParse handles newlines in the path; behavior is deterministic
        // The newline becomes part of the path, which normalization preserves
        expect(result, isNotNull);
        expect(result!.url.startsWith('https://example.com/article'), isTrue);
      });
    });
  });
}
