import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';
import 'package:marky/features/detail/presentation/detail_action_controller.dart';
import 'package:marky/features/notes/domain/note.dart';
import 'package:marky/features/notes/domain/note_repository.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/features/reminders/domain/unread_reminder_scheduler.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

import '../../../../fakes/fake_notification_service.dart';

void main() {
  group('DetailActionController', () {
    late _FakeBookmarkRepository bookmarkRepo;
    late _FakeTagRepository tagRepo;
    late _FakeCollectionRepository collectionRepo;
    late _FakeNoteRepository noteRepo;
    late _FakeScrapingOrchestrator scrapingOrchestrator;
    late _FakeReminderRepository reminderRepo;
    late FakeNotificationService notificationService;
    late ReminderScheduler reminderScheduler;
    late UnreadReminderScheduler unreadReminderScheduler;
    late AppSettings currentSettings;
    late DetailActionController controller;
    late Bookmark sampleBookmark;

    setUp(() {
      final DateTime now = DateTime.utc(2026, 3, 1, 12);
      sampleBookmark = Bookmark(
        id: 10,
        originalUrl: 'https://example.com/post',
        canonicalUrl: 'https://example.com/post',
        normalizedHost: 'example.com',
        title: 'Initial Title',
        description: 'Initial Description',
        inlineNotes: 'Legacy note content',
        createdAt: now,
        updatedAt: now,
      );
      bookmarkRepo = _FakeBookmarkRepository()..items[10] = sampleBookmark;
      tagRepo = _FakeTagRepository();
      collectionRepo = _FakeCollectionRepository();
      noteRepo = _FakeNoteRepository();
      scrapingOrchestrator = _FakeScrapingOrchestrator();
      reminderRepo = _FakeReminderRepository();
      notificationService = FakeNotificationService();
      reminderScheduler = ReminderScheduler(
        reminderRepository: reminderRepo,
        notificationService: notificationService,
        now: () => now,
        timezoneName: () => 'UTC',
      );
      unreadReminderScheduler = UnreadReminderScheduler(
        bookmarkRepository: bookmarkRepo,
        notificationService: notificationService,
        payload: Routes.homeUnread,
        now: () => now,
        timezoneName: () => 'UTC',
      );
      currentSettings = const AppSettings.defaults();
      controller = DetailActionController(
        bookmarkRepository: bookmarkRepo,
        tagRepository: tagRepo,
        collectionRepository: collectionRepo,
        noteRepository: noteRepo,
        scrapingOrchestrator: scrapingOrchestrator,
        reminderScheduler: reminderScheduler,
        unreadReminderScheduler: unreadReminderScheduler,
        readSettings: () => currentSettings,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('toggles favorite, pin, and archive flags via BookmarkRepository',
        () async {
      await controller.toggleFavorite(sampleBookmark);
      expect(bookmarkRepo.items[10]!.isFavorite, isTrue);
      expect(controller.state.status, DetailActionStatus.success);

      await controller.togglePin(bookmarkRepo.items[10]!);
      expect(bookmarkRepo.items[10]!.isPinned, isTrue);

      await controller.toggleArchive(bookmarkRepo.items[10]!);
      expect(bookmarkRepo.items[10]!.isArchived, isTrue);
    });

    test(
      'toggleRead flips isRead and syncs UnreadReminderScheduler when cadence is active',
      () async {
        currentSettings = const AppSettings.defaults().copyWith(
          unreadReminderCadence: UnreadReminderCadence.dailyEvening,
        );
        bookmarkRepo.unreadCount = 2;

        await controller.toggleRead(sampleBookmark);
        expect(bookmarkRepo.items[10]!.isRead, isTrue);
        expect(
          notificationService.scheduledIds,
          contains(UnreadReminderScheduler.notificationId),
        );
      },
    );

    test(
      'updateTitleAndDescription saves edits and emits bookmarkUpdated feedback',
      () async {
        await controller.updateTitleAndDescription(
          sampleBookmark,
          title: 'New Title',
          description: 'New Description',
        );

        expect(bookmarkRepo.items[10]!.title, 'New Title');
        expect(bookmarkRepo.items[10]!.description, 'New Description');
        expect(controller.state.status, DetailActionStatus.success);
        expect(
          controller.state.feedback,
          DetailActionFeedback.bookmarkUpdated,
        );
      },
    );

    test(
      'refetchMetadata transitions through metadataRefetching to metadataRefreshed',
      () async {
        final List<DetailActionState> states = <DetailActionState>[];
        final void Function() removeListener = controller.addListener(
          states.add,
          fireImmediately: false,
        );
        addTearDown(removeListener);

        await controller.refetchMetadata(10);

        expect(scrapingOrchestrator.enrichedIds, <int>[10]);
        expect(states.length, 2);
        expect(states[0].status, DetailActionStatus.loading);
        expect(states[0].feedback, DetailActionFeedback.metadataRefetching);
        expect(states[1].status, DetailActionStatus.success);
        expect(states[1].feedback, DetailActionFeedback.metadataRefreshed);
      },
    );

    test(
      'deleteBookmark cancels scraping, deletes bookmark, and emits bookmarkDeleted',
      () async {
        await controller.deleteBookmark(10);

        expect(scrapingOrchestrator.cancelledIds, <int>[10]);
        expect(bookmarkRepo.items.containsKey(10), isFalse);
        expect(
          controller.state.feedback,
          DetailActionFeedback.bookmarkDeleted,
        );
      },
    );

    test('manages tags and updates tag usage counts', () async {
      final DateTime now = DateTime.utc(2026, 3, 1);
      tagRepo.tags.addAll(<Tag>[
        Tag(id: 1, name: 'Flutter', slug: 'flutter', createdAt: now, updatedAt: now),
        Tag(id: 2, name: 'Dart', slug: 'dart', createdAt: now, updatedAt: now),
      ]);

      await controller.addTag(sampleBookmark, 1);
      final Bookmark withTag = bookmarkRepo.items[10]!;
      expect(withTag.tagIds, <int>[1]);
      expect(tagRepo.incrementedIds, <int>[1]);

      final List<Tag> available = await controller.loadAvailableTags(withTag);
      expect(available.map((Tag t) => t.id), <int?>[2]);

      await controller.removeTag(withTag, 1);
      expect(bookmarkRepo.items[10]!.tagIds, isEmpty);
      expect(tagRepo.decrementedIds, <int>[1]);
    });

    test('manages collections and updates collection item counts', () async {
      final DateTime now = DateTime.utc(2026, 3, 1);
      collectionRepo.collections.addAll(<BookmarkCollection>[
        BookmarkCollection(
          id: 5,
          title: 'Reading',
          slug: 'reading',
          createdAt: now,
          updatedAt: now,
        ),
      ]);

      await controller.addCollection(sampleBookmark, 5);
      final Bookmark withCol = bookmarkRepo.items[10]!;
      expect(withCol.collectionIds, <int>[5]);
      expect(collectionRepo.incrementedIds, <int>[5]);

      expect(await controller.loadAvailableCollections(withCol), isEmpty);

      await controller.removeCollection(withCol, 5);
      expect(bookmarkRepo.items[10]!.collectionIds, isEmpty);
      expect(collectionRepo.decrementedIds, <int>[5]);
    });

    test('manages notes and converts legacy inline note', () async {
      await controller.addNote(10, 'First note');
      expect(noteRepo.notes.length, 1);
      expect(noteRepo.notes.first.content, 'First note');

      final Note created = noteRepo.notes.first;
      await controller.editNote(created, '  Updated note  ');
      expect(noteRepo.notes.first.content, 'Updated note');

      await controller.convertLegacyNote(sampleBookmark);
      expect(noteRepo.notes.length, 2);
      expect(bookmarkRepo.items[10]!.inlineNotes, '');

      await controller.deleteNote(created.id!);
      expect(noteRepo.notes.where((Note n) => n.id == created.id), isEmpty);
    });

    test('cancelReminder delegates to ReminderScheduler', () async {
      final DateTime now = DateTime.utc(2026, 3, 1);
      reminderRepo.items[99] = Reminder(
        id: 99,
        bookmarkId: 10,
        title: 'Check later',
        notificationId: 99,
        scheduledAt: now.add(const Duration(hours: 2)),
        timezone: 'UTC',
        createdAt: now,
      );

      await controller.cancelReminder(99);
      expect(notificationService.cancelledIds, contains(99));
      expect(reminderRepo.cancelledIds, contains(99));
    });
  });
}

class _FakeBookmarkRepository implements BookmarkRepository {
  final Map<int, Bookmark> items = <int, Bookmark>{};
  int unreadCount = 0;

  @override
  Future<Bookmark> save(Bookmark bookmark) async {
    final int id = bookmark.id ?? (items.length + 1);
    final Bookmark saved = bookmark.copyWith(id: id);
    items[id] = saved;
    return saved;
  }

  @override
  Future<bool> delete(int id) async => items.remove(id) != null;

  @override
  Future<int> count(BookmarkFeedQuery query) async => unreadCount;

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) async => bookmarks;
  @override
  Future<Bookmark?> getById(int id) async => items[id];
  @override
  Future<List<Bookmark>> getByIds(List<int> ids) async => <Bookmark>[];
  @override
  Future<int> deleteAll(List<int> ids) async => 0;
  @override
  Future<Bookmark?> findByUrlHash(String urlHash) async => null;
  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) async => null;
  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) async =>
      null;
  @override
  Future<int> countAll() async => items.length;
  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => <Bookmark>[];
  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      const Stream<List<Bookmark>>.empty();
  @override
  Stream<Bookmark?> watchById(int id) => const Stream<Bookmark?>.empty();
  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async =>
      <Bookmark>[];
}

