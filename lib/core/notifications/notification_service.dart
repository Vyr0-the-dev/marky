import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

abstract interface class NotificationService {
  Future<void> initialize();

  Future<bool> requestPermission();

  Future<void> showInstantSaveNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isError = false,
  });

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    String repeatMode = 'none',
  });

  Future<void> cancelNotification(int id);

  Future<void> cancelAllNotifications();

  Future<NotificationAppLaunchDetails?> getLaunchDetails();

  Future<bool> canScheduleExactNotifications();
}

class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl._();

  static final NotificationServiceImpl instance = NotificationServiceImpl._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;
  bool _initialized = false;
  void Function(String payload)? payloadHandler;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    final Future<void>? initializing = _initializing;
    if (initializing != null) {
      await initializing;
      return;
    }
    final Future<void> future = _initializePlugin();
    _initializing = future;
    try {
      await future;
      _initialized = true;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _initializePlugin() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@drawable/ic_stat_marky',
    );
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
  }

  @override
  Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool? androidGranted =
        await android?.requestNotificationsPermission();
    final IOSFlutterLocalNotificationsPlugin? ios =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final bool? iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return androidGranted ?? iosGranted ?? true;
  }

  @override
  Future<void> showInstantSaveNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isError = false,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          isError ? 'marky_errors' : 'marky_saves',
          isError ? 'Marky errors' : 'Marky saves',
          enableVibration: false,
        ),
      ),
      payload: payload,
    );
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
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'marky_reminders',
          'Marky reminders',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: repeatMode == 'daily'
          ? DateTimeComponents.time
          : repeatMode == 'weekly'
              ? DateTimeComponents.dayOfWeekAndTime
              : null,
    );
  }

  @override
  Future<void> cancelNotification(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelAllNotifications() => _plugin.cancelAll();

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    try {
      return await _plugin.getNotificationAppLaunchDetails();
    } on Object {
      return null;
    }
  }

  @override
  Future<bool> canScheduleExactNotifications() async {
    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await android?.canScheduleExactNotifications() ?? true;
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload?.trim();
    if (payload == null || payload.isEmpty) return;
    payloadHandler?.call(payload);
  }
}
