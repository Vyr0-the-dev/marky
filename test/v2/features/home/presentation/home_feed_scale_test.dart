import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/home/presentation/home_screen.dart';
import 'package:marky/features/home/presentation/widgets/bookmark_card.dart';

void main() {
  testWidgets('home feed keeps first render bounded at scale',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final int total in <int>[0, 100, 1000, 5000]) {
      final _ScaleBookmarkRepository repository =
          _ScaleBookmarkRepository(_bookmarks(total));

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            ...testAppSettingsOverrides(),
            bookmarkRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(repository.requestedQueries, isNotEmpty);
      expect(
        repository.requestedQueries.any(
          (BookmarkFeedQuery query) => query.limit == 100 && query.offset == 0,
        ),
        isTrue,
      );

      if (total == 0) {
        expect(find.text('Your library is quiet'), findsOneWidget);
      } else {
        expect(find.text('Scale Bookmark 0001'), findsOneWidget);
        expect(find.byType(BookmarkCard).evaluate().length, lessThan(40));
      }
    }
  });
}

List<Bookmark> _bookmarks(int count) {
  final DateTime base = DateTime(2026, 1, 1, 12);
  return List<Bookmark>.generate(count, (int index) {
    final int id = index + 1;
    return Bookmark(
      id: id,
      originalUrl: 'https://example.com/scale/$id',
      canonicalUrl: 'https://example.com/scale/$id',
      normalizedHost: 'example.com',
      title: 'Scale Bookmark ${id.toString().padLeft(4, '0')}',
      scrapingStatus: BookmarkScrapingStatus.done,
      createdAt: base.subtract(Duration(minutes: index)),
      updatedAt: base.subtract(Duration(minutes: index)),
    );
  }, growable: false);
}

class _ScaleBookmarkRepository implements BookmarkRepository {
  _ScaleBookmarkRepository(this._bookmarks);

  final List<Bookmark> _bookmarks;
  final List<BookmarkFeedQuery> requestedQueries = <BookmarkFeedQuery>[];

  @override
  Future<Bookmark> save(Bookmark bookmark) async => bookmark;

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) async => bookmarks;

  @override
  Future<Bookmark?> getById(int id) async {
    for (final Bookmark bookmark in _bookmarks) {
      if (bookmark.id == id) return bookmark;
    }
    return null;
  }

  @override
  Future<List<Bookmark>> getByIds(List<int> ids) async {
    return _bookmarks
        .where((Bookmark bookmark) => ids.contains(bookmark.id))
        .toList(growable: false);
  }

  @override
  Future<bool> delete(int id) async => false;

  @override
  Future<int> deleteAll(List<int> ids) async => 0;

  @override
  Future<Bookmark?> findByUrlHash(String urlHash) async => null;

  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) async =>
      null;

  @override
  Future<int> countAll() async => _bookmarks.length;

  @override
  Future<int> count(BookmarkFeedQuery query) async => _filtered(query).length;

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => _page(query);

  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) {
    requestedQueries.add(query);
    return Stream<List<Bookmark>>.value(_page(query));
  }

  @override
  Stream<Bookmark?> watchById(int id) => Stream<Bookmark?>.value(null);

  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async =>
      <Bookmark>[];

  List<Bookmark> _page(BookmarkFeedQuery query) {
    return _filtered(query)
        .skip(query.offset)
        .take(query.limit)
        .toList(growable: false);
  }

  Iterable<Bookmark> _filtered(BookmarkFeedQuery query) {
    return _bookmarks.where((Bookmark bookmark) {
      return switch (query.filter) {
        BookmarkFeedFilter.all => !bookmark.isArchived,
        BookmarkFeedFilter.favorites =>
          !bookmark.isArchived && bookmark.isFavorite,
        BookmarkFeedFilter.unread => !bookmark.isArchived && !bookmark.isRead,
        BookmarkFeedFilter.archived => bookmark.isArchived,
      };
    });
  }
}
