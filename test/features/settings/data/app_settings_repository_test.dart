import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/settings/data/repositories/app_settings_repository_impl.dart';
import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/shared/models/app_settings.dart';

void main() {
  group('AppSettingsRepositoryImpl', () {
    late Directory tempDir;
    late Isar isar;
    late AppSettingsRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('app_settings_test_');

      isar = await Isar.open(
        [AppSettingsSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      repository = AppSettingsRepositoryImpl(isar: isar);
    });

    tearDown(() async {
      if (isar.isOpen) {
        await isar.close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('getSettings returns null when no settings exist', () async {
      final settings = await repository.getSettings();
      expect(settings, isNull);
    });

    test('saveSettings creates a new row', () async {
      final settings = AppSettings(themeMode: 'dark', accentColor: 'purple');
      await repository.saveSettings(settings);

      final fetched = await repository.getSettings();
      expect(fetched, isNotNull);
      expect(fetched!.themeMode, 'dark');
      expect(fetched.accentColor, 'purple');
      expect(fetched.id, 0);
    });

    test('saveSettings updates existing row (upsert)', () async {
      final first = AppSettings(themeMode: 'dark', accentColor: 'purple');
      await repository.saveSettings(first);

      final second = AppSettings(themeMode: 'light', accentColor: 'blue');
      await repository.saveSettings(second);

      final fetched = await repository.getSettings();
      expect(fetched, isNotNull);
      expect(fetched!.themeMode, 'light');
      expect(fetched.accentColor, 'blue');

      // Verify only one row exists.
      final all = await isar.appSettings.where().findAll();
      expect(all.length, 1);
    });

    test('double insert same fixed-ID settings updates, not duplicates',
        () async {
      final settings1 = AppSettings(themeMode: 'dark');
      final settings2 = AppSettings(themeMode: 'light');

      await repository.saveSettings(settings1);
      await repository.saveSettings(settings2);

      final all = await isar.appSettings.where().findAll();
      expect(all.length, 1);
      expect(all.first.themeMode, 'light');
    });

    test('deleteSettings removes existing row', () async {
      final settings = AppSettings();
      await repository.saveSettings(settings);

      expect(await repository.getSettings(), isNotNull);

      await repository.deleteSettings();

      expect(await repository.getSettings(), isNull);
    });

    test('deleteSettings on non-existent row is no-op', () async {
      expect(await repository.getSettings(), isNull);

      // Should not throw.
      await repository.deleteSettings();

      expect(await repository.getSettings(), isNull);
    });

    test('full CRUD cycle', () async {
      // Create
      final created = AppSettings(
        themeMode: 'dark',
        accentColor: 'green',
        hapticsEnabled: false,
      );
      await repository.saveSettings(created);

      // Read
      var fetched = await repository.getSettings();
      expect(fetched, isNotNull);
      expect(fetched!.themeMode, 'dark');
      expect(fetched.accentColor, 'green');
      expect(fetched.hapticsEnabled, false);

      // Update
      final updated = AppSettings(
        themeMode: 'light',
        accentColor: 'green',
      );
      await repository.saveSettings(updated);

      fetched = await repository.getSettings();
      expect(fetched!.themeMode, 'light');
      expect(fetched.hapticsEnabled, true);

      // Delete
      await repository.deleteSettings();
      expect(await repository.getSettings(), isNull);
    });

    test('update without prior insert creates a new row', () async {
      // No prior insert.
      expect(await repository.getSettings(), isNull);

      // Calling saveSettings should create the row.
      final settings = AppSettings();
      await repository.saveSettings(settings);

      final fetched = await repository.getSettings();
      expect(fetched, isNotNull);
      expect(fetched!.themeMode, 'system');
    });
  });
}
