import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/routing/routes.dart';
import 'package:marky/core/database/database_providers.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/reminders/data/isar_reminder_repository.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/features/reminders/domain/unread_reminder_scheduler.dart';

final Provider<ReminderRepository> reminderRepositoryProvider =
    Provider<ReminderRepository>((Ref ref) {
  return IsarReminderRepository(ref.watch(markyIsarProvider));
});

final Provider<ReminderScheduler> reminderSchedulerProvider =
    Provider<ReminderScheduler>((Ref ref) {
  final ReminderRepository repository = ref.watch(reminderRepositoryProvider);
  return ReminderScheduler(
    reminderRepository: repository,
    notificationService: ref.watch(notificationServiceProvider),
  );
});

final Provider<UnreadReminderScheduler> unreadReminderSchedulerProvider =
    Provider<UnreadReminderScheduler>((Ref ref) {
  return UnreadReminderScheduler(
    bookmarkRepository: ref.watch(bookmarkRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
    payload: Routes.homeUnread,
  );
});

/// Reactive list of reminders for one bookmark — used by the detail
/// screen.
final AutoDisposeStreamProviderFamily<List<Reminder>, int>
    remindersForBookmarkProvider =
    StreamProvider.autoDispose.family<List<Reminder>, int>((Ref ref, int id) {
  return ref.watch(reminderRepositoryProvider).watchByBookmarkId(id);
});

final AutoDisposeFutureProvider<List<Reminder>> activeRemindersProvider =
    FutureProvider.autoDispose<List<Reminder>>((Ref ref) async {
  final List<Reminder> reminders =
      await ref.watch(reminderRepositoryProvider).getAllActive();
  reminders.sort(
    (Reminder a, Reminder b) => a.effectiveFireAt.compareTo(b.effectiveFireAt),
  );
  return reminders;
});
