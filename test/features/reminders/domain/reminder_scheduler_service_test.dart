import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/features/reminders/domain/services/reminder_scheduler_service.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../fakes/fake_notification_service.dart';

void main() {
  tz_data.initializeTimeZones();

  group('ReminderSchedulerService', () {
    late Directory tempDir;
    late Isar isar;
    late ReminderRepository repository;
    late FakeNotificationService fakeNotificationService;
    late ReminderSchedulerService scheduler;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('scheduler_test_');

      isar = await Isar.open(
        [ReminderSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      repository = ReminderRepositoryImpl(isar: isar);
      fakeNotificationService = FakeNotificationService();
      scheduler = ReminderSchedulerService(
        reminderRepository: repository,
        notificationService: fakeNotificationService,
      );
    });

    tearDown(() async {
      if (isar.isOpen) {
        await isar.close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    // ─── Create ──────────────────────────────────────────────────────────

    test('createReminder inserts to DB and schedules notification', () async {
      final scheduledAt = DateTime.now().add(const Duration(hours: 2));

      final reminder = await scheduler.createReminder(
        bookmarkId: 42,
        title: 'Test Reminder',
        scheduledAt: scheduledAt,
      );

      expect(reminder.id, greaterThan(0));
      expect(reminder.bookmarkId, 42);
      expect(reminder.title, 'Test Reminder');
      expect(reminder.status, 'pending');

      final fetched = await repository.getById(reminder.id);
      expect(fetched, isNotNull);
      expect(fetched!.notificationId, reminder.id.toString());

      expect(fakeNotificationService.scheduledIds, contains(reminder.id));
      expect(
        fakeNotificationService.scheduled[reminder.id]?.title,
        'Test Reminder',
      );
    });

    test('createReminder with invalid repeatMode throws ArgumentError',
        () async {
      expect(
        () => scheduler.createReminder(
          bookmarkId: 1,
          title: 'Test',
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          repeatMode: 'monthly',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('createReminder with past scheduledAt throws ArgumentError',
        () async {
      expect(
        () => scheduler.createReminder(
          bookmarkId: 1,
          title: 'Test',
          scheduledAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'createReminder with scheduledAt 1 year in the future is accepted',
        () async {
      final scheduledAt = DateTime.now().add(const Duration(days: 365));

      final reminder = await scheduler.createReminder(
        bookmarkId: 1,
        title: 'Future Reminder',
        scheduledAt: scheduledAt,
      );

      expect(reminder.id, greaterThan(0));
      expect(fakeNotificationService.scheduledIds, contains(reminder.id));
    });

    test('createReminder rolls back DB when scheduling throws', () async {
      fakeNotificationService.shouldThrowOnSchedule = true;

      await expectLater(
        () => scheduler.createReminder(
          bookmarkId: 1,
          title: 'Test',
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        ),
        throwsA(isA<Exception>()),
      );

      expect(fakeNotificationService.scheduledIds, isEmpty);
      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    // ─── Cancel ──────────────────────────────────────────────────────────

    test('cancelReminder deletes from DB and cancels notification', () async {
      final reminder = await scheduler.createReminder(
        bookmarkId: 1,
        title: 'To Cancel',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(await repository.getById(reminder.id), isNotNull);
      expect(fakeNotificationService.scheduledIds, contains(reminder.id));

      await scheduler.cancelReminder(reminder.id);

      expect(await repository.getById(reminder.id), isNull);
      expect(fakeNotificationService.cancelledIds, contains(reminder.id));
    });

    test('cancelReminder on unknown id is no-op', () async {
      await scheduler.cancelReminder(99999);
      expect(fakeNotificationService.cancelledIds, isEmpty);
    });

    // ─── Complete ────────────────────────────────────────────────────────

    test('completeReminder updates status and cancels notification',
        () async {
      final reminder = await scheduler.createReminder(
        bookmarkId: 1,
        title: 'To Complete',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(fakeNotificationService.scheduledIds, contains(reminder.id));

      await scheduler.completeReminder(reminder.id);

      final fetched = await repository.getById(reminder.id);
      expect(fetched!.status, 'completed');
      expect(fetched.completedAt, isNotNull);
      expect(fakeNotificationService.cancelledIds, contains(reminder.id));
    });

    test('completeReminder on unknown id is no-op', () async {
      await scheduler.completeReminder(99999);
      expect(fakeNotificationService.cancelledIds, isEmpty);
    });

    // ─── Snooze ──────────────────────────────────────────────────────────

    test('snoozeReminder updates scheduledAt and reschedules', () async {
      final originalTime = DateTime.now().add(const Duration(hours: 1));
      final reminder = await scheduler.createReminder(
        bookmarkId: 1,
        title: 'To Snooze',
        scheduledAt: originalTime,
      );

      final originalScheduleCount = fakeNotificationService.scheduledIds.length;
      expect(fakeNotificationService.scheduledIds, contains(reminder.id));

      const snoozeDuration = Duration(minutes: 30);
      await scheduler.snoozeReminder(reminder.id, snoozeDuration);

      final fetched = await repository.getById(reminder.id);
      expect(fetched!.status, 'snoozed');
      expect(fetched.snoozedUntil, isNotNull);
      // Snoozed time should be ~30 minutes from now, which is before
      // the original 1-hour target but still in the future.
      expect(
        fetched.scheduledAt.isAfter(DateTime.now()),
        isTrue,
      );
      expect(
        fetched.scheduledAt.difference(DateTime.now()).inMinutes,
        closeTo(30, 1),
      );

      // Should have cancelled original and scheduled new.
      expect(fakeNotificationService.cancelledIds, contains(reminder.id));
      expect(
        fakeNotificationService.scheduledIds.length,
        originalScheduleCount + 1,
      );
    });

    test('snoozeReminder on unknown id is no-op', () async {
      await scheduler.snoozeReminder(99999, const Duration(minutes: 10));
      expect(fakeNotificationService.scheduledIds, isEmpty);
      expect(fakeNotificationService.cancelledIds, isEmpty);
    });

    // ─── Boot reschedule ─────────────────────────────────────────────────

    test('rescheduleAllPending schedules all pending reminders', () async {
      final r1 = await scheduler.createReminder(
        bookmarkId: 1,
        title: 'Reminder 1',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );
      final r2 = await scheduler.createReminder(
        bookmarkId: 2,
        title: 'Reminder 2',
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      );

      // Clear tracking and simulate reboot.
      fakeNotificationService.scheduledIds.clear();
      fakeNotificationService.scheduled.clear();

      await scheduler.rescheduleAllPending();

      expect(fakeNotificationService.scheduledIds, containsAll([r1.id, r2.id]));
      expect(fakeNotificationService.scheduled.length, 2);
    });

    test('rescheduleAllPending skips completed reminders', () async {
      final reminder = await scheduler.createReminder(
        bookmarkId: 1,
        title: 'To Complete',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await scheduler.completeReminder(reminder.id);

      fakeNotificationService.scheduledIds.clear();
      fakeNotificationService.scheduled.clear();

      await scheduler.rescheduleAllPending();

      expect(fakeNotificationService.scheduledIds, isEmpty);
    });

    test(
        'rescheduleAllPending continues when individual scheduling fails',
        () async {
      final r1 = await scheduler.createReminder(
        bookmarkId: 1,
        title: 'Reminder 1',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );
      final r2 = await scheduler.createReminder(
        bookmarkId: 2,
        title: 'Reminder 2',
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      );

      // Simulate reboot.
      fakeNotificationService.scheduledIds.clear();
      fakeNotificationService.scheduled.clear();

      // Make scheduling fail for the first reminder only.
      fakeNotificationService.shouldThrowOnSchedule = true;
      fakeNotificationService.throwOnId = r1.id;

      await scheduler.rescheduleAllPending();

      // r1 failed, but r2 should still be scheduled.
      expect(
        fakeNotificationService.scheduledIds,
        isNot(contains(r1.id)),
      );
      expect(fakeNotificationService.scheduledIds, contains(r2.id));
    });
  });
}
