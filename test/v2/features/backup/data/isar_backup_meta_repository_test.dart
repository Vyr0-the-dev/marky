@Tags(<String>['integration'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/backup_meta_entity.dart';
import 'package:marky/core/database/marky_database.dart';
import 'package:marky/features/backup/data/isar_backup_meta_repository.dart';
import 'package:marky/features/backup/domain/backup_meta.dart';
import 'package:marky/features/backup/domain/backup_meta_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late BackupMetaRepository repo;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('backup_meta_repo_test_');
    isar = await MarkyDatabase.open(
      directory: tempDir.path,
      name: 'test_${tempDir.path.hashCode}',
    );
    repo = IsarBackupMetaRepository(isar);
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('get returns defaults on fresh install', () async {
    final BackupMeta meta = await repo.get();
    expect(meta, const BackupMeta.defaults());
    expect(meta.autoBackupEnabled, isFalse);
    expect(meta.backupIntervalHours, 24);
    expect(meta.isSignedIn, isFalse);
  });

  test('save persists at id=0 (singleton)', () async {
    await repo.save(const BackupMeta(
      autoBackupEnabled: true,
      backupIntervalHours: 6,
      googleDriveAccountEmail: 'me@example.com',
    ));
    expect(await isar.backupMeta.count(), 1);

    final BackupMeta loaded = await repo.get();
    expect(loaded.autoBackupEnabled, isTrue);
    expect(loaded.backupIntervalHours, 6);
    expect(loaded.googleDriveAccountEmail, 'me@example.com');
  });

  test('recordSuccess clears error and resets failure counter', () async {
    // Seed with a failing state.
    await repo.recordFailure(at: DateTime(2026), error: 'boom');
    await repo.recordFailure(at: DateTime(2026, 2), error: 'boom2');
    BackupMeta meta = await repo.get();
    expect(meta.consecutiveFailureCount, 2);
    expect(meta.lastBackupError, 'boom2');

    // Now success.
    meta = await repo.recordSuccess(
      at: DateTime(2026, 3),
      fileId: 'file-abc',
      bytes: 1024,
    );
    expect(meta.lastBackupSuccess, isTrue);
    expect(meta.lastBackupError, isNull);
    expect(meta.lastBackupFileId, 'file-abc');
    expect(meta.lastBackupBytes, 1024);
    expect(meta.consecutiveFailureCount, 0);
  });

  test('recordFailure increments the streak', () async {
    BackupMeta meta = await repo.recordFailure(
      at: DateTime(2026),
      error: 'one',
    );
    expect(meta.consecutiveFailureCount, 1);
    expect(meta.lastBackupSuccess, isFalse);
    expect(meta.lastBackupError, 'one');

    meta = await repo.recordFailure(at: DateTime(2026, 2), error: 'two');
    expect(meta.consecutiveFailureCount, 2);
    expect(meta.lastBackupError, 'two');
  });

  test('signOut clears Drive credentials and disables auto-backup', () async {
    await repo.save(const BackupMeta(
      autoBackupEnabled: true,
      googleDriveAccountEmail: 'me@example.com',
      googleDriveFolderId: 'folder-1',
      lastBackupFileId: 'file-1',
    ));
    final BackupMeta after = await repo.signOut();
    expect(after.autoBackupEnabled, isFalse);
    expect(after.googleDriveAccountEmail, isNull);
    expect(after.googleDriveFolderId, isNull);
    expect(after.lastBackupFileId, isNull);
  });

  test('isHealthy reflects sign-in + enabled + last success', () async {
    expect((await repo.get()).isHealthy, isFalse);

    await repo.save(const BackupMeta(
      autoBackupEnabled: true,
      googleDriveAccountEmail: 'me@example.com',
      lastBackupSuccess: true,
    ));
    expect((await repo.get()).isHealthy, isTrue);

    await repo.recordFailure(at: DateTime(2026), error: 'oops');
    expect((await repo.get()).isHealthy, isFalse);
  });

  test('watch emits initial value then re-emits after a write', () async {
    final Stream<BackupMeta> stream = repo.watch();

    final Completer<BackupMeta> first = Completer<BackupMeta>();
    final Completer<BackupMeta> second = Completer<BackupMeta>();
    int seen = 0;
    late StreamSubscription<BackupMeta> sub;
    sub = stream.listen((BackupMeta m) {
      seen++;
      if (seen == 1) {
        first.complete(m);
      } else if (seen == 2 && !second.isCompleted) {
        second.complete(m);
      }
    });

    final BackupMeta initial = await first.future;
    expect(initial, const BackupMeta.defaults());

    await repo.save(const BackupMeta(autoBackupEnabled: true));
    final BackupMeta next = await second.future;
    expect(next.autoBackupEnabled, isTrue);

    await sub.cancel();
  });
}
