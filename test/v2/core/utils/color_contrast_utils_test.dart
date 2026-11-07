import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/utils/color_contrast_utils.dart';

void main() {
  group('ColorContrastUtils', () {
    test('contrastRatio returns 21.0 for black on white', () {
      final double ratio = ColorContrastUtils.contrastRatio(
        const Color(0xFF000000),
        const Color(0xFFFFFFFF),
      );
      expect(ratio, closeTo(21.0, 0.1));
    });

    test('contrastRatio returns 1.0 for identical colors', () {
      final double ratio = ColorContrastUtils.contrastRatio(
        const Color(0xFF1E3A8A),
        const Color(0xFF1E3A8A),
      );
      expect(ratio, closeTo(1.0, 0.01));
    });

    test('ensureAccessibleTextColor boosts dark colors on dark surface', () {
      const Color darkNavy = Color(0xFF0A192F);
      const Color darkSurface = ReadingRoomColors.darkSurface; // #0E0E0C

      final double originalRatio =
          ColorContrastUtils.contrastRatio(darkNavy, darkSurface);
      expect(originalRatio, lessThan(4.5));

      final Color adjusted = ColorContrastUtils.ensureAccessibleTextColor(
        color: darkNavy,
        surface: darkSurface,
      );

      final double adjustedRatio =
          ColorContrastUtils.contrastRatio(adjusted, darkSurface);
      expect(adjustedRatio, greaterThanOrEqualTo(4.45));
    });

    test('ensureAccessibleTextColor dims bright colors on light surface', () {
      const Color brightYellow = Color(0xFFFFEB3B);
      const Color lightSurface = ReadingRoomColors.lightSurface; // #FAFAF7

      final double originalRatio =
          ColorContrastUtils.contrastRatio(brightYellow, lightSurface);
      expect(originalRatio, lessThan(4.5));

      final Color adjusted = ColorContrastUtils.ensureAccessibleTextColor(
        color: brightYellow,
        surface: lightSurface,
      );

      final double adjustedRatio =
          ColorContrastUtils.contrastRatio(adjusted, lightSurface);
      expect(adjustedRatio, greaterThanOrEqualTo(4.45));
    });

    testWidgets('resolveTagStyle produces accessible styling in context',
        (WidgetTester tester) async {
      late TagColorStyle lightStyle;
      late TagColorStyle darkStyle;
      late TagColorStyle oledStyle;

      const int darkPurpleArgb = 0xFF2D114D;

      await tester.pumpWidget(
        MaterialApp(
          home: Theme(
            data: ReadingRoomTheme.build(ReadingRoomVariant.light),
            child: Builder(
              builder: (BuildContext context) {
                lightStyle = ColorContrastUtils.resolveTagStyle(
                  colorArgb: darkPurpleArgb,
                  context: context,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(lightStyle.baseColor.value, equals(darkPurpleArgb));
      expect(
        ColorContrastUtils.contrastRatio(
            lightStyle.textColor, ReadingRoomColors.lightSurface),
        greaterThanOrEqualTo(4.45),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Theme(
            data: ReadingRoomTheme.build(ReadingRoomVariant.dark),
            child: Builder(
              builder: (BuildContext context) {
                darkStyle = ColorContrastUtils.resolveTagStyle(
                  colorArgb: darkPurpleArgb,
                  context: context,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(
        ColorContrastUtils.contrastRatio(
            darkStyle.textColor, ReadingRoomColors.darkSurface),
        greaterThanOrEqualTo(4.45),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Theme(
            data: ReadingRoomTheme.build(ReadingRoomVariant.oled),
            child: Builder(
              builder: (BuildContext context) {
                oledStyle = ColorContrastUtils.resolveTagStyle(
                  colorArgb: darkPurpleArgb,
                  context: context,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(
        ColorContrastUtils.contrastRatio(
            oledStyle.textColor, ReadingRoomColors.oledSurface),
        greaterThanOrEqualTo(4.45),
      );
    });
  });
}
