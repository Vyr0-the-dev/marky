import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/core/search/query_parser.dart';
import 'package:marky/features/bookmarks/data/repositories/bookmark_item_repository_impl.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';

void main() {
  group('BookmarkItemRepositoryImpl.search', () {
    late Directory tempDir;
    late Isar isar;
    late BookmarkItemRepository repository;

    BookmarkItem makeBookmark({
      required String originalUrl,
      String? title,
      String? description,
      String? snippet,
      String? extractedText,
      String? normalizedHost,
      String? sourceDomain,
      String? sourceType,
      String? contentType,
      bool isFavorite = false,
      bool isArchived = false,
      bool isRead = false,
      bool isDeleted = false,
      bool isInVault = false,
      List<int>? noteIds,
      List<int>? tagIds,
      DateTime? createdAt,
    }) {
      final now = createdAt ?? DateTime.now();
      return BookmarkItem(
        originalUrl: originalUrl,
        title: title,
        description: description,
        snippet: snippet,
        extractedText: extractedText,
        normalizedHost: normalizedHost,
        sourceDomain: sourceDomain,
        sourceType: sourceType,
        contentType: contentType,
        isFavorite: isFavorite,
        isArchived: isArchived,
        isRead: isRead,
        isDeleted: isDeleted,
        isInVault: isInVault,
        noteIds: noteIds,
        tagIds: tagIds,
        createdAt: now,
        updatedAt: now,
      );
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('bookmark_search_test_');

      isar = await Isar.open(
        [BookmarkItemSchema],
        directory: tempDir.path,
        name: 'test_${tempDir.path.hashCode}',
      );

      repository = BookmarkItemRepositoryImpl(isar: isar);
    });

    tearDown(() async {
      if (isar.isOpen) {
        await isar.close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    // ─── Free-text search ────────────────────────────────────────────────

    test('free-text matches title', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        title: 'Flutter tips',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://b.com',
        title: 'Dart guide',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['flutter']),
      );
      expect(results.length, 1);
      expect(results.first.title, 'Flutter tips');
    });

    test('free-text matches description', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        description: 'Amazing flutter article',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['amazing']),
      );
      expect(results.length, 1);
    });

    test('free-text matches snippet', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        snippet: 'Quick summary of flutter widgets',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['widgets']),
      );
      expect(results.length, 1);
    });

    test('free-text matches extractedText', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        extractedText: 'Deep dive into flutter state management',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['management']),
      );
      expect(results.length, 1);
    });

    test('free-text matches originalUrl', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://flutter.dev/docs',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['flutter.dev']),
      );
      expect(results.length, 1);
    });

    test('free-text is case-insensitive', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        title: 'FLUTTER Tips',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['flutter']),
      );
      expect(results.length, 1);
    });

    test('multiple free-text terms are ANDed together', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        title: 'Flutter state management',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://b.com',
        title: 'Flutter widgets',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['flutter', 'management']),
      );
      expect(results.length, 1);
      expect(results.first.title, 'Flutter state management');
    });

    test('free-text returns empty when no match', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        title: 'Dart guide',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['nonexistent']),
      );
      expect(results, isEmpty);
    });

    // ─── Operator search ─────────────────────────────────────────────────

    test('is:favorite operator', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://fav.com',
        isFavorite: true,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://plain.com',
      ));

      final results = await repository.search(
        QueryParser.parse('is:favorite'),
      );
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://fav.com');
    });

    test('is:archived operator', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://archived.com',
        isArchived: true,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://active.com',
      ));

      final results = await repository.search(
        QueryParser.parse('is:archived'),
      );
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://archived.com');
    });

    test('is:unread operator', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://unread.com',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://read.com',
        isRead: true,
      ));

      final results = await repository.search(
        QueryParser.parse('is:unread'),
      );
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://unread.com');
    });

    test('has:note operator', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://with-note.com',
        noteIds: [1, 2],
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://no-note.com',
      ));

      final results = await repository.search(
        QueryParser.parse('has:note'),
      );
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://with-note.com');
    });

    test('domain: operator matches normalizedHost', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://youtube.com/watch',
        normalizedHost: 'youtube.com',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://google.com',
        normalizedHost: 'google.com',
      ));

      final results = await repository.search(
        QueryParser.parse('domain:youtube'),
      );
      expect(results.length, 1);
      expect(results.first.normalizedHost, 'youtube.com');
    });

    test('domain: operator matches sourceDomain', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        sourceDomain: 'github.com',
      ));

      final results = await repository.search(
        QueryParser.parse('domain:github'),
      );
      expect(results.length, 1);
    });

    test('source: operator', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        sourceType: 'share_sheet',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://b.com',
        sourceType: 'manual',
      ));

      final results = await repository.search(
        QueryParser.parse('source:share_sheet'),
      );
      expect(results.length, 1);
      expect(results.first.sourceType, 'share_sheet');
    });

    test('type: operator', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        contentType: 'video',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://b.com',
        contentType: 'article',
      ));

      final results = await repository.search(
        QueryParser.parse('type:video'),
      );
      expect(results.length, 1);
      expect(results.first.contentType, 'video');
    });

    test('before: operator', () async {
      final oldDate = DateTime(2023);
      final newDate = DateTime(2024, 6);
      await repository.insert(makeBookmark(
        originalUrl: 'https://old.com',
        createdAt: oldDate,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://new.com',
        createdAt: newDate,
      ));

      final results = await repository.search(
        QueryParser.parse('before:2024-01-01'),
      );
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://old.com');
    });

    test('after: operator', () async {
      final oldDate = DateTime(2023);
      final newDate = DateTime(2024, 6);
      await repository.insert(makeBookmark(
        originalUrl: 'https://old.com',
        createdAt: oldDate,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://new.com',
        createdAt: newDate,
      ));

      final results = await repository.search(
        QueryParser.parse('after:2024-01-01'),
      );
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://new.com');
    });

    // ─── Vault exclusion / inclusion ─────────────────────────────────────

    test('vault items are excluded by default', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://vault.com',
        isInVault: true,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://public.com',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['com']),
      );
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://public.com');
    });

    test('in:vault operator includes vault items', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://vault.com',
        isInVault: true,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://public.com',
      ));

      final results = await repository.search(
        QueryParser.parse('in:vault'),
      );
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://vault.com');
    });

    // ─── Combined queries ────────────────────────────────────────────────

    test('free-text combined with operator', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        title: 'Flutter tips',
        isFavorite: true,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://b.com',
        title: 'Flutter guide',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://c.com',
        title: 'Dart tips',
        isFavorite: true,
      ));

      final results = await repository.search(
        QueryParser.parse('flutter is:favorite'),
      );
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://a.com');
    });

    // ─── Soft-delete guard ───────────────────────────────────────────────

    test('soft-deleted bookmarks are excluded', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://deleted.com',
        isDeleted: true,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://active.com',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['com']),
      );
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://active.com');
    });

    // ─── Tag / collection placeholder ────────────────────────────────────

    test('tag: operator yields empty result (placeholder)', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        tagIds: [1],
      ));

      final results = await repository.search(
        QueryParser.parse('tag:flutter'),
      );
      expect(results, isEmpty);
    });

    test('collection: operator yields empty result (placeholder)', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
      ));

      final results = await repository.search(
        QueryParser.parse('collection:reading'),
      );
      expect(results, isEmpty);
    });

    // ─── Edge cases ──────────────────────────────────────────────────────

    test('empty query returns all non-deleted non-vault bookmarks', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://b.com',
        isInVault: true,
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://c.com',
        isDeleted: true,
      ));

      final results = await repository.search(const SearchQuery());
      expect(results.length, 1);
      expect(results.first.originalUrl, 'https://a.com');
    });

    test('unknown is: value is ignored', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
      ));

      final results = await repository.search(
        QueryParser.parse('is:unknown_value'),
      );
      expect(results.length, 1);
    });

    test('unknown has: value is ignored', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
      ));

      final results = await repository.search(
        QueryParser.parse('has:unknown_value'),
      );
      expect(results.length, 1);
    });

    test('query matching zero bookmarks returns empty', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
        title: 'Dart',
      ));

      final results = await repository.search(
        const SearchQuery(freeText: ['flutter']),
      );
      expect(results, isEmpty);
    });

    test('query matching all bookmarks returns all', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
      ));
      await repository.insert(makeBookmark(
        originalUrl: 'https://b.com',
      ));

      final results = await repository.search(const SearchQuery());
      expect(results.length, 2);
    });

    test('malformed date in before: is ignored', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
      ));

      final results = await repository.search(
        QueryParser.parse('before:not-a-date'),
      );
      expect(results.length, 1);
    });

    test('malformed date in after: is ignored', () async {
      await repository.insert(makeBookmark(
        originalUrl: 'https://a.com',
      ));

      final results = await repository.search(
        QueryParser.parse('after:not-a-date'),
      );
      expect(results.length, 1);
    });
  });
}
