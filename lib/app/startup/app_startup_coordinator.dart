import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/core/time/timezone_bootstrap.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/features/reminders/domain/unread_reminder_scheduler.dart';

final Provider<AppStartupCoordinator> appStartupCoordinatorProvider =
    Provider<AppStartupCoordinator>((Ref ref) {
  return DefaultAppStartupCoordinator(
    notificationService: ref.watch(notificationServiceProvider),
    readReminderScheduler: () => ref.read(reminderSchedulerProvider),
    readUnreadReminderScheduler: () =>
        ref.read(unreadReminderSchedulerProvider),
    readScrapingOrchestrator: () => ref.read(scrapingOrchestratorProvider),
  );
});

abstract interface class AppStartupCoordinator {
  Future<void> runPostLaunchStartup(AppSettings settings);

  void registerNotificationPayloadHandler(
    void Function(String payload)? handler,
  );

  Future<String?> consumeInitialNotificationPayload();

  Future<void> enrichPendingBookmarks();
}

class DefaultAppStartupCoordinator implements AppStartupCoordinator {
  DefaultAppStartupCoordinator({
    required NotificationService notificationService,
    ReminderScheduler? reminderScheduler,
    ReminderScheduler Function()? readReminderScheduler,
    UnreadReminderScheduler? unreadReminderScheduler,
    UnreadReminderScheduler Function()? readUnreadReminderScheduler,
    ScrapingOrchestrator? scrapingOrchestrator,
    ScrapingOrchestrator Function()? readScrapingOrchestrator,
    Future<void> Function() initializeTimezone = ensureTimezoneInitialized,
  })  : _notificationService = notificationService,
        _reminderScheduler = reminderScheduler,
        _readReminderScheduler = readReminderScheduler,
        _unreadReminderScheduler = unreadReminderScheduler,
        _readUnreadReminderScheduler = readUnreadReminderScheduler,
        _scrapingOrchestrator = scrapingOrchestrator,
        _readScrapingOrchestrator = readScrapingOrchestrator,
        _initializeTimezone = initializeTimezone;

  final NotificationService _notificationService;
  final ReminderScheduler? _reminderScheduler;
  final ReminderScheduler Function()? _readReminderScheduler;
  final UnreadReminderScheduler? _unreadReminderScheduler;
  final UnreadReminderScheduler Function()? _readUnreadReminderScheduler;
  final ScrapingOrchestrator? _scrapingOrchestrator;
  final ScrapingOrchestrator Function()? _readScrapingOrchestrator;
  final Future<void> Function() _initializeTimezone;

  ReminderScheduler get _resolvedReminderScheduler {
    final ReminderScheduler? direct = _reminderScheduler;
    if (direct != null) return direct;
    final ReminderScheduler Function()? reader = _readReminderScheduler;
    if (reader != null) return reader();
    throw StateError('ReminderScheduler not provided');
  }

  UnreadReminderScheduler get _resolvedUnreadReminderScheduler {
    final UnreadReminderScheduler? direct = _unreadReminderScheduler;
    if (direct != null) return direct;
    final UnreadReminderScheduler Function()? reader =
        _readUnreadReminderScheduler;
    if (reader != null) return reader();
    throw StateError('UnreadReminderScheduler not provided');
  }

  ScrapingOrchestrator get _resolvedScrapingOrchestrator {
    final ScrapingOrchestrator? direct = _scrapingOrchestrator;
    if (direct != null) return direct;
    final ScrapingOrchestrator Function()? reader = _readScrapingOrchestrator;
    if (reader != null) return reader();
    throw StateError('ScrapingOrchestrator not provided');
  }

  @override
  Future<void> runPostLaunchStartup(AppSettings settings) async {
    await _initializeTimezone();
    await _notificationService.initialize();
    try {
      await _resolvedReminderScheduler.rescheduleAllActive();
    } on Object {
      // Best-effort reminder reschedule on startup.
    }
    try {
      await _resolvedUnreadReminderScheduler.sync(
        settings.unreadReminderCadence,
        weekday: settings.unreadReminderWeekday,
        hour: settings.unreadReminderHour,
        minute: settings.unreadReminderMinute,
      );
    } on Object {
      return;
    }
  }

  @override
  void registerNotificationPayloadHandler(
    void Function(String payload)? handler,
  ) {
    _notificationService.setPayloadHandler(handler);
  }

  @override
  Future<String?> consumeInitialNotificationPayload() async {
    try {
      await _notificationService.initialize();
    } on Object {
      return null;
    }
    final NotificationAppLaunchDetails? details =
        await _notificationService.getLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    final String? payload = details?.notificationResponse?.payload?.trim();
    if (payload == null || payload.isEmpty) return null;
    return payload;
  }

  @override
  Future<void> enrichPendingBookmarks() async {
    try {
      await _resolvedScrapingOrchestrator.enrichIncomplete();
    } on Object {
      return;
    }
  }
}
