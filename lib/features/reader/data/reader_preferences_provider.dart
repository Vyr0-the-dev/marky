import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReaderThemeMode {
  light(
    background: Color(0xFFFDFBF7),
    surface: Color(0xFFF5F0E6),
    text: Color(0xFF1E1E1E),
    subtext: Color(0xFF6E6E6C),
    accent: Color(0xFF8C5E35),
    border: Color(0xFFE8E2D5),
  ),
  sepia(
    background: Color(0xFFF4ECD8),
    surface: Color(0xFFEADFCA),
    text: Color(0xFF382C1E),
    subtext: Color(0xFF7A6A55),
    accent: Color(0xFF7A4A25),
    border: Color(0xFFDDD2BC),
  ),
  dark(
    background: Color(0xFF141413),
    surface: Color(0xFF20201E),
    text: Color(0xFFE6E5E3),
    subtext: Color(0xFF9E9D9A),
    accent: Color(0xFFD4A373),
    border: Color(0xFF2C2C28),
  );

  const ReaderThemeMode({
    required this.background,
    required this.surface,
    required this.text,
    required this.subtext,
    required this.accent,
    required this.border,
  });

  final Color background;
  final Color surface;
  final Color text;
  final Color subtext;
  final Color accent;
  final Color border;
}

enum ReaderFontFamily {
  serif,
  sans,
}

@immutable
class ReaderPreferences {
  const ReaderPreferences({
    this.themeMode,
    this.fontFamily = ReaderFontFamily.serif,
    this.fontSize = 17,
    this.lineHeight = 1.68,
  });

  /// Null means follow the active app theme brightness on first open.
  final ReaderThemeMode? themeMode;
  final ReaderFontFamily fontFamily;
  final double fontSize;
  final double lineHeight;

  ReaderPreferences copyWith({
    ReaderThemeMode? themeMode,
    ReaderFontFamily? fontFamily,
    double? fontSize,
    double? lineHeight,
  }) {
    return ReaderPreferences(
      themeMode: themeMode ?? this.themeMode,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}

class ReaderPreferencesNotifier extends StateNotifier<ReaderPreferences> {
  ReaderPreferencesNotifier() : super(const ReaderPreferences()) {
    unawaited(_load());
  }

  static const String _keyTheme = 'marky_reader_theme';
  static const String _keyFont = 'marky_reader_font';
  static const String _keySize = 'marky_reader_font_size';
  static const String _keyLineHeight = 'marky_reader_line_height';

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedTheme = prefs.getString(_keyTheme);
      final String? savedFont = prefs.getString(_keyFont);
      final double? savedSize = prefs.getDouble(_keySize);
      final double? savedLineHeight = prefs.getDouble(_keyLineHeight);

      ReaderThemeMode? themeMode;
      if (savedTheme != null) {
        for (final ReaderThemeMode mode in ReaderThemeMode.values) {
          if (mode.name == savedTheme) {
            themeMode = mode;
            break;
          }
        }
      }

      ReaderFontFamily fontFamily = state.fontFamily;
      if (savedFont != null) {
        for (final ReaderFontFamily f in ReaderFontFamily.values) {
          if (f.name == savedFont) {
            fontFamily = f;
            break;
          }
        }
      }

      state = ReaderPreferences(
        themeMode: themeMode,
        fontFamily: fontFamily,
        fontSize: (savedSize ?? state.fontSize).clamp(14.0, 26.0),
        lineHeight: (savedLineHeight ?? state.lineHeight).clamp(1.4, 2.0),
      );
    } on Object {
      // Ignore in widget tests without SharedPreferences channel.
    }
  }

  Future<void> setThemeMode(ReaderThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist((SharedPreferences p) => p.setString(_keyTheme, mode.name));
  }

  Future<void> setFontFamily(ReaderFontFamily font) async {
    state = state.copyWith(fontFamily: font);
    await _persist((SharedPreferences p) => p.setString(_keyFont, font.name));
  }

  Future<void> setFontSize(double size) async {
    final double clamped = size.clamp(14.0, 26.0);
    state = state.copyWith(fontSize: clamped);
    await _persist((SharedPreferences p) => p.setDouble(_keySize, clamped));
  }

  Future<void> setLineHeight(double height) async {
    final double clamped = height.clamp(1.4, 2.0);
    state = state.copyWith(lineHeight: clamped);
    await _persist(
      (SharedPreferences p) => p.setDouble(_keyLineHeight, clamped),
    );
  }

  static Future<void> _persist(
    Future<bool> Function(SharedPreferences prefs) write,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await write(prefs);
    } on Object {
      // Best-effort persistence.
    }
  }
}

final StateNotifierProvider<ReaderPreferencesNotifier, ReaderPreferences>
    readerPreferencesProvider =
    StateNotifierProvider<ReaderPreferencesNotifier, ReaderPreferences>(
  (Ref ref) => ReaderPreferencesNotifier(),
);
