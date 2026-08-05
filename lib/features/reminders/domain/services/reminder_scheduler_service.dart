import 'dart:async';

import 'package:logger/logger.dart';

import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:timezone/timezone.dart' as tz;

const Set<String> _validRepeatModes = <String>{'none', 'daily', 'weekly'};

/// Coordinates reminder CRUD with platform notification scheduling.
///
/// All operations are transactional at the business-logic level: if
/// notification scheduling fails, the database is not updated (or is
/// rolled back via compensating action).
class ReminderSchedulerService {
  ReminderSchedulerService({
    required ReminderRepository reminderRepository,
    required NotificationService notificationService,
  })  : _reminderRepository = reminderRepository,
        _notificationService = notificationService;

  final ReminderRepository _reminderRepository;
  final NotificationService _notificationService;
  final Logger _logger = Logger();

  // ─── Create ────────────────────────────────────────────────────────────

  /// Creates a reminder, schedules the platform notification, and persists
  /// the reminder to the database.
  ///
  /// Throws [ArgumentError] when [repeatMode] is invalid or [scheduledAt]
  /// is in the past.
  Future<Reminder> createReminder({
    required int bookmarkId,
    required String title,
    String? body,
    required DateTime scheduledAt,
    String repeatMode = 'none',
    String? timezone,
  }) async {
    _validateRepeatMode(repeatMode);
    _validateScheduledAt(scheduledAt);

    final String tzName = timezone ?? DateTime.now().timeZoneName;

    final Reminder reminder = Reminder(
      bookmarkId: bookmarkId,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      timezone: tzName,
      repeatMode: repeatMode,
      createdAt: DateTime.now(),
    );

    // Persist first so we get a real Isar ID for the notification.
    final int id = await _reminderRepository.insert(reminder);
    reminder.id = id;

    try {
      await _scheduleNotificationForReminder(reminder);
    } on Object catch (e, stackTrace) {
      _logger.e(
        'Failed to schedule notification for reminder $id — deleting reminder',
        error: e,
        stackTrace: stackTrace,
      );
      await _reminderRepository.delete(id);
      rethrow;
    }

    // Store the platform notification id (same as reminder id).
    reminder.notificationId = id.toString();
    await _reminderRepository.update(reminder);

    _logger.i('Created reminder $id for bookmark $bookmarkId at $scheduledAt');
    return reminder;
  }

  // ─── Cancel ────────────────────────────────────────────────────────────

  /// Cancels the platform notification and deletes the reminder.
  Future<void> cancelReminder(int reminderId) async {
    final Reminder? reminder = await _reminderRepository.getById(reminderId);
    if (reminder == null) {
      _logger.w('Cancel requested for unknown reminder $reminderId');
      return;
    }

    await _notificationService.cancelNotification(reminderId);
    await _reminderRepository.delete(reminderId);
    _logger.i('Cancelled and deleted reminder $reminderId');
  }

  // ─── Complete ──────────────────────────────────────────────────────────

  /// Marks the reminder as completed and cancels its notification.
  Future<void> completeReminder(int reminderId) async {
    final Reminder? reminder = await _reminderRepository.getById(reminderId);
    if (reminder == null) {
      _logger.w('Complete requested for unknown reminder $reminderId');
      return;
    }

    await _notificationService.cancelNotification(reminderId);

    reminder
      ..status = 'completed'
      ..completedAt = DateTime.now();

    await _reminderRepository.update(reminder);
    _logger.i('Completed reminder $reminderId');
  }

  // ─── Snooze ────────────────────────────────────────────────────────────

  /// Snoozes the reminder by [duration], updating [scheduledAt] and
  /// re-scheduling the platform notification.
  Future<void> snoozeReminder(int reminderId, Duration duration) async {
    final Reminder? reminder = await _reminderRepository.getById(reminderId);
    if (reminder == null) {
      _logger.w('Snooze requested for unknown reminder $reminderId');
      return;
    }

    final DateTime newScheduledAt = DateTime.now().add(duration);

    reminder
      ..status = 'snoozed'
      ..snoozedUntil = newScheduledAt
      ..scheduledAt = newScheduledAt;

    await _notificationService.cancelNotification(reminderId);
    await _scheduleNotificationForReminder(reminder);
    await _reminderRepository.update(reminder);

    _logger.i('Snoozed reminder $reminderId until $newScheduledAt');
  }

  // ─── Boot reschedule ───────────────────────────────────────────────────

  /// Re-schedules all pending reminders. Call this after app bootstrap.
  Future<void> rescheduleAllPending() async {
    final List<Reminder> pending = await _reminderRepository.getPending();
    int successCount = 0;

    for (final Reminder reminder in pending) {
      try {
        await _scheduleNotificationForReminder(reminder);
        successCount++;
      } on Object catch (e, stackTrace) {
        _logger.e(
          'Failed to reschedule reminder ${reminder.id}',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    _logger.i('Rescheduled $successCount/${pending.length} pending reminders');
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  void _validateRepeatMode(String repeatMode) {
    if (!_validRepeatModes.contains(repeatMode)) {
      throw ArgumentError.value(
        repeatMode,
        'repeatMode',
        "Must be one of: 'none', 'daily', 'weekly'",
      );
    }
  }

  void _validateScheduledAt(DateTime scheduledAt) {
    if (scheduledAt.isBefore(DateTime.now())) {
      throw ArgumentError.value(
        scheduledAt,
        'scheduledAt',
        'Scheduled time must be in the future',
      );
    }
  }

  Future<void> _scheduleNotificationForReminder(Reminder reminder) async {
    final tz.TZDateTime scheduledDate = _toTzDateTime(
      reminder.scheduledAt,
      reminder.timezone,
    );

    await _notificationService.scheduleNotification(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body ?? 'Tap to view your bookmark',
      scheduledDate: scheduledDate,
      payload: 'bookmark_detail:${reminder.bookmarkId}',
      repeatMode: reminder.repeatMode,
    );
  }

  tz.TZDateTime _toTzDateTime(DateTime dt, String timezoneName) {
    try {
      final tz.Location location = tz.getLocation(timezoneName);
      return tz.TZDateTime.from(dt, location);
    } on Object {
      _logger.w('Unknown timezone "$timezoneName", falling back to local');
      return tz.TZDateTime.from(dt, tz.local);
    }
  }
}
