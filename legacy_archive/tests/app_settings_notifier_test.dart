import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/shared/models/app_settings.dart';

import 'fakes/fake_app_settings_repository.dart';

void main() {
  group('AppSettingsNotifier', () {
    late FakeAppSettingsRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeAppSettingsRepository();
    });

    test('defaults to dark mode when no saved settings exist', () async {
      final notifier = AppSettingsNotifier(repository: fakeRepo);

      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.themeMode, 'dark');
      expect(fakeRepo.saved, isNull);
    });

    test('loads saved settings on init', () async {
      await fakeRepo.saveSettings(
        AppSettings(themeMode: 'light', accentColor: 'purple'),
      );

      final notifier = AppSettingsNotifier(repository: fakeRepo);

      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.themeMode, 'light');
      expect(notifier.state.accentColor, 'purple');
    });

    test('setThemeMode updates state and triggers a save', () async {
      final notifier = AppSettingsNotifier(repository: fakeRepo);

      await Future<void>.delayed(Duration.zero);

      notifier.setThemeMode(ThemeMode.light);

      expect(notifier.state.themeMode, 'light');
      expect(fakeRepo.saveCount, greaterThanOrEqualTo(1));
      expect(fakeRepo.saved?.themeMode, 'light');
    });

    test('toggleThemeMode cycles dark -> light -> system -> dark and saves each change',
        () async {
      final notifier = AppSettingsNotifier(repository: fakeRepo);

      await Future<void>.delayed(Duration.zero);

      // Start dark
      expect(notifier.state.themeMode, 'dark');

      // Toggle to light
      notifier.toggleThemeMode();
      expect(notifier.state.themeMode, 'light');
      await Future<void>.delayed(Duration.zero);
      expect(fakeRepo.saved?.themeMode, 'light');

      // Toggle to system
      notifier.toggleThemeMode();
      expect(notifier.state.themeMode, 'system');
      await Future<void>.delayed(Duration.zero);
      expect(fakeRepo.saved?.themeMode, 'system');

      // Toggle back to dark
      notifier.toggleThemeMode();
      expect(notifier.state.themeMode, 'dark');
      await Future<void>.delayed(Duration.zero);
      expect(fakeRepo.saved?.themeMode, 'dark');

      expect(fakeRepo.saveCount, greaterThanOrEqualTo(3));
    });

    test('saves oled pure black toggle', () async {
      final notifier = AppSettingsNotifier(repository: fakeRepo);

      await Future<void>.delayed(Duration.zero);

      notifier.setOledPureBlackEnabled(true);

      expect(notifier.state.oledPureBlackEnabled, true);
      expect(fakeRepo.saved?.oledPureBlackEnabled, true);
      expect(fakeRepo.saveCount, greaterThanOrEqualTo(1));
    });

    test('saves haptics toggle', () async {
      final notifier = AppSettingsNotifier(repository: fakeRepo);

      await Future<void>.delayed(Duration.zero);

      notifier.setHapticsEnabled(false);

      expect(notifier.state.hapticsEnabled, false);
      expect(fakeRepo.saved?.hapticsEnabled, false);
      expect(fakeRepo.saveCount, greaterThanOrEqualTo(1));
    });

    test('saves animations toggle', () async {
      final notifier = AppSettingsNotifier(repository: fakeRepo);

      await Future<void>.delayed(Duration.zero);

      notifier.setAnimationsEnabled(false);

      expect(notifier.state.animationsEnabled, false);
      expect(fakeRepo.saved?.animationsEnabled, false);
      expect(fakeRepo.saveCount, greaterThanOrEqualTo(1));
    });

    test('saves clipboard detection toggle', () async {
      final notifier = AppSettingsNotifier(repository: fakeRepo);

      await Future<void>.delayed(Duration.zero);

      notifier.setClipboardDetectionEnabled(false);

      expect(notifier.state.clipboardDetectionEnabled, false);
      expect(fakeRepo.saved?.clipboardDetectionEnabled, false);
      expect(fakeRepo.saveCount, greaterThanOrEqualTo(1));
    });

    test('themeModeToString converts enum values correctly', () {
      expect(AppSettingsNotifier.themeModeToString(ThemeMode.dark), 'dark');
      expect(AppSettingsNotifier.themeModeToString(ThemeMode.light), 'light');
      expect(AppSettingsNotifier.themeModeToString(ThemeMode.system), 'system');
    });

    test('themeModeFromString parses string values correctly', () {
      expect(AppSettingsNotifier.themeModeFromString('dark'), ThemeMode.dark);
      expect(AppSettingsNotifier.themeModeFromString('light'), ThemeMode.light);
      expect(
        AppSettingsNotifier.themeModeFromString('system'),
        ThemeMode.system,
      );
    });

    test('themeModeFromString falls back to system for unknown values', () {
      expect(
        AppSettingsNotifier.themeModeFromString('unknown'),
        ThemeMode.system,
      );
    });

    test('throws StateError when accessed before init', () {
      final notifier = AppSettingsNotifier(repository: fakeRepo);

      // Do NOT await the init delay — call mutator immediately.
      expect(
        () => notifier.setThemeMode(ThemeMode.light),
        throwsA(isA<StateError>()),
      );
    });
  });
}
