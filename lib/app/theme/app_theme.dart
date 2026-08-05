import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';

/// Factory that assembles raw design tokens into a production-ready
/// [ThemeData] for Marky's "pitch black luxury knowledge vault" aesthetic.
///
/// Call [AppTheme.dark] to obtain the fully-configured dark theme.
abstract final class AppTheme {
  // ─── Private helpers ───

  static Color _withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity);

  // ─── Theme factories ───

  /// The canonical Marky dark theme.
  ///
  /// Sets `useMaterial3: true` but overrides aggressively so the app
  /// does **not** look like a generic Material 3 app.
  static ThemeData dark() {
    const Color base = AppColors.base;
    const Color surface1 = AppColors.surface1;
    const Color surface2 = AppColors.surface2;
    const Color surface3 = AppColors.surface3;
    const Color border = AppColors.border;
    const Color textPrimary = AppColors.textPrimary;
    const Color textSecondary = AppColors.textSecondary;
    const Color textTertiary = AppColors.textTertiary;
    const Color accentPrimary = AppColors.accentPrimary;
    const Color accentSecondary = AppColors.accentSecondary;
    const Color accentTertiary = AppColors.accentTertiary;
    const Color danger = AppColors.danger;

    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accentPrimary,
      onPrimary: textPrimary,
      primaryContainer: _withOpacity(accentPrimary, 0.15),
      onPrimaryContainer: accentPrimary,
      secondary: accentSecondary,
      onSecondary: base,
      secondaryContainer: _withOpacity(accentSecondary, 0.15),
      onSecondaryContainer: accentSecondary,
      tertiary: accentTertiary,
      onTertiary: base,
      tertiaryContainer: _withOpacity(accentTertiary, 0.15),
      onTertiaryContainer: accentTertiary,
      error: danger,
      onError: textPrimary,
      errorContainer: _withOpacity(danger, 0.15),
      onErrorContainer: danger,
      surface: surface1,
      onSurface: textPrimary,
      surfaceContainerHighest: surface3,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: border,
      shadow: base,
      scrim: AppColors.overlay,
      inverseSurface: textPrimary,
      onInverseSurface: base,
      inversePrimary: accentPrimary,
      surfaceTint: accentPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: base,
      canvasColor: surface1,
      // ─── Text ───
      textTheme: AppTypography.textTheme,
      // ─── AppBar ───
      appBarTheme: AppBarTheme(
        backgroundColor: base,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.sectionTitle.copyWith(
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
        actionsIconTheme: const IconThemeData(color: textPrimary, size: 24),
        surfaceTintColor: Colors.transparent,
      ),
      // ─── Cards ───
      cardTheme: const CardThemeData(
        color: surface2,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: AppShapes.standardShape,
        clipBehavior: Clip.antiAlias,
      ),
      // ─── Bottom Navigation ───
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: base,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accentPrimary,
        unselectedItemColor: textTertiary,
        selectedLabelStyle: AppTypography.metadata,
        unselectedLabelStyle: AppTypography.metadata,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      // ─── Chips ───
      chipTheme: ChipThemeData(
        backgroundColor: surface3,
        disabledColor: surface1,
        selectedColor: _withOpacity(accentPrimary, 0.25),
        secondarySelectedColor: _withOpacity(accentPrimary, 0.25),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: AppTypography.metadata.copyWith(color: textSecondary),
        secondaryLabelStyle: AppTypography.metadata.copyWith(color: accentPrimary),
        iconTheme: const IconThemeData(color: textSecondary, size: 16),
        shape: AppShapes.capsuleShape,
        side: BorderSide.none,
        elevation: 0,
        pressElevation: 0,
      ),
      // ─── Inputs ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppShapes.screenPadding,
          vertical: 14,
        ),
        hintStyle: AppTypography.body.copyWith(color: textTertiary),
        labelStyle: AppTypography.body.copyWith(color: textSecondary),
        helperStyle: AppTypography.metadata.copyWith(color: textTertiary),
        errorStyle: AppTypography.metadata.copyWith(color: danger),
        prefixIconColor: textTertiary,
        suffixIconColor: textTertiary,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppShapes.radiusStandard),
          ),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppShapes.radiusStandard),
          ),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppShapes.radiusStandard),
          ),
          borderSide: BorderSide(color: accentPrimary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppShapes.radiusStandard),
          ),
          borderSide: BorderSide(color: danger, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppShapes.radiusStandard),
          ),
          borderSide: BorderSide(color: danger, width: 1.5),
        ),
      ),
      // ─── Bottom Sheets ───
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface2,
        elevation: 0,
        modalElevation: 0,
        shape: AppShapes.bottomSheetShape,
        clipBehavior: Clip.antiAlias,
        showDragHandle: true,
        dragHandleColor: textTertiary,
        dragHandleSize: Size(36, 4),
      ),
      // ─── Icons ───
      iconTheme: const IconThemeData(color: textSecondary, size: 24),
      primaryIconTheme: const IconThemeData(color: textPrimary, size: 24),
      // ─── Buttons ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: textPrimary,
          disabledBackgroundColor: surface3,
          disabledForegroundColor: textTertiary,
          textStyle: AppTypography.label,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppShapes.radiusMini),
            ),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPrimary,
          disabledForegroundColor: textTertiary,
          textStyle: AppTypography.label,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppShapes.radiusMini),
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          disabledForegroundColor: textTertiary,
          textStyle: AppTypography.label,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: border),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppShapes.radiusMini),
            ),
          ),
        ),
      ),
      // ─── Dividers ───
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      // ─── Dialogs ───
      dialogTheme: DialogThemeData(
        backgroundColor: surface2,
        elevation: 0,
        shape: AppShapes.standardShape,
        titleTextStyle: AppTypography.sectionTitle.copyWith(color: textPrimary),
        contentTextStyle: AppTypography.body.copyWith(color: textSecondary),
      ),
      // ─── List Tiles ───
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: _withOpacity(accentPrimary, 0.10),
        iconColor: textSecondary,
        textColor: textPrimary,
        selectedColor: accentPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppShapes.screenPadding,
          vertical: 8,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppShapes.radiusStandard),
          ),
        ),
        minLeadingWidth: 24,
        minVerticalPadding: 8,
      ),
      // ─── SnackBar ───
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surface3,
        contentTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.45,
          letterSpacing: 0.1,
          color: textPrimary,
        ),
        actionTextColor: accentPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppShapes.radiusMini),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      // ─── Switches / Checks ───
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return accentPrimary;
          }
          return surface3;
        }),
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return _withOpacity(accentPrimary, 0.35);
          }
          return surface1;
        }),
        trackOutlineColor: WidgetStateProperty.all(border),
        trackOutlineWidth: WidgetStateProperty.all(1),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return accentPrimary;
          }
          if (states.contains(WidgetState.disabled)) {
            return surface1;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(textPrimary),
        side: const BorderSide(color: border, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      // ─── Floating Action Button ───
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentPrimary,
        foregroundColor: textPrimary,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppShapes.radiusMini)),
        ),
        extendedPadding: EdgeInsets.symmetric(horizontal: 20),
      ),
      // ─── Tabs ───
      tabBarTheme: const TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textTertiary,
        labelStyle: AppTypography.label,
        unselectedLabelStyle: AppTypography.metadata,
        indicatorColor: accentPrimary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: border,
      ),
      // ─── Progress Indicators ───
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentPrimary,
        linearTrackColor: surface3,
        circularTrackColor: surface3,
        refreshBackgroundColor: surface2,
      ),
      // ─── Splash / Highlight ───
      splashColor: Colors.transparent,
      highlightColor: _withOpacity(accentPrimary, 0.08),
      hoverColor: _withOpacity(accentPrimary, 0.04),
      focusColor: _withOpacity(accentPrimary, 0.08),
    );
  }
}
