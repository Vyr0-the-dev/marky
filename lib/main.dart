import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/marky_app.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/settings/app_settings_repository.dart';
import 'package:marky/core/database/database_providers.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/core/time/timezone_bootstrap.dart';
import 'package:marky/features/bookmarks/data/isar_bookmark_repository.dart';
import 'package:marky/features/reminders/data/isar_reminder_repository.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/features/reminders/domain/unread_reminder_scheduler.dart';
import 'package:marky/features/share_intent/presentation/share_overlay_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> shareOverlayMain() => runShareOverlayApp();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final SharedPreferencesAppSettingsRepository settingsRepository =
      SharedPreferencesAppSettingsRepository(prefs);
  await settingsRepository.load();

  final ({Isar isar, List<Override> overrides}) databaseBootstrap =
      await markyDatabaseBootstrap();

  runApp(
    ProviderScope(
      overrides: <Override>[
        ...databaseBootstrap.overrides,
        ...appSettingsBootstrapOverrides(settingsRepository),
      ],
      child: const MarkyApp(),
    ),
  );

  unawaited(_finishPostLaunchStartup(
    databaseBootstrap.isar,
    settingsRepository.current,
  ));
}

Future<void> _finishPostLaunchStartup(
  Isar isar,
  AppSettings settings,
) async {
  await ensureTimezoneInitialized();
  await NotificationServiceImpl.instance.initialize();
  await _rescheduleReminderSchedules(isar, settings);
}

Future<void> _rescheduleReminderSchedules(
  Isar isar,
  AppSettings settings,
) async {
  await _rescheduleActiveBookmarkReminders(isar);
  await _syncUnreadReminderSchedule(isar, settings);
}

Future<void> _rescheduleActiveBookmarkReminders(Isar isar) async {
  try {
    final ReminderScheduler scheduler = ReminderScheduler(
      reminderRepository: IsarReminderRepository(isar),
      notificationService: NotificationServiceImpl.instance,
    );
    await scheduler.rescheduleAllActive();
  } on Object {
    return;
  }
}

Future<void> _syncUnreadReminderSchedule(
  Isar isar,
  AppSettings settings,
) async {
  try {
    final UnreadReminderScheduler unreadScheduler = UnreadReminderScheduler(
      bookmarkRepository: IsarBookmarkRepository(isar),
      notificationService: NotificationServiceImpl.instance,
      payload: Routes.homeUnread,
    );
    await unreadScheduler.sync(
      settings.unreadReminderCadence,
      weekday: settings.unreadReminderWeekday,
      hour: settings.unreadReminderHour,
      minute: settings.unreadReminderMinute,
    );
  } on Object {
    return;
  }
}
