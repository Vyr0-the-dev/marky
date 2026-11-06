import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/notes/data/repositories/note_repository_impl.dart';
import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/shared/models/note.dart';

void main() {
  group('NoteRepositoryImpl', () {
    late Directory tempDir;
    late Isar isar;
    late NoteRepository repository;

    Note makeNote({
      required int bookmarkId,
      required String content,
      String contentFormat = 'plain',
      bool isPinned = false,
    }) {
      final now = DateTime.now();
      return Note(
        bookmarkId: bookmarkId,
        content: content,
        contentFormat: contentFormat,
        createdAt: now,
        updatedAt: now,
        isPinned: isPinned,
      );
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('note_test_');

      isar = await Isar.open(
        [NoteSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      repository = NoteRepositoryImpl(isar: isar);
    });

    tearDown(() async {
      if (isar.isOpen) {
        await isar.close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    // ─── CRUD ────────────────────────────────────────────────────────────

    test('getById returns null when no note exists', () async {
      final result = await repository.getById(999);
      expect(result, isNull);
    });

    test('insert assigns an Id and the note can be fetched', () async {
      final note = makeNote(bookmarkId: 1, content: 'Hello world');
      final id = await repository.insert(note);

      expect(id, greaterThan(0));

      final fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.content, 'Hello world');
      expect(fetched.bookmarkId, 1);
    });

    test('getAll returns all notes', () async {
      final n1 = makeNote(bookmarkId: 1, content: 'Note A');
      final n2 = makeNote(bookmarkId: 2, content: 'Note B');

      await repository.insert(n1);
      await repository.insert(n2);

      final all = await repository.getAll();
      expect(all.length, 2);
      expect(all.map((n) => n.content).toSet(), {'Note A', 'Note B'});
    });

    test('getAll returns empty list when no notes exist', () async {
      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('update modifies existing note', () async {
      final note = makeNote(bookmarkId: 1, content: 'Old content');
      final id = await repository.insert(note);

      final fetched = await repository.getById(id);
      fetched!.content = 'Updated content';
      fetched.isPinned = true;
      await repository.update(fetched);

      final updated = await repository.getById(id);
      expect(updated!.content, 'Updated content');
      expect(updated.isPinned, true);
    });

    test('delete removes note', () async {
      final note = makeNote(bookmarkId: 1, content: 'ToDelete');
      final id = await repository.insert(note);

      expect(await repository.getById(id), isNotNull);

      await repository.delete(id);

      expect(await repository.getById(id), isNull);
    });

    test('delete on non-existent id is no-op', () async {
      await repository.delete(99999);

      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('clear removes all notes', () async {
      await repository.insert(makeNote(bookmarkId: 1, content: 'A'));
      await repository.insert(makeNote(bookmarkId: 2, content: 'B'));

      expect((await repository.getAll()).length, 2);

      await repository.clear();

      expect(await repository.getAll(), isEmpty);
    });

    test('full CRUD cycle', () async {
      final note = makeNote(bookmarkId: 1, content: 'Test');
      final id = await repository.insert(note);

      var fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.content, 'Test');

      fetched.content = 'Updated';
      await repository.update(fetched);

      fetched = await repository.getById(id);
      expect(fetched!.content, 'Updated');

      await repository.delete(id);
      expect(await repository.getById(id), isNull);
    });

    // ─── Query methods ───────────────────────────────────────────────────

    test('getByBookmarkId returns notes for bookmark', () async {
      await repository.insert(makeNote(bookmarkId: 1, content: 'Note 1'));
      await repository.insert(makeNote(bookmarkId: 1, content: 'Note 2'));
      await repository.insert(makeNote(bookmarkId: 2, content: 'Note 3'));

      final results = await repository.getByBookmarkId(1);
      expect(results.length, 2);
      expect(results.map((n) => n.content).toSet(), {'Note 1', 'Note 2'});
    });

    test('getByBookmarkId returns empty list when no matches', () async {
      await repository.insert(makeNote(bookmarkId: 1, content: 'Note'));

      final results = await repository.getByBookmarkId(99);
      expect(results, isEmpty);
    });
  });
}
