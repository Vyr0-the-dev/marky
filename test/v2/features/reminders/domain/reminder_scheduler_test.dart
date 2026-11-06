import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/database/enums/reminder_repeat_mode.dart';
import 'package:marky/core/database/enums/reminder_status.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../../fakes/fake_notification_service.dart';

void main() {
  late _FakeReminderRepository repository;
  late FakeNotificationService notificationService;
  late ReminderScheduler scheduler;
  late DateTime now;

  setUp(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    repository = _FakeReminderRepository();
    notificationService = FakeNotificationService();
    now = DateTime(2026, 4, 25, 12);
    scheduler = ReminderScheduler(
      reminderRepository: repository,
      notificationService: notificationService,
      now: () => now,
      timezoneName: () => 'Europe/Istanbul',
    );
  });

  test('createReminder persists, schedules, and stores notification id',
      () async {
    final Reminder reminder = await scheduler.createReminder(
      bookmarkId: 42,
      title: 'Read later',
      scheduledAt: now.add(const Duration(hours: 2)),
    );

    expect(reminder.id, 1);
    expect(reminder.notificationId, 1);
    expect(repository.saved[1]!.notificationId, 1);
    expect(notificationService.scheduledIds, <int>[1]);
    expect(notificationService.scheduled[1]!.payload, 'bookmark_detail:42');
    expect(notificationService.scheduled[1]!.repeatMode, 'none');
  });

  test('createReminder requests permission before saving', () async {
    notificationService.permissionGranted = false;

    await expectLater(
      () => scheduler.createReminder(
        bookmarkId: 1,
        title: 'Blocked',
        scheduledAt: now.add(const Duration(hours: 1)),
      ),
      throwsA(isA<ReminderNotificationPermissionDeniedException>()),
    );

    expect(repository.saved, isEmpty);
    expect(notificationService.scheduledIds, isEmpty);
  });

  test('createReminder checks exact alarm permission before saving', () async {
    notificationService.canScheduleExact = false;

    await expectLater(
      () => scheduler.createReminder(
        bookmarkId: 1,
        title: 'Blocked',
        scheduledAt: now.add(const Duration(hours: 1)),
      ),
      throwsA(isA<ReminderExactAlarmUnavailableException>()),
    );

    expect(repository.saved, isEmpty);
    expect(notificationService.scheduledIds, isEmpty);
  });

  test('createReminder rolls back persisted row if schedule fails', () async {
    notificationService.shouldThrowOnSchedule = true;

    await expectLater(
      () => scheduler.createReminder(
        bookmarkId: 1,
        title: 'Rollback',
        scheduledAt: now.add(const Duration(hours: 1)),
      ),
      throwsException,
    );

    expect(repository.saved, isEmpty);
  });

  test('cancelReminder cancels OS notification and marks row cancelled',
      () async {
    final Reminder reminder = await scheduler.createReminder(
      bookmarkId: 5,
      title: 'Cancel me',
      scheduledAt: now.add(const Duration(hours: 1)),
    );

    final Reminder? cancelled = await scheduler.cancelReminder(reminder.id!);

    expect(cancelled!.status, ReminderStatus.cancelled);
    expect(notificationService.cancelledIds, <int>[reminder.id!]);
    expect(repository.saved[reminder.id]!.status, ReminderStatus.cancelled);
  });

  test('snoozeReminder cancels existing schedule and creates a new one',
      () async {
    final Reminder reminder = await scheduler.createReminder(
      bookmarkId: 5,
      title: 'Snooze me',
      scheduledAt: now.add(const Duration(hours: 1)),
    );
    final DateTime until = now.add(const Duration(hours: 3));

    final Reminder? snoozed = await scheduler.snoozeReminder(
      reminder.id!,
      until: until,
    );

    expect(snoozed!.status, ReminderStatus.snoozed);
    expect(snoozed.snoozedUntil, until);
    expect(notificationService.cancelledIds, <int>[reminder.id!]);
    expect(notificationService.scheduledIds, <int>[reminder.id!, reminder.id!]);
  });

  test('rescheduleAllActive skips failed reminders and returns success count',
      () async {
    final Reminder a = await repository.save(_r(title: 'a'));
    final Reminder b = await repository.save(_r(title: 'b'));
    await repository.save(_r(title: 'done', status: ReminderStatus.fired));
    notificationService.shouldThrowOnSchedule = true;
    notificationService.throwOnId = a.id;

    final int count = await scheduler.rescheduleAllActive();

    expect(count, 1);
    expect(notificationService.scheduledIds, <int>[b.id!]);
  });

  test('rescheduleAllActive restores pending and snoozed reminders only',
      () async {
    final Reminder pending = await repository.save(_r(title: 'pending'));
    final Reminder snoozed = await repository.save(
      _r(title: 'snoozed').copyWith(
        status: ReminderStatus.snoozed,
        snoozedUntil: now.add(const Duration(hours: 4)),
      ),
    );
    await repository.save(_r(title: 'fired', status: ReminderStatus.fired));
    await repository.save(
      _r(title: 'cancelled', status: ReminderStatus.cancelled),
    );

    final int count = await scheduler.rescheduleAllActive();

    expect(count, 2);
    expect(notificationService.scheduledIds, <int>[pending.id!, snoozed.id!]);
    expect(
      notificationService.scheduled[snoozed.id]!.scheduledDate.hour,
      now.add(const Duration(hours: 4)).hour,
    );
  });

  test(
      'rescheduleAllActive falls back to reminder id when notification id is missing',
      () async {
    final Reminder reminder = await repository.save(
      _r(title: 'restore'),
    );

    final int count = await scheduler.rescheduleAllActive();

    expect(count, 1);
    expect(notificationService.scheduledIds, <int>[reminder.id!]);
    expect(notificationService.scheduled[reminder.id]!.payload,
        'bookmark_detail:1');
  });

  test('deleteByBookmarkId cancels every reminder notification', () async {
    final Reminder a = await repository.save(_r(bookmarkId: 9));
    final Reminder b = await repository.save(_r(bookmarkId: 9));
    await repository.save(_r(bookmarkId: 10));

    final int removed = await scheduler.deleteByBookmarkId(9);

    expect(removed, 2);
    expect(notificationService.cancelledIds, <int>[a.id!, b.id!]);
    expect(await repository.getByBookmarkId(9), isEmpty);
    expect(await repository.getByBookmarkId(10), hasLength(1));
  });

  test('passes repeat mode name to NotificationService', () async {
    final Reminder reminder = await scheduler.createReminder(
      bookmarkId: 1,
      title: 'Daily',
      scheduledAt: now.add(const Duration(hours: 1)),
      repeatMode: ReminderRepeatMode.daily,
    );

    expect(notificationService.scheduled[reminder.id]!.repeatMode, 'daily');
  });
}