class _FakeTagRepository implements TagRepository {
  final List<Tag> tags = <Tag>[];
  final List<int> incrementedIds = <int>[];
  final List<int> decrementedIds = <int>[];

  @override
  Future<List<Tag>> getAll() async => tags;

  @override
  Future<void> incrementUsageCount(int tagId) async {
    incrementedIds.add(tagId);
  }

  @override
  Future<void> decrementUsageCount(int tagId) async {
    decrementedIds.add(tagId);
  }

  @override
  Future<Tag> save(Tag tag) async => tag;
  @override
  Future<Tag> createFromName(String name, {int? colorArgb, String? icon}) =>
      throw UnimplementedError();
  @override
  Future<Tag?> getById(int id) async => null;
  @override
  Future<Tag?> findBySlug(String slug) async => null;
  @override
  Future<List<Tag>> getByIds(List<int> ids) async => <Tag>[];
  @override
  Future<bool> delete(int id) async => false;
  @override
  Future<int> recomputeUsageCount(int tagId) async => 0;
  @override
  Future<Map<int, int>> recomputeAllUsageCounts() async => <int, int>{};
  @override
  Stream<List<Tag>> watchAll() => const Stream<List<Tag>>.empty();
  @override
  Stream<Tag?> watchById(int id) => const Stream<Tag?>.empty();
}

