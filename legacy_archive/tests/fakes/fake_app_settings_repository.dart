import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_repository.dart';

/// Pure-Dart fake repository that records every [saveSettings] call.
class FakeAppSettingsRepository implements AppSettingsRepository {
  AppSettings _current = const AppSettings.defaults();
  AppSettings? _saved;
  int saveCount = 0;

  AppSettings? get saved => _saved;

  @override
  AppSettings get current => _current;

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings settings) async {
    _current = settings;
    _saved = settings;
    saveCount++;
  }

  Future<AppSettings?> getSettings() async => _saved;

  Future<void> saveSettings(AppSettings settings) => save(settings);

  Future<void> deleteSettings() async {
    _current = const AppSettings.defaults();
    _saved = null;
  }
}
