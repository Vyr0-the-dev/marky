import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/core/database/database_providers.dart';
import 'package:marky/features/backup/data/isar_backup_meta_repository.dart';
import 'package:marky/features/backup/domain/backup_meta.dart';
import 'package:marky/features/backup/domain/backup_meta_repository.dart';

final Provider<BackupMetaRepository> backupMetaRepositoryProvider =
    Provider<BackupMetaRepository>((Ref ref) {
  return IsarBackupMetaRepository(ref.watch(markyIsarProvider));
});

/// Reactive backup meta — used by Settings → Backup screen.
final AutoDisposeStreamProvider<BackupMeta> backupMetaProvider =
    StreamProvider.autoDispose<BackupMeta>((Ref ref) {
  return ref.watch(backupMetaRepositoryProvider).watch();
});
