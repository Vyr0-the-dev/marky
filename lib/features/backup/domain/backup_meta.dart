import 'package:flutter/foundation.dart';

/// Immutable view of the singleton backup-state row.
///
/// Backed by [BackupMetaEntity] with a forced `id = 0`. The
/// repository handles the singleton ergonomics so feature code can
/// just call `repo.get()` and `repo.save(meta)` without thinking
/// about the row count.
@immutable
class BackupMeta {
  const BackupMeta({
    this.autoBackupEnabled = false,
    this.backupIntervalHours = 24,
    this.lastBackupAt,
    this.lastBackupSuccess,
    this.lastBackupError,
    this.lastBackupBytes,
    this.googleDriveAccountEmail,
    this.googleDriveFolderId,
    this.lastBackupFileId,
    this.consecutiveFailureCount = 0,
  });

  /// Sane defaults for a fresh install. Backup is OFF by default —
  /// we never run a backup until the user signs in.
  const BackupMeta.defaults() : this();

  final bool autoBackupEnabled;
  final int backupIntervalHours;
  final DateTime? lastBackupAt;
  final bool? lastBackupSuccess;
  final String? lastBackupError;
  final int? lastBackupBytes;
  final String? googleDriveAccountEmail;
  final String? googleDriveFolderId;
  final String? lastBackupFileId;
  final int consecutiveFailureCount;

  /// True when a Google account is currently linked.
  bool get isSignedIn => googleDriveAccountEmail != null;

  /// True when the backup subsystem is in a healthy state — signed
  /// in, enabled, and the most recent attempt succeeded (or there
  /// hasn't been an attempt yet).
  bool get isHealthy =>
      isSignedIn &&
      autoBackupEnabled &&
      (lastBackupSuccess ?? true) &&
      consecutiveFailureCount == 0;

  BackupMeta copyWith({
    bool? autoBackupEnabled,
    int? backupIntervalHours,
    DateTime? lastBackupAt,
    bool? lastBackupSuccess,
    String? lastBackupError,
    int? lastBackupBytes,
    String? googleDriveAccountEmail,
    String? googleDriveFolderId,
    String? lastBackupFileId,
    int? consecutiveFailureCount,
  }) {
    return BackupMeta(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupIntervalHours: backupIntervalHours ?? this.backupIntervalHours,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      lastBackupSuccess: lastBackupSuccess ?? this.lastBackupSuccess,
      lastBackupError: lastBackupError ?? this.lastBackupError,
      lastBackupBytes: lastBackupBytes ?? this.lastBackupBytes,
      googleDriveAccountEmail:
          googleDriveAccountEmail ?? this.googleDriveAccountEmail,
      googleDriveFolderId: googleDriveFolderId ?? this.googleDriveFolderId,
      lastBackupFileId: lastBackupFileId ?? this.lastBackupFileId,
      consecutiveFailureCount:
          consecutiveFailureCount ?? this.consecutiveFailureCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackupMeta &&
        other.autoBackupEnabled == autoBackupEnabled &&
        other.backupIntervalHours == backupIntervalHours &&
        other.lastBackupAt == lastBackupAt &&
        other.lastBackupSuccess == lastBackupSuccess &&
        other.lastBackupError == lastBackupError &&
        other.lastBackupBytes == lastBackupBytes &&
        other.googleDriveAccountEmail == googleDriveAccountEmail &&
        other.googleDriveFolderId == googleDriveFolderId &&
        other.lastBackupFileId == lastBackupFileId &&
        other.consecutiveFailureCount == consecutiveFailureCount;
  }

  @override
  int get hashCode => Object.hash(
        autoBackupEnabled,
        backupIntervalHours,
        lastBackupAt,
        lastBackupSuccess,
        lastBackupError,
        lastBackupBytes,
        googleDriveAccountEmail,
        googleDriveFolderId,
        lastBackupFileId,
        consecutiveFailureCount,
      );

  @override
  String toString() =>
      'BackupMeta(enabled: $autoBackupEnabled, interval: ${backupIntervalHours}h, '
      'lastAt: $lastBackupAt, success: $lastBackupSuccess, '
      'failStreak: $consecutiveFailureCount)';
}
