import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/import_export/domain/models/export_data.dart';
import 'package:marky/features/import_export/domain/use_cases/export_bookmarks_use_case.dart';
import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/note.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:marky/shared/models/tag.dart';

// ─── Fake Repositories ──────────────────────────────────────────────────────

class _FakeBookmarkItemRepository implements BookmarkItemRepository {
  final List<BookmarkItem> _items = <BookmarkItem>[];

  void add(BookmarkItem item) => _items.add(item);

  @override
  Future<BookmarkItem?> getById(Id id) async =>
      _items.cast<BookmarkItem?>().firstWhere((b) => b?.id == id, orElse: () => null);

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async => List<BookmarkItem>.from(_items);

  @override
  Future<Id> insert(BookmarkItem entity) async {
    _items.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async => entity.id;

  @override
  Future<void> delete(Id id) async => _items.removeWhere((b) => b.id == id);

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(String externalContentId) async => null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId, {int? offset, int? limit}) async => <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(dynamic query, {int? offset, int? limit}) async => <BookmarkItem>[];
}

class _FakeTagRepository implements TagRepository {
  final List<Tag> _items = <Tag>[];

  void add(Tag item) => _items.add(item);

  @override
  Future<Tag?> getById(Id id) async =>
      _items.cast<Tag?>().firstWhere((t) => t?.id == id, orElse: () => null);

  @override
  Future<List<Tag>> getAll() async => List<Tag>.from(_items);

  @override
  Future<Id> insert(Tag entity) async {
    _items.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(Tag entity) async => entity.id;

  @override
  Future<void> delete(Id id) async => _items.removeWhere((t) => t.id == id);

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<Tag?> getBySlug(String slug) async => null;
}

class _FakeCollectionRepository implements CollectionRepository {
  final List<BookmarkCollection> _items = <BookmarkCollection>[];

  void add(BookmarkCollection item) => _items.add(item);

  @override
  Future<BookmarkCollection?> getById(Id id) async =>
      _items.cast<BookmarkCollection?>().firstWhere((c) => c?.id == id, orElse: () => null);

  @override
  Future<List<BookmarkCollection>> getAll() async => List<BookmarkCollection>.from(_items);

  @override
  Future<Id> insert(BookmarkCollection entity) async {
    _items.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkCollection entity) async => entity.id;

  @override
  Future<void> delete(Id id) async => _items.removeWhere((c) => c.id == id);

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<BookmarkCollection?> getBySlug(String slug) async => null;
}

class _FakeNoteRepository implements NoteRepository {
  final List<Note> _items = <Note>[];

  void add(Note item) => _items.add(item);

  @override
  Future<Note?> getById(Id id) async =>
      _items.cast<Note?>().firstWhere((n) => n?.id == id, orElse: () => null);

  @override
  Future<List<Note>> getAll() async => List<Note>.from(_items);

  @override
  Future<Id> insert(Note entity) async {
    _items.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(Note entity) async => entity.id;

  @override
  Future<void> delete(Id id) async => _items.removeWhere((n) => n.id == id);

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<List<Note>> getByBookmarkId(Id bookmarkId) async => <Note>[];
}

class _FakeReminderRepository implements ReminderRepository {
  final List<Reminder> _items = <Reminder>[];

  void add(Reminder item) => _items.add(item);

  @override
  Future<Reminder?> getById(Id id) async =>
      _items.cast<Reminder?>().firstWhere((r) => r?.id == id, orElse: () => null);

  @override
  Future<List<Reminder>> getAll() async => List<Reminder>.from(_items);

  @override
  Future<Id> insert(Reminder entity) async {
    _items.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(Reminder entity) async => entity.id;

  @override
  Future<void> delete(Id id) async => _items.removeWhere((r) => r.id == id);

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<List<Reminder>> getByBookmarkId(Id bookmarkId) async => <Reminder>[];

  @override
  Future<List<Reminder>> getPending() async => <Reminder>[];
}

class _FakeSettingsRepository implements AppSettingsRepository {
  AppSettings? settings;

  @override
  Future<AppSettings?> getSettings() async => settings;

  @override
  Future<void> saveSettings(AppSettings value) async {
    settings = value;
  }