Reminder _r({
  int? id,
  int bookmarkId = 1,
  String title = 'r',
  ReminderStatus status = ReminderStatus.pending,
}) {
  return Reminder(
    id: id,
    bookmarkId: bookmarkId,
    title: title,
    scheduledAt: DateTime(2026, 4, 25, 13),
    timezone: 'Europe/Istanbul',
    notificationId: id,
    status: status,
    createdAt: DateTime(2026, 4, 25, 12),
  );
}

class _FakeReminderRepository implements ReminderRepository {
  final Map<int, Reminder> saved = <int, Reminder>{};
  int _nextId = 1;

  @override
  Future<Reminder> save(Reminder reminder) async {
    final int id = reminder.id ?? _nextId++;
    final Reminder persisted = reminder.copyWith(id: id);
    saved[id] = persisted;
    return persisted;
  }

  @override
  Future<Reminder?> getById(int id) async => saved[id];

  @override
  Future<List<Reminder>> getByBookmarkId(int bookmarkId) async {
    return saved.values
        .where((Reminder r) => r.bookmarkId == bookmarkId)
        .toList(growable: false);
  }

  @override
  Future<List<Reminder>> getUpcoming({
    required DateTime now,
    required Duration window,
  }) async =>
      <Reminder>[];

  @override
  Future<List<Reminder>> getAllActive() async {
    return saved.values
        .where((Reminder r) => r.isActive)
        .toList(growable: false);
  }

  @override
  Future<bool> delete(int id) async => saved.remove(id) != null;

  @override
  Future<int> deleteByBookmarkId(int bookmarkId) async {
    final List<int> ids = saved.values
        .where((Reminder r) => r.bookmarkId == bookmarkId)
        .map((Reminder r) => r.id!)
        .toList(growable: false);
    for (final int id in ids) {
      saved.remove(id);
    }
    return ids.length;
  }

  @override
  Future<Reminder?> markFired(int id, {DateTime? firedAt}) async {
    final Reminder? reminder = saved[id];
    if (reminder == null) return null;
    return save(reminder.copyWith(
      status: ReminderStatus.fired,
      firedAt: firedAt ?? DateTime.now(),
    ));
  }

  @override
  Future<Reminder?> markSnoozed(int id, {required DateTime until}) async {
    final Reminder? reminder = saved[id];
    if (reminder == null) return null;
    return save(reminder.copyWith(
      status: ReminderStatus.snoozed,
      snoozedUntil: until,
    ));
  }

  @override
  Future<Reminder?> markCancelled(int id) async {
    final Reminder? reminder = saved[id];
    if (reminder == null) return null;
    return save(reminder.copyWith(status: ReminderStatus.cancelled));
  }

  @override
  Stream<List<Reminder>> watchByBookmarkId(int bookmarkId) {
    throw UnimplementedError();
  }

  @override
  Stream<Reminder?> watchById(int id) {
    throw UnimplementedError();
  }
}
