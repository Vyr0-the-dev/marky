@Tags(<String>['integration'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/bookmark_entity.dart';
import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/core/database/marky_database.dart';
import 'package:marky/features/bookmarks/data/isar_bookmark_repository.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';

/// Fixture builder. The repository tests don't care about most fields
/// most of the time; this collapses the noise so the asserts read
/// clearly.
Bookmark _bookmark({
  String url = 'https://example.com/',
  String? canonical,
  String? host,
  String? hash,
  String? title,
  bool fav = false,
  bool archived = false,
  bool unread = true,
  bool pinned = false,
  DateTime? createdAt,
  DateTime? lastInteractionAt,
  List<int> tagIds = const <int>[],
  List<int> collectionIds = const <int>[],
  BookmarkContentType type = BookmarkContentType.unknown,
  BookmarkSourceType source = BookmarkSourceType.manual,
  BookmarkScrapingStatus status = BookmarkScrapingStatus.done,
}) {
  final DateTime now = createdAt ?? DateTime(2026);
  return Bookmark(
    originalUrl: url,
    canonicalUrl: canonical ?? url,
    normalizedHost: host ?? Uri.parse(url).host,
    urlHash: hash,
    title: title,
    isFavorite: fav,
    isArchived: archived,
    isRead: !unread,
    isPinned: pinned,
    tagIds: tagIds,
    collectionIds: collectionIds,
    contentType: type,
    sourceType: source,
    scrapingStatus: status,
    createdAt: now,
    updatedAt: now,
    lastInteractionAt: lastInteractionAt,
  );
}

void main() {
  late Directory tempDir;
  late Isar isar;
  late BookmarkRepository repo;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('bookmark_repo_test_');
    isar = await MarkyDatabase.open(
      directory: tempDir.path,
      name: 'test_${tempDir.path.hashCode}',
    );
    repo = IsarBookmarkRepository(isar);
  });

  tearDown(() async {
    if (isar.isOpen) {
      await isar.close(deleteFromDisk: true);
    }
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('save / getById', () {
    test('insert assigns id and stamps updatedAt', () async {
      final DateTime before = DateTime.now();
      final Bookmark saved = await repo.save(
        _bookmark(url: 'https://flutter.dev/'),
      );

      expect(saved.id, isNotNull);
      // Repository writes its own `updatedAt`, regardless of input.
      expect(
        saved.updatedAt.isAtSameMomentAs(before) ||
            saved.updatedAt.isAfter(before),
        isTrue,
      );

      final Bookmark? roundtrip = await repo.getById(saved.id!);
      expect(roundtrip, equals(saved));
    });

    test('update by passing existing id replaces the row', () async {
      final Bookmark saved = await repo.save(_bookmark());
      final Bookmark edited = saved.copyWith(title: 'Edited');
      final Bookmark updated = await repo.save(edited);

      expect(updated.id, saved.id);
      expect(updated.title, 'Edited');
      expect(await isar.bookmarks.count(), 1);
    });

    test('saveAll preserves order and assigns ids', () async {
      final List<Bookmark> input = <Bookmark>[
        _bookmark(url: 'https://a.test/'),
        _bookmark(url: 'https://b.test/'),
        _bookmark(url: 'https://c.test/'),
      ];
      final List<Bookmark> out = await repo.saveAll(input);
      expect(out.map((Bookmark b) => b.originalUrl),
          <String>['https://a.test/', 'https://b.test/', 'https://c.test/']);
      expect(out.every((Bookmark b) => b.id != null), isTrue);
    });
  });

  group('lookup probes', () {
    test('findByUrlHash returns the right row', () async {
      await repo.save(_bookmark(hash: 'abc'));
      await repo.save(_bookmark(url: 'https://other.test/', hash: 'xyz'));

      final Bookmark? hit = await repo.findByUrlHash('xyz');
      expect(hit?.originalUrl, 'https://other.test/');

      final Bookmark? miss = await repo.findByUrlHash('nope');
      expect(miss, isNull);
    });

    test('findByCanonicalUrl matches exact canonical', () async {
      await repo.save(_bookmark(canonical: 'https://example.com/x'));
      final Bookmark? hit =
          await repo.findByCanonicalUrl('https://example.com/x');
      expect(hit, isNotNull);
    });
  });

  group('feed query', () {
    Future<void> seed() async {
      final DateTime base = DateTime(2026);
      // Six bookmarks with mixed states. Indexes for clarity:
      //   0 — fresh, fav, unread
      //   1 — older, plain, unread
      //   2 — pinned + read
      //   3 — archived (should hide from .all/.favorites/.unread)
      //   4 — favorite + read
      //   5 — youtube.com host, video content type
      await repo.saveAll(<Bookmark>[
        _bookmark(
          url: 'https://a.test/0',
          title: 'Alpha',
          fav: true,
          createdAt: base.add(const Duration(days: 6)),
        ),
        _bookmark(
          url: 'https://b.test/1',
          title: 'Bravo',
          createdAt: base.add(const Duration(days: 3)),
        ),
        _bookmark(
          url: 'https://c.test/2',
          title: 'Charlie',
          unread: false,
          pinned: true,
          createdAt: base.add(const Duration(days: 1)),
        ),
        _bookmark(
          url: 'https://d.test/3',
          title: 'Delta',
          archived: true,
          createdAt: base.add(const Duration(days: 5)),
        ),
        _bookmark(
          url: 'https://e.test/4',
          title: 'Echo',
          fav: true,
          unread: false,
          createdAt: base.add(const Duration(days: 4)),
        ),
        _bookmark(
          url: 'https://www.youtube.com/watch?v=1',
          host: 'youtube.com',
          title: 'Foxtrot',
          type: BookmarkContentType.video,
          createdAt: base.add(const Duration(days: 2)),
        ),
      ]);
    }

    test('all + newestFirst hides archived and pins to top', () async {
      await seed();
      final List<Bookmark> page = await repo.feed(const BookmarkFeedQuery());
      // Charlie is pinned → first regardless of createdAt.
      expect(page.first.title, 'Charlie');
      // Remaining order is newest → oldest among non-archived,
      // non-pinned: Alpha(6), Echo(4), Bravo(3), Foxtrot(2).
      expect(
        page.skip(1).map((Bookmark b) => b.title),
        <String>['Alpha', 'Echo', 'Bravo', 'Foxtrot'],
      );
    });

    test('favorites filter narrows to fav only', () async {
      await seed();
      final List<Bookmark> page = await repo.feed(
        const BookmarkFeedQuery(filter: BookmarkFeedFilter.favorites),
      );
      expect(page.map((Bookmark b) => b.title), <String>['Alpha', 'Echo']);
    });

    test('unread filter excludes read items', () async {
      await seed();
      final List<Bookmark> page = await repo.feed(
        const BookmarkFeedQuery(filter: BookmarkFeedFilter.unread),
      );
      // Charlie pinned (but read so excluded), Echo read so excluded,
      // Delta archived. Remaining: Alpha, Bravo, Foxtrot.
      expect(page.map((Bookmark b) => b.title),
          <String>['Alpha', 'Bravo', 'Foxtrot']);
    });

    test('archived filter shows ONLY archived', () async {
      await seed();
      final List<Bookmark> page = await repo.feed(
        const BookmarkFeedQuery(filter: BookmarkFeedFilter.archived),
      );
      expect(page.map((Bookmark b) => b.title), <String>['Delta']);
    });

    test('host narrowing returns matching items only', () async {
      await seed();
      final List<Bookmark> page = await repo.feed(
        const BookmarkFeedQuery(host: 'youtube.com'),
      );
      expect(page.map((Bookmark b) => b.title), <String>['Foxtrot']);
    });

    test('contentType narrowing returns matching items only', () async {
      await seed();
      final List<Bookmark> page = await repo.feed(
        const BookmarkFeedQuery(contentType: BookmarkContentType.video),
      );
      expect(page.map((Bookmark b) => b.title), <String>['Foxtrot']);
    });

    test('titleAscending sorts alphabetically with pin override', () async {
      await seed();
      final List<Bookmark> page = await repo.feed(
        const BookmarkFeedQuery(sort: BookmarkSort.titleAscending),
      );
      // Charlie pinned first, then alpha-asc among the rest:
      // Alpha, Bravo, Echo, Foxtrot.
      expect(
        page.map((Bookmark b) => b.title),
        <String>['Charlie', 'Alpha', 'Bravo', 'Echo', 'Foxtrot'],
      );
    });

    test('limit + offset paginates deterministically', () async {
      await seed();
      final List<Bookmark> p0 = await repo.feed(
        const BookmarkFeedQuery(limit: 2),
      );
      final List<Bookmark> p1 = await repo.feed(
        const BookmarkFeedQuery(limit: 2, offset: 2),
      );
      expect(p0.map((Bookmark b) => b.title), <String>['Charlie', 'Alpha']);
      expect(p1.map((Bookmark b) => b.title), <String>['Echo', 'Bravo']);
    });

    test('invalid pagination values are safe', () async {
      await seed();

      final List<Bookmark> empty = await repo.feed(
        const BookmarkFeedQuery(limit: -1),
      );
      final List<Bookmark> negativeOffset = await repo.feed(
        const BookmarkFeedQuery(limit: 2, offset: -20),
      );
      final List<Bookmark> hugeLimit = await repo.feed(
        const BookmarkFeedQuery(limit: 9999),
      );

      expect(empty, isEmpty);
      expect(
        negativeOffset.map((Bookmark b) => b.title),
        <String>['Charlie', 'Alpha'],
      );
      expect(hugeLimit.length, 5);
    });

    test('count matches feed length when limit is generous', () async {
      await seed();
      const BookmarkFeedQuery query = BookmarkFeedQuery();
      final List<Bookmark> page = await repo.feed(query);
      final int total = await repo.count(query);
      expect(total, page.length);
    });

    test('countAll excludes archived', () async {
      await seed();
      // 5 non-archived + 1 archived = 5 expected.
      expect(await repo.countAll(), 5);
    });
  });

  group('search', () {
    test('returns empty result for non-positive limit', () async {
      await repo.save(_bookmark(title: 'Flutter Guide'));

      expect(await repo.search('flutter', limit: 0), isEmpty);
      expect(await repo.search('flutter', limit: -4), isEmpty);
    });

    test('clamps very large limits', () async {
      final List<Bookmark> rows = List<Bookmark>.generate(
        120,
        (int index) => _bookmark(
          url: 'https://search.test/$index',
          title: 'Flutter Guide $index',
        ),
      );
      await repo.saveAll(rows);

      final List<Bookmark> results = await repo.search('flutter', limit: 500);

      expect(results.length, 100);
      expect(
        results.every((Bookmark b) => b.title!.contains('Flutter')),
        isTrue,
      );
    });
  });

  group('streams', () {
    test('watchFeed emits initial page then re-emits after a write', () async {
      final Stream<List<Bookmark>> stream =
          repo.watchFeed(const BookmarkFeedQuery());

      final Completer<List<Bookmark>> first = Completer<List<Bookmark>>();
      final Completer<List<Bookmark>> second = Completer<List<Bookmark>>();
      int seen = 0;
      late StreamSubscription<List<Bookmark>> sub;
      sub = stream.listen((List<Bookmark> page) {
        seen++;
        if (seen == 1) {
          first.complete(page);
        } else if (seen == 2 && !second.isCompleted) {
          second.complete(page);
        }
      });

      final List<Bookmark> initial = await first.future;
      expect(initial, isEmpty);

      await repo.save(_bookmark(title: 'Saved'));

      final List<Bookmark> next = await second.future;
      expect(next.single.title, 'Saved');

      await sub.cancel();
    });

    test('watchById emits null after the row is deleted', () async {
      final Bookmark saved = await repo.save(_bookmark(title: 'Doomed'));
      final Stream<Bookmark?> stream = repo.watchById(saved.id!);

      final Completer<Bookmark?> first = Completer<Bookmark?>();
      final Completer<Bookmark?> deleted = Completer<Bookmark?>();
      int seen = 0;
      late StreamSubscription<Bookmark?> sub;
      sub = stream.listen((Bookmark? row) {
        seen++;
        if (seen == 1) {
          first.complete(row);
        } else if (seen == 2 && !deleted.isCompleted) {
          deleted.complete(row);
        }
      });

      expect((await first.future)?.title, 'Doomed');
      await repo.delete(saved.id!);
      expect(await deleted.future, isNull);

      await sub.cancel();
    });
  });

  group('delete', () {
    test('delete returns true for existing, false for missing', () async {
      final Bookmark saved = await repo.save(_bookmark());
      expect(await repo.delete(saved.id!), isTrue);
      expect(await repo.delete(saved.id!), isFalse);
    });

    test('deleteAll returns count actually removed', () async {
      final List<Bookmark> rows = await repo.saveAll(<Bookmark>[
        _bookmark(url: 'https://a.test/'),
        _bookmark(url: 'https://b.test/'),
      ]);
      final List<int> ids = rows.map((Bookmark b) => b.id!).toList();
      ids.add(99999); // doesn't exist
      expect(await repo.deleteAll(ids), 2);
    });
  });
}
