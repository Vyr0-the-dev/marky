import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:marky/app/routing/app_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Abstract interface for local notification operations.
abstract interface class NotificationService {
  /// Initializes the notification plugin, timezone database, and channels.
  Future<void> initialize();

  /// Schedules a local notification at the given [scheduledDate].
  ///
  /// [repeatMode] may be `'none'`, `'daily'`, or `'weekly'`.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    String repeatMode = 'none',
  });

  /// Cancels a single scheduled notification by [id].
  Future<void> cancelNotification(int id);

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications();

  /// Returns details about whether the app was launched from a notification.
  Future<NotificationAppLaunchDetails?> getLaunchDetails();

  /// Returns whether exact alarm scheduling is permitted (Android 12+).
  Future<bool> canScheduleExactNotifications();
}

/// Concrete implementation of [NotificationService] using
/// `flutter_local_notifications`.
class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl._();

  static final NotificationServiceImpl _instance = NotificationServiceImpl._();

  /// Returns the singleton instance.
  static NotificationServiceImpl get instance => _instance;

  static final Logger _logger = Logger();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'marky_reminders';
  static const String _channelName = 'Marky Reminders';
  static const String _channelDescription =
      'Reminder notifications for your saved bookmarks';

  @override
  Future<void> initialize() async {
    try {
      // Initialize timezone database.
      tz_data.initializeTimeZones();
      final String timeZoneName = DateTime.now().timeZoneName;
      try {
        final tz.Location location = tz.getLocation(timeZoneName);
        tz.setLocalLocation(location);
      } catch (e) {
        _logger.w(
          'Could not resolve local timezone "$timeZoneName", falling back to UTC',
        );
        tz.setLocalLocation(tz.UTC);
      }

      // Android initialization settings.
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS/macOS initialization settings.
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings();

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create Android notification channel.
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(channel);

      // Request exact alarm permission on Android 12+ (API 31).
      await androidPlugin?.requestExactAlarmsPermission();

      _logger.i('NotificationService initialized');
    } catch (e, st) {
      _logger.e('NotificationService init failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    String repeatMode = 'none',
  }) async {
    if (id <= 0) {
      throw ArgumentError.value(id, 'id', 'Notification ID must be positive');
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final DateTimeComponents? matchDateTimeComponents = switch (repeatMode) {
      'daily' => DateTimeComponents.time,
      'weekly' => DateTimeComponents.dayOfWeekAndTime,
      _ => null,
    };

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
      payload: payload,
    );

    _logger.i(
      'Scheduled notification $id at $scheduledDate (mode: $repeatMode)',
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    _logger.i('Cancelled notification $id');
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    _logger.i('Cancelled all notifications');
  }

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    return _plugin.getNotificationAppLaunchDetails();
  }

  @override
  Future<bool> canScheduleExactNotifications() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool? canSchedule = await androidPlugin?.canScheduleExactNotifications();
    return canSchedule ?? true;
  }
}

/// Top-level callback invoked when the user taps a notification.
///
/// Expects payload in the format `bookmark_detail:<id>`.
@pragma('vm:entry-point')
void _onNotificationTap(NotificationResponse response) {
  final String? payload = response.payload;
  if (payload == null || payload.isEmpty) {
    return;
  }

  const String prefix = 'bookmark_detail:';
  if (payload.startsWith(prefix)) {
    final String idStr = payload.substring(prefix.length);
    final int? id = int.tryParse(idStr);
    if (id == null) {
      NotificationServiceImpl._logger.w(
        'Malformed bookmark_detail payload: "$payload"',
      );
      return;
    }

    final NavigatorState? navigator = AppRouter.rootNavigatorKey.currentState;
    if (navigator == null) {
      NotificationServiceImpl._logger.w(
        'No navigator available for notification tap',
      );
      return;
    }

    final BuildContext context = navigator.context;
    GoRouter.of(context).go('/detail/$id');
    NotificationServiceImpl._logger.i(
      'Navigated to bookmark detail from notification tap: $id',
    );
  } else {
    NotificationServiceImpl._logger.w(
      'Unknown notification payload format: "$payload"',
    );
  }
}
