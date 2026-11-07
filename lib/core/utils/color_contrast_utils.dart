import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Tag styling container guaranteed to meet WCAG AA contrast against
/// the current background surface.
@immutable
class TagColorStyle {
  const TagColorStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.baseColor,
  });

  /// Flat tinted fill for the tag chip.
  final Color backgroundColor;

  /// 0.5px - 1px border stroke.
  final Color borderColor;

  /// High-contrast foreground text and icon color.
  final Color textColor;

  /// The original chosen color before accessibility adjustment.
  final Color baseColor;
}

/// Utilities for computing WCAG 2.1 contrast ratios and adapting
/// user-selected colors across Light, Dark, and OLED surfaces.
abstract final class ColorContrastUtils {
  /// Computes WCAG 2.1 contrast ratio between [foreground] and [background].
  ///
  /// Returns a ratio between 1.0 (identical colors) and 21.0 (pure black on white).
  static double contrastRatio(Color foreground, Color background) {
    final double l1 = foreground.computeLuminance();
    final double l2 = background.computeLuminance();
    final double lighter = math.max(l1, l2);
    final double darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Adjusts [color] in HSL space so that it achieves at least [targetRatio]
  /// contrast ratio against [surface].
  ///
  /// Preserves the user's chosen hue and saturation while adjusting
  /// lightness toward light (for dark surfaces) or dark (for light surfaces).
  static Color ensureAccessibleTextColor({
    required Color color,
    required Color surface,
    double targetRatio = 4.5,
  }) {
    if (contrastRatio(color, surface) >= targetRatio) {
      return color;
    }

    final HSLColor hsl = HSLColor.fromColor(color);
    final bool surfaceIsDark = surface.computeLuminance() < 0.5;

    double low = surfaceIsDark ? hsl.lightness : 0.0;
    double high = surfaceIsDark ? 1.0 : hsl.lightness;
    Color bestColor = surfaceIsDark ? Colors.white : Colors.black;

    for (int i = 0; i < 10; i++) {
      final double mid = (low + high) / 2;
      final Color candidate = hsl.withLightness(mid).toColor();
      final double ratio = contrastRatio(candidate, surface);

      if (surfaceIsDark) {
        if (ratio >= targetRatio) {
          bestColor = candidate;
          high = mid; // Try to stay closer to original lightness
        } else {
          low = mid;
        }
      } else {
        if (ratio >= targetRatio) {
          bestColor = candidate;
          low = mid; // Try to stay closer to original lightness
        } else {
          high = mid;
        }
      }
    }

    return bestColor;
  }

  /// Resolves a complete, contrast-safe [TagColorStyle] for a given [colorArgb]
  /// (or fallback color) against the active theme in [context].
  static TagColorStyle resolveTagStyle({
    int? colorArgb,
    Color? fallbackColor,
    required BuildContext context,
  }) {
    final ThemeData theme = Theme.of(context);
    final Color surface = theme.colorScheme.surface;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color defaultAccent = fallbackColor ?? theme.colorScheme.primary;

    final Color base = colorArgb != null ? Color(colorArgb) : defaultAccent;

    final Color accessibleText = ensureAccessibleTextColor(
      color: base,
      surface: surface,
    );

    final double bgAlpha = isDark ? 0.18 : 0.12;
    final double borderAlpha = isDark ? 0.38 : 0.28;

    return TagColorStyle(
      backgroundColor: base.withValues(alpha: bgAlpha),
      borderColor: accessibleText.withValues(alpha: borderAlpha),
      textColor: accessibleText,
      baseColor: base,
    );
  }
}
