import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/home/presentation/home_screen.dart';
import 'package:marky/features/home/presentation/widgets/editorial_grid_card.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';

void main() {
  final DateTime baseTime = DateTime(2026, 2, 10, 12);

  List<Bookmark> sampleBookmarks() {
    return <Bookmark>[
      Bookmark(
        id: 1,
        originalUrl: 'https://linear.app/method/editorial-systems',
        canonicalUrl: 'https://linear.app/method/editorial-systems',
        normalizedHost: 'linear.app',
        title: 'Designing High-Craft Editorial Interfaces',
        snippet:
            'How typography, hairline borders, and warm graphite surfaces shape calm software.',
        readingTimeMinutes: 6,
        tagIds: const <int>[1, 2, 3],
        isFavorite: true,
        isPinned: true,
        scrapingStatus: BookmarkScrapingStatus.done,
        createdAt: baseTime,
        updatedAt: baseTime,
      ),
      Bookmark(
        id: 2,
        originalUrl: 'https://stripe.com/blog/payment-api-design',
        canonicalUrl: 'https://stripe.com/blog/payment-api-design',
        normalizedHost: 'stripe.com',
        title: 'API Design Principles for Long-Term Stability',
        readingTimeMinutes: 4,
        isRead: true,
        scrapingStatus: BookmarkScrapingStatus.done,
        createdAt: baseTime.subtract(const Duration(hours: 2)),
        updatedAt: baseTime.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  Widget buildTestHome({
    required List<Bookmark> bookmarks,
    List<Tag> tags = const <Tag>[],
    ReadingRoomVariant variant = ReadingRoomVariant.dark,
  }) {
    final _TestGridBookmarkRepository repo =
        _TestGridBookmarkRepository(bookmarks);
    return ProviderScope(
      overrides: <Override>[
        ...testAppSettingsOverrides(),
        bookmarkRepositoryProvider.overrideWithValue(repo),
        tagsProvider.overrideWith((ref) => Stream<List<Tag>>.value(tags)),
      ],
      child: MaterialApp(
        theme: ReadingRoomTheme.build(variant),
        home: const HomeScreen(),
      ),
    );
  }

  group('Dark Editorial Grid View', () {
    testWidgets(
      'renders EditorialGridCard with dark graphite surface, typographic cover fallback, snippet, meta footer, and max 2 tags',
      (WidgetTester tester) async {
        final List<Tag> tags = <Tag>[
          Tag(
            id: 1,
            name: 'Design',
            slug: 'design',
            createdAt: baseTime,
            updatedAt: baseTime,
          ),
          Tag(
            id: 2,
            name: 'Systems',
            slug: 'systems',
            createdAt: baseTime,
            updatedAt: baseTime,
          ),
          Tag(
            id: 3,
            name: 'OverflowTag',
            slug: 'overflow-tag',
            createdAt: baseTime,
            updatedAt: baseTime,
          ),
        ];

        await tester.pumpWidget(
          buildTestHome(bookmarks: sampleBookmarks(), tags: tags),
        );
        await tester.pumpAndSettle();

        // Switch from list view to grid view.
        await tester.tap(find.byIcon(Icons.grid_view_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(MasonryGridView), findsOneWidget);
        expect(find.byType(EditorialGridCard), findsNWidgets(2));
        expect(find.byType(TypographicEditorialCover), findsNWidgets(2));

        // Verify Title, Snippet, and Meta Footer ('linear.app • 6m').
        expect(
          find.text('Designing High-Craft Editorial Interfaces'),
          findsOneWidget,
        );
        expect(
          find.text(
            'How typography, hairline borders, and warm graphite surfaces shape calm software.',
          ),
          findsOneWidget,
        );
        expect(find.text('linear.app • 6m'), findsOneWidget);
        expect(find.text('stripe.com • 4m'), findsOneWidget);

        // Verify tag clamping (max 2 tags rendered on grid card).
        expect(find.text('Design'), findsOneWidget);
        expect(find.text('Systems'), findsOneWidget);
        expect(find.text('OverflowTag'), findsNothing);

        // Verify unread dot is shown for unread item #1 only.
        expect(
          find.byKey(const ValueKey<String>('editorial_unread_dot')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'adapts masonry column count across <600 (2 cols), <900 (3 cols), and >=900 (4 cols)',
      (WidgetTester tester) async {
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // 1) Compact phone width (400px -> 2 columns)
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(400, 900);

        await tester.pumpWidget(buildTestHome(bookmarks: sampleBookmarks()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.grid_view_rounded));
        await tester.pumpAndSettle();

        MasonryGridView grid = tester.widget<MasonryGridView>(
          find.byType(MasonryGridView),
        );
        SliverSimpleGridDelegateWithFixedCrossAxisCount delegate =
            grid.gridDelegate
                as SliverSimpleGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);

        // 2) Tablet width (720px -> 3 columns)
        tester.view.physicalSize = const Size(720, 900);
        await tester.pumpAndSettle();

        grid = tester.widget<MasonryGridView>(find.byType(MasonryGridView));
        delegate = grid.gridDelegate
            as SliverSimpleGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 3);

        // 3) Wide desktop/landscape width (1024px -> 4 columns)
        tester.view.physicalSize = const Size(1024, 900);
        await tester.pumpAndSettle();

        grid = tester.widget<MasonryGridView>(find.byType(MasonryGridView));
        delegate = grid.gridDelegate
            as SliverSimpleGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 4);
      },
    );

    testWidgets('applies 0.97 scale micro-interaction on press', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestHome(bookmarks: sampleBookmarks()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      final Finder firstCard = find.byType(EditorialGridCard).first;
      final Finder scaleFinder = find.descendant(
        of: firstCard,
        matching: find.byType(AnimatedScale),
      );

      expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1.0);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(firstCard),
      );
      await tester.pump();
      expect(tester.widget<AnimatedScale>(scaleFinder).scale, 0.97);

      await gesture.cancel();
      await tester.pump();
      expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1.0);
    });
  });
}

class _TestGridBookmarkRepository implements BookmarkRepository {
  _TestGridBookmarkRepository(this._bookmarks);

  final List<Bookmark> _bookmarks;

  @override
  Future<Bookmark> save(Bookmark bookmark) async => bookmark;

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) async => bookmarks;

  @override
  Future<Bookmark?> getById(int id) async => null;

  @override
  Future<List<Bookmark>> getByIds(List<int> ids) async => <Bookmark>[];

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
  Future<int> count(BookmarkFeedQuery query) async => _bookmarks.length;

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => _bookmarks;

  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      Stream<List<Bookmark>>.value(_bookmarks);

  @override
  Stream<Bookmark?> watchById(int id) => Stream<Bookmark?>.value(null);

  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async =>
      <Bookmark>[];
}
