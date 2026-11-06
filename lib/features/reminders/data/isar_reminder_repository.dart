import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/reminder_entity.dart';
import 'package:marky/core/database/enums/reminder_status.dart';
import 'package:marky/features/reminders/data/reminder_mapper.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/reminders/domain/reminder_repository.dart';

class IsarReminderRepository implements ReminderRepository {
  IsarReminderRepository(this._isar);

  final Isar _isar;

  @override
  Future<Reminder> save(Reminder reminder) async {
    final ReminderEntity entity = ReminderMapper.toEntity(reminder);
    final int id = await _isar.writeTxn<int>(() async {
      return _isar.reminders.put(entity);
    });
    return reminder.copyWith(id: id);
  }

  @override
  Future<Reminder?> getById(int id) async {
    final ReminderEntity? e = await _isar.reminders.get(id);
    return e == null ? null : ReminderMapper.toDomain(e);
  }

  @override
  Future<List<Reminder>> getByBookmarkId(int bookmarkId) async {
    final List<ReminderEntity> rows = await _isar.reminders
        .where()
        .bookmarkIdEqualTo(bookmarkId)
        .sortByScheduledAt()
        .findAll();
    return rows.map(ReminderMapper.toDomain).toList(growable: false);
  }

  @override
  Future<List<Reminder>> getUpcoming({
    required DateTime now,
    required Duration window,
  }) async {
    // Active = pending OR snoozed. The Isar typed query DSL groups
    // alternates with `.or()`, but we still want the time bound to
    // apply to both — so we wrap in `.group()` to keep precedence
    // explicit and match SQL-style "(status IN (...)) AND (scheduledAt
    // BETWEEN now AND now+window)".
    final DateTime upper = now.add(window);
    final List<ReminderEntity> rows = await _isar.reminders
        .filter()
        .group((q) => q
            .statusEqualTo(ReminderStatus.pending)
            .or()
            .statusEqualTo(ReminderStatus.snoozed))
        .scheduledAtBetween(now, upper)
        .sortByScheduledAt()
        .findAll();
    return rows.map(ReminderMapper.toDomain).toList(growable: false);
  }

  @override
  Future<List<Reminder>> getAllActive() async {
    final List<ReminderEntity> rows = await _isar.reminders
        .filter()
        .statusEqualTo(ReminderStatus.pending)
        .or()
        .statusEqualTo(ReminderStatus.snoozed)
        .sortByScheduledAt()
        .findAll();
    return rows.map(ReminderMapper.toDomain).toList(growable: false);
  }

  @override
  Future<bool> delete(int id) {
    return _isar.writeTxn<bool>(() async => _isar.reminders.delete(id));
  }

  @override
  Future<int> deleteByBookmarkId(int bookmarkId) {
    return _isar.writeTxn<int>(() async {
      final List<int> ids = await _isar.reminders
          .where()
          .bookmarkIdEqualTo(bookmarkId)
          .idProperty()
          .findAll();
      if (ids.isEmpty) return 0;
      return _isar.reminders.deleteAll(ids);
    });
  }

  // ─── Status transitions ────────────────────────────────────────

  @override
  Future<Reminder?> markFired(int id, {DateTime? firedAt}) async {
    return _transition(
        id,
        (Reminder r) => r.copyWith(
              status: ReminderStatus.fired,
              firedAt: firedAt ?? DateTime.now(),
            ));
  }

  @override
  Future<Reminder?> markSnoozed(int id, {required DateTime until}) async {
    return _transition(
        id,
        (Reminder r) => r.copyWith(
              status: ReminderStatus.snoozed,
              snoozedUntil: until,
            ));
  }

  @override
  Future<Reminder?> markCancelled(int id) async {
    return _transition(
      id,
      (Reminder r) => r.copyWith(status: ReminderStatus.cancelled),
    );
  }

  /// Shared transition helper — load, mutate, save, re-read in one
  /// transaction so concurrent writes can't tear the row.
  Future<Reminder?> _transition(
    int id,
    Reminder Function(Reminder) edit,
  ) async {
    return _isar.writeTxn<Reminder?>(() async {
      final ReminderEntity? before = await _isar.reminders.get(id);
      if (before == null) return null;
      final Reminder edited = edit(ReminderMapper.toDomain(before));
      await _isar.reminders.put(ReminderMapper.toEntity(edited));
      return edited;
    });
  }

  // ─── Streams ────────────────────────────────────────────────────

  @override
  Stream<List<Reminder>> watchByBookmarkId(int bookmarkId) {
    final Query<ReminderEntity> q = _isar.reminders
        .where()
        .bookmarkIdEqualTo(bookmarkId)
        .sortByScheduledAt()
        .build();
    return q.watch(fireImmediately: true).map(
          (List<ReminderEntity> rows) =>
              rows.map(ReminderMapper.toDomain).toList(growable: false),
        );
  }

  @override
  Stream<Reminder?> watchById(int id) {
    return _isar.reminders.watchObject(id, fireImmediately: true).map(
          (ReminderEntity? e) => e == null ? null : ReminderMapper.toDomain(e),
        );
  }
}
