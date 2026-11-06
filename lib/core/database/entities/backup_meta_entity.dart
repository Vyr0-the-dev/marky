import 'package:isar/isar.dart';

part 'backup_meta_entity.g.dart';

/// Singleton row holding the state of the auto-backup subsystem
/// (Faz 11). Kept in Isar (not SharedPreferences) for two reasons:
///
/// 1. The backup worker writes to this from a background isolate;
///    Isar handles cross-isolate transactions natively, while
///    SharedPreferences requires extra plumbing.
/// 2. The "what to back up?" query is "everything in Isar" — keeping
///    the meta in the same store means a backup is a single
///    consistent snapshot.
///
/// Always use `id = 0` so the row is unique. The repository wraps
/// access so callers don't have to remember.
@Collection(accessor: 'backupMeta')
class BackupMetaEntity {
  BackupMetaEntity({
    this.id = 0,
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

  /// Force-singleton — always 0. The repository asserts this on save.
  Id id;

  /// User toggle — when false the worker noop's. Defaults to false on
  /// fresh install: we never run a backup until the user explicitly
  /// signs in to Google Drive.
  bool autoBackupEnabled;

  /// User-configurable cadence. Default 24h matches the brief; the
  /// settings UI clamps to a sensible range (e.g. 6h…7d).
  int backupIntervalHours;

  /// Wall-clock time of the last completed backup attempt, regardless
  /// of success.
  DateTime? lastBackupAt;

  /// True if [lastBackupAt]'s attempt finished without error.
  bool? lastBackupSuccess;

  /// Short, human-readable failure message from the most recent
  /// failed attempt. Cleared on the next success.
  String? lastBackupError;

  /// Size in bytes of the last successful backup ZIP, surfaced in the
  /// Settings → Backup screen so users can see "your library: 4.8 MB".
  int? lastBackupBytes;

  /// Email of the signed-in Google account. Null = signed out. We
  /// store the email rather than the OAuth token because tokens
  /// rotate and `google_sign_in` can refresh them on demand.
  String? googleDriveAccountEmail;

  /// Drive folder ID where backups live. We use the **App Data**
  /// folder so backups never appear in the user's Drive UI; this
  /// field caches the resolved id to avoid an extra round-trip on
  /// every backup.
  String? googleDriveFolderId;

  /// File ID of the most recent backup on Drive. Used to overwrite
  /// instead of accumulating duplicate `marky-backup.zip` files.
  String? lastBackupFileId;

  /// Counter for back-to-back failures. The settings UI shows a
  /// warning banner when this hits a threshold (e.g. 3) so users
  /// know to re-auth or check connectivity.
  int consecutiveFailureCount;
}
