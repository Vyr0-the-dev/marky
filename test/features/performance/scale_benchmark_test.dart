import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/data/repositories/bookmark_item_repository_impl.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/dashboard/domain/services/dashboard_statistics_service.dart';
import 'package:marky/shared/models/bookmark_item.dart';
import 'package:marky/shared/models/collection.dart';
import 'package:marky/shared/models/tag.dart';

// ─── Constants ─────────────────────────────────────────────────────────

const int _kRecordCount = 10000;
const int _kPageSize = 24;

const List<String> _sourceTypes = <String>[
  'manual',
  'share_sheet',
  'clipboard',
  'import',
  'other',
];

const List<String> _contentTypes = <String>[
  'article',
  'video',
  'image',
  'product',
  'repository',
  'audio',
  'document',
  'other',
];

const List<String> _commonWords = <String>[
  'flutter',
  'dart',
  'design',
  'article',
  'guide',
  'tutorial',
  'news',
  'tech',
  'programming',
  'web',
  'mobile',
  'app',
  'development',
  'software',
  'engineering',
];

const List<String> _tagNames = <String>[
  'flutter',
  'dart',
  'ios',
  'android',
  'web',
  'backend',
  'frontend',
  'design',
  'ux',
  'ai',
  'machine-learning',
  'devops',
  'cloud',
  'security',
  'performance',
];

// ─── Helpers ───────────────────────────────────────────────────────────

String _randomWord(Random rng) => _commonWords[rng.nextInt(_commonWords.length)];

String _randomTitle(Random rng) {
  final parts = <String>[
    _randomWord(rng),
    _randomWord(rng),
    _randomWord(rng),
  ];
  return parts.join(' ');
}

String _randomDescription(Random rng) {
  final parts = <String>[];
  for (var i = 0; i < 5 + rng.nextInt(10); i++) {
    parts.add(_randomWord(rng));
  }
  return parts.join(' ');
}

String _randomUrl(Random rng, int index) {
  final hosts = <String>[
    'example.com',
    'medium.com',
    'github.com',
    'stackoverflow.com',
    'news.ycombinator.com',
    'reddit.com',
    'youtube.com',
    'twitter.com',
    'dev.to',
    'flutter.dev',
  ];
  return 'https://${hosts[rng.nextInt(hosts.length)]}/page-$index';
}

/// Benchmark helper: runs [action], prints duration, and returns elapsed ms.
Future<int> _benchmark(String label, Future<void> Function() action) async {
  final sw = Stopwatch()..start();
  await action();
  sw.stop();
  final ms = sw.elapsedMilliseconds;
  print('  $label: ${ms}ms');
  return ms;
}

// ─── Test ──────────────────────────────────────────────────────────────

