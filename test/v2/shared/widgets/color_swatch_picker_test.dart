import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marky/shared/widgets/color_swatch_picker.dart';

void main() {
  group('ColorSwatchPicker', () {
    testWidgets('renders one swatch per palette entry',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ColorSwatchPicker(
            selected: null,
            onChanged: (_) {},
          ),
        ),
      ));

      // Each swatch is wrapped in a Semantics(button: true).
      final Iterable<Semantics> swatches = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((Semantics s) => s.properties.button ?? false);
      // +1 for the custom color picker dot.
      expect(swatches.length, MarkyAccentPalette.values.length + 1);
    });

    testWidgets('tapping a swatch fires onChanged with the right argb',
        (WidgetTester tester) async {
      int? picked;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ColorSwatchPicker(
            selected: null,
            onChanged: (int? argb) => picked = argb,
          ),
        ),
      ));

      // Tap the second swatch (first non-null color).
      final Finder secondSwatch = find.byType(InkWell).at(1);
      await tester.tap(secondSwatch);
      await tester.pumpAndSettle();

      expect(picked, MarkyAccentPalette.values[1]);
    });

    testWidgets('selected swatch shows a check mark',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ColorSwatchPicker(
            selected: MarkyAccentPalette.values[2],
            onChanged: (_) {},
          ),
        ),
      ));

      // Exactly one check icon should appear.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('"no color" swatch shows reset icon when not selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ColorSwatchPicker(
            selected: MarkyAccentPalette.values[2],
            onChanged: (_) {},
          ),
        ),
      ));

      expect(find.byIcon(Icons.format_color_reset_outlined), findsOneWidget);
    });
  });

  group('MarkyAccentPalette', () {
    test('first entry is null (no color)', () {
      expect(MarkyAccentPalette.values.first, isNull);
    });

    test('all non-null entries are valid ARGB ints', () {
      for (final int? argb in MarkyAccentPalette.values.skip(1)) {
        expect(argb, isNotNull);
        expect(argb! >> 24 & 0xFF, 0xFF, reason: 'must be fully opaque');
      }
    });

    test('palette has at least 8 colors plus the no-color entry', () {
      expect(MarkyAccentPalette.values.length, greaterThanOrEqualTo(9));
    });
  });
}
