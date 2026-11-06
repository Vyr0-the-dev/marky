import 'package:marky/features/reminders/domain/reminder.dart';

/// Persistence + query boundary for [Reminder].
///
/// The repository owns Isar reads/writes only — it does **not**
/// schedule OS notifications. Scheduling is the responsibility of
/// the reminder use-case in `feature/reminders/domain/services/`
/// (which lives in Faz 9 — Reminder feature). That keeps the data
/// layer free of `flutter_local_notifications` imports and lets us
/// swap notification engines without touching storage.
abstract interface class ReminderRepository {
  Future<Reminder> save(Reminder reminder);
  Future<Reminder?> getById(int id);

  /// All reminders for a single bookmark, ordered by [Reminder.effectiveFireAt]
  /// ascending (next-up first). Cancelled reminders are still
  /// returned — the detail screen shows them greyed out so users
  /// can audit history.
  Future<List<Reminder>> getByBookmarkId(int bookmarkId);

  /// Reminders that should fire between now and [now + window],
  /// excluding cancelled / fired. Used by the dashboard widget and
  /// the optional re-engagement nudges.
  Future<List<Reminder>> getUpcoming({
    required DateTime now,
    required Duration window,
  });

  /// All active (pending + snoozed) reminders, regardless of
  /// bookmark. Used by `rescheduleAllPending` after a device reboot
  /// or app update wipes the OS notification queue.
  Future<List<Reminder>> getAllActive();

  Future<bool> delete(int id);

  /// Hard-deletes every reminder belonging to [bookmarkId]. Used
  /// when the parent bookmark is deleted; returns the count removed
  /// so callers can also cancel the matching OS notifications.
  Future<int> deleteByBookmarkId(int bookmarkId);

  // ─── Status transitions ────────────────────────────────────────

  /// Marks [id] as fired and stamps [Reminder.firedAt]. Returns the
  /// updated row, or null if the id has been deleted concurrently.
  Future<Reminder?> markFired(int id, {DateTime? firedAt});

  /// Snoozes the reminder until [until]. Sets [Reminder.status] to
  /// `snoozed` and [Reminder.snoozedUntil].
  Future<Reminder?> markSnoozed(int id, {required DateTime until});

  /// Cancels — keeps the row for the audit trail but flips status.
  Future<Reminder?> markCancelled(int id);

  // ─── Streams ────────────────────────────────────────────────────

  Stream<List<Reminder>> watchByBookmarkId(int bookmarkId);
  Stream<Reminder?> watchById(int id);
}
