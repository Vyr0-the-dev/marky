import 'package:isar/isar.dart';
import 'package:marky/core/database/base_repository.dart';
import 'package:marky/shared/models/reminder.dart';

/// Domain contract for [Reminder] persistence and querying.
///
/// Implementations provide CRUD via [BaseRepository] plus reminder-specific
/// lookups for bookmark relationship traversal and pending scheduling.
abstract class ReminderRepository implements BaseRepository<Reminder> {
  /// Returns all reminders attached to the bookmark with [bookmarkId].
  Future<List<Reminder>> getByBookmarkId(Id bookmarkId);

  /// Returns reminders with status 'pending', ordered by [Reminder.scheduledAt].
  Future<List<Reminder>> getPending();
}
