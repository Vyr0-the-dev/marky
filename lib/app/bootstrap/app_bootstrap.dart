import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/errors/crash_rate_service.dart';
import 'package:marky/core/ai/domain/models/embedding_document.dart';
import 'package:marky/core/database/isar_service.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/core/scraping/metadata_scraper_service.dart';
import 'package:marky/core/scraping/services/favicon_cache_service.dart';
import 'package:marky/core/scraping/services/image_cache_service.dart';
import 'package:marky/core/scraping/source_parser_registry.dart';
import 'package:marky/features/bookmarks/data/repositories/bookmark_item_repository_impl.dart';
import 'package:marky/features/capture/domain/services/duplicate_detection_service.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:marky/features/reminders/domain/services/reminder_scheduler_service.dart';
import 'package:marky/features/vault/domain/services/vault_security_service.dart';
import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/automation_rule.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/crash_log.dart';
import 'package:marky/shared/models/note.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:marky/shared/models/tag.dart';
import 'package:marky/shared/models/vault_config.dart';

/// Stores a pending deep-link route when the app is launched from a
/// killed state via a notification tap. Cleared after first use.
String? _pendingNotificationRoute;

/// Returns and clears any pending notification route set during bootstrap.
String? consumePendingNotificationRoute() {
  final String? route = _pendingNotificationRoute;
  _pendingNotificationRoute = null;
  return route;
}

/// Bootstraps the application before calling [runApp].
///
/// Locks orientation to portrait, ensures the Flutter binding is
/// initialized, and opens the Isar database. Additional async init
/// (settings, notifications, etc.) can be added here later without
/// changing [main.dart].
///
/// [isarDirectory] overrides the default app documents directory for
/// Isar. Useful in tests to bypass path_provider on non-mobile platforms.
Future<void> bootstrap({
  required void Function() run,
  String? isarDirectory,
  bool skipNotifications = false,
}) async {
  final Logger logger = Logger();

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Isar database with all collection schemas.
  try {
    await IsarService.instance.open(
      schemas: <CollectionSchema<dynamic>>[
        AppSettingsSchema,
        AutomationRuleSchema,
        BookmarkItemSchema,
        TagSchema,
        BookmarkCollectionSchema,
        NoteSchema,
        ReminderSchema,
        VaultConfigSchema,
        EmbeddingDocumentSchema,
        CrashLogSchema,
      ],
      directory: isarDirectory,
    );
    logger.i('Database initialized');

    // Wire crash-rate observability to Isar for cross-session persistence.
    CrashRateService.instance.setIsar(IsarService.instance.isar!);
    await CrashRateService.instance.loadPersistedData();
  } on Object catch (e, stackTrace) {
    logger.e('Database initialization failed', error: e, stackTrace: stackTrace);
    // Re-throw fatal errors so the crash is visible in debug builds.
    rethrow;
  }

  // Initialize domain services that depend on the database.
  final Isar isar = IsarService.instance.isar!;
  final BookmarkItemRepositoryImpl repository =
      BookmarkItemRepositoryImpl(isar: isar);

  DuplicateDetectionService.initialize(
    repository: repository,
    normalizationService: UrlNormalizationService.instance,
  );
  logger.i('DuplicateDetectionService initialized');

  MetadataScraperService.initialize(
    registry: SourceParserRegistry.instance,
    repository: repository,
  );
  logger.i('MetadataScraperService initialized');

  ImageCacheService.initialize(
    repository: repository,
  );
  logger.i('ImageCacheService initialized');

  FaviconCacheService.initialize(
    repository: repository,
  );
  logger.i('FaviconCacheService initialized');

  VaultSecurityService.initialize();
  logger.i('VaultSecurityService initialized');

  if (!skipNotifications) {
    // Initialize notification system.
    final NotificationService notificationService = NotificationServiceImpl.instance;
    try {
      await notificationService.initialize();
      logger.i('NotificationService initialized');
    } on Object catch (e, stackTrace) {
      logger.e('NotificationService initialization failed', error: e, stackTrace: stackTrace);
      // Non-fatal: app can still function without notifications.
    }

    // Reschedule pending reminders after boot (notifications are lost on reboot).
    final ReminderRepositoryImpl reminderRepository = ReminderRepositoryImpl(isar: isar);
    final ReminderSchedulerService reminderScheduler = ReminderSchedulerService(
      reminderRepository: reminderRepository,
      notificationService: notificationService,
    );
    try {
      await reminderScheduler.rescheduleAllPending();
    } on Object catch (e, stackTrace) {
      logger.e('Failed to reschedule pending reminders', error: e, stackTrace: stackTrace);
      // Non-fatal: individual reminders will be rescheduled when accessed.
    }

    // Check if app was launched from a notification (killed state).
    try {
      final NotificationAppLaunchDetails? launchDetails =
          await notificationService.getLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final String? payload = launchDetails!.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          const String prefix = 'bookmark_detail:';
          if (payload.startsWith(prefix)) {
            final String idStr = payload.substring(prefix.length);
            final int? id = int.tryParse(idStr);
            if (id != null) {
              _pendingNotificationRoute = '/detail/$id';
              logger.i(
                'App launched from notification — pending route: $_pendingNotificationRoute',
              );
            }
          }
        }
      }
    } on Object catch (e, stackTrace) {
      logger.w('Failed to check notification launch details',
          error: e, stackTrace: stackTrace);
    }
  }

  run();
}
