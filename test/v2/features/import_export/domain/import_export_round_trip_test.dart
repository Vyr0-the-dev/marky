@Tags(<String>['integration'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/database/marky_database.dart';
import 'package:marky/core/url/url_hasher.dart';
import 'package:marky/core/url/url_normalizer.dart';
import 'package:marky/features/bookmarks/data/isar_bookmark_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/capture/data/default_upsert_merge_service.dart';
import 'package:marky/features/capture/data/isar_duplicate_detector.dart';
import 'package:marky/features/collections/data/isar_bookmark_collection_repository.dart';
import 'package:marky/features/import_export/domain/export_service.dart';
import 'package:marky/features/import_export/domain/import_service.dart';
import 'package:marky/features/tags/data/isar_tag_repository.dart';

void main() {
  late Directory sourceDir;
  late Directory targetDir;
  late Isar sourceIsar;
  late Isar targetIsar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    sourceDir = Directory.systemTemp.createTempSync('marky_export_source_');
    targetDir = Directory.systemTemp.createTempSync('marky_export_target_');
    sourceIsar = await MarkyDatabase.open(
      directory: sourceDir.path,
      name: 'source_${DateTime.now().microsecondsSinceEpoch}',
    );
    targetIsar = await MarkyDatabase.open(
      directory: targetDir.path,
      name: 'target_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    await sourceIsar.close(deleteFromDisk: true);
    await targetIsar.close(deleteFromDisk: true);
    if (sourceDir.existsSync()) sourceDir.deleteSync(recursive: true);
    if (targetDir.existsSync()) targetDir.deleteSync(recursive: true);
  });

  test('export wipe import restores core backup data', () async {
    final IsarBookmarkRepository sourceBookmarks =
        IsarBookmarkRepository(sourceIsar);
    final IsarTagRepository sourceTags = IsarTagRepository(sourceIsar);
    final IsarBookmarkCollectionRepository sourceCollections =
        IsarBookmarkCollectionRepository(sourceIsar);
    final DateTime now = DateTime.utc(2026, 4, 26, 12);
    const UrlNormalizer normalizer = UrlNormalizer();
    const UrlHasher hasher = UrlHasher();
    final String canonical = normalizer.normalize(
      'https://www.example.com/article?utm_source=share',
    )!;

    final tag = await sourceTags.createFromName(
      'Design',
      colorArgb: 0xFF112233,
      icon: 'palette',
    );
    final collection = await sourceCollections.createFromTitle(
      'Reading List',
      accentColorArgb: 0xFF445566,
      icon: 'book',
    );
    await sourceBookmarks.save(
      Bookmark(
        originalUrl: 'https://www.example.com/article?utm_source=share',
        canonicalUrl: canonical,
        normalizedHost: 'example.com',
        urlHash: hasher.hash(canonical),
        title: 'Backup article',
        inlineNotes: 'Important local note',
        tagIds: <int>[tag.id!],
        collectionIds: <int>[collection.id!],
        isFavorite: true,
        isArchived: true,
        isPinned: true,
        isRead: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final String backup = await ExportService(
      bookmarkRepository: sourceBookmarks,
      tagRepository: sourceTags,
      collectionRepository: sourceCollections,
    ).exportAll();

    final IsarBookmarkRepository targetBookmarks =
        IsarBookmarkRepository(targetIsar);
    final IsarTagRepository targetTags = IsarTagRepository(targetIsar);
    final IsarBookmarkCollectionRepository targetCollections =
        IsarBookmarkCollectionRepository(targetIsar);
    final ImportResult result = await ImportService(
      bookmarkRepository: targetBookmarks,
      tagRepository: targetTags,
      collectionRepository: targetCollections,
      duplicateDetector: IsarDuplicateDetector(targetBookmarks),
      mergeService: const DefaultUpsertMergeService(),
    ).importAll(backup);

    expect(result.tagsImported, 1);
    expect(result.collectionsImported, 1);
    expect(result.bookmarksImported, 1);

    final restoredTags = await targetTags.getAll();
    final restoredCollections =
        await targetCollections.getAll(includeArchived: true);
    final restoredBookmarks = await targetBookmarks.feed(
      const BookmarkFeedQuery(
        filter: BookmarkFeedFilter.archived,
      ),
    );

    expect(restoredTags.single.name, 'Design');
    expect(restoredTags.single.colorArgb, 0xFF112233);
    expect(restoredTags.single.icon, 'palette');
    expect(restoredCollections.single.title, 'Reading List');
    expect(restoredCollections.single.accentColorArgb, 0xFF445566);
    expect(restoredCollections.single.icon, 'book');
    expect(restoredBookmarks.single.canonicalUrl, canonical);
    expect(restoredBookmarks.single.title, 'Backup article');
    expect(restoredBookmarks.single.inlineNotes, 'Important local note');
    expect(restoredBookmarks.single.isFavorite, isTrue);
    expect(restoredBookmarks.single.isArchived, isTrue);
    expect(restoredBookmarks.single.isPinned, isTrue);
    expect(restoredBookmarks.single.isRead, isTrue);
  });
}
