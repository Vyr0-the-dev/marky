import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_repository.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppSettings.defaults', () {
    test('has system theme, system locale, and reminder defaults', () {
      const AppSettings settings = AppSettings.defaults();
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.locale, AppLocaleChoice.system);
      expect(settings.unreadReminderCadence, UnreadReminderCadence.off);
      expect(settings.unreadReminderWeekday, DateTime.saturday);
      expect(settings.unreadReminderHour, 20);
      expect(settings.unreadReminderMinute, 0);
      expect(settings.leftSwipeAction, SwipeAction.toggleArchive);
      expect(settings.rightSwipeAction, SwipeAction.toggleRead);
    });
  });

  group('AppSettings.resolveVariant', () {
    test('system mode follows platform brightness', () {
      const AppSettings settings = AppSettings.defaults();
      expect(
        settings.resolveVariant(Brightness.light),
        ReadingRoomVariant.light,
      );
      expect(
        settings.resolveVariant(Brightness.dark),
        ReadingRoomVariant.dark,
      );
    });

    test('explicit OLED ignores platform brightness', () {
      final AppSettings settings =
          const AppSettings.defaults().copyWith(themeMode: AppThemeMode.oled);
      expect(
        settings.resolveVariant(Brightness.light),
        ReadingRoomVariant.oled,
      );
      expect(
        settings.resolveVariant(Brightness.dark),
        ReadingRoomVariant.oled,
      );
    });
  });

  group('AppSettings.toFlutterThemeMode', () {
    test('OLED maps to dark (variant resolved separately)', () {
      final AppSettings settings =
          const AppSettings.defaults().copyWith(themeMode: AppThemeMode.oled);
      expect(settings.toFlutterThemeMode(), ThemeMode.dark);
    });
  });

  group('AppLocaleChoice', () {
    test('toLocale returns null for system', () {
      expect(AppLocaleChoice.system.toLocale(), isNull);
    });
    test('toLocale returns concrete Locale for en/tr', () {
      expect(AppLocaleChoice.en.toLocale(), const Locale('en'));
      expect(AppLocaleChoice.tr.toLocale(), const Locale('tr'));
    });
    test('fromString tolerates unknown values', () {
      expect(AppLocaleChoice.fromString(null), AppLocaleChoice.system);
      expect(AppLocaleChoice.fromString('ja'), AppLocaleChoice.system);
      expect(AppLocaleChoice.fromString('en'), AppLocaleChoice.en);
      expect(AppLocaleChoice.fromString('tr'), AppLocaleChoice.tr);
    });
  });

  group('UnreadReminderCadence', () {
    test('fromString tolerates unknown values', () {
      expect(UnreadReminderCadence.fromString(null), UnreadReminderCadence.off);
      expect(
        UnreadReminderCadence.fromString('dailyEvening'),
        UnreadReminderCadence.dailyEvening,
      );
      expect(
        UnreadReminderCadence.fromString('weeklyWeekend'),
        UnreadReminderCadence.weekly,
      );
      expect(
          UnreadReminderCadence.fromString('never'), UnreadReminderCadence.off);
    });
  });

  group('SwipeAction', () {
    test('fromString parses valid actions', () {
      expect(SwipeAction.fromString('toggleRead'), SwipeAction.toggleRead);
      expect(
        SwipeAction.fromString('toggleArchive'),
        SwipeAction.toggleArchive,
      );
      expect(
        SwipeAction.fromString('toggleFavorite'),
        SwipeAction.toggleFavorite,
      );
      expect(SwipeAction.fromString('delete'), SwipeAction.delete);
      expect(SwipeAction.fromString('none'), SwipeAction.none);
    });

    test('fromString falls back on unknown or null values', () {
      expect(SwipeAction.fromString(null), SwipeAction.none);
      expect(SwipeAction.fromString('invalid_action'), SwipeAction.none);
      expect(
        SwipeAction.fromString(
          'unknown',
          fallback: SwipeAction.toggleArchive,
        ),
        SwipeAction.toggleArchive,
      );
    });
  });

  group('AppSettings equality', () {
    test('two defaults are equal and hash to the same value', () {
      const AppSettings a = AppSettings.defaults();
      const AppSettings b = AppSettings.defaults();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith changes equality', () {
      const AppSettings a = AppSettings.defaults();
      final AppSettings b = a.copyWith(unreadReminderWeekday: DateTime.sunday);
      expect(a, isNot(equals(b)));
    });
  });

  group('SharedPreferencesAppSettingsRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('returns defaults on fresh install', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SharedPreferencesAppSettingsRepository repo =
          SharedPreferencesAppSettingsRepository(prefs);
      final AppSettings loaded = await repo.load();
      expect(loaded, const AppSettings.defaults());
    });

    test('round-trips all fields through save → load', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SharedPreferencesAppSettingsRepository repo =
          SharedPreferencesAppSettingsRepository(prefs);

      final AppSettings written = const AppSettings.defaults().copyWith(
        themeMode: AppThemeMode.oled,
        locale: AppLocaleChoice.tr,
        unreadReminderCadence: UnreadReminderCadence.dailyEvening,
        unreadReminderWeekday: DateTime.friday,
        unreadReminderHour: 22,
        unreadReminderMinute: 30,
        leftSwipeAction: SwipeAction.delete,
        rightSwipeAction: SwipeAction.toggleFavorite,
      );
      await repo.save(written);

      // Fresh repo reading the same SharedPreferences instance should
      // observe everything we saved.
      final SharedPreferencesAppSettingsRepository fresh =
          SharedPreferencesAppSettingsRepository(prefs);
      final AppSettings loaded = await fresh.load();
      expect(loaded, written);
    });

    test('corrupted theme value falls back to system', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPreferencesAppSettingsRepository.keyThemeMode: 'neon-cyber',
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SharedPreferencesAppSettingsRepository repo =
          SharedPreferencesAppSettingsRepository(prefs);
      final AppSettings loaded = await repo.load();
      expect(loaded.themeMode, AppThemeMode.system);
    });
  });
}
