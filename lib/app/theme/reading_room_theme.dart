import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// Builds [ThemeData] for the **Reading Room** visual identity.
///
/// Uses a clean, cohesive editorial sans pairing across the app shell:
/// - **Plus Jakarta Sans** for brand wordmark, screen headings, and card titles
/// - **Inter** (with tabular numerals for metadata/counters) for body and UI
///
/// Reader Mode separately exposes Source Serif 4 / Inter for long-form reading
/// and JetBrains Mono strictly for article code blocks.
///
/// Callers pick the palette via [ReadingRoomVariant]:
/// - [ReadingRoomVariant.light] — warm off-white
/// - [ReadingRoomVariant.dark]  — warm black
/// - [ReadingRoomVariant.oled]  — pure `#000000` (battery save on AMOLED)
abstract final class ReadingRoomTheme {
  /// Returns a fully-configured [ThemeData] for [variant].
  static ThemeData build(ReadingRoomVariant variant) {
    final _Palette p = _paletteFor(variant);
    final Brightness brightness = variant == ReadingRoomVariant.light
        ? Brightness.light
        : Brightness.dark;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: variant == ReadingRoomVariant.light
          ? ReadingRoomColors.lightSurfaceRaised
          : ReadingRoomColors.lightInk,
      secondary: p.accent,
      onSecondary: variant == ReadingRoomVariant.light
          ? ReadingRoomColors.lightSurfaceRaised
          : ReadingRoomColors.lightInk,
      error: p.danger,
      onError: variant == ReadingRoomVariant.light
          ? ReadingRoomColors.lightSurfaceRaised
          : ReadingRoomColors.lightInk,
      surface: p.surface,
      onSurface: p.ink,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceRaised,
      surfaceContainerHighest: p.surfaceRaised,
      onSurfaceVariant: p.muted,
      outline: p.outline,
      outlineVariant: p.outline,
    );

