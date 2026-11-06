import 'package:marky/app/settings/app_settings.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for [AppSettings].
///
/// Abstracting this is cheap insurance: the SharedPreferences backend
/// is fine for Faz 1 (4 scalar fields, no migrations) but once the
/// settings grow to include auto-backup credentials and automation
/// rule defaults, we may want Isar or a versioned JSON blob. Feature
/// code depends only on the interface, so the swap stays local.
abstract interface class AppSettingsRepository {
  /// Loads settings synchronously from the in-memory cache after the
  /// repository has been initialised. Returns defaults on cold start
  /// before [load] has been awaited.
  AppSettings get current;

  /// Reads from the backing store and refreshes [current]. Idempotent.
  Future<AppSettings> load();

  /// Persists [settings] and updates [current]. Overwrites any in-
  /// flight save (last-writer-wins) — settings UI debounces rapid
  /// toggles at the notifier layer, so we don't also queue here.
  Future<void> save(AppSettings settings);
}

/// Default implementation backed by [SharedPreferences].
///
/// SharedPreferences is platform-native (NSUserDefaults / Android
/// SharedPreferences / Windows Registry-ish) and survives app updates
/// without migration. We store each field under a stable key so a
/// corrupted blob can never take out *all* settings at once.
class SharedPreferencesAppSettingsRepository implements AppSettingsRepository {
  SharedPreferencesAppSettingsRepository(this._prefs);

  @visibleForTesting
  static const String keyThemeMode = 'v2.settings.themeMode';
  @visibleForTesting
  static const String keyLocale = 'v2.settings.locale';
  @visibleForTesting
  static const String keyAnimations = 'v2.settings.animationsEnabled';
  @visibleForTesting
  static const String keyUnreadReminderCadence =
      'v2.settings.unreadReminderCadence';
  @visibleForTesting
  static const String keyUnreadReminderWeekday =
      'v2.settings.unreadReminderWeekday';
  @visibleForTesting
  static const String keyUnreadReminderHour = 'v2.settings.unreadReminderHour';
  @visibleForTesting
  static const String keyUnreadReminderMinute =
      'v2.settings.unreadReminderMinute';

  final SharedPreferences _prefs;
  AppSettings _current = const AppSettings.defaults();

  @override
  AppSettings get current => _current;

  @override
  Future<AppSettings> load() async {
    _current = AppSettings(
      themeMode: _parseThemeMode(_prefs.getString(keyThemeMode)),
      locale: AppLocaleChoice.fromString(_prefs.getString(keyLocale)),
      animationsEnabled: _prefs.getBool(keyAnimations) ?? true,
      unreadReminderCadence: UnreadReminderCadence.fromString(
        _prefs.getString(keyUnreadReminderCadence),
      ),
      unreadReminderWeekday: _normalizeWeekday(
        _prefs.getInt(keyUnreadReminderWeekday),
      ),
      unreadReminderHour: _prefs.getInt(keyUnreadReminderHour) ?? 20,
      unreadReminderMinute: _prefs.getInt(keyUnreadReminderMinute) ?? 0,
    );
    return _current;
  }

  @override
  Future<void> save(AppSettings settings) async {
    _current = settings;
    // Write each key in parallel — SharedPreferences serialises the
    // underlying file write, so the `await Future.wait` is cosmetic,
    // but it makes the "all or nothing" intent explicit.
    await Future.wait<bool>(<Future<bool>>[
      _prefs.setString(keyThemeMode, settings.themeMode.name),
      _prefs.setString(keyLocale, settings.locale.name),
      _prefs.setBool(keyAnimations, settings.animationsEnabled),
      _prefs.setString(
        keyUnreadReminderCadence,
        settings.unreadReminderCadence.name,
      ),
      _prefs.setInt(
        keyUnreadReminderWeekday,
        settings.unreadReminderWeekday,
      ),
      _prefs.setInt(keyUnreadReminderHour, settings.unreadReminderHour),
      _prefs.setInt(keyUnreadReminderMinute, settings.unreadReminderMinute),
    ]);
  }

  static AppThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'oled':
        return AppThemeMode.oled;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  static int _normalizeWeekday(int? value) {
    if (value == null || value < DateTime.monday || value > DateTime.sunday) {
      return DateTime.saturday;
    }
    return value;
  }
}

/// In-memory implementation — used by tests + widget previews where a
/// real [SharedPreferences] instance isn't worth the setup cost.
class InMemoryAppSettingsRepository implements AppSettingsRepository {
  InMemoryAppSettingsRepository({AppSettings? initial})
      : _current = initial ?? const AppSettings.defaults();

  AppSettings _current;

  @override
  AppSettings get current => _current;

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings settings) async {
    _current = settings;
  }
}
