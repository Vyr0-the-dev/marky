import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/features/feed/presentation/widgets/bookmark_card.dart';
import 'package:marky/shared/models/bookmark_item.dart';

void main() {
  group('BookmarkCard', () {
    BookmarkItem createBookmark({
      String? title,
      String? heroImageUrl,
      String? thumbnailUrl,
      String? localThumbnailPath,
      String? faviconUrl,
      String? localFaviconPath,
      bool isFavorite = false,
      List<int>? noteIds,
    }) {
      return BookmarkItem(
        originalUrl: 'https://example.com/article',
        title: title,
        heroImageUrl: heroImageUrl,
        thumbnailUrl: thumbnailUrl,
        localThumbnailPath: localThumbnailPath,
        faviconUrl: faviconUrl,
        localFaviconPath: localFaviconPath,
        isFavorite: isFavorite,
        noteIds: noteIds,
        createdAt: DateTime(2024, 6, 15),
        updatedAt: DateTime(2024, 6, 15),
      );
    }

    testWidgets('shows note badge with count when noteIds has multiple items',
        (WidgetTester tester) async {
      final bookmark = createBookmark(noteIds: <int>[1, 2, 3]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BookmarkCard(bookmark: bookmark),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.note), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows note icon without count when noteIds has one item',
        (WidgetTester tester) async {
      final bookmark = createBookmark(noteIds: <int>[42]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BookmarkCard(bookmark: bookmark),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.note), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('note badge is absent when noteIds is null',
        (WidgetTester tester) async {
      final bookmark = createBookmark();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BookmarkCard(bookmark: bookmark),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.note), findsNothing);
    });

    testWidgets('renders title when present', (WidgetTester tester) async {
      final bookmark = createBookmark(title: 'My Great Article');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.text('My Great Article'), findsOneWidget);
    });

    testWidgets('falls back to domain when title is null',
        (WidgetTester tester) async {
      final bookmark = createBookmark();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      // Domain appears as fallback title (cardTitle style, 16px) and in
      // metadata row (metadata style, 12px). Verify at least one presence.
      expect(find.text('example.com'), findsWidgets);
    });

    testWidgets('renders image area when heroImageUrl is present',
        (WidgetTester tester) async {
      final bookmark = createBookmark(
        heroImageUrl: 'https://example.com/image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      // CachedNetworkImage renders a placeholder widget initially while loading
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('renders placeholder when no image URL is present',
        (WidgetTester tester) async {
      final bookmark = createBookmark();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('shows filled favorite icon when isFavorite is true',
        (WidgetTester tester) async {
      final bookmark = createBookmark(isFavorite: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      final Icon favoriteIcon = tester.widget(
        find.byIcon(Icons.star),
      );
      expect(favoriteIcon.color, AppColors.accentPrimary);
    });

    testWidgets('shows outlined favorite icon when isFavorite is false',
        (WidgetTester tester) async {
      final bookmark = createBookmark();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('all three action icons are visible',
        (WidgetTester tester) async {
      final bookmark = createBookmark();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    testWidgets('exposes semantic labels for bookmark action buttons',
        (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);
      final bookmark = createBookmark();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Favorite'), findsOneWidget);
      expect(find.bySemanticsLabel('Archive'), findsOneWidget);
      expect(find.bySemanticsLabel('Share'), findsOneWidget);
    });

    testWidgets('calls onFavoriteToggle when favorite icon tapped',
        (WidgetTester tester) async {
      bool toggled = false;
      final bookmark = createBookmark();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(
              bookmark: bookmark,
              onFavoriteToggle: () => toggled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.star_border));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('calls onArchive when archive icon tapped',
        (WidgetTester tester) async {
      bool archived = false;
      final bookmark = createBookmark();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(
              bookmark: bookmark,
              onArchive: () => archived = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pump();

      expect(archived, isTrue);
    });

    testWidgets('calls onShare when share icon tapped',
        (WidgetTester tester) async {
      bool shared = false;
      final bookmark = createBookmark();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(
              bookmark: bookmark,
              onShare: () => shared = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pump();

      expect(shared, isTrue);
    });

    testWidgets('prefers localThumbnailPath over remote URLs',
        (WidgetTester tester) async {
      final bookmark = createBookmark(
        localThumbnailPath: '/fake/local/path.jpg',
        heroImageUrl: 'https://example.com/image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('fade-in AnimatedOpacity is present when local image is used',
        (WidgetTester tester) async {
      final bookmark = createBookmark(
        localThumbnailPath: '/fake/local/path.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.byType(AnimatedOpacity), findsOneWidget);
    });

    testWidgets('remote URL fallback works when no local path is set',
        (WidgetTester tester) async {
      final bookmark = createBookmark(
        heroImageUrl: 'https://example.com/image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('renders local favicon when localFaviconPath is present',
        (WidgetTester tester) async {
      final bookmark = createBookmark(
        localFaviconPath: '/fake/favicon.png',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(AnimatedOpacity), findsOneWidget);
    });

    testWidgets('renders remote favicon when faviconUrl is present',
        (WidgetTester tester) async {
      final bookmark = createBookmark(
        faviconUrl: 'https://example.com/favicon.ico',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('shows monogram fallback when both favicon fields are null',
        (WidgetTester tester) async {
      final bookmark = createBookmark();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.text('E'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('skips SVG favicon and falls back to monogram',
        (WidgetTester tester) async {
      final bookmark = createBookmark(
        faviconUrl: 'https://example.com/icon.svg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookmarkCard(bookmark: bookmark),
          ),
        ),
      );

      expect(find.text('E'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });
  });
}
