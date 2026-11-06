import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

import 'package:marky/app/theme/reading_room_theme.dart';

/// How the user wants Marky's palette resolved.
///
/// Distinct from Flutter's [ThemeMode] because we want a first-class
/// **OLED** variant (pure `#000000`), which is a dark-mode *sub-choice*
/// rather than a parallel to system/light/dark.
enum AppThemeMode {
  /// Follow the OS brightness. Maps to [ReadingRoomVariant.light] or
  /// [ReadingRoomVariant.dark] at runtime depending on [MediaQuery].
  system,

  /// Force Reading Room light (warm off-white).
  light,

  /// Force Reading Room dark (warm near-black).
  dark,

  /// Force Reading Room OLED (pure black). Only meaningful on AMOLED
  /// panels, but the user knows their device better than we do —
  /// always honour the request.
  oled,
}

/// User's language preference.
///
/// [system] means "defer to [WidgetsBinding.platformDispatcher.locale]"
/// and is the default for fresh installs. The two explicit values lock
/// the app regardless of OS setting — used by travellers / multi-
/// lingual households who want Marky to stay in their chosen tongue.
enum AppLocaleChoice {
  system,
  en,
  tr;

  /// Returns the concrete [Locale] to hand to `MaterialApp.locale`,
  /// or `null` for [system] (which tells Flutter to pick from
  /// `supportedLocales`).
  Locale? toLocale() {
    switch (this) {
      case AppLocaleChoice.system:
        return null;
      case AppLocaleChoice.en:
        return const Locale('en');
      case AppLocaleChoice.tr:
        return const Locale('tr');
    }
  }

  /// Parses a persisted locale tag (`"system"`, `"en"`, `"tr"`).
  /// Unknown values fall back to [system] rather than throwing — this
  /// matters when migrating between app versions that add/remove
  /// supported languages.
  static AppLocaleChoice fromString(String? value) {
    switch (value) {
      case 'en':
        return AppLocaleChoice.en;
      case 'tr':
        return AppLocaleChoice.tr;
      case 'system':
      default:
        return AppLocaleChoice.system;
    }
  }
}

enum UnreadReminderCadence {
  off,
  dailyEvening,
  weekly;

  static UnreadReminderCadence fromString(String? value) {
    switch (value) {
      case 'dailyEvening':
        return UnreadReminderCadence.dailyEvening;
      case 'weekly':
      case 'weeklyWeekend':
        return UnreadReminderCadence.weekly;
      case 'off':
      default:
        return UnreadReminderCadence.off;
    }
  }
}

/// Immutable snapshot of Marky's v2 user preferences.
///
/// Intentionally **not** a Freezed union — this is a simple record
/// with a handful of scalar fields, and Freezed would add a code-gen
/// step to Faz 1 without buying us anything. When richer domain
/// types arrive in later phases (e.g. `AutomationRule`) those will
/// use Freezed; keep the boundary explicit.
///
/// Future fields (staged per phase, not part of Faz 1):
/// - `autoBackupIntervalHours: int` (Faz 11)
/// - `googleDriveAccountEmail: String?` (Faz 11)
/// - `defaultFeedSort: FeedSort` (Faz 5)
@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.locale,
    required this.animationsEnabled,
    required this.unreadReminderCadence,
    required this.unreadReminderWeekday,
    required this.unreadReminderHour,
    required this.unreadReminderMinute,
  });

  /// Factory-reset defaults. Safe to materialise before
  /// [AppSettingsRepository.load] has completed.
  const AppSettings.defaults()
      : themeMode = AppThemeMode.system,
        locale = AppLocaleChoice.system,
        animationsEnabled = true,
        unreadReminderCadence = UnreadReminderCadence.off,
        unreadReminderWeekday = DateTime.saturday,
        unreadReminderHour = 20,
        unreadReminderMinute = 0;

  final AppThemeMode themeMode;
  final AppLocaleChoice locale;
  final bool animationsEnabled;

  final UnreadReminderCadence unreadReminderCadence;
  final int unreadReminderWeekday;
  final int unreadReminderHour;
  final int unreadReminderMinute;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppLocaleChoice? locale,
    bool? animationsEnabled,
    UnreadReminderCadence? unreadReminderCadence,
    int? unreadReminderWeekday,
    int? unreadReminderHour,
    int? unreadReminderMinute,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      unreadReminderCadence:
          unreadReminderCadence ?? this.unreadReminderCadence,
      unreadReminderWeekday:
          unreadReminderWeekday ?? this.unreadReminderWeekday,
      unreadReminderHour: unreadReminderHour ?? this.unreadReminderHour,
      unreadReminderMinute: unreadReminderMinute ?? this.unreadReminderMinute,
    );
  }

  /// Maps to a Flutter [ThemeMode] for `MaterialApp.themeMode`. OLED
  /// is treated as dark (the variant distinction is resolved at the
  /// theme-builder layer).
  ThemeMode toFlutterThemeMode() {
    switch (themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.oled:
        return ThemeMode.dark;
    }
  }

  /// Resolves the [ReadingRoomVariant] to use given the current OS
  /// brightness. Call this from the top-level app widget where
  /// `MediaQuery.platformBrightnessOf` is available.
  ReadingRoomVariant resolveVariant(Brightness platformBrightness) {
    switch (themeMode) {
      case AppThemeMode.light:
        return ReadingRoomVariant.light;
      case AppThemeMode.dark:
        return ReadingRoomVariant.dark;
      case AppThemeMode.oled:
        return ReadingRoomVariant.oled;
      case AppThemeMode.system:
        return platformBrightness == Brightness.dark
            ? ReadingRoomVariant.dark
            : ReadingRoomVariant.light;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.locale == locale &&
        other.animationsEnabled == animationsEnabled &&
        other.unreadReminderCadence == unreadReminderCadence &&
        other.unreadReminderWeekday == unreadReminderWeekday &&
        other.unreadReminderHour == unreadReminderHour &&
        other.unreadReminderMinute == unreadReminderMinute;
  }

  @override
  int get hashCode => Object.hash(
        themeMode,
        locale,
        animationsEnabled,
        unreadReminderCadence,
        unreadReminderWeekday,
        unreadReminderHour,
        unreadReminderMinute,
      );

  @override
  String toString() => 'AppSettings(theme: $themeMode, locale: $locale, '
      'animations: $animationsEnabled, '
      'unreadReminderCadence: $unreadReminderCadence, '
      'unreadReminderWeekday: $unreadReminderWeekday, '
      'unreadReminderTime: ${unreadReminderHour.toString().padLeft(2, '0')}:${unreadReminderMinute.toString().padLeft(2, '0')})';
}
