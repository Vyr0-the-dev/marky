import 'package:marky/shared/models/app_settings.dart';

/// Contract for persisting and retrieving the single-row [AppSettings].
///
/// Implementations guarantee that at most one settings row exists
/// (id == 0) at any time.
abstract class AppSettingsRepository {
  /// Returns the current settings, or `null` if none have been saved yet.
  Future<AppSettings?> getSettings();

  /// Persists [settings].
  ///
  /// Insert semantics: if no row exists, one is created.
  /// Update semantics: if a row exists, it is overwritten.
  Future<void> saveSettings(AppSettings settings);

  /// Removes the settings row if it exists.
  ///
  /// No-op when no row is present.
  Future<void> deleteSettings();
}
