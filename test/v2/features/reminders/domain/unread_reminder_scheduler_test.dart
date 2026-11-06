import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/features/reminders/domain/unread_reminder_scheduler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../../fakes/fake_notification_service.dart';

void main() {
  late _FakeBookmarkRepository repository;
  late FakeNotificationService notificationService;
  late UnreadReminderScheduler scheduler;
  late DateTime now;

  setUp(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    repository = _FakeBookmarkRepository();
    notificationService = FakeNotificationService();
    now = DateTime(2026, 5, 4, 12);
    scheduler = UnreadReminderScheduler(
      bookmarkRepository: repository,
      notificationService: notificationService,
      payload: '/home/unread',
      now: () => now,
      timezoneName: () => 'Europe/Istanbul',
    );
  });

  test('daily schedule creates a repeating unread notification', () async {
    repository.countResult = 3;

    final int unreadCount = await scheduler.schedule(
      UnreadReminderCadence.dailyEvening,
    );

    expect(unreadCount, 3);
    expect(notificationService.cancelledIds, <int>[
      UnreadReminderScheduler.notificationId,
    ]);
    expect(notificationService.scheduledIds, <int>[
      UnreadReminderScheduler.notificationId,
    ]);
    final scheduled =
        notificationService.scheduled[UnreadReminderScheduler.notificationId]!;
    expect(scheduled.payload, '/home/unread');
    expect(scheduled.repeatMode, 'daily');
    expect(scheduled.scheduledDate.hour, 20);
  });

  test('weekly schedule uses selected day and time repeat', () async {
    repository.countResult = 1;

    await scheduler.schedule(
      UnreadReminderCadence.weekly,
      weekday: DateTime.friday,
      hour: 18,
      minute: 30,
    );

    final scheduled =
        notificationService.scheduled[UnreadReminderScheduler.notificationId]!;
    expect(scheduled.repeatMode, 'weekly');
    expect(scheduled.scheduledDate.weekday, DateTime.friday);
    expect(scheduled.scheduledDate.hour, 18);
    expect(scheduled.scheduledDate.minute, 30);
  });

  test('custom time is used when provided', () async {
    repository.countResult = 2;

    await scheduler.schedule(
      UnreadReminderCadence.dailyEvening,
      hour: 23,
      minute: 45,
    );

    final scheduled =
        notificationService.scheduled[UnreadReminderScheduler.notificationId]!;
    expect(scheduled.scheduledDate.hour, 23);
    expect(scheduled.scheduledDate.minute, 45);
  });

  test('zero unread cancels existing schedule', () async {
    repository.countResult = 0;
    notificationService.permissionGranted = false;

    final int unreadCount = await scheduler.schedule(
      UnreadReminderCadence.dailyEvening,
    );

    expect(unreadCount, 0);
    expect(notificationService.cancelledIds, <int>[
      UnreadReminderScheduler.notificationId,
    ]);
    expect(notificationService.scheduledIds, isEmpty);
  });

  test('off sync cancels without requesting permission', () async {
    notificationService.permissionGranted = false;

    await scheduler.sync(UnreadReminderCadence.off);

    expect(notificationService.cancelledIds, <int>[
      UnreadReminderScheduler.notificationId,
    ]);
    expect(notificationService.scheduledIds, isEmpty);
  });

  test('permission denial prevents scheduling', () async {
    repository.countResult = 2;
    notificationService.permissionGranted = false;

    await expectLater(
      () => scheduler.schedule(UnreadReminderCadence.dailyEvening),
      throwsA(isA<ReminderNotificationPermissionDeniedException>()),
    );

    expect(notificationService.scheduledIds, isEmpty);
  });
}

class _FakeBookmarkRepository implements BookmarkRepository {
  int countResult = 0;

  @override
  Future<int> count(BookmarkFeedQuery query) async => countResult;

  @override
  Future<int> countAll() async => countResult;

  @override
  Future<bool> delete(int id) async => false;

  @override
  Future<int> deleteAll(List<int> ids) async => 0;

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => <Bookmark>[];

  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) async =>
      null;

  @override
  Future<Bookmark?> findByUrlHash(String urlHash) async => null;

  @override
  Future<Bookmark?> getById(int id) async => null;

  @override
  Future<List<Bookmark>> getByIds(List<int> ids) async => <Bookmark>[];

  @override
  Future<Bookmark> save(Bookmark bookmark) async => bookmark;

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) async => bookmarks;

  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async =>
      <Bookmark>[];

  @override
  Stream<Bookmark?> watchById(int id) => Stream<Bookmark?>.value(null);

  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      Stream<List<Bookmark>>.value(<Bookmark>[]);
}