    final TextTheme baseText = _buildTextTheme(p.ink, p.muted);
    final Color navActiveColor = variant == ReadingRoomVariant.light
        ? ReadingRoomColors.lightInk
        : const Color(0xFFEDEDEC);
    const Color navInactiveColor = Color(0xFF6E6E6C);
    final TextStyle navActiveLabelStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: navActiveColor,
    );
    final TextStyle navInactiveLabelStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: navInactiveColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.surface,
      canvasColor: p.surface,
      dividerColor: p.outline,
      textTheme: baseText,
      splashFactory: InkSparkle.splashFactory,
      splashColor: p.ink.withValues(alpha: 0.06),
      highlightColor: p.ink.withValues(alpha: 0.04),
      // ─── AppBar: flat, solid, large-title by default ───
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baseText.titleLarge,
        iconTheme: IconThemeData(color: p.ink, size: 22),
      ),
      // ─── Bottom Nav: flat, no shadow, no selection pill, uniform 22px icons ───
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: navActiveColor,
        unselectedItemColor: navInactiveColor,
        selectedIconTheme: IconThemeData(color: navActiveColor, size: 22),
        unselectedIconTheme: const IconThemeData(
          color: navInactiveColor,
          size: 22,
        ),
        selectedLabelStyle: navActiveLabelStyle,
        unselectedLabelStyle: navInactiveLabelStyle,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) {
            final bool isSelected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: isSelected ? navActiveColor : navInactiveColor,
              size: 22,
            );
          },
        ),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) {
            final bool isSelected = states.contains(WidgetState.selected);
            return isSelected ? navActiveLabelStyle : navInactiveLabelStyle;
          },
        ),
      ),
      // ─── Cards: flat fills, 1px border ───
      cardTheme: CardThemeData(
        color: p.surfaceRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          side: BorderSide(color: p.outline),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      // ─── Buttons: filled primary + outlined secondary ───
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          ),
          textStyle: baseText.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(64, 44),
          side: BorderSide(color: p.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          ),
          textStyle: baseText.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: baseText.labelLarge,
        ),
      ),
      // ─── Inputs: flat, bordered ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.lg,
          vertical: ReadingRoomSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          borderSide: BorderSide(color: p.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          borderSide: BorderSide(color: p.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
        hintStyle: baseText.bodyMedium?.copyWith(color: p.muted),
        labelStyle: baseText.bodyMedium,
      ),
      // ─── Chips: 4px radius, flat ───
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceRaised,
        disabledColor: p.surface,
        selectedColor: p.accent,
        secondarySelectedColor: p.accent,
        labelStyle: baseText.labelMedium,
        secondaryLabelStyle: baseText.labelMedium?.copyWith(
          color: scheme.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.sm,
          vertical: ReadingRoomSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReadingRoomRadii.chip),
          side: BorderSide(color: p.outline),
        ),
        side: BorderSide(color: p.outline),
      ),
      // ─── Dividers ───
      dividerTheme: DividerThemeData(
        color: p.outline,
        thickness: 1,
        space: 1,
      ),
      // ─── Bottom sheets ───
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ReadingRoomRadii.sheet),
          ),
        ),
      ),
      // ─── Dialogs ───
      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          side: BorderSide(color: p.outline),
        ),
        titleTextStyle: baseText.titleMedium,
        contentTextStyle: baseText.bodyMedium,
      ),
      // ─── SnackBar: floating, flat ───
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: baseText.bodyMedium?.copyWith(color: p.surface),
        actionTextColor: variant == ReadingRoomVariant.light
            ? ReadingRoomColors.darkAccent
            : ReadingRoomColors.lightAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        ),
      ),
      // ─── List tiles ───
      listTileTheme: ListTileThemeData(
        iconColor: p.muted,
        textColor: p.ink,
        dense: false,
        horizontalTitleGap: ReadingRoomSpacing.lg,
      ),
    );
  }

  /// Builds the unified modern editorial text theme.
  ///
  /// - `display*` / `headline*` / `title*` → Plus Jakarta Sans (clean geometric editorial sans)
  /// - `body*` / `label*` → Inter (benchmark UI legibility)
  static TextTheme _buildTextTheme(Color ink, Color muted) {
    final TextTheme display = GoogleFonts.plusJakartaSansTextTheme();
    final TextTheme sans = GoogleFonts.interTextTheme();

    return TextTheme(
      // Large display — rare, reserved for empty state hero copy.
      displayLarge: display.displayLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: display.displaySmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      // Headlines — screen titles and section heroes.
      headlineLarge: display.headlineLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      // Titles — AppBar titles, sheet titles, bookmark card headings.
      titleLarge: display.titleLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: display.titleMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
      ),
      titleSmall: display.titleSmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      // Body — Inter for clarity at small & reading sizes.
      bodyLarge: sans.bodyLarge?.copyWith(color: ink),
      bodyMedium: sans.bodyMedium?.copyWith(color: ink),
      bodySmall: sans.bodySmall?.copyWith(color: muted),
      // Labels — Inter, button + chip text.
      labelLarge: sans.labelLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: sans.labelMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: sans.labelSmall?.copyWith(
        color: muted,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static _Palette _paletteFor(ReadingRoomVariant variant) {
    switch (variant) {
      case ReadingRoomVariant.light:
        return const _Palette(
          surface: ReadingRoomColors.lightSurface,
          surfaceRaised: ReadingRoomColors.lightSurfaceRaised,
          ink: ReadingRoomColors.lightInk,
          muted: ReadingRoomColors.lightMuted,
          outline: ReadingRoomColors.lightOutline,
          accent: ReadingRoomColors.lightAccent,
          danger: ReadingRoomColors.lightDanger,
        );
      case ReadingRoomVariant.dark:
        return const _Palette(
          surface: ReadingRoomColors.darkSurface,
          surfaceRaised: ReadingRoomColors.darkSurfaceRaised,
          ink: ReadingRoomColors.darkInk,
          muted: ReadingRoomColors.darkMuted,
          outline: ReadingRoomColors.darkOutline,
          accent: ReadingRoomColors.darkAccent,
          danger: ReadingRoomColors.darkDanger,
        );
      case ReadingRoomVariant.oled:
        return const _Palette(
          surface: ReadingRoomColors.oledSurface,
          surfaceRaised: ReadingRoomColors.oledSurfaceRaised,
          ink: ReadingRoomColors.darkInk,
          muted: ReadingRoomColors.darkMuted,
          outline: ReadingRoomColors.oledOutline,
          accent: ReadingRoomColors.darkAccent,
          danger: ReadingRoomColors.darkDanger,
        );
    }
  }
}

/// Which Reading Room palette to render.
enum ReadingRoomVariant { light, dark, oled }

/// Exposes clean tabular metadata styles used for domains, timestamps,
/// reading durations, and stat counters without jarring terminal monospace.
abstract final class ReadingRoomTextStyles {
  /// 12px Inter with tabular numerals, muted — for domain + time + counters.
  static TextStyle metadata(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GoogleFonts.inter(
      fontSize: 12,
      height: 1.35,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.05,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  /// 14px Plus Jakarta Sans with tabular numerals — for emphasised counters.
  static TextStyle monoValue(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      height: 1.25,
      fontWeight: FontWeight.w700,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      color: theme.colorScheme.onSurface,
    );
  }
}

/// Lightweight value-type bag for a palette triple. Private — not
/// part of the public API.
class _Palette {
  const _Palette({
    required this.surface,
    required this.surfaceRaised,
    required this.ink,
    required this.muted,
    required this.outline,
    required this.accent,
    required this.danger,
  });

  final Color surface;
  final Color surfaceRaised;
  final Color ink;
  final Color muted;
  final Color outline;
  final Color accent;
  final Color danger;
}
