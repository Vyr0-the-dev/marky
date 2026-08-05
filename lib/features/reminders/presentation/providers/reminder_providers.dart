import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/features/reminders/domain/services/reminder_scheduler_service.dart';
import 'package:marky/shared/models/reminder.dart';

// ─── Simple future providers ───────────────────────────────────────────

/// Loads all pending reminders ordered by scheduled time.
final FutureProvider<List<Reminder>> pendingRemindersProvider =
    FutureProvider<List<Reminder>>((Ref ref) async {
  final ReminderRepository repository = ref.watch(reminderRepositoryProvider);
  return repository.getPending();
});

/// Loads all reminders attached to the bookmark with [bookmarkId].
final FutureProviderFamily<List<Reminder>, int> remindersByBookmarkProvider =
    FutureProvider.family<List<Reminder>, int>(
  (Ref ref, int bookmarkId) async {
    final ReminderRepository repository = ref.watch(reminderRepositoryProvider);
    return repository.getByBookmarkId(bookmarkId);
  },
);

// ─── Service provider ──────────────────────────────────────────────────

/// Provider for [ReminderSchedulerService], wired to live dependencies.
final Provider<ReminderSchedulerService> reminderSchedulerServiceProvider =
    Provider<ReminderSchedulerService>((Ref ref) {
  final ReminderRepository repository = ref.watch(reminderRepositoryProvider);
  final NotificationService notificationService =
      ref.watch(notificationServiceProvider);
  return ReminderSchedulerService(
    reminderRepository: repository,
    notificationService: notificationService,
  );
});

// ─── State notifier ────────────────────────────────────────────────────

/// Notifier that manages reminders with CRUD + scheduling operations.
class ReminderManagerNotifier
    extends StateNotifier<AsyncValue<List<Reminder>>> {
  /// Creates the notifier and immediately loads pending reminders.
  ReminderManagerNotifier({
    required ReminderSchedulerService service,
    required ReminderRepository repository,
  })  : _service = service,
        _repository = repository,
        super(const AsyncValue<List<Reminder>>.loading()) {
    unawaited(load());
  }

  final ReminderSchedulerService _service;
  final ReminderRepository _repository;
  final Logger _logger = Logger();

  /// Reloads pending reminders from the repository.
  Future<void> load() async {
    state = const AsyncValue<List<Reminder>>.loading();
    try {
      final List<Reminder> reminders = await _repository.getPending();
      state = AsyncValue<List<Reminder>>.data(reminders);
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to load reminders', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Reminder>>.error(e, stackTrace);
    }
  }

  /// Creates a reminder and refreshes the list.
  Future<Reminder> create({
    required int bookmarkId,
    required String title,
    String? body,
    required DateTime scheduledAt,
    String repeatMode = 'none',
    String? timezone,
  }) async {
    try {
      final Reminder reminder = await _service.createReminder(
        bookmarkId: bookmarkId,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        repeatMode: repeatMode,
        timezone: timezone,
      );
      await load();
      return reminder;
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to create reminder', error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Reminder>>.error(e, stackTrace);
      rethrow;
    }
  }

  /// Cancels a reminder by [reminderId] and refreshes the list.
  Future<void> cancel(int reminderId) async {
    try {
      await _service.cancelReminder(reminderId);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to cancel reminder $reminderId',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Reminder>>.error(e, stackTrace);
      rethrow;
    }
  }

  /// Completes a reminder by [reminderId] and refreshes the list.
  Future<void> complete(int reminderId) async {
    try {
      await _service.completeReminder(reminderId);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to complete reminder $reminderId',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Reminder>>.error(e, stackTrace);
      rethrow;
    }
  }

  /// Snoozes a reminder by [duration] and refreshes the list.
  Future<void> snooze(int reminderId, Duration duration) async {
    try {
      await _service.snoozeReminder(reminderId, duration);
      await load();
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to snooze reminder $reminderId',
          error: e, stackTrace: stackTrace);
      state = AsyncValue<List<Reminder>>.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Provider for [ReminderManagerNotifier].
final StateNotifierProvider<ReminderManagerNotifier,
    AsyncValue<List<Reminder>>> reminderManagerNotifierProvider =
    StateNotifierProvider<ReminderManagerNotifier, AsyncValue<List<Reminder>>>(
  (Ref ref) => ReminderManagerNotifier(
    service: ref.watch(reminderSchedulerServiceProvider),
    repository: ref.watch(reminderRepositoryProvider),
  ),
);
