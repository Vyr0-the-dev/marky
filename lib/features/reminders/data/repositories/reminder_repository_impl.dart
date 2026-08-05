import 'package:isar/isar.dart';

import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/shared/models/reminder.dart';

/// Isar-backed implementation of [ReminderRepository].
///
/// Expects [isar] to be an open database instance that includes
/// [ReminderSchema].
class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl({required Isar isar}) : _isar = isar;

  final Isar _isar;

  // ─── BaseRepository<Reminder> ──────────────────────────────────────────

  @override
  Future<Reminder?> getById(Id id) async {
    return _isar.reminders.get(id);
  }

  @override
  Future<List<Reminder>> getAll() async {
    return _isar.reminders.where().findAll();
  }

  @override
  Future<Id> insert(Reminder entity) async {
    return _isar.writeTxn(() async {
      return _isar.reminders.put(entity);
    });
  }

  @override
  Future<Id> update(Reminder entity) async {
    return _isar.writeTxn(() async {
      return _isar.reminders.put(entity);
    });
  }

  @override
  Future<void> delete(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.reminders.delete(id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.reminders.clear();
    });
  }

  // ─── ReminderRepository queries ────────────────────────────────────────

  @override
  Future<List<Reminder>> getByBookmarkId(Id bookmarkId) async {
    return _isar.reminders
        .where()
        .bookmarkIdEqualTo(bookmarkId)
        .findAll();
  }

  @override
  Future<List<Reminder>> getPending() async {
    return _isar.reminders
        .filter()
        .statusEqualTo('pending')
        .sortByScheduledAt()
        .findAll();
  }
}
