import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/shared/models/app_settings.dart';

/// Pure-Dart fake repository that records every [saveSettings] call.
class FakeAppSettingsRepository implements AppSettingsRepository {
  AppSettings? _saved;
  int saveCount = 0;

  AppSettings? get saved => _saved;

  @override
  Future<AppSettings?> getSettings() async => _saved;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _saved = settings;
    saveCount++;
  }

  @override
  Future<void> deleteSettings() async {
    _saved = null;
  }
}
