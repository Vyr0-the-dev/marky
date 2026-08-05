import 'package:marky/shared/models/vault_config.dart';

/// Contract for persisting and retrieving the single-row [VaultConfig].
///
/// Implementations guarantee that at most one config row exists
/// (id == 0) at any time.
abstract class VaultConfigRepository {
  /// Returns the current vault config, or `null` if none have been saved yet.
  Future<VaultConfig?> getConfig();

  /// Persists [config].
  ///
  /// Insert semantics: if no row exists, one is created.
  /// Update semantics: if a row exists, it is overwritten.
  Future<void> saveConfig(VaultConfig config);

  /// Removes the config row if it exists.
  ///
  /// No-op when no row is present.
  Future<void> deleteConfig();
}
