import 'package:isar/isar.dart';

import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/shared/models/app_settings.dart';

/// Isar-backed implementation of [AppSettingsRepository].
///
/// Expects [isar] to be an open database instance that includes
/// [AppSettingsSchema].
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl({required Isar isar}) : _isar = isar;

  final Isar _isar;

  static const Id _settingsId = 0;

  @override
  Future<AppSettings?> getSettings() async {
    return _isar.appSettings.get(_settingsId);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    settings.id = _settingsId;
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings);
    });
  }

  @override
  Future<void> deleteSettings() async {
    await _isar.writeTxn(() async {
      await _isar.appSettings.delete(_settingsId);
    });
  }
}
