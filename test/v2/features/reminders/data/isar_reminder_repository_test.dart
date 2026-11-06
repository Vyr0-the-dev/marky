@Tags(<String>['integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/enums/reminder_repeat_mode.dart';
import 'package:marky/core/database/enums/reminder_status.dart';
import 'package:marky/core/database/marky_database.dart';
import 'package:marky/features/reminders/data/isar_reminder_repository.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';

Reminder _r({
  int bookmarkId = 1,
  DateTime? at,
  ReminderRepeatMode repeat = ReminderRepeatMode.none,
  ReminderStatus status = ReminderStatus.pending,
  String title = 'r',
}) {
  return Reminder(
    bookmarkId: bookmarkId,
    title: title,
    scheduledAt: at ?? DateTime(2026),
    timezone: 'Europe/Istanbul',
    repeatMode: repeat,
    status: status,
    createdAt: DateTime(2026),
  );
}

void main() {
  late Directory tempDir;
  late Isar isar;
  late ReminderRepository repo;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('reminder_repo_test_');
    isar = await MarkyDatabase.open(
      directory: tempDir.path,
      name: 'test_${tempDir.path.hashCode}',
    );
    repo = IsarReminderRepository(isar);
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('save assigns id', () async {
    final Reminder saved = await repo.save(_r());
    expect(saved.id, isNotNull);
  });

  test('getByBookmarkId sorts by scheduledAt ASC', () async {
    final DateTime base = DateTime(2026);
    await repo.save(_r(at: base.add(const Duration(days: 3)), title: 'c'));
    await repo.save(_r(at: base.add(const Duration(days: 1)), title: 'a'));
    await repo.save(_r(at: base.add(const Duration(days: 2)), title: 'b'));

    final List<Reminder> all = await repo.getByBookmarkId(1);
    expect(all.map((Reminder r) => r.title), <String>['a', 'b', 'c']);
  });

  test('getUpcoming respects window and excludes fired/cancelled', () async {
    final DateTime now = DateTime(2026, 5);
    await repo.save(_r(at: now.add(const Duration(hours: 1))));
    await repo.save(_r(
      at: now.add(const Duration(hours: 2)),
      status: ReminderStatus.fired,
    )); // excluded
    await repo.save(_r(
      at: now.add(const Duration(hours: 3)),
      status: ReminderStatus.cancelled,
    )); // excluded
    await repo.save(_r(
      at: now.add(const Duration(hours: 4)),
      status: ReminderStatus.snoozed,
    )); // included
    await repo.save(_r(
      at: now.add(const Duration(days: 2)),
    )); // outside window

    final List<Reminder> upcoming = await repo.getUpcoming(
      now: now,
      window: const Duration(hours: 12),
    );
    expect(upcoming.length, 2);
    expect(
      upcoming.map((Reminder r) => r.status).toList(),
      <ReminderStatus>[ReminderStatus.pending, ReminderStatus.snoozed],
    );
  });

  test('markFired stamps firedAt and flips status', () async {
    final Reminder saved = await repo.save(_r());
    final Reminder? fired = await repo.markFired(
      saved.id!,
      firedAt: DateTime(2026, 6),
    );
    expect(fired, isNotNull);
    expect(fired!.status, ReminderStatus.fired);
    expect(fired.firedAt, DateTime(2026, 6));
  });

  test('markSnoozed sets snoozedUntil', () async {
    final Reminder saved = await repo.save(_r());
    final DateTime until = DateTime(2026, 6);
    final Reminder? snoozed = await repo.markSnoozed(saved.id!, until: until);
    expect(snoozed!.status, ReminderStatus.snoozed);
    expect(snoozed.snoozedUntil, until);
  });

  test('markCancelled keeps the row, flips status', () async {
    final Reminder saved = await repo.save(_r());
    final Reminder? cancelled = await repo.markCancelled(saved.id!);
    expect(cancelled!.status, ReminderStatus.cancelled);
    expect(await repo.getById(saved.id!), isNotNull);
  });

  test('deleteByBookmarkId nukes all matches and returns count', () async {
    await repo.save(_r());
    await repo.save(_r());
    await repo.save(_r(bookmarkId: 2));

    final int removed = await repo.deleteByBookmarkId(1);
    expect(removed, 2);
    expect(await repo.getByBookmarkId(1), isEmpty);
    expect(await repo.getByBookmarkId(2), hasLength(1));
  });

  test('Reminder.effectiveFireAt prefers snoozedUntil', () {
    final DateTime base = DateTime(2026);
    final Reminder r = _r(at: base);
    expect(r.effectiveFireAt, base);

    final Reminder snoozed = r.copyWith(
      status: ReminderStatus.snoozed,
      snoozedUntil: base.add(const Duration(hours: 12)),
    );
    expect(snoozed.effectiveFireAt, base.add(const Duration(hours: 12)));
  });
}
