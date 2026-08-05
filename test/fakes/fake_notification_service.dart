import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// Pure-Dart fake of [NotificationService] that tracks schedule/cancel calls
/// in memory for test verification.
class FakeNotificationService implements NotificationService {
  final List<int> scheduledIds = <int>[];
  final List<int> cancelledIds = <int>[];
  final Map<int, FakeScheduledNotification> scheduled = <int, FakeScheduledNotification>{};

  bool shouldThrowOnSchedule = false;
  bool canScheduleExact = true;
  int? throwOnId;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    String repeatMode = 'none',
  }) async {
    if (shouldThrowOnSchedule && (throwOnId == null || throwOnId == id)) {
      throw Exception('Fake schedule error');
    }
    scheduledIds.add(id);
    scheduled[id] = FakeScheduledNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
      repeatMode: repeatMode,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelledIds.add(id);
    scheduled.remove(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    cancelledIds.addAll(scheduledIds);
    scheduled.clear();
  }

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async => null;

  @override
  Future<bool> canScheduleExactNotifications() async => canScheduleExact;
}

/// Record of a scheduled notification captured by [FakeNotificationService].
class FakeScheduledNotification {
  FakeScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    this.payload,
    required this.repeatMode,
  });

  final int id;
  final String title;
  final String body;
  final tz.TZDateTime scheduledDate;
  final String? payload;
  final String repeatMode;
}
