import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:timezone/timezone.dart' as tz;

class UnreadReminderScheduler {
  UnreadReminderScheduler({
    required BookmarkRepository bookmarkRepository,
    required NotificationService notificationService,
    required String payload,
    DateTime Function()? now,
    String Function()? timezoneName,
  })  : _bookmarkRepository = bookmarkRepository,
        _notificationService = notificationService,
        _payload = payload,
        _now = now ?? DateTime.now,
        _timezoneName = timezoneName ?? _defaultTimezoneName;

  static const int notificationId = 820042;

  final BookmarkRepository _bookmarkRepository;
  final NotificationService _notificationService;
  final String _payload;
  final DateTime Function() _now;
  final String Function() _timezoneName;

  Future<int> sync(
    UnreadReminderCadence cadence, {
    int? weekday,
    int? hour,
    int? minute,
  }) async {
    if (cadence == UnreadReminderCadence.off) {
      await cancel();
      return 0;
    }
    return schedule(cadence, weekday: weekday, hour: hour, minute: minute);
  }

  Future<int> schedule(
    UnreadReminderCadence cadence, {
    int? weekday,
    int? hour,
    int? minute,
  }) async {
    if (cadence == UnreadReminderCadence.off) {
      await cancel();
      return 0;
    }

    final int unreadCount = await _bookmarkRepository.count(
      const BookmarkFeedQuery(filter: BookmarkFeedFilter.unread),
    );
    if (unreadCount == 0) {
      await cancel();
      return 0;
    }

    await _ensureCanSchedule();

    final int effectiveHour = hour ?? _defaultHour(cadence);
    final int effectiveMinute = minute ?? _defaultMinute(cadence);
    final int effectiveWeekday = _normalizeWeekday(weekday);

    await _notificationService.cancelNotification(notificationId);
    await _notificationService.scheduleNotification(
      id: notificationId,
      title: 'Unread saves are waiting',
      body: unreadCount == 1
          ? 'You still have 1 unread save in Marky.'
          : 'You still have $unreadCount unread saves in Marky.',
      scheduledDate: _toTzDateTime(
        _nextFireAt(
          cadence,
          weekday: effectiveWeekday,
          hour: effectiveHour,
          minute: effectiveMinute,
        ),
        _timezoneName(),
      ),
      payload: _payload,
      repeatMode: _repeatMode(cadence),
    );
    return unreadCount;
  }

  Future<void> cancel() {
    return _notificationService.cancelNotification(notificationId);
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

  DateTime _nextFireAt(
    UnreadReminderCadence cadence, {
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final DateTime now = _now();
    switch (cadence) {
      case UnreadReminderCadence.off:
        return now;
      case UnreadReminderCadence.dailyEvening:
        final DateTime today = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        return today.isAfter(now)
            ? today
            : DateTime(now.year, now.month, now.day + 1, hour, minute);
      case UnreadReminderCadence.weekly:
        final DateTime selectedDay =
            DateTime(now.year, now.month, now.day, hour, minute);
        final int daysUntilSelected = (weekday - now.weekday) % 7;
        if (daysUntilSelected == 0 && selectedDay.isAfter(now)) {
          return selectedDay;
        }
        final int offset =
            daysUntilSelected == 0 ? DateTime.daysPerWeek : daysUntilSelected;
        return DateTime(
          now.year,
          now.month,
          now.day + offset,
          hour,
          minute,
        );
    }
  }

  int _defaultHour(UnreadReminderCadence cadence) {
    switch (cadence) {
      case UnreadReminderCadence.off:
        return 20;
      case UnreadReminderCadence.dailyEvening:
        return 20;
      case UnreadReminderCadence.weekly:
        return 20;
    }
  }

  int _defaultMinute(UnreadReminderCadence cadence) {
    switch (cadence) {
      case UnreadReminderCadence.off:
      case UnreadReminderCadence.dailyEvening:
      case UnreadReminderCadence.weekly:
        return 0;
    }
  }

  String _repeatMode(UnreadReminderCadence cadence) {
    switch (cadence) {
      case UnreadReminderCadence.off:
        return 'none';
      case UnreadReminderCadence.dailyEvening:
        return 'daily';
      case UnreadReminderCadence.weekly:
        return 'weekly';
    }
  }

  int _normalizeWeekday(int? weekday) {
    if (weekday == null ||
        weekday < DateTime.monday ||
        weekday > DateTime.sunday) {
      return DateTime.saturday;
    }
    return weekday;
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
