import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/shared/widgets/bookmark_image.dart';

void main() {
  // Valid 1x1 transparent PNG encoded as base64 (same shape as Firefox ICON).
  const String validPngDataUri =
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

  group('BookmarkImage helpers', () {
    test('decodeDataImageUri decodes valid raster base64 data URI', () {
      final Uint8List? bytes =
          BookmarkImage.decodeDataImageUri(validPngDataUri);
      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(10));
    });

    test('decodeDataImageUri returns null for SVG or invalid data URI', () {
      expect(
        BookmarkImage.decodeDataImageUri(
          'data:image/svg+xml;base64,PHN2Zz48L3N2Zz4=',
        ),
        isNull,
      );
      expect(
        BookmarkImage.decodeDataImageUri('data:image/png;base64,!!!bad!!!'),
        isNull,
      );
    });

    test('faviconFallbackUrlForHost builds Google 128px PNG favicon URL', () {
      expect(
        BookmarkImage.faviconFallbackUrlForHost('tr.wikipedia.org'),
        'https://www.google.com/s2/favicons?domain_url=https%3A%2F%2Ftr.wikipedia.org&sz=128',
      );
      expect(
        BookmarkImage.faviconFallbackUrlForHost(
          'https://docs.flutter.dev/perf/impeller',
        ),
        'https://www.google.com/s2/favicons?domain_url=https%3A%2F%2Fdocs.flutter.dev&sz=128',
      );
      expect(BookmarkImage.faviconFallbackUrlForHost('localhost'), isNull);
      expect(BookmarkImage.faviconFallbackUrlForHost(''), isNull);
    });

    testWidgets('renders data:image/png;base64 URI via Image.memory', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookmarkImage(
              imageUrl: validPngDataUri,
              width: 32,
              height: 32,
            ),
          ),
        ),
      );

      final Image img = tester.widget<Image>(find.byType(Image));
      expect(img.image, isA<MemoryImage>());
    });
  });
}
