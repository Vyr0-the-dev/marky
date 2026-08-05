import 'dart:convert';
import 'dart:io';

// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/scraping/enums/favicon_status.dart';
import 'package:marky/core/scraping/enums/scraping_status.dart';
import 'package:marky/core/scraping/enums/thumbnail_status.dart';
import 'package:marky/features/import_export/data/services/export_service.dart';
import 'package:marky/features/import_export/domain/models/export_data.dart';
import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/note.dart';
import 'package:marky/shared/models/reminder.dart';
import 'package:marky/shared/models/tag.dart';

import '../../../fakes/fake_share_platform.dart';

// ─── Test Helpers ───────────────────────────────────────────────────────────

BookmarkItem _makeBookmark({
  required String url,
  String? localThumbnailPath,
  String? heroImageLocalPath,
  String? localFaviconPath,
}) {
  final now = DateTime.now();
  return BookmarkItem(
    originalUrl: url,
    localThumbnailPath: localThumbnailPath,
    heroImageLocalPath: heroImageLocalPath,
    localFaviconPath: localFaviconPath,
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

ExportData _makeExportData({
  List<BookmarkItem> bookmarks = const <BookmarkItem>[],
  List<Tag> tags = const <Tag>[],
  List<BookmarkCollection> collections = const <BookmarkCollection>[],
  List<Note> notes = const <Note>[],
  List<Reminder> reminders = const <Reminder>[],
  AppSettings? settings,
}) {
  return ExportData(
    bookmarks: bookmarks,
    tags: tags,
    collections: collections,
    notes: notes,
    reminders: reminders,
    settings: settings,
    schemaVersion: '1.0.0',
    exportTimestamp: DateTime.utc(2024, 6, 15, 12, 30, 0),
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('ExportService', () {
    late FakeSharePlatform fakeShare;
    late Directory tempDir;
    late ExportService service;

    setUp(() async {
      fakeShare = FakeSharePlatform();
      tempDir = await Directory.systemTemp.createTemp('marky_export_test_');

      service = ExportService(
        sharePlatform: fakeShare,
        getTempDirectory: () async => tempDir,
      );
    });

    tearDown(() {
      // Clean up temp files
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('JSON output contains expected top-level keys', () async {
      final data = _makeExportData(
        bookmarks: [_makeBookmark(url: 'https://example.com')],
        tags: [_makeTag(name: 'flutter')],
      );

      final filePath = await service.exportAndShare(data);
      final file = File(filePath);
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;

      expect(json['version'], 'marky_export_v1');
      expect(json['schemaVersion'], '1.0.0');
      expect(json['exportedAt'], '2024-06-15T12:30:00.000Z');
      expect(json['bookmarks'], isA<List>());
      expect(json['tags'], isA<List>());
      expect(json['collections'], isA<List>());
      expect(json['notes'], isA<List>());
      expect(json['reminders'], isA<List>());
    });

    test('local paths are excluded from bookmark JSON', () async {
      final data = _makeExportData(
        bookmarks: [
          _makeBookmark(
            url: 'https://example.com',
            localThumbnailPath: '/data/data/com.marky/thumbs/1.jpg',
            heroImageLocalPath: '/data/data/com.marky/heros/1.jpg',
            localFaviconPath: '/data/data/com.marky/favicons/1.png',
          ),
        ],
      );

      final filePath = await service.exportAndShare(data);
      final file = File(filePath);
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final bookmark = (json['bookmarks'] as List).first as Map<String, dynamic>;

      expect(bookmark.containsKey('localThumbnailPath'), isFalse);
      expect(bookmark.containsKey('heroImageLocalPath'), isFalse);
      expect(bookmark.containsKey('localFaviconPath'), isFalse);

      // Other fields should still be present
      expect(bookmark['originalUrl'], 'https://example.com');
    });

    test('schema version is present in export JSON', () async {
      final data = _makeExportData();

      final filePath = await service.exportAndShare(data);
      final file = File(filePath);
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;

      expect(json['version'], 'marky_export_v1');
    });

    test('timestamp is ISO8601 format', () async {
      final data = _makeExportData();

      final filePath = await service.exportAndShare(data);
      final file = File(filePath);
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;

      expect(json['exportedAt'], '2024-06-15T12:30:00.000Z');
    });

    test('file is written to temp directory', () async {
      final data = _makeExportData();

      final filePath = await service.exportAndShare(data);

      expect(filePath.startsWith(tempDir.path), isTrue);
      final file = File(filePath);
      expect(file.existsSync(), isTrue);
    });

    test('sharePlatform is called with the file path', () async {
      final data = _makeExportData();

      final filePath = await service.exportAndShare(data);

      expect(fakeShare.sharedPaths, hasLength(1));
      expect(fakeShare.sharedPaths.first, filePath);
      expect(fakeShare.sharedSubjects.first, 'Marky Export');
    });

    test('settings are included when present', () async {
      final data = _makeExportData(
        settings: AppSettings(themeMode: 'dark'),
      );

      final filePath = await service.exportAndShare(data);
      final file = File(filePath);
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;

      expect(json['settings'], isA<Map<String, dynamic>>());
      expect((json['settings'] as Map<String, dynamic>)['themeMode'], 'dark');
    });

    test('settings key is absent when null', () async {
      final data = _makeExportData();

      final filePath = await service.exportAndShare(data);
      final file = File(filePath);
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;

      expect(json.containsKey('settings'), isFalse);
    });

    test('bookmark enum values are serialized as names', () async {
      final bookmark = _makeBookmark(url: 'https://example.com')
        ..scrapingStatus = ScrapingStatus.done
        ..thumbnailStatus = ThumbnailStatus.failed
        ..faviconStatus = FaviconStatus.processing;

      final data = _makeExportData(bookmarks: [bookmark]);

      final filePath = await service.exportAndShare(data);
      final file = File(filePath);
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final bm = (json['bookmarks'] as List).first as Map<String, dynamic>;

      expect(bm['scrapingStatus'], 'done');
      expect(bm['thumbnailStatus'], 'failed');
      expect(bm['faviconStatus'], 'processing');
    });

    test('collection local path is excluded', () async {
      final collection = _makeCollection(title: 'Reading List')
        ..coverLocalPath = '/data/data/com.marky/covers/c1.jpg';

      final data = _makeExportData(collections: [collection]);

      final filePath = await service.exportAndShare(data);
      final file = File(filePath);
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final col = (json['collections'] as List).first as Map<String, dynamic>;

      expect(col.containsKey('coverLocalPath'), isFalse);
      expect(col['title'], 'Reading List');
    });

    test('file name contains marky_export prefix and timestamp', () async {
      final data = _makeExportData();

      final filePath = await service.exportAndShare(data);
      final fileName = filePath.split(Platform.pathSeparator).last;

      expect(fileName, startsWith('marky_export_'));
      expect(fileName, endsWith('.json'));
    });

    test('empty export produces empty lists', () async {
      final data = _makeExportData();

      final filePath = await service.exportAndShare(data);
      final file = File(filePath);
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;

      expect(json['bookmarks'], isEmpty);
      expect(json['tags'], isEmpty);
      expect(json['collections'], isEmpty);
      expect(json['notes'], isEmpty);
      expect(json['reminders'], isEmpty);
    });
  });
}
