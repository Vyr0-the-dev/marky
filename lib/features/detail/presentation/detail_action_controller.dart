import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/notes/data/note_providers.dart';
import 'package:marky/features/notes/domain/note.dart';
import 'package:marky/features/notes/domain/note_repository.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/features/reminders/domain/unread_reminder_scheduler.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

enum DetailActionStatus { idle, loading, success, failure }

enum DetailActionFeedback {
  bookmarkUpdated,
  metadataRefetching,
  metadataRefreshed,
  bookmarkDeleted,
}

class DetailActionState {
  const DetailActionState({
    required this.status,
    this.feedback,
    this.errorMessage,
  });

  const DetailActionState.idle()
      : status = DetailActionStatus.idle,
        feedback = null,
        errorMessage = null;

  final DetailActionStatus status;
  final DetailActionFeedback? feedback;
  final String? errorMessage;

  DetailActionState copyWith({
    DetailActionStatus? status,
    DetailActionFeedback? feedback,
    bool clearFeedback = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DetailActionState(
      status: status ?? this.status,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final AutoDisposeStateNotifierProvider<DetailActionController,
        DetailActionState> detailActionControllerProvider =
    StateNotifierProvider.autoDispose<DetailActionController,
        DetailActionState>((Ref ref) {
  return DetailActionController(
    readBookmarkRepository: () => ref.read(bookmarkRepositoryProvider),
    readTagRepository: () => ref.read(tagRepositoryProvider),
    readCollectionRepository: () =>
        ref.read(bookmarkCollectionRepositoryProvider),
    readNoteRepository: () => ref.read(noteRepositoryProvider),
    readScrapingOrchestrator: () => ref.read(scrapingOrchestratorProvider),
    readReminderScheduler: () => ref.read(reminderSchedulerProvider),
    readUnreadReminderScheduler: () =>
        ref.read(unreadReminderSchedulerProvider),
    readSettings: () => ref.read(appSettingsProvider),
  );
});

class DetailActionController extends StateNotifier<DetailActionState> {
  DetailActionController({
    BookmarkRepository? bookmarkRepository,
    BookmarkRepository Function()? readBookmarkRepository,
    TagRepository? tagRepository,
    TagRepository Function()? readTagRepository,
    BookmarkCollectionRepository? collectionRepository,
    BookmarkCollectionRepository Function()? readCollectionRepository,
    NoteRepository? noteRepository,
    NoteRepository Function()? readNoteRepository,
    ScrapingOrchestrator? scrapingOrchestrator,
    ScrapingOrchestrator Function()? readScrapingOrchestrator,
    ReminderScheduler? reminderScheduler,
    ReminderScheduler Function()? readReminderScheduler,
    UnreadReminderScheduler? unreadReminderScheduler,
    UnreadReminderScheduler Function()? readUnreadReminderScheduler,
    required AppSettings Function() readSettings,
  })  : _bookmarkRepository = bookmarkRepository,
        _readBookmarkRepository = readBookmarkRepository,
        _tagRepository = tagRepository,
        _readTagRepository = readTagRepository,
        _collectionRepository = collectionRepository,
        _readCollectionRepository = readCollectionRepository,
        _noteRepository = noteRepository,
        _readNoteRepository = readNoteRepository,
        _scrapingOrchestrator = scrapingOrchestrator,
        _readScrapingOrchestrator = readScrapingOrchestrator,
        _reminderScheduler = reminderScheduler,
        _readReminderScheduler = readReminderScheduler,
        _unreadReminderScheduler = unreadReminderScheduler,
        _readUnreadReminderScheduler = readUnreadReminderScheduler,
        _readSettings = readSettings,
        super(const DetailActionState.idle());

  final BookmarkRepository? _bookmarkRepository;
  final BookmarkRepository Function()? _readBookmarkRepository;
  final TagRepository? _tagRepository;
  final TagRepository Function()? _readTagRepository;
  final BookmarkCollectionRepository? _collectionRepository;
  final BookmarkCollectionRepository Function()? _readCollectionRepository;
  final NoteRepository? _noteRepository;
  final NoteRepository Function()? _readNoteRepository;
  final ScrapingOrchestrator? _scrapingOrchestrator;
  final ScrapingOrchestrator Function()? _readScrapingOrchestrator;
  final ReminderScheduler? _reminderScheduler;
  final ReminderScheduler Function()? _readReminderScheduler;
  final UnreadReminderScheduler? _unreadReminderScheduler;
  final UnreadReminderScheduler Function()? _readUnreadReminderScheduler;
  final AppSettings Function() _readSettings;

  BookmarkRepository get _bookmarks {
    final BookmarkRepository? direct = _bookmarkRepository;
    if (direct != null) return direct;
    final BookmarkRepository Function()? reader = _readBookmarkRepository;
    if (reader != null) return reader();
    throw StateError('BookmarkRepository not provided');
  }

  TagRepository get _tags {
    final TagRepository? direct = _tagRepository;
    if (direct != null) return direct;
    final TagRepository Function()? reader = _readTagRepository;
    if (reader != null) return reader();
    throw StateError('TagRepository not provided');
  }

  BookmarkCollectionRepository get _collections {
    final BookmarkCollectionRepository? direct = _collectionRepository;
    if (direct != null) return direct;
    final BookmarkCollectionRepository Function()? reader =
        _readCollectionRepository;
    if (reader != null) return reader();
    throw StateError('BookmarkCollectionRepository not provided');
  }

  NoteRepository get _notes {
    final NoteRepository? direct = _noteRepository;
    if (direct != null) return direct;
    final NoteRepository Function()? reader = _readNoteRepository;
    if (reader != null) return reader();
    throw StateError('NoteRepository not provided');
  }

  ScrapingOrchestrator get _scraper {
    final ScrapingOrchestrator? direct = _scrapingOrchestrator;
    if (direct != null) return direct;
    final ScrapingOrchestrator Function()? reader = _readScrapingOrchestrator;
    if (reader != null) return reader();
    throw StateError('ScrapingOrchestrator not provided');
  }

  ReminderScheduler get _reminders {
    final ReminderScheduler? direct = _reminderScheduler;
    if (direct != null) return direct;
    final ReminderScheduler Function()? reader = _readReminderScheduler;
    if (reader != null) return reader();
    throw StateError('ReminderScheduler not provided');
  }

  UnreadReminderScheduler get _unreadReminders {
    final UnreadReminderScheduler? direct = _unreadReminderScheduler;
    if (direct != null) return direct;
    final UnreadReminderScheduler Function()? reader =
        _readUnreadReminderScheduler;
    if (reader != null) return reader();
    throw StateError('UnreadReminderScheduler not provided');
  }

  Future<void> toggleFavorite(Bookmark bookmark) {
    return _runGuarded(() async {
      await _bookmarks
          .save(bookmark.copyWith(isFavorite: !bookmark.isFavorite));
    });
  }

  Future<void> togglePin(Bookmark bookmark) {
    return _runGuarded(() async {
      await _bookmarks.save(bookmark.copyWith(isPinned: !bookmark.isPinned));
    });
  }

  Future<void> toggleArchive(Bookmark bookmark) {
    return _runGuarded(() async {
      await _bookmarks
          .save(bookmark.copyWith(isArchived: !bookmark.isArchived));
    });
  }

  Future<void> toggleRead(Bookmark bookmark) {
    return _runGuarded(() async {
      await _bookmarks.save(bookmark.copyWith(isRead: !bookmark.isRead));
      final AppSettings settings = _readSettings();
      final UnreadReminderCadence cadence = settings.unreadReminderCadence;
      if (cadence != UnreadReminderCadence.off) {
        try {
          await _unreadReminders.sync(
            cadence,
            weekday: settings.unreadReminderWeekday,
            hour: settings.unreadReminderHour,
            minute: settings.unreadReminderMinute,
          );
        } on Object {
          return;
        }
      }
    });
  }

  Future<void> updateTitleAndDescription(
    Bookmark bookmark, {
    required String title,
    required String description,
  }) {
    return _runGuarded(
      () async {
        await _bookmarks.save(
          bookmark.copyWith(
            title: title,
            description: description,
          ),
        );
      },
      successFeedback: DetailActionFeedback.bookmarkUpdated,
    );
  }

  Future<void> refetchMetadata(int bookmarkId) {
    return _runGuarded(
      () async {
        await _scraper.enrich(bookmarkId);
      },
      loadingFeedback: DetailActionFeedback.metadataRefetching,
      successFeedback: DetailActionFeedback.metadataRefreshed,
    );
  }

  Future<void> deleteBookmark(int bookmarkId) {
    return _runGuarded(
      () async {
        _scraper.cancel(bookmarkId);
        await _bookmarks.delete(bookmarkId);
      },
      successFeedback: DetailActionFeedback.bookmarkDeleted,
    );
  }

  Future<List<Tag>> loadAvailableTags(Bookmark bookmark) async {
    final List<Tag> allTags = await _tags.getAll();
    final Set<int> current = bookmark.tagIds.toSet();
    return allTags
        .where((Tag t) => t.id != null && !current.contains(t.id))
        .toList();
  }

  Future<void> addTag(Bookmark bookmark, int tagId) {
    if (bookmark.tagIds.contains(tagId)) return Future<void>.value();
    return _runGuarded(() async {
      await _bookmarks.save(
        bookmark.copyWith(tagIds: <int>[...bookmark.tagIds, tagId]),
      );
      await _tags.incrementUsageCount(tagId);
    });
  }

  Future<void> removeTag(Bookmark bookmark, int tagId) {
    return _runGuarded(() async {
      final List<int> updated =
          bookmark.tagIds.where((int id) => id != tagId).toList();
      await _bookmarks.save(bookmark.copyWith(tagIds: updated));
      await _tags.decrementUsageCount(tagId);
    });
  }

  Future<List<BookmarkCollection>> loadAvailableCollections(
    Bookmark bookmark,
  ) async {
    final List<BookmarkCollection> all = await _collections.getAll();
    final Set<int> current = bookmark.collectionIds.toSet();
    return all
        .where(
          (BookmarkCollection c) => c.id != null && !current.contains(c.id),
        )
        .toList();
  }

  Future<void> addCollection(Bookmark bookmark, int collectionId) {
    if (bookmark.collectionIds.contains(collectionId)) {
      return Future<void>.value();
    }
    return _runGuarded(() async {
      await _bookmarks.save(
        bookmark.copyWith(
          collectionIds: <int>[...bookmark.collectionIds, collectionId],
        ),
      );
      await _collections.incrementItemCount(collectionId);
    });
  }

  Future<void> removeCollection(Bookmark bookmark, int collectionId) {
    return _runGuarded(() async {
      final List<int> updated =
          bookmark.collectionIds.where((int id) => id != collectionId).toList();
      await _bookmarks.save(bookmark.copyWith(collectionIds: updated));
      await _collections.decrementItemCount(collectionId);
    });
  }

  Future<void> addNote(int bookmarkId, String content) {
    final String trimmed = content.trim();
    if (trimmed.isEmpty) return Future<void>.value();
    return _runGuarded(() async {
      await _notes.createForBookmark(bookmarkId, content);
    });
  }

  Future<void> editNote(Note note, String newContent) {
    final String trimmed = newContent.trim();
    if (trimmed.isEmpty || trimmed == note.content) {
      return Future<void>.value();
    }
    return _runGuarded(() async {
      await _notes.save(note.copyWith(content: trimmed));
    });
  }

  Future<void> deleteNote(int noteId) {
    return _runGuarded(() async {
      await _notes.delete(noteId);
    });
  }

  Future<void> convertLegacyNote(Bookmark bookmark) {
    final String? legacy = bookmark.inlineNotes?.trim();
    if (legacy == null || legacy.isEmpty || bookmark.id == null) {
      return Future<void>.value();
    }
    return _runGuarded(() async {
      await _notes.createForBookmark(bookmark.id!, legacy);
      await _bookmarks.save(bookmark.copyWith(inlineNotes: ''));
    });
  }

  Future<void> cancelReminder(int reminderId) {
    return _runGuarded(() async {
      await _reminders.cancelReminder(reminderId);
    });
  }

  Future<void> _runGuarded(
    Future<void> Function() action, {
    DetailActionFeedback? loadingFeedback,
    DetailActionFeedback? successFeedback,
  }) async {
    state = DetailActionState(
      status: DetailActionStatus.loading,
      feedback: loadingFeedback,
    );
    try {
      await action();
      if (!mounted) return;
      state = DetailActionState(
        status: DetailActionStatus.success,
        feedback: successFeedback,
      );
    } on Object catch (error) {
      if (!mounted) return;
      state = DetailActionState(
        status: DetailActionStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }
}
