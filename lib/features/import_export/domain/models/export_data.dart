import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/note.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:marky/shared/models/tag.dart';

/// Immutable snapshot of all user data for export.
///
/// Holds every entity the user has created so that a single JSON file
/// can fully restore the application's state (minus local file assets).
class ExportData {
  const ExportData({
    required this.bookmarks,
    required this.tags,
    required this.collections,
    required this.notes,
    required this.reminders,
    this.settings,
    required this.schemaVersion,
    required this.exportTimestamp,
  });

  final List<BookmarkItem> bookmarks;
  final List<Tag> tags;
  final List<BookmarkCollection> collections;
  final List<Note> notes;
  final List<Reminder> reminders;
  final AppSettings? settings;
  final String schemaVersion;
  final DateTime exportTimestamp;
}
