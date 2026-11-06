import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/backup_meta_entity.dart';
import 'package:marky/features/backup/data/backup_meta_mapper.dart';
import 'package:marky/features/backup/domain/backup_meta.dart';
import 'package:marky/features/backup/domain/backup_meta_repository.dart';

/// Isar-backed [BackupMetaRepository]. Always operates on a single
/// row at `id = 0` — the entity's default constructor enforces this.
class IsarBackupMetaRepository implements BackupMetaRepository {
  IsarBackupMetaRepository(this._isar);

  final Isar _isar;

  @override
  Future<BackupMeta> get() async {
    final BackupMetaEntity? row = await _isar.backupMeta.get(0);
    return row == null
        ? const BackupMeta.defaults()
        : BackupMetaMapper.toDomain(row);
  }

  @override
  Future<BackupMeta> save(BackupMeta meta) async {
    final BackupMetaEntity entity = BackupMetaMapper.toEntity(meta);
    await _isar.writeTxn<void>(() async {
      await _isar.backupMeta.put(entity);
    });
    return meta;
  }

  @override
  Future<BackupMeta> recordSuccess({
    required DateTime at,
    required String fileId,
    int? bytes,
  }) async {
    final BackupMeta current = await get();
    // Build the next state directly rather than chaining copyWith so
    // we can null `lastBackupError` (copyWith preserves non-null on
    // a null argument) and reset the failure counter in one go.
    final BackupMeta cleared = BackupMeta(
      autoBackupEnabled: current.autoBackupEnabled,
      backupIntervalHours: current.backupIntervalHours,
      lastBackupAt: at,
      lastBackupSuccess: true,
      // lastBackupError intentionally omitted → null on success.
      lastBackupBytes: bytes,
      googleDriveAccountEmail: current.googleDriveAccountEmail,
      googleDriveFolderId: current.googleDriveFolderId,
      lastBackupFileId: fileId,
      // consecutiveFailureCount intentionally omitted → 0.
    );
    return save(cleared);
  }

  @override
  Future<BackupMeta> recordFailure({
    required DateTime at,
    required String error,
  }) async {
    final BackupMeta current = await get();
    final BackupMeta next = current.copyWith(
      lastBackupAt: at,
      lastBackupSuccess: false,
      lastBackupError: error,
      consecutiveFailureCount: current.consecutiveFailureCount + 1,
    );
    return save(next);
  }

  @override
  Future<BackupMeta> signOut() async {
    final BackupMeta current = await get();
    // Build the next state directly so we can null the Drive
    // credentials and force-disable auto-backup at the same time.
    final BackupMeta next = BackupMeta(
      // autoBackupEnabled omitted → false (forced disable on sign-out).
      backupIntervalHours: current.backupIntervalHours,
      lastBackupAt: current.lastBackupAt,
      lastBackupSuccess: current.lastBackupSuccess,
      lastBackupError: current.lastBackupError,
      lastBackupBytes: current.lastBackupBytes,
      // googleDriveAccountEmail / googleDriveFolderId / lastBackupFileId
      // → null (signed out, no folder context, last file forgotten).
      // consecutiveFailureCount omitted → 0.
    );
    return save(next);
  }

  @override
  Stream<BackupMeta> watch() {
    // `fireImmediately: true` makes Isar emit the current value
    // synchronously after subscribe, then re-emit on every mutation.
    // We map null → defaults so callers always see a concrete row,
    // even on a fresh install where id=0 hasn't been materialised yet.
    return _isar.backupMeta.watchObject(0, fireImmediately: true).map(
          (BackupMetaEntity? e) => e == null
              ? const BackupMeta.defaults()
              : BackupMetaMapper.toDomain(e),
        );
  }
}
