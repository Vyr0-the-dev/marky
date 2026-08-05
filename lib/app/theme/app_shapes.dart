import 'package:flutter/material.dart';

/// Static shape and spacing tokens for Marky's design system.
///
/// Defines corner radii and spacing values referenced throughout the app
/// to keep the visual language consistent (§5 UI.md).
abstract final class AppShapes {
  // ─── Border Radii ───

  /// Large cards and hero panels.
  static const double radiusLarge = 20;

  /// Standard cards and input fields.
  static const double radiusStandard = 18;

  /// Top corners of bottom sheets.
  static const double radiusBottomSheet = 28;

  /// Mini buttons and compact actions.
  static const double radiusMini = 14;

  /// Chips and pills — full capsule.
  static const double radiusCapsule = 999;

  // ─── Pre-built corner geometries ───

  /// Rounded rectangle for large cards.
  static const RoundedRectangleBorder largeCardShape =
      RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
  );

  /// Rounded rectangle for standard cards and inputs.
  static const RoundedRectangleBorder standardShape =
      RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusStandard)),
  );

  /// Top-only rounding for bottom sheets.
  static const RoundedRectangleBorder bottomSheetShape =
      RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(radiusBottomSheet),
      topRight: Radius.circular(radiusBottomSheet),
    ),
  );

  /// Capsule shape for chips and pills.
  static const RoundedRectangleBorder capsuleShape =
      RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusCapsule)),
  );

  // ─── Spacing ───

  /// Base grid unit: 4.
  static const double grid = 4;

  /// General screen padding.
  static const double screenPadding = 16;

  /// Large block spacing between major sections.
  static const double blockSpacing = 24;

  /// Internal padding for cards.
  static const double cardPadding = 14;

  /// Gap between rows in dense lists.
  static const double listRowGap = 12;

  /// Cross-axis spacing for masonry/grid layouts.
  static const double gridCrossAxisSpacing = 12;

  /// Main-axis spacing for masonry/grid layouts.
  static const double gridMainAxisSpacing = 16;

  // ─── Pre-built edge insets ───

  /// Standard screen padding as [EdgeInsets].
  static const EdgeInsets screenPaddingInsets = EdgeInsets.all(screenPadding);

  /// Card internal padding as [EdgeInsets].
  static const EdgeInsets cardPaddingInsets = EdgeInsets.all(cardPadding);

  /// Horizontal-only screen padding.
  static const EdgeInsets horizontalScreenPadding =
      EdgeInsets.symmetric(horizontal: screenPadding);
}
