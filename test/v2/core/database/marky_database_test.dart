@Tags(<String>['integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/automation_rule_entity.dart';
import 'package:marky/core/database/entities/backup_meta_entity.dart';
import 'package:marky/core/database/entities/bookmark_entity.dart';
import 'package:marky/core/database/entities/collection_entity.dart';
import 'package:marky/core/database/entities/reminder_entity.dart';
import 'package:marky/core/database/entities/tag_entity.dart';
import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';
import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/core/database/enums/collection_sort_mode.dart';
import 'package:marky/core/database/enums/reminder_repeat_mode.dart';
import 'package:marky/core/database/enums/reminder_status.dart';
import 'package:marky/core/database/marky_database.dart';

/// Faz 2 Tur 1 — schema sanity tests.
///
/// We don't test repository semantics here (those land in Tur 2);
/// the goal is to assert that:
/// 1. [MarkyDatabase.open] succeeds with every registered schema.
/// 2. Each schema accepts a representative row and returns it
///    losslessly through `put → get`.
/// 3. The composite + uniqueness indexes we declared are honoured by
///    Isar at runtime (so a typo in the annotations doesn't slip
///    through).
void main() {
  late Directory tempDir;
  late Isar isar;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('marky_v2_db_test_');
    isar = await MarkyDatabase.open(
      directory: tempDir.path,
      name: 'test_${tempDir.path.hashCode}',
    );
  });

  tearDown(() async {
    if (isar.isOpen) {
      await isar.close(deleteFromDisk: true);
    }
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('opens with all schemas registered', () {
    // Don't hard-code the count — adding a new entity should require
    // editing `MarkyDatabase.schemas` and nothing else. The lower
    // bound just guards against accidental schema removal.
    expect(MarkyDatabase.schemas.length, greaterThanOrEqualTo(7));
    expect(isar.isOpen, isTrue);
  });

  test('BookmarkEntity round-trips through put → get', () async {
    final DateTime now = DateTime(2026, 4, 25, 1, 30);
    final BookmarkEntity bookmark = BookmarkEntity(
      originalUrl: 'https://flutter.dev/',
      canonicalUrl: 'https://flutter.dev',
      normalizedHost: 'flutter.dev',
      urlHash: 'sha256:abc',
      title: 'Flutter',
      description: 'Build apps for any screen.',
      contentType: BookmarkContentType.article,
      sourceType: BookmarkSourceType.share,
      tagIds: <int>[1, 2, 3],
      collectionIds: <int>[10],
      reminderIds: <int>[],
      isFavorite: true,
      createdAt: now,
      updatedAt: now,
      scrapingStatus: BookmarkScrapingStatus.done,
    );

    late int id;
    await isar.writeTxn(() async {
      id = await isar.bookmarks.put(bookmark);
    });

    final BookmarkEntity? loaded = await isar.bookmarks.get(id);
    expect(loaded, isNotNull);
    expect(loaded!.originalUrl, 'https://flutter.dev/');
    expect(loaded.contentType, BookmarkContentType.article);
    expect(loaded.sourceType, BookmarkSourceType.share);
    expect(loaded.scrapingStatus, BookmarkScrapingStatus.done);
    expect(loaded.tagIds, <int>[1, 2, 3]);
    expect(loaded.isFavorite, isTrue);
  });

  test(
      'BookmarkEntity composite (isArchived, createdAt) index serves '
      'the feed query', () async {
    final DateTime base = DateTime(2026);
    await isar.writeTxn(() async {
      // Three rows: two visible, one archived.
      await isar.bookmarks.putAll(<BookmarkEntity>[
        BookmarkEntity(
          originalUrl: 'a',
          createdAt: base.add(const Duration(days: 1)),
          updatedAt: base,
        ),
        BookmarkEntity(
          originalUrl: 'b',
          createdAt: base.add(const Duration(days: 2)),
          updatedAt: base,
        ),
        BookmarkEntity(
          originalUrl: 'c',
          isArchived: true,
          createdAt: base.add(const Duration(days: 3)),
          updatedAt: base,
        ),
      ]);
    });

    // The "feed" query: not archived, newest first.
    final List<BookmarkEntity> feed = await isar.bookmarks
        .filter()
        .isArchivedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();

    expect(feed.map((BookmarkEntity b) => b.originalUrl), <String>['b', 'a']);
  });

  test('TagEntity slug uniqueness is enforced', () async {
    final DateTime now = DateTime.now();
    await isar.writeTxn(() async {
      await isar.tags.put(TagEntity(
        name: 'Reading',
        slug: 'reading',
        createdAt: now,
        updatedAt: now,
      ));
    });

    expect(
      () async => isar.writeTxn(() async {
        await isar.tags.put(TagEntity(
          name: 'Reading 2',
          slug: 'reading',
          createdAt: now,
          updatedAt: now,
        ));
      }),
      throwsA(isA<IsarError>()),
    );
  });

  test('TagEntity slug index is case-insensitive', () async {
    final DateTime now = DateTime.now();
    await isar.writeTxn(() async {
      await isar.tags.put(TagEntity(
        name: 'Design',
        slug: 'design',
        createdAt: now,
        updatedAt: now,
      ));
    });

    final TagEntity? upper =
        await isar.tags.where().slugEqualTo('DESIGN').findFirst();
    expect(upper, isNotNull,
        reason: 'caseSensitive: false should resolve DESIGN → design');
  });

  test('CollectionEntity round-trips with enum sort mode', () async {
    final DateTime now = DateTime.now();
    late int id;
    await isar.writeTxn(() async {
      id = await isar.collections.put(CollectionEntity(
        title: 'Research',
        slug: 'research',
        sortMode: CollectionSortMode.titleAscending,
        accentColorArgb: 0xFFAA3300,
        createdAt: now,
        updatedAt: now,
      ));
    });

    final CollectionEntity? loaded = await isar.collections.get(id);
    expect(loaded?.sortMode, CollectionSortMode.titleAscending);
    expect(loaded?.accentColorArgb, 0xFFAA3300);
  });

  test('ReminderEntity round-trips with enum repeat mode and status', () async {
    final DateTime scheduled = DateTime(2026, 5);
    late int id;
    await isar.writeTxn(() async {
      id = await isar.reminders.put(ReminderEntity(
        bookmarkId: 1,
        title: 'Read it',
        scheduledAt: scheduled,
        timezone: 'Europe/Istanbul',
        repeatMode: ReminderRepeatMode.weekly,
        status: ReminderStatus.snoozed,
        createdAt: DateTime.now(),
      ));
    });

    final ReminderEntity? loaded = await isar.reminders.get(id);
    expect(loaded?.repeatMode, ReminderRepeatMode.weekly);
    expect(loaded?.status, ReminderStatus.snoozed);
    expect(loaded?.timezone, 'Europe/Istanbul');
  });

  test('AutomationRuleEntity round-trips parallel actionTypes/actionArgs',
      () async {
    final DateTime now = DateTime.now();
    late int id;
    await isar.writeTxn(() async {
      id = await isar.automationRules.put(AutomationRuleEntity(
        name: 'Auto-tag YouTube',
        triggerType: AutomationTriggerType.domainEquals,
        triggerValue: 'youtube.com',
        actionTypes: <AutomationActionType>[
          AutomationActionType.addTag,
          AutomationActionType.setFavorite,
        ],
        actionArgs: <String>['42', 'true'],
        createdAt: now,
        updatedAt: now,
      ));
    });

    final AutomationRuleEntity? loaded = await isar.automationRules.get(id);
    expect(loaded?.triggerType, AutomationTriggerType.domainEquals);
    expect(
      loaded?.actionTypes,
      <AutomationActionType>[
        AutomationActionType.addTag,
        AutomationActionType.setFavorite,
      ],
    );
    expect(loaded?.actionArgs, <String>['42', 'true']);
  });

  test('BackupMetaEntity persists as a singleton at id=0', () async {
    await isar.writeTxn(() async {
      await isar.backupMeta.put(BackupMetaEntity(
        autoBackupEnabled: true,
        backupIntervalHours: 12,
        googleDriveAccountEmail: 'user@example.com',
      ));
    });

    final BackupMetaEntity? loaded = await isar.backupMeta.get(0);
    expect(loaded, isNotNull);
    expect(loaded!.id, 0);
    expect(loaded.autoBackupEnabled, isTrue);
    expect(loaded.backupIntervalHours, 12);
    expect(loaded.googleDriveAccountEmail, 'user@example.com');

    // Saving again with the default ctor (id = 0) overwrites in
    // place — the row stays a singleton.
    await isar.writeTxn(() async {
      await isar.backupMeta.put(BackupMetaEntity());
    });
    final int count = await isar.backupMeta.count();
    expect(count, 1);
  });

  test('cross-entity write txn keeps consistency on rollback', () async {
    final DateTime now = DateTime.now();
    await expectLater(
      isar.writeTxn(() async {
        await isar.tags.put(TagEntity(
          name: 'Doomed',
          slug: 'doomed',
          createdAt: now,
          updatedAt: now,
        ));
        // Force a constraint violation: same slug, same txn → both
        // writes must roll back.
        await isar.tags.put(TagEntity(
          name: 'Doomed 2',
          slug: 'doomed',
          createdAt: now,
          updatedAt: now,
        ));
      }),
      throwsA(isA<IsarError>()),
    );
    expect(await isar.tags.count(), 0,
        reason: 'rolled-back transaction must leave the collection empty');
  });
}
