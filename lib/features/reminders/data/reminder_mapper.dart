import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/reminder_entity.dart';
import 'package:marky/features/reminders/domain/reminder.dart';

abstract final class ReminderMapper {
  static Reminder toDomain(ReminderEntity e) => Reminder(
        id: e.id == Isar.autoIncrement ? null : e.id,
        bookmarkId: e.bookmarkId,
        title: e.title,
        body: e.body,
        scheduledAt: e.scheduledAt,
        timezone: e.timezone,
        repeatMode: e.repeatMode,
        notificationId: e.notificationId,
        status: e.status,
        createdAt: e.createdAt,
        firedAt: e.firedAt,
        snoozedUntil: e.snoozedUntil,
      );

  static ReminderEntity toEntity(Reminder r) {
    final ReminderEntity entity = ReminderEntity(
      bookmarkId: r.bookmarkId,
      title: r.title,
      body: r.body,
      scheduledAt: r.scheduledAt,
      timezone: r.timezone,
      repeatMode: r.repeatMode,
      notificationId: r.notificationId,
      status: r.status,
      createdAt: r.createdAt,
      firedAt: r.firedAt,
      snoozedUntil: r.snoozedUntil,
    );
    if (r.id != null) entity.id = r.id!;
    return entity;
  }
}
