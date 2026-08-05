import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';

/// Static typography tokens for Marky's editorial design system.
///
/// Maps the editorial scale (§4 UI.md) to Material 3 semantic [TextTheme] slots
/// so the entire app can refer to `Theme.of(context).textTheme.titleMedium`
/// and receive the correct Marky styling.
abstract final class AppTypography {
  // ─── Editorial scale → Material 3 mapping ───

  /// App title / büyük başlık: 28, semibold.
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Section title: 20, semibold.
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// Card title: 16, medium.
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  /// Body: 14, regular.
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  /// Metadata: 12, medium.
  static const TextStyle metadata = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.15,
    color: AppColors.textTertiary,
  );

  /// Label / button text: 14, semibold.
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  // ─── Material 3 TextTheme assembly ───

  /// A const [TextTheme] that injects the Marky editorial scale into every
  /// Material 3 slot used by the app.
  static const TextTheme textTheme = TextTheme(
    // Display
    displayLarge: display,
    displayMedium: display,
    displaySmall: display,

    // Headline
    headlineLarge: sectionTitle,
    headlineMedium: sectionTitle,
    headlineSmall: sectionTitle,

    // Title
    titleLarge: sectionTitle,
    titleMedium: cardTitle,
    titleSmall: cardTitle,

    // Body
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: metadata,

    // Label
    labelLarge: label,
    labelMedium: metadata,
    labelSmall: metadata,
  );
}
