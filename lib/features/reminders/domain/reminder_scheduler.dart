import 'package:marky/core/database/enums/reminder_repeat_mode.dart';
import 'package:marky/core/database/enums/reminder_status.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';
import 'package:timezone/timezone.dart' as tz;

class ReminderScheduler {
  ReminderScheduler({
    required ReminderRepository reminderRepository,
    required NotificationService notificationService,
    DateTime Function()? now,
    String Function()? timezoneName,
  })  : _reminderRepository = reminderRepository,
        _notificationService = notificationService,
        _now = now ?? DateTime.now,
        _timezoneName = timezoneName ?? _defaultTimezoneName;

  final ReminderRepository _reminderRepository;
  final NotificationService _notificationService;
  final DateTime Function() _now;
  final String Function() _timezoneName;

  Future<Reminder> createReminder({
    required int bookmarkId,
    required String title,
    String? body,
    required DateTime scheduledAt,
    String? timezone,
    ReminderRepeatMode repeatMode = ReminderRepeatMode.none,
  }) async {
    await _ensureCanSchedule();

    final DateTime now = _now();
    final Reminder draft = Reminder(
      bookmarkId: bookmarkId,
      title: title.trim().isEmpty ? 'Marky reminder' : title.trim(),
      body: body,
      scheduledAt: scheduledAt,
      timezone: timezone ?? _timezoneName(),
      repeatMode: repeatMode,
      createdAt: now,
    );

    final Reminder saved = await _reminderRepository.save(draft);
    final Reminder scheduled = saved.copyWith(notificationId: saved.id);

    try {
      await _scheduleNotification(scheduled);
    } on Object {
      if (saved.id != null) {
        await _reminderRepository.delete(saved.id!);
      }
      rethrow;
    }

    return _reminderRepository.save(scheduled);
  }

  Future<Reminder?> cancelReminder(int id) async {
    final Reminder? reminder = await _reminderRepository.getById(id);
    if (reminder == null) return null;
    await _notificationService
        .cancelNotification(reminder.notificationId ?? id);
    return _reminderRepository.markCancelled(id);
  }

  Future<Reminder?> snoozeReminder(int id, {required DateTime until}) async {
    await _ensureCanSchedule();
    final Reminder? reminder = await _reminderRepository.getById(id);
    if (reminder == null) return null;

    final int notificationId = reminder.notificationId ?? id;
    final Reminder snoozed = reminder.copyWith(
      status: ReminderStatus.snoozed,
      snoozedUntil: until,
      notificationId: notificationId,
    );

    await _notificationService.cancelNotification(notificationId);
    await _scheduleNotification(snoozed);
    return _reminderRepository.save(snoozed);
  }

  Future<int> rescheduleAllActive() async {
    final List<Reminder> active = await _reminderRepository.getAllActive();
    int scheduledCount = 0;
    for (final Reminder reminder in active) {
      try {
        await _scheduleNotification(
          reminder.copyWith(
              notificationId: reminder.notificationId ?? reminder.id),
        );
        scheduledCount += 1;
      } on Object {
        continue;
      }
    }
    return scheduledCount;
  }

  Future<int> deleteByBookmarkId(int bookmarkId) async {
    final List<Reminder> reminders =
        await _reminderRepository.getByBookmarkId(bookmarkId);
    for (final Reminder reminder in reminders) {
      if (reminder.id == null) continue;
      await _notificationService.cancelNotification(
        reminder.notificationId ?? reminder.id!,
      );
    }
    return _reminderRepository.deleteByBookmarkId(bookmarkId);
  }

  Future<void> _ensureCanSchedule() async {
    final bool permissionGranted =
        await _notificationService.requestPermission();
    if (!permissionGranted) {
      throw const ReminderNotificationPermissionDeniedException();
    }
    final bool exactAlarmAllowed =
        await _notificationService.canScheduleExactNotifications();
    if (!exactAlarmAllowed) {
      throw const ReminderExactAlarmUnavailableException();
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    final int? id = reminder.notificationId ?? reminder.id;
    if (id == null) {
      throw StateError('Reminder must be persisted before scheduling.');
    }
    await _notificationService.scheduleNotification(
      id: id,
      title: reminder.title,
      body: reminder.body ?? 'Tap to view your bookmark',
      scheduledDate: _toTzDateTime(reminder.effectiveFireAt, reminder.timezone),
      payload: 'bookmark_detail:${reminder.bookmarkId}',
      repeatMode: reminder.repeatMode.name,
    );
  }

  tz.TZDateTime _toTzDateTime(DateTime dateTime, String timezoneName) {
    final tz.Location? preferredLocation = _tryGetLocation(timezoneName);
    if (preferredLocation != null) {
      return tz.TZDateTime.from(dateTime, preferredLocation);
    }

    final tz.Location? utcLocation = _tryGetLocation('UTC');
    if (utcLocation != null) {
      return tz.TZDateTime.from(dateTime, utcLocation);
    }

    return tz.TZDateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
      dateTime.microsecond,
    );
  }

  static tz.Location? _tryGetLocation(String timezoneName) {
    try {
      return tz.getLocation(timezoneName);
    } on Object {
      return null;
    }
  }

  static String _defaultTimezoneName() {
    try {
      return tz.local.name;
    } on Object {
      return 'UTC';
    }
  }
}

class ReminderNotificationPermissionDeniedException implements Exception {
  const ReminderNotificationPermissionDeniedException();

  @override
  String toString() => 'Reminder notification permission denied';
}

class ReminderExactAlarmUnavailableException implements Exception {
  const ReminderExactAlarmUnavailableException();

  @override
  String toString() => 'Exact alarm scheduling is unavailable';
}