  @override
  Future<void> deleteSettings() async {
    settings = null;
  }
}

// ─── Test Helpers ───────────────────────────────────────────────────────────

BookmarkItem _makeBookmark({required String url}) {
  final now = DateTime.now();
  return BookmarkItem(
    originalUrl: url,
    createdAt: now,
    updatedAt: now,
  );
}

Tag _makeTag({required String name}) {
  final now = DateTime.now();
  return Tag(
    name: name,
    slug: name.toLowerCase().replaceAll(' ', '-'),
    createdAt: now,
    updatedAt: now,
  );
}

BookmarkCollection _makeCollection({required String title}) {
  final now = DateTime.now();
  return BookmarkCollection(
    title: title,
    slug: title.toLowerCase().replaceAll(' ', '-'),
    createdAt: now,
    updatedAt: now,
  );
}

Note _makeNote({required int bookmarkId, required String content}) {
  final now = DateTime.now();
  return Note(
    bookmarkId: bookmarkId,
    content: content,
    createdAt: now,
    updatedAt: now,
  );
}

Reminder _makeReminder({required int bookmarkId, required String title}) {
  final now = DateTime.now();
  return Reminder(
    bookmarkId: bookmarkId,
    title: title,
    scheduledAt: now.add(const Duration(days: 1)),
    timezone: 'UTC',
    createdAt: now,
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('ExportBookmarksUseCase', () {
    late _FakeBookmarkItemRepository bookmarkRepo;
    late _FakeTagRepository tagRepo;
    late _FakeCollectionRepository collectionRepo;
    late _FakeNoteRepository noteRepo;
    late _FakeReminderRepository reminderRepo;
    late _FakeSettingsRepository settingsRepo;
    late ExportBookmarksUseCase useCase;

    setUp(() {
      bookmarkRepo = _FakeBookmarkItemRepository();
      tagRepo = _FakeTagRepository();
      collectionRepo = _FakeCollectionRepository();
      noteRepo = _FakeNoteRepository();
      reminderRepo = _FakeReminderRepository();
      settingsRepo = _FakeSettingsRepository();

      useCase = ExportBookmarksUseCase(
        bookmarkRepository: bookmarkRepo,
        tagRepository: tagRepo,
        collectionRepository: collectionRepo,
        noteRepository: noteRepo,
        reminderRepository: reminderRepo,
        settingsRepository: settingsRepo,
      );
    });

    test('aggregates all repo data into ExportData', () async {
      bookmarkRepo.add(_makeBookmark(url: 'https://example.com'));
      tagRepo.add(_makeTag(name: 'flutter'));
      collectionRepo.add(_makeCollection(title: 'Reading List'));
      noteRepo.add(_makeNote(bookmarkId: 1, content: 'Great article'));
      reminderRepo.add(_makeReminder(bookmarkId: 1, title: 'Read later'));
      settingsRepo.settings = AppSettings(themeMode: 'dark');

      final ExportData result = await useCase.execute();

      expect(result.bookmarks, hasLength(1));
      expect(result.tags, hasLength(1));
      expect(result.collections, hasLength(1));
      expect(result.notes, hasLength(1));
      expect(result.reminders, hasLength(1));
      expect(result.settings, isNotNull);
      expect(result.settings!.themeMode, 'dark');
    });

    test('includes settings when available', () async {
      settingsRepo.settings = AppSettings(
        themeMode: 'light',
        accentColor: 'purple',
        oledPureBlackEnabled: true,
      );

      final ExportData result = await useCase.execute();

      expect(result.settings, isNotNull);
      expect(result.settings!.themeMode, 'light');
      expect(result.settings!.accentColor, 'purple');
      expect(result.settings!.oledPureBlackEnabled, isTrue);
    });

    test('settings is null when none saved', () async {
      final ExportData result = await useCase.execute();

      expect(result.settings, isNull);
    });

    test('empty repos produce empty lists', () async {
      final ExportData result = await useCase.execute();

      expect(result.bookmarks, isEmpty);
      expect(result.tags, isEmpty);
      expect(result.collections, isEmpty);
      expect(result.notes, isEmpty);
      expect(result.reminders, isEmpty);
    });

    test('returns correct schema version', () async {
      final ExportData result = await useCase.execute();

      expect(result.schemaVersion, '1.0.0');
    });

    test('returns UTC timestamp', () async {
      final before = DateTime.now().toUtc();
      final ExportData result = await useCase.execute();
      final after = DateTime.now().toUtc();

      expect(result.exportTimestamp.isUtc, isTrue);
      expect(
        result.exportTimestamp.isAfter(before) || result.exportTimestamp.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        result.exportTimestamp.isBefore(after) || result.exportTimestamp.isAtSameMomentAs(after),
        isTrue,
      );
    });

    test('multiple items from each repo are all included', () async {
      bookmarkRepo.add(_makeBookmark(url: 'https://a.com'));
      bookmarkRepo.add(_makeBookmark(url: 'https://b.com'));
      tagRepo.add(_makeTag(name: 'dart'));
      tagRepo.add(_makeTag(name: 'flutter'));
      tagRepo.add(_makeTag(name: 'riverpod'));

      final ExportData result = await useCase.execute();

      expect(result.bookmarks, hasLength(2));
      expect(result.tags, hasLength(3));
    });
  });
}
