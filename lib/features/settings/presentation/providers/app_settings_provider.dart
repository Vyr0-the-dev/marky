import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import 'package:marky/core/database/isar_service.dart';
import 'package:marky/features/settings/data/repositories/app_settings_repository_impl.dart';
import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/shared/models/app_settings.dart';

/// Notifier that manages the application's [AppSettings] at runtime.
///
/// Defaults to a dark-mode [AppSettings] row, then asynchronously loads
/// any previously persisted settings from Isar via [AppSettingsRepository].
///
/// All mutation helpers are synchronous for the UI (state updates
/// immediately) and fire-and-forget the Isar write so the widget tree
/// is never blocked.
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  /// Creates the notifier, defaulting to dark mode and kicking off an
  /// async load of saved settings.
  AppSettingsNotifier({required AppSettingsRepository repository})
      : _repository = repository,
        super(AppSettings(themeMode: 'dark')) {
    unawaited(_load());
  }

  final AppSettingsRepository _repository;
  final Logger _logger = Logger();
  bool _initialized = false;

  /// Loads persisted settings, if any, and replaces the default state.
  Future<void> _load() async {
    try {
      final AppSettings? saved = await _repository.getSettings();
      if (saved != null) {
        state = saved;
        _logger.i('Loaded saved app settings from Isar');
      } else {
        _logger.w('No saved app settings found, using defaults');
      }
    } on Object catch (e, stackTrace) {
      _logger.e(
        'Failed to load app settings',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _initialized = true;
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'AppSettingsNotifier accessed before initialization completed. '
        'Wait for _load() to finish or avoid calling mutators in build().',
      );
    }
  }

  /// Explicitly sets the theme mode.
  void setThemeMode(ThemeMode mode) {
    _ensureInitialized();
    state = state.copyWith(themeMode: _themeModeToString(mode));
    unawaited(_persist());
  }

  /// Cycles through available modes: dark → light → system → dark.
  void toggleThemeMode() {
    _ensureInitialized();
    final ThemeMode current = _themeModeFromString(state.themeMode);
    final ThemeMode next = switch (current) {
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
      ThemeMode.system => ThemeMode.dark,
    };
    state = state.copyWith(themeMode: _themeModeToString(next));
    unawaited(_persist());
  }

  /// Toggles pure-black OLED backgrounds.
  // ignore: avoid_positional_boolean_parameters
  void setOledPureBlackEnabled(bool value) {
    _ensureInitialized();
    state = state.copyWith(oledPureBlackEnabled: value);
    unawaited(_persist());
  }

  /// Toggles haptic feedback.
  // ignore: avoid_positional_boolean_parameters
  void setHapticsEnabled(bool value) {
    _ensureInitialized();
    state = state.copyWith(hapticsEnabled: value);
    unawaited(_persist());
  }

  /// Toggles animations.
  // ignore: avoid_positional_boolean_parameters
  void setAnimationsEnabled(bool value) {
    _ensureInitialized();
    state = state.copyWith(animationsEnabled: value);
    unawaited(_persist());
  }

  /// Toggles clipboard URL detection.
  // ignore: avoid_positional_boolean_parameters
  void setClipboardDetectionEnabled(bool value) {
    _ensureInitialized();
    state = state.copyWith(clipboardDetectionEnabled: value);
    unawaited(_persist());
  }

  /// Converts a [ThemeMode] enum value to its persisted string form.
  static String themeModeToString(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'system',
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
      };

  /// Parses a persisted theme-mode string back to [ThemeMode].
  static ThemeMode themeModeFromString(String value) => switch (value) {
        'system' => ThemeMode.system,
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  String _themeModeToString(ThemeMode mode) => themeModeToString(mode);

  ThemeMode _themeModeFromString(String value) => themeModeFromString(value);

  Future<void> _persist() async {
    try {
      await _repository.saveSettings(state);
    } on Object catch (e, stackTrace) {
      _logger.e(
        'Failed to persist app settings',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Provider that exposes the live [Isar] instance as an
/// [AppSettingsRepository].
///
/// Throws [StateError] if the database has not been opened yet.
final Provider<AppSettingsRepository> appSettingsRepositoryProvider =
    Provider<AppSettingsRepository>((Ref ref) {
  final Isar? isar = IsarService.instance.isar;
  if (isar == null) {
    throw StateError(
      'Isar database not initialized. '
      'Ensure IsarService.instance.open() is called during app bootstrap.',
    );
  }
  return AppSettingsRepositoryImpl(isar: isar);
});
