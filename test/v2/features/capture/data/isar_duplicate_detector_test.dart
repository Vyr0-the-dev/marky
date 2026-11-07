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
import 'package:marky/features/bookmarks/data/isar_bookmark_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/capture/data/isar_duplicate_detector.dart';
import 'package:marky/features/capture/domain/duplicate_check_result.dart';

void main() {
  late Isar isar;
  late IsarBookmarkRepository bookmarkRepo;
  late IsarDuplicateDetector detector;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      <CollectionSchema<dynamic>>[
        BookmarkEntitySchema,
        TagEntitySchema,
        CollectionEntitySchema,
        ReminderEntitySchema,
        AutomationRuleEntitySchema,
        BackupMetaEntitySchema,
      ],
      directory: Directory.systemTemp.createTempSync('dup_test_').path,
      name: 'dup_test_${DateTime.now().microsecondsSinceEpoch}',
    );
    bookmarkRepo = IsarBookmarkRepository(isar);
    detector = IsarDuplicateDetector(bookmarkRepo);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  // ─── Helpers ───────────────────────────────────────────────────

  Bookmark bookmark({
    String url = 'https://example.com',
    String? canonicalUrl,
    String? urlHash,
    String? externalContentId,
  }) {
    final DateTime now = DateTime.now();
    return Bookmark(
      originalUrl: url,
      canonicalUrl: canonicalUrl,
      urlHash: urlHash,
      externalContentId: externalContentId,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ─── Tests ─────────────────────────────────────────────────────

  group('DuplicateDetector', () {
    test('returns fresh when no bookmarks exist', () async {
      final DuplicateCheckResult result = await detector.check(
        urlHash: 'hash_abc',
        canonicalUrl: 'https://example.com/page',
      );

      expect(result.isNew, isTrue);
      expect(result.existingBookmark, isNull);
      expect(result.matchLevel, isNull);
    });

    test('detects duplicate by urlHash (level 1)', () async {
      await bookmarkRepo.save(bookmark(
        url: 'https://example.com/page',
        canonicalUrl: 'https://example.com/page',
        urlHash: 'hash_123',
      ));

      final DuplicateCheckResult result = await detector.check(
        urlHash: 'hash_123',
        canonicalUrl: 'https://example.com/page',
      );

      expect(result.isNew, isFalse);
      expect(result.matchLevel, DuplicateMatchLevel.urlHash);
      expect(result.existingBookmark!.originalUrl, 'https://example.com/page');
    });

    test('detects duplicate by canonicalUrl (level 2)', () async {
      // Bookmark was saved without urlHash (legacy or edge case).
      await bookmarkRepo.save(bookmark(
        url: 'https://example.com/article',
        canonicalUrl: 'https://example.com/article',
        // no urlHash
      ));

      final DuplicateCheckResult result = await detector.check(
        urlHash: 'different_hash',
        canonicalUrl: 'https://example.com/article',
      );

      expect(result.isNew, isFalse);
      expect(result.matchLevel, DuplicateMatchLevel.canonicalUrl);
    });

    test('detects duplicate by externalContentId (level 3)', () async {
      // Same YouTube video saved via different URL variant.
      await bookmarkRepo.save(bookmark(
        url: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
        canonicalUrl: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
        urlHash: 'hash_yt_1',
        externalContentId: 'youtube:dQw4w9WgXcQ',
      ));

      // Same video arrives via youtu.be (different hash, different canonical).
      final DuplicateCheckResult result = await detector.check(
        urlHash: 'hash_yt_2',
        canonicalUrl: 'https://youtu.be/dQw4w9WgXcQ',
        externalContentId: 'youtube:dQw4w9WgXcQ',
      );

      expect(result.isNew, isFalse);
      expect(result.matchLevel, DuplicateMatchLevel.externalContentId);
    });

    test('urlHash match wins over canonicalUrl match', () async {
      await bookmarkRepo.save(bookmark(
        url: 'https://example.com/page',
        canonicalUrl: 'https://example.com/page',
        urlHash: 'hash_xyz',
      ));

      final DuplicateCheckResult result = await detector.check(
        urlHash: 'hash_xyz',
        canonicalUrl: 'https://example.com/page',
      );

      // Should be urlHash, not canonicalUrl, because hash is checked first.
      expect(result.matchLevel, DuplicateMatchLevel.urlHash);
    });

    test('skips externalContentId when null', () async {
      await bookmarkRepo.save(bookmark(
        url: 'https://example.com/page',
        urlHash: 'hash_a',
      ));

      final DuplicateCheckResult result = await detector.check(
        urlHash: 'hash_b',
        canonicalUrl: 'https://different.com/page',
      );

      expect(result.isNew, isTrue);
    });

    test('skips externalContentId when empty', () async {
      await bookmarkRepo.save(bookmark(
        url: 'https://example.com/page',
        urlHash: 'hash_a',
        externalContentId: 'youtube:abc',
      ));

      final DuplicateCheckResult result = await detector.check(
        urlHash: 'hash_b',
        canonicalUrl: 'https://different.com/page',
        externalContentId: '',
      );

      expect(result.isNew, isTrue);
    });

    test('multiple bookmarks: matches the correct one', () async {
      await bookmarkRepo.save(bookmark(
        url: 'https://example.com/a',
        canonicalUrl: 'https://example.com/a',
        urlHash: 'hash_a',
      ));
      await bookmarkRepo.save(bookmark(
        url: 'https://example.com/b',
        canonicalUrl: 'https://example.com/b',
        urlHash: 'hash_b',
      ));

      final DuplicateCheckResult result = await detector.check(
        urlHash: 'hash_b',
        canonicalUrl: 'https://example.com/b',
      );

      expect(result.isNew, isFalse);
      expect(result.existingBookmark!.originalUrl, 'https://example.com/b');
    });
  });
}