class _FakeCollectionRepository implements BookmarkCollectionRepository {
  final List<BookmarkCollection> collections = <BookmarkCollection>[];
  final List<int> incrementedIds = <int>[];
  final List<int> decrementedIds = <int>[];

  @override
  Future<List<BookmarkCollection>> getAll({
    bool includeArchived = false,
  }) async =>
      collections;

  @override
  Future<void> incrementItemCount(int collectionId) async {
    incrementedIds.add(collectionId);
  }

  @override
  Future<void> decrementItemCount(int collectionId) async {
    decrementedIds.add(collectionId);
  }

  @override
  Future<BookmarkCollection> save(BookmarkCollection collection) async =>
      collection;
  @override
  Future<BookmarkCollection> createFromTitle(
    String title, {
    int? accentColorArgb,
    String? icon,
  }) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection> createSmartFromRule(
    String title,
    SmartCollectionRule rule, {
    int? accentColorArgb,
    String? icon,
  }) =>
      throw UnimplementedError();
  @override
  Future<BookmarkCollection?> getById(int id) async => null;
  @override
  Future<BookmarkCollection?> findBySlug(String slug) async => null;
  @override
  Future<List<BookmarkCollection>> getByIds(List<int> ids) async =>
      <BookmarkCollection>[];
  @override
  Future<bool> delete(int id) async => false;
  @override
  Future<int> recomputeItemCount(int collectionId) async => 0;
  @override
  Future<Map<int, int>> recomputeAllItemCounts() async => <int, int>{};
  @override
  Stream<List<BookmarkCollection>> watchAll({bool includeArchived = false}) =>
      const Stream<List<BookmarkCollection>>.empty();
  @override
  Stream<BookmarkCollection?> watchById(int id) =>
      const Stream<BookmarkCollection?>.empty();
}

