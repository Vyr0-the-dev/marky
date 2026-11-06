import 'package:marky/core/database/entities/backup_meta_entity.dart';
import 'package:marky/features/backup/domain/backup_meta.dart';

abstract final class BackupMetaMapper {
  static BackupMeta toDomain(BackupMetaEntity e) => BackupMeta(
        autoBackupEnabled: e.autoBackupEnabled,
        backupIntervalHours: e.backupIntervalHours,
        lastBackupAt: e.lastBackupAt,
        lastBackupSuccess: e.lastBackupSuccess,
        lastBackupError: e.lastBackupError,
        lastBackupBytes: e.lastBackupBytes,
        googleDriveAccountEmail: e.googleDriveAccountEmail,
        googleDriveFolderId: e.googleDriveFolderId,
        lastBackupFileId: e.lastBackupFileId,
        consecutiveFailureCount: e.consecutiveFailureCount,
      );

  /// Always pins `id = 0` regardless of any caller input — this is
  /// the singleton invariant.
  static BackupMetaEntity toEntity(BackupMeta m) {
    return BackupMetaEntity(
      autoBackupEnabled: m.autoBackupEnabled,
      backupIntervalHours: m.backupIntervalHours,
      lastBackupAt: m.lastBackupAt,
      lastBackupSuccess: m.lastBackupSuccess,
      lastBackupError: m.lastBackupError,
      lastBackupBytes: m.lastBackupBytes,
      googleDriveAccountEmail: m.googleDriveAccountEmail,
      googleDriveFolderId: m.googleDriveFolderId,
      lastBackupFileId: m.lastBackupFileId,
      consecutiveFailureCount: m.consecutiveFailureCount,
    );
  }
}
