import 'package:flutter/foundation.dart';

import 'package:marky/core/database/enums/reminder_repeat_mode.dart';
import 'package:marky/core/database/enums/reminder_status.dart';

/// Immutable domain model for a scheduled reminder.
@immutable
class Reminder {
  const Reminder({
    this.id,
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

  final int? id;
  final int bookmarkId;
  final String title;
  final String? body;
  final DateTime scheduledAt;

  /// IANA zone (`Europe/Istanbul`). Resolved at write time via
  /// `TimezoneBootstrap`.
  final String timezone;

  final ReminderRepeatMode repeatMode;

  /// Native notification id. `null` until [ReminderRepository.save]
  /// (or a snooze) registers the schedule with the OS layer.
  final int? notificationId;

  final ReminderStatus status;
  final DateTime createdAt;
  final DateTime? firedAt;
  final DateTime? snoozedUntil;

  /// True when this reminder is still expected to fire — scope of
  /// "active" excludes already-fired and cancelled, but **includes**
  /// snoozed (those will fire again).
  bool get isActive =>
      status == ReminderStatus.pending || status == ReminderStatus.snoozed;

  /// The next wall-clock time the user expects a notification.
  /// Snoozed reminders prefer [snoozedUntil] over [scheduledAt].
  DateTime get effectiveFireAt =>
      status == ReminderStatus.snoozed && snoozedUntil != null
          ? snoozedUntil!
          : scheduledAt;

  Reminder copyWith({
    int? id,
    int? bookmarkId,
    String? title,
    String? body,
    DateTime? scheduledAt,
    String? timezone,
    ReminderRepeatMode? repeatMode,
    int? notificationId,
    ReminderStatus? status,
    DateTime? createdAt,
    DateTime? firedAt,
    DateTime? snoozedUntil,
  }) {
    return Reminder(
      id: id ?? this.id,
      bookmarkId: bookmarkId ?? this.bookmarkId,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      timezone: timezone ?? this.timezone,
      repeatMode: repeatMode ?? this.repeatMode,
      notificationId: notificationId ?? this.notificationId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      firedAt: firedAt ?? this.firedAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder &&
        other.id == id &&
        other.bookmarkId == bookmarkId &&
        other.title == title &&
        other.body == body &&
        other.scheduledAt == scheduledAt &&
        other.timezone == timezone &&
        other.repeatMode == repeatMode &&
        other.notificationId == notificationId &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.firedAt == firedAt &&
        other.snoozedUntil == snoozedUntil;
  }

  @override
  int get hashCode => Object.hash(
        id,
        bookmarkId,
        title,
        body,
        scheduledAt,
        timezone,
        repeatMode,
        notificationId,
        status,
        createdAt,
        firedAt,
        snoozedUntil,
      );

  @override
  String toString() =>
      'Reminder(id: $id, bookmark: $bookmarkId, at: $scheduledAt, '
      'status: $status)';
}
