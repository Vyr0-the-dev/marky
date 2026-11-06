import 'package:marky/features/backup/domain/backup_meta.dart';

abstract interface class BackupMetaRepository {
  /// Returns the singleton row, materialising defaults on fresh
  /// installs. Always non-null.
  Future<BackupMeta> get();

  /// Replaces the row in full. The repository forces `id = 0` to
  /// preserve singleton-ness.
  Future<BackupMeta> save(BackupMeta meta);

  /// Convenience: marks a successful backup. Stamps `lastBackupAt`,
  /// flips `lastBackupSuccess` to true, clears the error / failure
  /// streak, records the file id and size.
  Future<BackupMeta> recordSuccess({
    required DateTime at,
    required String fileId,
    int? bytes,
  });

  /// Convenience: marks a failed backup. Stamps `lastBackupAt`,
  /// flips `lastBackupSuccess` to false, records the error and
  /// increments the consecutive-failure counter.
  Future<BackupMeta> recordFailure({
    required DateTime at,
    required String error,
  });

  /// Convenience: signs the user out. Clears Drive credentials and
  /// disables auto-backup so the worker doesn't keep running into
  /// auth failures.
  Future<BackupMeta> signOut();

  Stream<BackupMeta> watch();
}
