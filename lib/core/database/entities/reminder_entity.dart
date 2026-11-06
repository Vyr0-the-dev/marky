import 'package:isar/isar.dart';

import 'package:marky/core/database/enums/reminder_repeat_mode.dart';
import 'package:marky/core/database/enums/reminder_status.dart';

part 'reminder_entity.g.dart';

/// A scheduled re-engagement nudge attached to a [BookmarkEntity].
///
/// Differences from the legacy `Reminder`:
/// - `repeatMode` becomes a typed [ReminderRepeatMode] enum.
/// - `status` becomes a typed [ReminderStatus] enum (with `fired`
///   replacing the loose string `"completed"` so the dashboard can
///   distinguish "user hit Done" from "OS delivered the notification").
/// - `notificationId` is now an `int?` because
///   `flutter_local_notifications` deals in 32-bit signed integers,
///   not opaque strings.
/// - Dropped `repeatRule` / `completedAt` — the four built-in repeat
///   modes cover the brief, and `firedAt` (renamed from
///   `completedAt`) keeps the meaning honest.
@Collection(accessor: 'reminders')
class ReminderEntity {
  ReminderEntity({
    required this.bookmarkId,
    required this.title,
    this.body,
    required this.scheduledAt,
    required this.timezone,
    this.repeatMode = ReminderRepeatMode.none,
    this.notificationId,
    this.status = ReminderStatus.pending,
    required this.createdAt,
    this.firedAt,
    this.snoozedUntil,
  });

  Id id = Isar.autoIncrement;

  /// Bookmark this reminder belongs to. Indexed so the detail screen
  /// can pull all reminders for a given bookmark in one query.
  @Index()
  int bookmarkId;

  String title;
  String? body;

  /// Absolute fire time. Indexed so the "upcoming reminders" widget
  /// (Library + dashboard) can scan a forward window cheaply.
  @Index()
  DateTime scheduledAt;

  /// IANA zone (e.g. `Europe/Istanbul`). Resolved via
  /// `TimezoneBootstrap` at write time so the schedule survives
  /// device-side timezone changes (DST, travel).
  String timezone;

  @Enumerated(EnumType.name)
  ReminderRepeatMode repeatMode;

  /// Native notification id assigned by the scheduler. Kept so we
  /// can cancel/reschedule the underlying OS notification when the
  /// user edits or completes the reminder.
  int? notificationId;

  @Enumerated(EnumType.name)
  ReminderStatus status;

  DateTime createdAt;

  /// Set when [status] transitions to [ReminderStatus.fired]. Not
  /// when the user dismisses it — that just flips status without
  /// touching this field, so the dashboard can compute "fired but
  /// never actioned" rates.
  DateTime? firedAt;

  /// When the reminder should re-surface after a snooze. Only
  /// meaningful when [status] is [ReminderStatus.snoozed].
  DateTime? snoozedUntil;
}