class _FakeNoteRepository implements NoteRepository {
  final List<Note> notes = <Note>[];

  @override
  Future<Note> createForBookmark(int bookmarkId, String content) async {
    final DateTime now = DateTime.utc(2026, 3, 1);
    final Note note = Note(
      id: notes.length + 1,
      bookmarkId: bookmarkId,
      content: content.trim(),
      createdAt: now,
      updatedAt: now,
    );
    notes.add(note);
    return note;
  }

  @override
  Future<Note> save(Note note) async {
    final int idx = notes.indexWhere((Note n) => n.id == note.id);
    if (idx >= 0) {
      notes[idx] = note;
    } else {
      notes.add(note);
    }
    return note;
  }

  @override
  Future<bool> delete(int id) async {
    final int before = notes.length;
    notes.removeWhere((Note n) => n.id == id);
    return notes.length < before;
  }

  @override
  Future<Note?> getById(int id) async => null;
  @override
  Future<int> deleteByBookmarkId(int bookmarkId) async => 0;
  @override
  Future<List<Note>> getByBookmarkId(int bookmarkId) async => notes;
  @override
  Future<int> count() async => notes.length;
  @override
  Stream<List<Note>> watchByBookmarkId(int bookmarkId) =>
      const Stream<List<Note>>.empty();
}

class _FakeScrapingOrchestrator implements ScrapingOrchestrator {
  final List<int> enrichedIds = <int>[];
  final List<int> cancelledIds = <int>[];

  @override
  Future<void> enrich(int bookmarkId) async {
    enrichedIds.add(bookmarkId);
  }

  @override
  void cancel(int bookmarkId) {
    cancelledIds.add(bookmarkId);
  }

  @override
  Future<void> enrichIncomplete({int limit = 3}) async {}
}

class _FakeReminderRepository implements ReminderRepository {
  final Map<int, Reminder> items = <int, Reminder>{};
  final List<int> cancelledIds = <int>[];

  @override
  Future<Reminder?> getById(int id) async => items[id];

  @override
  Future<Reminder?> markCancelled(int id) async {
    cancelledIds.add(id);
    return items[id];
  }

  @override
  Future<Reminder> save(Reminder reminder) async => reminder;
  @override
  Future<bool> delete(int id) async => false;
  @override
  Future<int> deleteByBookmarkId(int bookmarkId) async => 0;
  @override
  Future<List<Reminder>> getByBookmarkId(int bookmarkId) async => <Reminder>[];
  @override
  Future<List<Reminder>> getAllActive() async => <Reminder>[];
  @override
  Future<List<Reminder>> getDueBefore(DateTime cutoff) async => <Reminder>[];
  @override
  Future<Reminder?> markFired(int id, {DateTime? firedAt}) async => null;
  @override
  Future<Reminder?> snooze(int id, DateTime until) async => null;
  @override
  Future<Reminder?> markSnoozed(int id, {required DateTime until}) async =>
      null;
  @override
  Future<List<Reminder>> getUpcoming({
    required DateTime now,
    int? limit,
  }) async =>
      <Reminder>[];
  @override
  Future<int> countActive() async => 0;
  @override
  Stream<Reminder?> watchById(int id) => const Stream<Reminder?>.empty();
  @override
  Stream<List<Reminder>> watchByBookmarkId(int bookmarkId) =>
      const Stream<List<Reminder>>.empty();
  @override
  Stream<List<Reminder>> watchAllActive() =>
      const Stream<List<Reminder>>.empty();
}
