import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/import_export/domain/models/export_data.dart';
import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/note.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:marky/shared/models/tag.dart';

/// Use case that aggregates all user data into an [ExportData] snapshot.
///
/// This is a pure-Dart domain use case with no Flutter dependencies.
/// It injects all six repositories and collects their contents in parallel
/// where possible.
class ExportBookmarksUseCase {
  ExportBookmarksUseCase({
    required BookmarkItemRepository bookmarkRepository,
    required TagRepository tagRepository,
    required CollectionRepository collectionRepository,
    required NoteRepository noteRepository,
    required ReminderRepository reminderRepository,
    required AppSettingsRepository settingsRepository,
  })  : _bookmarkRepository = bookmarkRepository,
        _tagRepository = tagRepository,
        _collectionRepository = collectionRepository,
        _noteRepository = noteRepository,
        _reminderRepository = reminderRepository,
        _settingsRepository = settingsRepository;

  final BookmarkItemRepository _bookmarkRepository;
  final TagRepository _tagRepository;
  final CollectionRepository _collectionRepository;
  final NoteRepository _noteRepository;
  final ReminderRepository _reminderRepository;
  final AppSettingsRepository _settingsRepository;

  /// Gathers all user data from the injected repositories.
  ///
  /// Returns an [ExportData] containing every bookmark, tag, collection,
  /// note, reminder, and settings. The [schemaVersion] is hard-coded to
  /// the current export format version.
  Future<ExportData> execute() async {
    final results = await Future.wait([
      _bookmarkRepository.getAll(),
      _tagRepository.getAll(),
      _collectionRepository.getAll(),
      _noteRepository.getAll(),
      _reminderRepository.getAll(),
    ]);

    final settings = await _settingsRepository.getSettings();

    return ExportData(
      bookmarks: results[0] as List<BookmarkItem>,
      tags: results[1] as List<Tag>,
      collections: results[2] as List<BookmarkCollection>,
      notes: results[3] as List<Note>,
      reminders: results[4] as List<Reminder>,
      settings: settings,
      schemaVersion: '1.0.0',
      exportTimestamp: DateTime.now().toUtc(),
    );
  }
}
