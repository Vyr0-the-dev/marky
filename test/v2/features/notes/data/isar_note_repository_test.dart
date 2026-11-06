@Tags(<String>['integration'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/marky_database.dart';
import 'package:marky/features/notes/data/isar_note_repository.dart';
import 'package:marky/features/notes/domain/note.dart';
import 'package:marky/features/notes/domain/note_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late NoteRepository repo;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('note_repo_test_');
    isar = await MarkyDatabase.open(
      directory: tempDir.path,
      name: 'test_${tempDir.path.hashCode}',
    );
    repo = IsarNoteRepository(isar);
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('createForBookmark', () {
    test('persists with timestamps stamped to now', () async {
      final DateTime before = DateTime.now();
      final Note note = await repo.createForBookmark(42, 'first thought');
      final DateTime after = DateTime.now();

      expect(note.id, isNotNull);
      expect(note.bookmarkId, 42);
      expect(note.content, 'first thought');
      expect(
        note.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        note.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
      // newly created notes are not "edited"
      expect(note.isEdited, isFalse);
    });

    test('trims whitespace from content', () async {
      final Note note = await repo.createForBookmark(1, '   spaced out   ');
      expect(note.content, 'spaced out');
    });

    test('blank content throws ArgumentError', () async {
      expect(
        () async => repo.createForBookmark(1, '   '),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () async => repo.createForBookmark(1, ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('save', () {
    test('updating bumps updatedAt and marks isEdited', () async {
      final Note original = await repo.createForBookmark(1, 'v1');
      // Force separation so updatedAt > createdAt + 100ms (jitter
      // window). 200ms is safely past the threshold without making
      // the test sluggish.
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final Note updated = await repo.save(
        original.copyWith(content: 'v2 with edits'),
      );

      expect(updated.id, original.id);
      expect(updated.content, 'v2 with edits');
      expect(updated.updatedAt.isAfter(original.updatedAt), isTrue);
      expect(updated.isEdited, isTrue);
    });

    test('round-trips through getById', () async {
      final Note saved = await repo.createForBookmark(7, 'round trip');
      final Note? fetched = await repo.getById(saved.id!);

      expect(fetched, isNotNull);
      expect(fetched!.id, saved.id);
      expect(fetched.bookmarkId, 7);
      expect(fetched.content, 'round trip');
    });
  });

  group('getByBookmarkId', () {
    test('returns notes for a single bookmark, newest first', () async {
      final Note a = await repo.createForBookmark(1, 'oldest');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final Note b = await repo.createForBookmark(1, 'middle');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final Note c = await repo.createForBookmark(1, 'newest');

      // unrelated bookmark — must not appear
      await repo.createForBookmark(99, 'other bookmark');

      final List<Note> notes = await repo.getByBookmarkId(1);
      expect(notes.map((Note n) => n.id), <int?>[c.id, b.id, a.id]);
    });

    test('returns empty list for bookmark with no notes', () async {
      final List<Note> notes = await repo.getByBookmarkId(404);
      expect(notes, isEmpty);
    });
  });

  group('delete + deleteByBookmarkId', () {
    test('delete removes a single note and returns true', () async {
      final Note note = await repo.createForBookmark(1, 'doomed');
      final bool removed = await repo.delete(note.id!);

      expect(removed, isTrue);
      expect(await repo.getById(note.id!), isNull);
    });

    test('delete returns false for missing id', () async {
      expect(await repo.delete(999999), isFalse);
    });

    test("deleteByBookmarkId nukes only that bookmark's notes", () async {
      await repo.createForBookmark(1, 'a');
      await repo.createForBookmark(1, 'b');
      await repo.createForBookmark(1, 'c');
      await repo.createForBookmark(2, 'survivor');

      final int removed = await repo.deleteByBookmarkId(1);
      expect(removed, 3);

      expect(await repo.getByBookmarkId(1), isEmpty);
      expect((await repo.getByBookmarkId(2)).length, 1);
    });

    test('deleteByBookmarkId is a no-op for empty bookmark', () async {
      expect(await repo.deleteByBookmarkId(404), 0);
    });
  });

  group('count', () {
    test('counts across all bookmarks', () async {
      expect(await repo.count(), 0);

      await repo.createForBookmark(1, 'x');
      await repo.createForBookmark(2, 'y');
      await repo.createForBookmark(3, 'z');

      expect(await repo.count(), 3);
    });
  });

  group('watchByBookmarkId', () {
    test('emits the current snapshot then deltas', () async {
      // Seed before subscribing so the first emission is non-empty.
      await repo.createForBookmark(1, 'seed');

      final List<List<Note>> emissions = <List<Note>>[];
      final Stream<List<Note>> stream = repo.watchByBookmarkId(1);
      final StreamSubscription<List<Note>> sub = stream.listen(emissions.add);

      // Wait one micro-tick for the initial fire.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Mutate.
      await repo.createForBookmark(1, 'second');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await sub.cancel();

      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.first.length, 1);
      expect(emissions.last.length, 2);
    });
  });

  group('Note.isEdited', () {
    test('false for fresh note (within 100ms jitter window)', () {
      final DateTime now = DateTime.now();
      final Note n = Note(
        bookmarkId: 1,
        content: 'x',
        createdAt: now,
        updatedAt: now.add(const Duration(milliseconds: 50)),
      );
      expect(n.isEdited, isFalse);
    });

    test('true once updatedAt exceeds the jitter window', () {
      final DateTime created = DateTime(2024);
      final Note n = Note(
        bookmarkId: 1,
        content: 'x',
        createdAt: created,
        updatedAt: created.add(const Duration(milliseconds: 250)),
      );
      expect(n.isEdited, isTrue);
    });
  });
}