void main() {
  group('10K scale benchmark', () {
    late Directory tempDir;
    late Isar isar;
    late BookmarkItemRepository repository;
    late DashboardStatisticsService statsService;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('marky_scale_test_');

      isar = await Isar.open(
        [
          BookmarkItemSchema,
          TagSchema,
          BookmarkCollectionSchema,
        ],
        directory: tempDir.path,
        name: 'scale_benchmark',
      );

      repository = BookmarkItemRepositoryImpl(isar: isar);
      statsService = DashboardStatisticsService(isar: isar);

      // ─── Seed tags ──────────────────────────────────────────────────
      final rng = Random(42);
      final tags = <Tag>[];
      for (var i = 0; i < _tagNames.length; i++) {
        final tag = Tag(
          name: _tagNames[i],
          slug: _tagNames[i],
          createdAt: DateTime.now().subtract(Duration(days: rng.nextInt(365))),
          updatedAt: DateTime.now(),
        );
        tags.add(tag);
      }
      await isar.writeTxn(() async {
        await isar.tags.putAll(tags);
      });

      // ─── Seed collections ───────────────────────────────────────────
      final collections = <BookmarkCollection>[];
      for (var i = 0; i < 5; i++) {
        collections.add(BookmarkCollection(
          title: 'Collection $i',
          slug: 'collection-$i',
          createdAt: DateTime.now().subtract(Duration(days: rng.nextInt(365))),
          updatedAt: DateTime.now(),
        ));
      }
      await isar.writeTxn(() async {
        await isar.bookmarkCollections.putAll(collections);
      });

      // ─── Seed 10,000 bookmarks ──────────────────────────────────────
      print('Seeding $_kRecordCount bookmark records...');
      final seedSw = Stopwatch()..start();

      final tagIds = tags.map((t) => t.id).toList();
      final collectionIds = collections.map((c) => c.id).toList();

      // Insert in batches to avoid excessive memory pressure.
      const batchSize = 500;
      for (var batchStart = 0; batchStart < _kRecordCount; batchStart += batchSize) {
        final batch = <BookmarkItem>[];
        final batchEnd = min(batchStart + batchSize, _kRecordCount);
        for (var i = batchStart; i < batchEnd; i++) {
          final now = DateTime.now().subtract(Duration(days: rng.nextInt(365)));
          final tagCount = rng.nextInt(4); // 0–3 tags
          final itemTagIds = <int>[];
          for (var t = 0; t < tagCount; t++) {
            itemTagIds.add(tagIds[rng.nextInt(tagIds.length)]);
          }

          final colCount = rng.nextBool() ? 1 : 0;
          final itemCollectionIds = <int>[];
          for (var c = 0; c < colCount; c++) {
            itemCollectionIds.add(collectionIds[rng.nextInt(collectionIds.length)]);
          }

          batch.add(BookmarkItem(
            originalUrl: _randomUrl(rng, i),
            canonicalUrl: _randomUrl(rng, i),
            urlHash: 'hash_$i',
            title: _randomTitle(rng),
            description: _randomDescription(rng),
            snippet: _randomDescription(rng),
            extractedText: '${_randomDescription(rng)} ${_randomDescription(rng)}',
            normalizedHost: 'example-${i % 10}.com',
            sourceDomain: 'example-${i % 10}.com',
            sourceType: _sourceTypes[rng.nextInt(_sourceTypes.length)],
            contentType: _contentTypes[rng.nextInt(_contentTypes.length)],
            tagIds: itemTagIds.isEmpty ? null : itemTagIds,
            collectionIds: itemCollectionIds.isEmpty ? null : itemCollectionIds,
            isFavorite: rng.nextDouble() < 0.15,
            isArchived: rng.nextDouble() < 0.05,
            isDeleted: false,
            isRead: rng.nextDouble() < 0.4,
            isInVault: rng.nextDouble() < 0.02,
            createdAt: now,
            updatedAt: now,
          ));
        }
        await isar.writeTxn(() async {
          await isar.bookmarkItems.putAll(batch);
        });
      }

      seedSw.stop();
      print('Seeding complete in ${seedSw.elapsedMilliseconds}ms');
    });

    tearDownAll(() async {
      if (isar.isOpen) {
        await isar.close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    // ── Benchmark 1: getAll first page ───────────────────────────────
    test('getAll(offset: 0, limit: 24) returns in < 500ms', () async {
      final ms = await _benchmark(
        'getAll(offset: 0, limit: 24)',
        () async {
          final items = await repository.getAll(offset: 0, limit: _kPageSize);
          expect(items.length, lessThanOrEqualTo(_kPageSize));
        },
      );
      expect(ms, lessThan(500), reason: 'First-page fetch should be fast');
    });

    // ── Benchmark 2: search with common term ─────────────────────────
    test('search with common term returns in < 500ms and respects 100-item limit',
        () async {
      final query = SearchQuery(freeText: const <String>['flutter']);

      late List<BookmarkItem> results;
      final ms = await _benchmark(
        "search(query: 'flutter')",
        () async {
          results = await repository.search(query);
        },
      );

      expect(ms, lessThan(500), reason: 'Search should be fast');
      expect(results.length, lessThanOrEqualTo(100),
          reason: 'Default search limit is 100');
      expect(results.length, greaterThan(0),
          reason: 'Should find matches for common term');
    });

    // ── Benchmark 3: dashboard stats ─────────────────────────────────
    test('computeStats() completes in < 2s', () async {
      final ms = await _benchmark(
        'computeStats()',
        () async {
          final stats = await statsService.computeStats();
          expect(stats.totalBookmarks, greaterThan(0));
        },
      );
      expect(ms, lessThan(2000), reason: 'Dashboard stats should compute quickly');
    });

    test('_computeTopTags equivalent query completes in < 500ms', () async {
      // _computeTopTags is private; benchmark the exact query it executes.
      final ms = await _benchmark(
        '_computeTopTags query',
        () async {
          final bookmarks = await isar.bookmarkItems
              .filter()
              .isDeletedEqualTo(false)
              .isInVaultEqualTo(false)
              .tagIdsIsNotNull()
              .sortByCreatedAtDesc()
              .limit(1000)
              .findAll();
          expect(bookmarks.length, greaterThan(0));
        },
      );
      expect(ms, lessThan(500),
          reason: 'Top-tags bounded query should be fast');
    });

    // ── Benchmark 4: incremental loadMore ────────────────────────────
    test('incremental loadMore calls (offset 24, 48, 72) each return in < 300ms',
        () async {
      for (final offset in const <int>[24, 48, 72]) {
        late List<BookmarkItem> items;
        final ms = await _benchmark(
          'getAll(offset: $offset, limit: $_kPageSize)',
          () async {
            items = await repository.getAll(offset: offset, limit: _kPageSize);
          },
        );
        expect(ms, lessThan(300),
            reason: 'Page at offset $offset should load fast');
        expect(items.length, lessThanOrEqualTo(_kPageSize));
      }
    });

    // ── Baseline count verification ──────────────────────────────────
    test('database contains expected record count', () async {
      final count = await isar.bookmarkItems.where().count();
      expect(count, _kRecordCount);
    });
  });
}
