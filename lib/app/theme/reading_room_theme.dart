import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';

/// Builds [ThemeData] for the **Reading Room** visual identity.
///
/// Reading Room uses a tripartite type system:
/// - **Source Serif 4** for headlines (body of the library)
/// - **Inter** for body + UI (legibility at small sizes)
/// - **JetBrains Mono** for metadata / timestamps / counters (data feel)
///
/// Fonts are currently pulled via `google_fonts` (runtime fetch, cached
/// after first launch). Faz 12 will replace this with a local asset
/// bundle so first-launch is fully offline-capable.
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
          : ReadingRoomColors.darkInk,
      secondary: p.accent,
      onSecondary: p.ink,
      error: p.danger,
      onError: variant == ReadingRoomVariant.light
          ? ReadingRoomColors.lightSurfaceRaised
          : ReadingRoomColors.darkInk,
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
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
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
          foregroundColor: variant == ReadingRoomVariant.light
              ? ReadingRoomColors.lightSurfaceRaised
              : ReadingRoomColors.darkInk,
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
          color: variant == ReadingRoomVariant.light
              ? ReadingRoomColors.lightSurfaceRaised
              : ReadingRoomColors.darkInk,
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

  /// Builds the three-voice text theme.
  ///
  /// - `headline*` → Source Serif 4 (500 weight)
  /// - `title*` / `body*` / `label*` → Inter (400/500)
  /// - `bodySmall` is Inter too, but feature code should use the
  ///   exposed [ReadingRoomTextStyles.metadata] getter to reach mono
  ///   (not part of Material's vocabulary).
  static TextTheme _buildTextTheme(Color ink, Color muted) {
    final TextTheme serif = GoogleFonts.sourceSerif4TextTheme();
    final TextTheme sans = GoogleFonts.interTextTheme();

    return TextTheme(
      // Large display — rare, reserved for empty state hero copy.
      displayLarge: serif.displayLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      displayMedium: serif.displayMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      displaySmall: serif.displaySmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      // Headlines — bookmark titles, screen titles in serif.
      headlineLarge: serif.headlineLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: serif.headlineMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: serif.headlineSmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      // Titles — card headings, sheet titles (serif, tighter).
      titleLarge: serif.titleLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: sans.titleMedium?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: sans.titleSmall?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      // Body — sans for legibility at reading sizes.
      bodyLarge: sans.bodyLarge?.copyWith(color: ink),
      bodyMedium: sans.bodyMedium?.copyWith(color: ink),
      bodySmall: sans.bodySmall?.copyWith(color: muted),
      // Labels — sans, button + chip text.
      labelLarge: sans.labelLarge?.copyWith(
        color: ink,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: sans.labelMedium?.copyWith(color: ink),
      labelSmall: sans.labelSmall?.copyWith(color: muted),
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

/// Exposes the monospace "metadata" text style that isn't part of the
/// Material [TextTheme] vocabulary. Used for timestamps, domain names,
/// counters, and any other data-feel copy.
abstract final class ReadingRoomTextStyles {
  /// 12-13px JetBrains Mono, muted — for domain + time + counters.
  static TextStyle metadata(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GoogleFonts.jetBrainsMono(
      fontSize: 12,
      height: 1.4,
      letterSpacing: 0,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  /// 14px JetBrains Mono, ink-coloured — for emphasised mono (counter
  /// value on top of [metadata] label).
  static TextStyle monoValue(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GoogleFonts.jetBrainsMono(
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.w500,
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
