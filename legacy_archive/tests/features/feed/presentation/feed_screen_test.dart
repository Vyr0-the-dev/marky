import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/feed/presentation/screens/feed_screen.dart';
import 'package:marky/features/feed/presentation/widgets/bookmark_card.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ─── Fake Repository ───────────────────────────────────────────────────

/// In-memory fake implementation of [BookmarkItemRepository] for testing.
class FakeBookmarkItemRepository implements BookmarkItemRepository {
  final List<BookmarkItem> _items = <BookmarkItem>[];

  void setItems(List<BookmarkItem> items) {
    _items
      ..clear()
      ..addAll(items);
  }

  @override
  Future<BookmarkItem?> getById(Id id) async {
    try {
      return _items.firstWhere((BookmarkItem item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async {
    var result = List<BookmarkItem>.from(_items);
    if (offset != null && offset > 0) {
      final int start = offset.clamp(0, result.length);
      result = result.sublist(start);
    }
    if (limit != null && limit >= 0) {
      result = result.take(limit).toList();
    }
    return result;
  }

  @override
  Future<Id> insert(BookmarkItem entity) async {
    _items.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async => entity.id;

  @override
  Future<void> delete(Id id) async {
    _items.removeWhere((BookmarkItem item) => item.id == id);
  }

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(
          String externalContentId) async =>
      null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId,
          {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId,
          {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query,
          {int? offset, int? limit}) async =>
      <BookmarkItem>[];
}

// ─── Test Helpers ──────────────────────────────────────────────────────

/// Creates sample bookmarks for test data.
BookmarkItem _makeBookmark({
  required int id,
  required String url,
  String? title,
  DateTime? createdAt,
}) {
  final DateTime now = createdAt ?? DateTime(2025, 1, 15);
  return BookmarkItem(
    originalUrl: url,
    canonicalUrl: url,
    urlHash: 'hash_$id',
    title: title,
    createdAt: now,
    updatedAt: now,
  )..id = id;
}

/// Builds the [FeedScreen] inside a [MaterialApp] with the Marky dark
/// theme and a [ProviderScope] that overrides the bookmark repository
/// with the given [fakeRepository].
Widget buildFeedScreen(FakeBookmarkItemRepository fakeRepository) {
  return ProviderScope(
    overrides: <Override>[
      bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: const FeedScreen(),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────

void main() {
  group('FeedScreen', () {
    late FakeBookmarkItemRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeBookmarkItemRepository();
    });

    testWidgets('renders app bar title "Feed"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      expect(find.text('Feed'), findsOneWidget);
    });

    testWidgets('shows empty state when no bookmarks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      expect(find.text('No bookmarks yet'), findsOneWidget);
      expect(
        find.text('Saved links will appear here once you add your first item.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('exposes feed header and main content semantics', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Feed')),
        matchesSemantics(label: 'Feed', isHeader: true),
      );
      expect(find.bySemanticsLabel('Bookmarks feed content'), findsOneWidget);
    });

    testWidgets('shows bookmark cards when bookmarks exist', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm1 = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter Documentation',
      );
      final BookmarkItem bm2 = _makeBookmark(
        id: 2,
        url: 'https://dart.dev',
        title: 'Dart Programming Language',
      );
      fakeRepository.setItems(<BookmarkItem>[bm1, bm2]);

      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      // Titles should be visible (scroll to second item if needed).
      expect(find.text('Flutter Documentation'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Dart Programming Language'),
        200,
      );
      expect(find.text('Dart Programming Language'), findsOneWidget);

      // Domains should be visible.
      expect(find.text('flutter.dev'), findsOneWidget);
      expect(find.text('dart.dev'), findsOneWidget);
    });

    testWidgets('falls back to domain when title is null', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://example.com/article',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      // Title is null, so domain is used as title fallback.
      expect(find.text('example.com'), findsNWidgets(2));
    });

    testWidgets('shows formatted date for each bookmark', (
      WidgetTester tester,
    ) async {
      final DateTime createdAt = DateTime(2025, 3, 20);
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://example.com',
        title: 'Example',
        createdAt: createdAt,
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      final String expectedDate = DateFormat.yMMMd().format(createdAt);
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('does not show empty state when bookmarks exist', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://example.com',
        title: 'Example',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      expect(find.text('No bookmarks yet'), findsNothing);
    });

    testWidgets('renders Card widgets for bookmarks', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://example.com',
        title: 'Example',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders correct number of BookmarkCard widgets', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm1 = _makeBookmark(
        id: 1,
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      final BookmarkItem bm2 = _makeBookmark(
        id: 2,
        url: 'https://dart.dev',
        title: 'Dart',
      );
      final BookmarkItem bm3 = _makeBookmark(
        id: 3,
        url: 'https://pub.dev',
        title: 'Pub',
      );
      fakeRepository.setItems(<BookmarkItem>[bm1, bm2, bm3]);

      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      expect(find.byType(BookmarkCard), findsNWidgets(3));
    });

    testWidgets('tapping BookmarkCard triggers onTap callback', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      final BookmarkItem bm = _makeBookmark(
        id: 42,
        url: 'https://flutter.dev',
        title: 'Flutter Docs',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            bookmarkRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: Scaffold(
              body: BookmarkCard(
                bookmark: bm,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the bookmark card.
      await tester.tap(find.byType(BookmarkCard));
      await tester.pumpAndSettle();

      // Verify onTap was called.
      expect(tapped, isTrue);
    });

    testWidgets('triggers loadMore when scrolled to bottom', (
      WidgetTester tester,
    ) async {
      // Generate enough items to fill more than one page (24 per page).
      final List<BookmarkItem> items = List<BookmarkItem>.generate(
        30,
        (int i) => _makeBookmark(
          id: i + 1,
          url: 'https://example.com/$i',
          title: 'Bookmark $i',
        ),
      );
      fakeRepository.setItems(items);

      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      // Bookmark 29 should not be visible initially (only first 24 loaded).
      expect(find.text('Bookmark 29'), findsNothing);

      // Scroll to the bottom to trigger loadMore.
      await tester.scrollUntilVisible(
        find.text('Bookmark 29'),
        300,
        scrollable: find.descendant(
          of: find.byType(MasonryGridView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      // After loadMore, the last item should be visible.
      expect(find.text('Bookmark 29'), findsOneWidget);
    });

    testWidgets('BookmarkCards are wrapped in RepaintBoundary', (
      WidgetTester tester,
    ) async {
      final BookmarkItem bm = _makeBookmark(
        id: 1,
        url: 'https://example.com',
        title: 'Example',
      );
      fakeRepository.setItems(<BookmarkItem>[bm]);

      await tester.pumpWidget(buildFeedScreen(fakeRepository));
      await tester.pumpAndSettle();

      // Find the BookmarkCard inside the MasonryGridView and verify
      // it has a RepaintBoundary as a direct ancestor.
      final Finder cardInGrid = find.descendant(
        of: find.byType(MasonryGridView),
        matching: find.byType(BookmarkCard),
      );
      expect(cardInGrid, findsOneWidget);

      final Element cardElement = tester.element(cardInGrid);
      final RenderObject renderObject = cardElement.renderObject!;
      // Walk up the render tree to find a RepaintBoundary.
      RenderObject? parent = renderObject.parent;
      bool foundRepaintBoundary = false;
      while (parent != null) {
        if (parent is RenderRepaintBoundary) {
          foundRepaintBoundary = true;
          break;
        }
        parent = parent.parent;
      }
      expect(foundRepaintBoundary, isTrue);
    });
  });
}

// ─── Delayed fake repository for testing loading states ────────────────

class DelayedFakeRepository implements BookmarkItemRepository {
  final List<BookmarkItem> _items = <BookmarkItem>[];
  final List<Completer<List<BookmarkItem>>> _pendingGetAllCompleters =
      <Completer<List<BookmarkItem>>>[];

  void setItems(List<BookmarkItem> items) {
    _items
      ..clear()
      ..addAll(items);
  }

  void startNextRequest() {
    // No-op: the completer is created in getAll.
  }

  void completeNextRequest() {
    for (final completer in _pendingGetAllCompleters) {
      if (!completer.isCompleted) {
        completer.complete(List<BookmarkItem>.from(_items));
      }
    }
    _pendingGetAllCompleters.clear();
  }

  @override
  Future<List<BookmarkItem>> getAll({int? offset, int? limit}) async {
    var result = List<BookmarkItem>.from(_items);
    if (offset != null && offset > 0) {
      final int start = offset.clamp(0, result.length);
      result = result.sublist(start);
    }
    if (limit != null && limit >= 0) {
      result = result.take(limit).toList();
    }

    // For non-initial loads (offset > 0), delay to allow catching loading state.
    if (offset != null && offset > 0) {
      final Completer<List<BookmarkItem>> completer =
          Completer<List<BookmarkItem>>();
      _pendingGetAllCompleters.add(completer);
      return completer.future;
    }

    return result;
  }

  @override
  Future<BookmarkItem?> getById(Id id) async {
    try {
      return _items.firstWhere((BookmarkItem item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Id> insert(BookmarkItem entity) async {
    _items.add(entity);
    return entity.id;
  }

  @override
  Future<Id> update(BookmarkItem entity) async => entity.id;

  @override
  Future<void> delete(Id id) async {
    _items.removeWhere((BookmarkItem item) => item.id == id);
  }

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<BookmarkItem?> getByUrlHash(String urlHash) async => null;

  @override
  Future<BookmarkItem?> getByCanonicalUrl(String canonicalUrl) async => null;

  @override
  Future<BookmarkItem?> getByExternalContentId(
          String externalContentId) async =>
      null;

  @override
  Future<List<BookmarkItem>> getByDuplicateGroupId(String groupId) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getFavorites({int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getArchived({int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByCollectionId(Id collectionId,
          {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> getByTagId(Id tagId,
          {int? offset, int? limit}) async =>
      <BookmarkItem>[];

  @override
  Future<List<BookmarkItem>> search(SearchQuery query,
          {int? offset, int? limit}) async =>
      <BookmarkItem>[];
}
