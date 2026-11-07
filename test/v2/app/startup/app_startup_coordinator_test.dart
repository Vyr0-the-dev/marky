import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/startup/app_startup_coordinator.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/features/reminders/domain/unread_reminder_scheduler.dart';

import '../../../fakes/fake_notification_service.dart';

void main() {
  group('DefaultAppStartupCoordinator', () {
    late _ConfigurableFakeNotificationService notificationService;
    late _FakeReminderRepository reminderRepository;
    late _FakeBookmarkRepository bookmarkRepository;
    late _FakeScrapingOrchestrator scrapingOrchestrator;
    late ReminderScheduler reminderScheduler;
    late UnreadReminderScheduler unreadReminderScheduler;
    late int timezoneInitCalls;
    late DefaultAppStartupCoordinator coordinator;

    setUp(() {
      timezoneInitCalls = 0;
      notificationService = _ConfigurableFakeNotificationService();
      reminderRepository = _FakeReminderRepository();
      bookmarkRepository = _FakeBookmarkRepository(unreadCount: 3);
      scrapingOrchestrator = _FakeScrapingOrchestrator();
      reminderScheduler = ReminderScheduler(
        reminderRepository: reminderRepository,
        notificationService: notificationService,
        now: () => DateTime.utc(2026, 3, 1, 10),
        timezoneName: () => 'UTC',
      );
      unreadReminderScheduler = UnreadReminderScheduler(
        bookmarkRepository: bookmarkRepository,
        notificationService: notificationService,
        payload: Routes.homeUnread,
        now: () => DateTime.utc(2026, 3, 1, 10),
        timezoneName: () => 'UTC',
      );
      coordinator = DefaultAppStartupCoordinator(
        notificationService: notificationService,
        reminderScheduler: reminderScheduler,
        unreadReminderScheduler: unreadReminderScheduler,
        scrapingOrchestrator: scrapingOrchestrator,
        initializeTimezone: () async {
          timezoneInitCalls += 1;
        },
      );
    });

    test(
      'runPostLaunchStartup initializes timezone, notifications, active reminders, and unread schedule',
      () async {
        reminderRepository.activeReminders.add(
          Reminder(
            id: 7,
            bookmarkId: 42,
            title: 'Read article',
            scheduledAt: DateTime.utc(2026, 3, 2, 9),
            timezone: 'UTC',
            createdAt: DateTime.utc(2026, 3, 1, 8),
          ),
        );

        await coordinator.runPostLaunchStartup(
          const AppSettings.defaults().copyWith(
            unreadReminderCadence: UnreadReminderCadence.dailyEvening,
            unreadReminderHour: 21,
            unreadReminderMinute: 15,
          ),
        );

        expect(timezoneInitCalls, 1);
        expect(notificationService.initializeCalls, 1);
        expect(notificationService.scheduledIds, contains(7));
        expect(
          notificationService.scheduledIds,
          contains(UnreadReminderScheduler.notificationId),
        );
      },
    );

    test(
      'registerNotificationPayloadHandler wires and clears handler on NotificationService',
      () {
        String? received;
        coordinator.registerNotificationPayloadHandler((String payload) {
          received = payload;
        });
        expect(notificationService.payloadHandler, isNotNull);
        notificationService.payloadHandler!('bookmark_detail:9');
        expect(received, 'bookmark_detail:9');

        coordinator.registerNotificationPayloadHandler(null);
        expect(notificationService.payloadHandler, isNull);
      },
    );

    test(
      'consumeInitialNotificationPayload returns trimmed payload only when notification launched app',
      () async {
        notificationService.launchDetails = const NotificationAppLaunchDetails(
          true,
          notificationResponse: NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            payload: '  bookmark_detail:12  ',
          ),
        );

        final String? payload =
            await coordinator.consumeInitialNotificationPayload();
        expect(payload, 'bookmark_detail:12');

        notificationService.launchDetails = const NotificationAppLaunchDetails(
          false,
        );
        expect(await coordinator.consumeInitialNotificationPayload(), isNull);
      },
    );

    test(
      'enrichPendingBookmarks delegates to ScrapingOrchestrator and swallows errors',
      () async {
        await coordinator.enrichPendingBookmarks();
        expect(scrapingOrchestrator.enrichIncompleteCalls, 1);

        scrapingOrchestrator.shouldThrow = true;
        await coordinator.enrichPendingBookmarks();
        expect(scrapingOrchestrator.enrichIncompleteCalls, 2);
      },
    );
  });
}

class _ConfigurableFakeNotificationService extends FakeNotificationService {
  int initializeCalls = 0;
  NotificationAppLaunchDetails? launchDetails;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    return launchDetails;
  }
}

class _FakeScrapingOrchestrator implements ScrapingOrchestrator {
  int enrichIncompleteCalls = 0;
  bool shouldThrow = false;

  @override
  Future<void> enrich(int bookmarkId) async {}

  @override
  void cancel(int bookmarkId) {}

  @override
  Future<void> enrichIncomplete({int limit = 3}) async {
    enrichIncompleteCalls += 1;
    if (shouldThrow) {
      throw StateError('enrich error');
    }
  }
}

class _FakeReminderRepository implements ReminderRepository {
  final List<Reminder> activeReminders = <Reminder>[];

  @override
  Future<List<Reminder>> getAllActive() async => activeReminders;

  @override
  Future<Reminder> save(Reminder reminder) async => reminder;
  @override
  Future<Reminder?> getById(int id) async => null;
  @override
  Future<bool> delete(int id) async => false;
  @override
  Future<int> deleteByBookmarkId(int bookmarkId) async => 0;
  @override
  Future<List<Reminder>> getByBookmarkId(int bookmarkId) async => <Reminder>[];
  @override
  Future<Reminder?> markFired(int id, {DateTime? firedAt}) async => null;
  @override
  Future<Reminder?> markCancelled(int id) async => null;
  @override
  Future<Reminder?> markSnoozed(int id, {required DateTime until}) async =>
      null;
  @override
  Future<List<Reminder>> getUpcoming({
    required DateTime now,
    required Duration window,
  }) async =>
      <Reminder>[];
  @override
  Stream<Reminder?> watchById(int id) => const Stream<Reminder?>.empty();
  @override
  Stream<List<Reminder>> watchByBookmarkId(int bookmarkId) =>
      const Stream<List<Reminder>>.empty();
}

class _FakeBookmarkRepository implements BookmarkRepository {
  _FakeBookmarkRepository({required this.unreadCount});

  final int unreadCount;

  @override
  Future<int> count(BookmarkFeedQuery query) async => unreadCount;

  @override
  Future<Bookmark> save(Bookmark bookmark) async => bookmark;
  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) async => bookmarks;
  @override
  Future<Bookmark?> getById(int id) async => null;
  @override
  Future<List<Bookmark>> getByIds(List<int> ids) async => <Bookmark>[];
  @override
  Future<bool> delete(int id) async => false;
  @override
  Future<int> deleteAll(List<int> ids) async => 0;
  @override
  Future<Bookmark?> findByUrlHash(String urlHash) async => null;
  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) async => null;
  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) async =>
      null;
  @override
  Future<int> countAll() async => unreadCount;
  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => <Bookmark>[];
  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      const Stream<List<Bookmark>>.empty();
  @override
  Stream<Bookmark?> watchById(int id) => const Stream<Bookmark?>.empty();
  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async =>
      <Bookmark>[];
}
