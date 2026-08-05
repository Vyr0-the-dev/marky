import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/vault/data/repositories/vault_config_repository_impl.dart';
import 'package:marky/features/vault/domain/repositories/vault_config_repository.dart';
import 'package:marky/shared/models/vault_config.dart';

void main() {
  group('VaultConfigRepositoryImpl', () {
    late Directory tempDir;
    late Isar isar;
    late VaultConfigRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('vault_config_test_');

      isar = await Isar.open(
        [VaultConfigSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      repository = VaultConfigRepositoryImpl(isar: isar);
    });

    tearDown(() async {
      if (isar.isOpen) {
        await isar.close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('getConfig returns null when no config exists', () async {
      final config = await repository.getConfig();
      expect(config, isNull);
    });

    test('saveConfig creates a new row', () async {
      final config = VaultConfig(
        biometricsEnabled: true,
        autoLockDurationSeconds: 60,
      );
      await repository.saveConfig(config);

      final fetched = await repository.getConfig();
      expect(fetched, isNotNull);
      expect(fetched!.biometricsEnabled, true);
      expect(fetched.autoLockDurationSeconds, 60);
      expect(fetched.id, 0);
    });

    test('saveConfig updates existing row (upsert)', () async {
      final first = VaultConfig(
        biometricsEnabled: true,
        autoLockDurationSeconds: 60,
      );
      await repository.saveConfig(first);

      final second = VaultConfig(
        autoLockDurationSeconds: 120,
      );
      await repository.saveConfig(second);

      final fetched = await repository.getConfig();
      expect(fetched, isNotNull);
      expect(fetched!.biometricsEnabled, false);
      expect(fetched.autoLockDurationSeconds, 120);

      // Verify only one row exists.
      final all = await isar.vaultConfigs.where().findAll();
      expect(all.length, 1);
    });

    test('double insert same fixed-ID config updates, not duplicates',
        () async {
      final config1 = VaultConfig(biometricsEnabled: true);
      final config2 = VaultConfig();

      await repository.saveConfig(config1);
      await repository.saveConfig(config2);

      final all = await isar.vaultConfigs.where().findAll();
      expect(all.length, 1);
      expect(all.first.biometricsEnabled, false);
    });

    test('deleteConfig removes existing row', () async {
      final config = VaultConfig();
      await repository.saveConfig(config);

      expect(await repository.getConfig(), isNotNull);

      await repository.deleteConfig();

      expect(await repository.getConfig(), isNull);
    });

    test('deleteConfig on non-existent row is no-op', () async {
      expect(await repository.getConfig(), isNull);

      // Should not throw.
      await repository.deleteConfig();

      expect(await repository.getConfig(), isNull);
    });

    test('full CRUD cycle', () async {
      // Create
      final created = VaultConfig(
        biometricsEnabled: true,
        decoyModeEnabled: true,
        screenshotProtectionEnabled: false,
        autoLockDurationSeconds: 30,
        failedAttemptCount: 2,
      );
      await repository.saveConfig(created);

      // Read
      var fetched = await repository.getConfig();
      expect(fetched, isNotNull);
      expect(fetched!.biometricsEnabled, true);
      expect(fetched.decoyModeEnabled, true);
      expect(fetched.screenshotProtectionEnabled, false);
      expect(fetched.autoLockDurationSeconds, 30);
      expect(fetched.failedAttemptCount, 2);

      // Update
      final updated = VaultConfig(
        autoLockDurationSeconds: 600,
      );
      await repository.saveConfig(updated);

      fetched = await repository.getConfig();
      expect(fetched!.biometricsEnabled, false);
      expect(fetched.autoLockDurationSeconds, 600);
      // Unspecified fields revert to defaults on new instance
      expect(fetched.decoyModeEnabled, false);
      expect(fetched.screenshotProtectionEnabled, true);

      // Delete
      await repository.deleteConfig();
      expect(await repository.getConfig(), isNull);
    });

    test('update without prior insert creates a new row', () async {
      // No prior insert.
      expect(await repository.getConfig(), isNull);

      // Calling saveConfig should create the row.
      final config = VaultConfig();
      await repository.saveConfig(config);

      final fetched = await repository.getConfig();
      expect(fetched, isNotNull);
      expect(fetched!.biometricsEnabled, false);
      expect(fetched.autoLockDurationSeconds, 300);
    });

    test('lastUnlockAt timestamp is persisted correctly', () async {
      final now = DateTime(2026, 4, 23, 12);
      final config = VaultConfig(
        biometricsEnabled: true,
        lastUnlockAt: now,
      );
      await repository.saveConfig(config);

      final fetched = await repository.getConfig();
      expect(fetched, isNotNull);
      expect(fetched!.lastUnlockAt, isNotNull);
      expect(fetched.lastUnlockAt!.year, 2026);
      expect(fetched.lastUnlockAt!.month, 4);
      expect(fetched.lastUnlockAt!.day, 23);
      expect(fetched.lastUnlockAt!.hour, 12);
      expect(fetched.lastUnlockAt!.minute, 0);
      expect(fetched.lastUnlockAt!.second, 0);
    });
  });
}
