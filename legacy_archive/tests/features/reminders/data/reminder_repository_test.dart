import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/shared/models/reminder.dart';

void main() {
  group('ReminderRepositoryImpl', () {
    late Directory tempDir;
    late Isar isar;
    late ReminderRepository repository;

    Reminder makeReminder({
      required int bookmarkId,
      required String title,
      required DateTime scheduledAt,
      String status = 'pending',
      String timezone = 'UTC',
    }) {
      return Reminder(
        bookmarkId: bookmarkId,
        title: title,
        scheduledAt: scheduledAt,
        timezone: timezone,
        status: status,
        createdAt: DateTime.now(),
      );
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('reminder_test_');

      isar = await Isar.open(
        [ReminderSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      repository = ReminderRepositoryImpl(isar: isar);
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

    test('getById returns null when no reminder exists', () async {
      final result = await repository.getById(999);
      expect(result, isNull);
    });

    test('insert assigns an Id and the reminder can be fetched', () async {
      final reminder = makeReminder(
        bookmarkId: 1,
        title: 'Read later',
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
      );
      final id = await repository.insert(reminder);

      expect(id, greaterThan(0));

      final fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Read later');
      expect(fetched.bookmarkId, 1);
    });

    test('getAll returns all reminders', () async {
      final r1 = makeReminder(
        bookmarkId: 1,
        title: 'Reminder A',
        scheduledAt: DateTime.now(),
      );
      final r2 = makeReminder(
        bookmarkId: 2,
        title: 'Reminder B',
        scheduledAt: DateTime.now(),
      );

      await repository.insert(r1);
      await repository.insert(r2);

      final all = await repository.getAll();
      expect(all.length, 2);
      expect(all.map((r) => r.title).toSet(), {'Reminder A', 'Reminder B'});
    });

    test('getAll returns empty list when no reminders exist', () async {
      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('update modifies existing reminder', () async {
      final reminder = makeReminder(
        bookmarkId: 1,
        title: 'Old Title',
        scheduledAt: DateTime.now(),
      );
      final id = await repository.insert(reminder);

      final fetched = await repository.getById(id);
      fetched!.title = 'New Title';
      fetched.status = 'completed';
      await repository.update(fetched);

      final updated = await repository.getById(id);
      expect(updated!.title, 'New Title');
      expect(updated.status, 'completed');
    });

    test('delete removes reminder', () async {
      final reminder = makeReminder(
        bookmarkId: 1,
        title: 'ToDelete',
        scheduledAt: DateTime.now(),
      );
      final id = await repository.insert(reminder);

      expect(await repository.getById(id), isNotNull);

      await repository.delete(id);

      expect(await repository.getById(id), isNull);
    });

    test('delete on non-existent id is no-op', () async {
      await repository.delete(99999);

      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('clear removes all reminders', () async {
      await repository.insert(makeReminder(
        bookmarkId: 1,
        title: 'A',
        scheduledAt: DateTime.now(),
      ));
      await repository.insert(makeReminder(
        bookmarkId: 2,
        title: 'B',
        scheduledAt: DateTime.now(),
      ));

      expect((await repository.getAll()).length, 2);

      await repository.clear();

      expect(await repository.getAll(), isEmpty);
    });

    test('full CRUD cycle', () async {
      final reminder = makeReminder(
        bookmarkId: 1,
        title: 'Test',
        scheduledAt: DateTime.now(),
      );
      final id = await repository.insert(reminder);

      var fetched = await repository.getById(id);
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Test');

      fetched.title = 'Updated';
      await repository.update(fetched);

      fetched = await repository.getById(id);
      expect(fetched!.title, 'Updated');

      await repository.delete(id);
      expect(await repository.getById(id), isNull);
    });

    // ─── Query methods ───────────────────────────────────────────────────

    test('getByBookmarkId returns reminders for bookmark', () async {
      await repository.insert(makeReminder(
        bookmarkId: 1,
        title: 'Reminder 1',
        scheduledAt: DateTime.now(),
      ));
      await repository.insert(makeReminder(
        bookmarkId: 1,
        title: 'Reminder 2',
        scheduledAt: DateTime.now(),
      ));
      await repository.insert(makeReminder(
        bookmarkId: 2,
        title: 'Reminder 3',
        scheduledAt: DateTime.now(),
      ));

      final results = await repository.getByBookmarkId(1);
      expect(results.length, 2);
      expect(
        results.map((r) => r.title).toSet(),
        {'Reminder 1', 'Reminder 2'},
      );
    });

    test('getByBookmarkId returns empty list when no matches', () async {
      await repository.insert(makeReminder(
        bookmarkId: 1,
        title: 'Reminder',
        scheduledAt: DateTime.now(),
      ));

      final results = await repository.getByBookmarkId(99);
      expect(results, isEmpty);
    });

    test('getPending returns only pending reminders sorted by scheduledAt',
        () async {
      final now = DateTime.now();

      await repository.insert(makeReminder(
        bookmarkId: 1,
        title: 'Later',
        scheduledAt: now.add(const Duration(days: 2)),
        
      ));
      await repository.insert(makeReminder(
        bookmarkId: 2,
        title: 'Sooner',
        scheduledAt: now.add(const Duration(days: 1)),
        
      ));
      await repository.insert(makeReminder(
        bookmarkId: 3,
        title: 'Completed',
        scheduledAt: now.add(const Duration(days: 1)),
        status: 'completed',
      ));

      final pending = await repository.getPending();
      expect(pending.length, 2);
      expect(pending.first.title, 'Sooner');
      expect(pending.last.title, 'Later');
    });

    test('getPending returns empty list when no pending reminders', () async {
      await repository.insert(makeReminder(
        bookmarkId: 1,
        title: 'Done',
        scheduledAt: DateTime.now(),
        status: 'completed',
      ));

      final pending = await repository.getPending();
      expect(pending, isEmpty);
    });
  });
}
