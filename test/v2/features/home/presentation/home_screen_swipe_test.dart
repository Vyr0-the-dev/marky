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
import 'package:marky/l10n/app_localizations.dart';

void main() {
  testWidgets('swiping right toggles read status with undo option',
      (WidgetTester tester) async {
    final _SwipeMockBookmarkRepository repository =
        _SwipeMockBookmarkRepository(<Bookmark>[
      Bookmark(
        id: 1,
        originalUrl: 'https://example.com/item1',
        canonicalUrl: 'https://example.com/item1',
        normalizedHost: 'example.com',
        title: 'Test Article',
        scrapingStatus: BookmarkScrapingStatus.done,
        isRead: false,
        isArchived: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          ...testAppSettingsOverrides(),
          bookmarkRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: HomeScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Article'), findsOneWidget);
    expect(find.byType(Dismissible), findsOneWidget);

    // Swipe right (start to end)
    await tester.fling(find.byType(BookmarkCard), const Offset(500, 0), 1000);
    await tester.pumpAndSettle();

    expect(repository.savedBookmarks, isNotEmpty);
    expect(repository.savedBookmarks.last.isRead, isTrue);

    expect(find.text('Marked as read'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(repository.savedBookmarks.last.isRead, isFalse);
  });

  testWidgets('swiping left archives active bookmark with undo option',
      (WidgetTester tester) async {
    final _SwipeMockBookmarkRepository repository =
        _SwipeMockBookmarkRepository(<Bookmark>[
      Bookmark(
        id: 2,
        originalUrl: 'https://example.com/item2',
        canonicalUrl: 'https://example.com/item2',
        normalizedHost: 'example.com',
        title: 'Archivable Bookmark',
        scrapingStatus: BookmarkScrapingStatus.done,
        isRead: false,
        isArchived: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          ...testAppSettingsOverrides(),
          bookmarkRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: HomeScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Swipe left (end to start)
    await tester.fling(find.byType(BookmarkCard), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();

    expect(repository.savedBookmarks, isNotEmpty);
    expect(repository.savedBookmarks.last.isArchived, isTrue);

    expect(find.text('Bookmark archived'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(repository.savedBookmarks.last.isArchived, isFalse);
  });
}

class _SwipeMockBookmarkRepository implements BookmarkRepository {
  _SwipeMockBookmarkRepository(this._items);

  final List<Bookmark> _items;
  final List<Bookmark> savedBookmarks = <Bookmark>[];
  final List<int> deletedIds = <int>[];

  @override
  Future<Bookmark> save(Bookmark bookmark) async {
    savedBookmarks.add(bookmark);
    final int idx = _items.indexWhere((Bookmark b) => b.id == bookmark.id);
    if (idx >= 0) {
      _items[idx] = bookmark;
    } else {
      _items.add(bookmark);
    }
    return bookmark;
  }

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) async {
    for (final Bookmark b in bookmarks) {
      await save(b);
    }
    return bookmarks;
  }

  @override
  Future<bool> delete(int id) async {
    deletedIds.add(id);
    _items.removeWhere((Bookmark b) => b.id == id);
    return true;
  }

  @override
  Future<int> deleteAll(List<int> ids) async {
    deletedIds.addAll(ids);
    _items.removeWhere((Bookmark b) => ids.contains(b.id));
    return ids.length;
  }

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => _filtered(query);

  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) {
    return Stream<List<Bookmark>>.value(_filtered(query));
  }

  @override
  Future<Bookmark?> getById(int id) async {
    return _items.cast<Bookmark?>().firstWhere(
          (Bookmark? b) => b?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<List<Bookmark>> getByIds(List<int> ids) async {
    return _items.where((Bookmark b) => ids.contains(b.id)).toList();
  }

  @override
  Stream<Bookmark?> watchById(int id) {
    return Stream<Bookmark?>.value(getById(id) as dynamic);
  }

  @override
  Future<int> count(BookmarkFeedQuery query) async => _filtered(query).length;

  @override
  Future<int> countAll() async => _items.length;

  @override
  Future<Bookmark?> findByCanonicalUrl(String url) async => null;

  @override
  Future<Bookmark?> findByUrlHash(String hash) async => null;

  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) async =>
      null;

  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async =>
      <Bookmark>[];

  List<Bookmark> _filtered(BookmarkFeedQuery query) {
    return _items.where((Bookmark bookmark) {
      return switch (query.filter) {
        BookmarkFeedFilter.all => !bookmark.isArchived,
        BookmarkFeedFilter.favorites =>
          !bookmark.isArchived && bookmark.isFavorite,
        BookmarkFeedFilter.unread => !bookmark.isArchived && !bookmark.isRead,
        BookmarkFeedFilter.archived => bookmark.isArchived,
      };
    }).toList();
  }
}
