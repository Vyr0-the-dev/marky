import 'package:isar/isar.dart';

part 'reminder.g.dart';

/// A reminder attached to a bookmark for scheduled re-engagement.
@collection
class Reminder {
  Reminder({
    required this.bookmarkId,
    required this.title,
    this.body,
    required this.scheduledAt,
    required this.timezone,
    this.repeatMode = 'none',
    this.repeatRule,
    this.notificationId,
    this.status = 'pending',
    required this.createdAt,
    this.completedAt,
    this.snoozedUntil,
  });

  /// Auto-increment primary key.
  Id id = Isar.autoIncrement;

  /// Reference to the parent bookmark this reminder belongs to.
  @Index()
  int bookmarkId;

  /// Short title of the reminder.
  String title;

  /// Optional body text with additional context.
  String? body;

  /// When the reminder should fire.
  @Index()
  DateTime scheduledAt;

  /// IANA timezone name (e.g. 'Europe/Istanbul').
  String timezone;

  /// Repeat mode: 'none', 'daily', 'weekly', 'monthly'.
  String repeatMode;

  /// JSON-encoded custom repeat rule for complex schedules.
  String? repeatRule;

  /// Platform-specific notification identifier.
  String? notificationId;

  /// Status: 'pending', 'completed', 'snoozed', 'cancelled'.
  String status;

  /// When the reminder was created.
  DateTime createdAt;

  /// When the reminder was marked as completed.
  DateTime? completedAt;

  /// If snoozed, when the reminder should reappear.
  DateTime? snoozedUntil;
}
