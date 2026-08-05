import 'package:isar/isar.dart';

part 'vault_config.g.dart';

/// Single-row vault configuration stored in Isar.
///
/// Always use [id] = 0 so only one config row ever exists.
/// Query with `isar.vaultConfigs.get(0)` or use a singleton repository pattern.
@collection
class VaultConfig {
  VaultConfig({
    this.biometricsEnabled = false,
    this.decoyModeEnabled = false,
    this.screenshotProtectionEnabled = true,
    this.autoLockDurationSeconds = 300,
    this.failedAttemptCount = 0,
    this.lastUnlockAt,
  });

  /// Fixed id for the single config row.
  Id id = 0;

  /// Whether biometric authentication is required to access the vault.
  bool biometricsEnabled;

  /// Whether decoy mode (fake vault) is enabled for plausible deniability.
  bool decoyModeEnabled;

  /// Whether screenshot and screen recording protection is active.
  bool screenshotProtectionEnabled;

  /// Auto-lock timeout in seconds when the vault is inactive.
  /// Default is 5 minutes (300 seconds).
  int autoLockDurationSeconds;

  /// Number of consecutive failed biometric unlock attempts.
  int failedAttemptCount;

  /// Timestamp of the last successful vault unlock.
  DateTime? lastUnlockAt;

  /// Creates a copy of this [VaultConfig] with the given fields replaced.
  VaultConfig copyWith({
    bool? biometricsEnabled,
    bool? decoyModeEnabled,
    bool? screenshotProtectionEnabled,
    int? autoLockDurationSeconds,
    int? failedAttemptCount,
    DateTime? lastUnlockAt,
  }) {
    final VaultConfig copy = VaultConfig(
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      decoyModeEnabled: decoyModeEnabled ?? this.decoyModeEnabled,
      screenshotProtectionEnabled:
          screenshotProtectionEnabled ?? this.screenshotProtectionEnabled,
      autoLockDurationSeconds:
          autoLockDurationSeconds ?? this.autoLockDurationSeconds,
      failedAttemptCount: failedAttemptCount ?? this.failedAttemptCount,
      lastUnlockAt: lastUnlockAt ?? this.lastUnlockAt,
    );
    copy.id = id;
    return copy;
  }
}
