import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marky/app/marky_app.dart';
import 'package:marky/app/routing/app_router.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/core/database/enums/bookmark_scraping_status.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/add/presentation/add_screen.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/capture/domain/capture_service.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_rule.dart';
import 'package:marky/features/notes/data/note_providers.dart';
import 'package:marky/features/notes/domain/note.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/features/search/data/search_query_providers.dart';
import 'package:marky/features/search/domain/search_query.dart';
import 'package:marky/features/search/domain/search_query_repository.dart';
import 'package:marky/features/share_intent/data/share_intent_providers.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';
import 'package:marky/shared/widgets/marky_bottom_nav.dart';

/// Faz 1 smoke tests for the Reading Room shell.
///
/// The tests are deliberately shallow — we're not testing feature
/// logic (those come in Faz 3+), just that the scaffold assembles and
/// primary tabs swap correctly without the old shell's regressions
/// (blank screens, missing nav, stuck branches).
void main() {
  /// Builds a [MarkyApp] inside a [ProviderScope] pre-seeded with
  /// the given [initial] settings. Tests that don't care about a
  /// specific setting pass `null` and get the factory defaults.
  Widget wrap({
    AppSettings? initial,
    String? initialLocation,
    List<Bookmark> bookmarks = const <Bookmark>[],
  }) {
    return ProviderScope(
      overrides: <Override>[
        ...testAppSettingsOverrides(initial: initial),
        markyRouterProvider.overrideWith(
          (ref) => MarkyAppRouter.build(initialLocation: initialLocation),
        ),
        bookmarkFeedProvider.overrideWith(
          (ref, query) => Stream<List<Bookmark>>.value(bookmarks),
        ),
        bookmarkCountProvider.overrideWith(
          (ref) async => bookmarks.length,
        ),
        bookmarkRepositoryProvider.overrideWithValue(_NoOpBookmarkRepository()),
        searchQueryRepositoryProvider.overrideWithValue(
          _NoOpSearchQueryRepository(),
        ),
        shareIntentInitialTextProvider.overrideWith((ref) async => null),
        shareIntentTextStreamProvider.overrideWith(
          (ref) => const Stream<String?>.empty(),
        ),
        tagRepositoryProvider.overrideWithValue(_NoOpTagRepository()),
        tagsProvider.overrideWith(
          (ref) => Stream<List<Tag>>.value(<Tag>[]),
        ),
        bookmarkCollectionRepositoryProvider.overrideWithValue(
          _NoOpBookmarkCollectionRepository(),
        ),
        bookmarkCollectionsProvider.overrideWith(
          (ref) =>
              Stream<List<BookmarkCollection>>.value(<BookmarkCollection>[]),
        ),
      ],
      child: const MarkyApp(),
    );
  }

  Widget wrapEndToEnd({
    required _StatefulBookmarkRepository repository,
    String? initialLocation,
  }) {
    return ProviderScope(
      overrides: <Override>[
        ...testAppSettingsOverrides(),
        markyRouterProvider.overrideWith(
          (ref) => MarkyAppRouter.build(initialLocation: initialLocation),
        ),
        bookmarkRepositoryProvider.overrideWithValue(repository),
        captureServiceProvider.overrideWithValue(_SmokeCaptureService(
          repository,
        )),
        searchQueryRepositoryProvider.overrideWithValue(
          _NoOpSearchQueryRepository(),
        ),
        shareIntentInitialTextProvider.overrideWith((ref) async => null),
        shareIntentTextStreamProvider.overrideWith(
          (ref) => const Stream<String?>.empty(),
        ),
        tagRepositoryProvider.overrideWithValue(_NoOpTagRepository()),
        tagsProvider.overrideWith(
          (ref) => Stream<List<Tag>>.value(<Tag>[]),
        ),
        tagByIdProvider.overrideWith(
          (ref, id) => Stream<Tag?>.value(null),
        ),
        bookmarkCollectionRepositoryProvider.overrideWithValue(
          _NoOpBookmarkCollectionRepository(),
        ),
        bookmarkCollectionsProvider.overrideWith(
          (ref) =>
              Stream<List<BookmarkCollection>>.value(<BookmarkCollection>[]),
        ),
        bookmarkCollectionByIdProvider.overrideWith(
          (ref, id) => Stream<BookmarkCollection?>.value(null),
        ),
        notesByBookmarkProvider.overrideWith(
          (ref, id) => Stream<List<Note>>.value(<Note>[]),
        ),
        remindersForBookmarkProvider.overrideWith(
          (ref, id) => Stream<List<Reminder>>.value(<Reminder>[]),
        ),
      ],
      child: const MarkyApp(),
    );
  }

  group('MarkyApp', () {
    testWidgets('renders Home tab on cold start', (WidgetTester tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('Marky'), findsOneWidget);
      expect(find.text('Your library is quiet'), findsOneWidget);
    });

    testWidgets('home bookmark cards expose useful semantic labels',
        (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final DateTime now = DateTime.now();
      try {
        await tester.pumpWidget(
          wrap(
            bookmarks: <Bookmark>[
              Bookmark(
                id: 1,
                originalUrl: 'https://example.com/article',
                canonicalUrl: 'https://example.com/article',
                normalizedHost: 'example.com',
                title: 'Semantic Article',
                isFavorite: true,
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.bySemanticsLabel(
            'Bookmark, Semantic Article, example.com · now, unread, favorite',
          ),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('shows bottom nav items including quick add and settings',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.byType(MarkyBottomNav), findsOneWidget);
      // One label per tab.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.byIcon(Icons.add_rounded),
        ),
        findsOneWidget,
      );
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('bottom nav exposes semantic labels',
        (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(MarkyBottomNav),
            matching: find.bySemanticsLabel('Home'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(MarkyBottomNav),
            matching: find.bySemanticsLabel('Search'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(MarkyBottomNav),
            matching: find.bySemanticsLabel('Quick Add'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(MarkyBottomNav),
            matching: find.bySemanticsLabel('Library'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(MarkyBottomNav),
            matching: find.bySemanticsLabel('Settings'),
          ),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('search field exposes a semantic input label',
        (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(MarkyBottomNav),
            matching: find.text('Search'),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel('Search bookmarks...'),
          findsAtLeastNWidgets(1),
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('release accessibility semantics cover detail actions',
        (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final _StatefulBookmarkRepository repository =
          _StatefulBookmarkRepository();
      try {
        final DateTime now = DateTime(2026, 1, 10, 9);
        final Bookmark saved = await repository.save(
          Bookmark(
            originalUrl: 'https://a11y.example.com/detail',
            canonicalUrl: 'https://a11y.example.com/detail',
            normalizedHost: 'a11y.example.com',
            title: 'D4 Accessibility Link',
            scrapingStatus: BookmarkScrapingStatus.done,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await tester.pumpWidget(
          wrapEndToEnd(
            repository: repository,
            initialLocation: Routes.bookmarkDetailPath(saved.id!),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel('Filter by domain a11y.example.com'),
          findsOneWidget,
        );
        expect(find.text('Open'), findsAtLeastNWidgets(1));
        expect(find.text('Copy'), findsAtLeastNWidgets(1));
        expect(find.byTooltip('Favorite'), findsOneWidget);
        expect(find.byTooltip('Pin'), findsOneWidget);
        expect(find.byTooltip('Share'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.more_horiz_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Edit'), findsAtLeastNWidgets(1));
        expect(find.text('Refetch'), findsAtLeastNWidgets(1));
        expect(find.text('Read'), findsAtLeastNWidgets(1));
        expect(find.text('Archive'), findsAtLeastNWidgets(1));
        expect(find.text('Delete'), findsAtLeastNWidgets(1));
        expect(tester.takeException(), isNull);
      } finally {
        repository.dispose();
        semantics.dispose();
      }
    });

    testWidgets('tapping Search nav item switches branch',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Find anything'), findsOneWidget);
    });

    testWidgets('tapping Library switches to Library branch',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();

      expect(find.text('No tags yet. Tap + to create one.'), findsOneWidget);
    });

    testWidgets('opens unread feed from cold-start route',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrap(initialLocation: Routes.homeUnread));
      await tester.pumpAndSettle();

      expect(find.text('All caught up'), findsOneWidget);
    });

    testWidgets('AppThemeMode.light applies warm off-white scaffold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          initial: const AppSettings.defaults().copyWith(
            themeMode: AppThemeMode.light,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext ctx = tester.element(find.text('Marky'));
      final ThemeData theme = Theme.of(ctx);
      expect(theme.scaffoldBackgroundColor.toARGB32(), 0xFFFAFAF7);
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('AppThemeMode.oled applies pure black scaffold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          initial: const AppSettings.defaults().copyWith(
            themeMode: AppThemeMode.oled,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext ctx = tester.element(find.text('Marky'));
      final ThemeData theme = Theme.of(ctx);
      expect(theme.scaffoldBackgroundColor.toARGB32(), 0xFF000000);
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('clamps large text scaling and respects reduced motion',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3)),
          child: wrap(
            initial: const AppSettings.defaults(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.text('Marky'));
      final MediaQueryData mediaQuery = MediaQuery.of(context);
      expect(mediaQuery.textScaler.scale(10), lessThanOrEqualTo(20));
      expect(mediaQuery.textScaler.scale(10), greaterThan(0));
      expect(mediaQuery.disableAnimations, isTrue);
    });

    testWidgets('preserves platform reduced motion when animations are enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: wrap(
            initial: const AppSettings.defaults(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.text('Marky'));
      expect(MediaQuery.of(context).disableAnimations, isTrue);

      final Finder navSwitchers = find.descendant(
        of: find.byType(MarkyBottomNav),
        matching: find.byType(AnimatedSwitcher),
      );
      final Iterable<AnimatedSwitcher> switchers =
          tester.widgetList<AnimatedSwitcher>(navSwitchers);
      expect(switchers, isNotEmpty);
      for (final AnimatedSwitcher switcher in switchers) {
        expect(switcher.duration, Duration.zero);
      }

      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.byIcon(Icons.add_rounded),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Manual input'));
      await tester.tap(find.text('Manual input'));
      await tester.pumpAndSettle();

      final Iterable<AnimatedSwitcher> addSwitchers =
          tester.widgetList<AnimatedSwitcher>(
        find.descendant(
          of: find.byType(AddScreen),
          matching: find.byType(AnimatedSwitcher),
        ),
      );
      expect(addSwitchers, isNotEmpty);
      for (final AnimatedSwitcher switcher in addSwitchers) {
        expect(switcher.duration, Duration.zero);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('large text scaling does not break primary tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3.5)),
          child: wrap(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Find anything'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.byIcon(Icons.add_rounded),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Manual input'));
      await tester.tap(find.text('Manual input'));
      await tester.pumpAndSettle();
      expect(find.text('Paste, share, or type a link'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      expect(find.text('No tags yet. Tap + to create one.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('release text scales keep core screens usable',
        (WidgetTester tester) async {
      for (final double scale in <double>[1, 1.5, 2]) {
        final _StatefulBookmarkRepository repository =
            _StatefulBookmarkRepository();
        try {
          final DateTime now = DateTime(2026, 1, 10, 9);
          await repository.save(
            Bookmark(
              originalUrl: 'https://example.com/d2-scale',
              canonicalUrl: 'https://example.com/d2-scale',
              normalizedHost: 'example.com',
              title: 'D2 Scale Link',
              scrapingStatus: BookmarkScrapingStatus.done,
              createdAt: now,
              updatedAt: now,
            ),
          );

          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: wrapEndToEnd(repository: repository),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('D2 Scale Link'), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.tap(find.text('D2 Scale Link'));
          await tester.pumpAndSettle();
          expect(find.text('Metadata'), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          await tester.tap(
            find.descendant(
              of: find.byType(MarkyBottomNav),
              matching: find.text('Search'),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Find anything'), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.tap(
            find.descendant(
              of: find.byType(MarkyBottomNav),
              matching: find.byIcon(Icons.add_rounded),
            ),
          );
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Manual input'));
          await tester.tap(find.text('Manual input'));
          await tester.pumpAndSettle();
          expect(find.text('Paste, share, or type a link'), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          await tester.tap(
            find.descendant(
              of: find.byType(MarkyBottomNav),
              matching: find.text('Library'),
            ),
          );
          await tester.pumpAndSettle();
          expect(
              find.text('No tags yet. Tap + to create one.'), findsOneWidget);
          expect(find.text('No collections yet. Tap + to create one.'),
              findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.tap(
            find.descendant(
              of: find.byType(MarkyBottomNav),
              matching: find.text('Settings'),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Unread reminders'), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        } finally {
          repository.dispose();
        }
      }
    });

    testWidgets('Add paste action fills the URL field without crashing',
        (WidgetTester tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.getData') {
            return <String, dynamic>{
              'text': 'https://example.com/from-clipboard',
            };
          }
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.byIcon(Icons.add_rounded),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Manual input'));
      await tester.tap(find.text('Manual input'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Paste from clipboard'));
      await tester.pump();

      final EditableText field = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(field.controller.text, 'https://example.com/from-clipboard');
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'runs capture to feed to detail to search to library smoke path',
        (WidgetTester tester) async {
      final _StatefulBookmarkRepository repository =
          _StatefulBookmarkRepository();
      addTearDown(repository.dispose);

      await tester.pumpWidget(wrapEndToEnd(repository: repository));
      await tester.pumpAndSettle();
      expect(find.text('Your library is quiet'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.byIcon(Icons.add_rounded),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Manual input'));
      await tester.tap(find.text('Manual input'));
      await tester.pumpAndSettle();
      expect(find.text('Paste, share, or type a link'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'https://example.com/b4-smoke',
      );
      await tester.testTextInput.receiveAction(TextInputAction.go);
      await tester.pumpAndSettle();

      expect(find.text('Saved!'), findsWidgets);
      expect(find.text('B4 Smoke Link'), findsOneWidget);

      await tester.tap(find.byTooltip('View detail'));
      await tester.pumpAndSettle();
      expect(find.text('Metadata'), findsOneWidget);
      expect(find.text('B4 Smoke Link'), findsWidgets);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('B4 Smoke Link'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.text('Search'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'b4 smoke');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('B4 Smoke Link'), findsOneWidget);

      await tester.tap(find.text('B4 Smoke Link'));
      await tester.pumpAndSettle();
      expect(find.text('Metadata'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.text('Library'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No tags yet. Tap + to create one.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Turkish locale renders TR exit warning on Home back press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          initial: const AppSettings.defaults().copyWith(
            locale: AppLocaleChoice.tr,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Simulate a hardware-back press on Home. PopScope intercepts
      // and fires the snackbar — we should see the TR translation.
      final NavigatorState nav = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      await nav.maybePop();
      await tester.pump();

      expect(find.text('Çıkmak için tekrar basın'), findsOneWidget);
    });

    testWidgets('uses explicit Turkish locale when selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          initial: const AppSettings.defaults().copyWith(
            locale: AppLocaleChoice.tr,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.text('Marky'));
      expect(Localizations.localeOf(context).languageCode, 'tr');
    });

    testWidgets('Turkish locale renders core release surfaces',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          initial: const AppSettings.defaults().copyWith(
            locale: AppLocaleChoice.tr,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kitaplığınız sessiz'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.text('Ara'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Her şeyi bulun'), findsOneWidget);
      expect(
        find.text(
          'Yararlı aramaları yıldız düğmesiyle kaydedin.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.byIcon(Icons.add_rounded),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Manuel Gir'));
      await tester.tap(find.text('Manuel Gir'));
      await tester.pumpAndSettle();
      expect(
        find.text('Bağlantı yapıştırın, paylaşın veya yazın'),
        findsOneWidget,
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.text('Kitaplık'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Henüz etiket yok. Oluşturmak için + düğmesine dokunun.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Henüz koleksiyon yok. Oluşturmak için + düğmesine dokunun.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(MarkyBottomNav),
          matching: find.text('Ayarlar'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Görünüm'), findsOneWidget);
      expect(find.text('Unread reminders'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Advanced'),
        150,
      );
      expect(find.text('Advanced'), findsOneWidget);
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Yedeği dışa aktar (JSON)'),
        200,
      );
      expect(find.text('Yedeği dışa aktar (JSON)'), findsOneWidget);
    });
  });

  group('MarkyAppRouter', () {
    test('exposes a stable rootNavigatorKey', () {
      final GlobalKey<NavigatorState> a = MarkyAppRouter.rootNavigatorKey;
      final GlobalKey<NavigatorState> b = MarkyAppRouter.rootNavigatorKey;
      expect(identical(a, b), isTrue);
    });
  });
}

/// Minimal no-op repository so smoke tests don't need Isar.
class _NoOpBookmarkRepository implements BookmarkRepository {
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
  Future<int> countAll() async => 0;
  @override
  Future<int> count(BookmarkFeedQuery query) async => 0;
  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => <Bookmark>[];
  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) =>
      Stream<List<Bookmark>>.value(<Bookmark>[]);
  @override
  Stream<Bookmark?> watchById(int id) => Stream<Bookmark?>.value(null);
  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async =>
      <Bookmark>[];
}

class _StatefulBookmarkRepository implements BookmarkRepository {
  final Map<int, Bookmark> _bookmarks = <int, Bookmark>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _nextId = 1;
  bool _disposed = false;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_changes.close());
  }

  @override
  Future<Bookmark> save(Bookmark bookmark) async {
    final int id = bookmark.id ?? _nextId++;
    final Bookmark saved = bookmark.copyWith(
      id: id,
      updatedAt: DateTime(2026, 1, 10, 9),
    );
    _bookmarks[id] = saved;
    _emit();
    return saved;
  }

  @override
  Future<List<Bookmark>> saveAll(List<Bookmark> bookmarks) async {
    final List<Bookmark> saved = <Bookmark>[];
    for (final Bookmark bookmark in bookmarks) {
      saved.add(await save(bookmark));
    }
    return saved;
  }

  @override
  Future<Bookmark?> getById(int id) async => _bookmarks[id];

  @override
  Future<List<Bookmark>> getByIds(List<int> ids) async {
    return ids
        .map((int id) => _bookmarks[id])
        .whereType<Bookmark>()
        .toList(growable: false);
  }

  @override
  Future<bool> delete(int id) async {
    final bool removed = _bookmarks.remove(id) != null;
    if (removed) _emit();
    return removed;
  }

  @override
  Future<int> deleteAll(List<int> ids) async {
    int removed = 0;
    for (final int id in ids) {
      if (_bookmarks.remove(id) != null) removed += 1;
    }
    if (removed > 0) _emit();
    return removed;
  }

  @override
  Future<Bookmark?> findByUrlHash(String urlHash) async {
    return _firstOrNull(
      _bookmarks.values.where((Bookmark b) => b.urlHash == urlHash),
    );
  }

  @override
  Future<Bookmark?> findByCanonicalUrl(String canonicalUrl) async {
    return _firstOrNull(
      _bookmarks.values.where((Bookmark b) => b.canonicalUrl == canonicalUrl),
    );
  }

  @override
  Future<Bookmark?> findByExternalContentId(String externalContentId) async {
    return _firstOrNull(
      _bookmarks.values
          .where((Bookmark b) => b.externalContentId == externalContentId),
    );
  }

  @override
  Future<int> countAll() async {
    return _bookmarks.values.where((Bookmark b) => !b.isArchived).length;
  }

  @override
  Future<int> count(BookmarkFeedQuery query) async {
    return _filter(query, applyPaging: false).length;
  }

  @override
  Future<List<Bookmark>> feed(BookmarkFeedQuery query) async => _filter(query);

  @override
  Stream<List<Bookmark>> watchFeed(BookmarkFeedQuery query) async* {
    yield _filter(query);
    await for (final _ in _changes.stream) {
      yield _filter(query);
    }
  }

  @override
  Stream<Bookmark?> watchById(int id) async* {
    yield _bookmarks[id];
    await for (final _ in _changes.stream) {
      yield _bookmarks[id];
    }
  }

  @override
  Future<List<Bookmark>> search(String query, {int limit = 50}) async {
    final String needle = query.toLowerCase().trim();
    if (needle.isEmpty) return <Bookmark>[];
    return _bookmarks.values
        .where((Bookmark bookmark) {
          if (bookmark.isArchived) return false;
          final List<String?> fields = <String?>[
            bookmark.title,
            bookmark.normalizedHost,
            bookmark.canonicalUrl,
            bookmark.originalUrl,
            bookmark.description,
          ];
          return fields.any(
            (String? field) => field?.toLowerCase().contains(needle) ?? false,
          );
        })
        .take(limit)
        .toList(growable: false);
  }

  List<Bookmark> _filter(
    BookmarkFeedQuery query, {
    bool applyPaging = true,
  }) {
    Iterable<Bookmark> items = _bookmarks.values;

    items = switch (query.filter) {
      BookmarkFeedFilter.all => items.where((Bookmark b) => !b.isArchived),
      BookmarkFeedFilter.favorites =>
        items.where((Bookmark b) => !b.isArchived && b.isFavorite),
      BookmarkFeedFilter.unread =>
        items.where((Bookmark b) => !b.isArchived && !b.isRead),
      BookmarkFeedFilter.archived => items.where((Bookmark b) => b.isArchived),
    };

    final String? host = query.host;
    if (host != null) {
      items = items.where((Bookmark b) => b.normalizedHost == host);
    }

    final List<Bookmark> sorted = items.toList(growable: false)
      ..sort((Bookmark a, Bookmark b) => b.createdAt.compareTo(a.createdAt));

    if (!applyPaging) return sorted;
    return sorted.skip(query.offset).take(query.limit).toList(growable: false);
  }

  void _emit() {
    if (!_disposed) _changes.add(null);
  }

  static Bookmark? _firstOrNull(Iterable<Bookmark> bookmarks) {
    final Iterator<Bookmark> iterator = bookmarks.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}

class _SmokeCaptureService implements CaptureService {
  const _SmokeCaptureService(this._repository);

  final _StatefulBookmarkRepository _repository;

  @override
  Future<CaptureResult> capture(
    String rawInput, {
    BookmarkSourceType sourceType = BookmarkSourceType.manual,
  }) {
    return _save(rawInput, sourceType: sourceType);
  }

  @override
  Future<CaptureResult> captureFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  }) {
    return _save(text, sourceType: sourceType);
  }

  @override
  Future<List<CaptureResult>> captureAllFromText(
    String text, {
    BookmarkSourceType sourceType = BookmarkSourceType.share,
  }) async {
    return <CaptureResult>[await _save(text, sourceType: sourceType)];
  }

  Future<CaptureResult> _save(
    String input, {
    required BookmarkSourceType sourceType,
  }) async {
    final String url = input.trim();
    if (!url.startsWith('http')) return const CaptureResult.invalidUrl();
    final DateTime now = DateTime(2026, 1, 10, 9);
    final Bookmark saved = await _repository.save(
      Bookmark(
        originalUrl: url,
        canonicalUrl: url,
        normalizedHost: 'example.com',
        title: 'B4 Smoke Link',
        description: 'Smoke path bookmark',
        sourceType: sourceType,
        scrapingStatus: BookmarkScrapingStatus.done,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return CaptureResult.saved(saved);
  }
}

class _NoOpSearchQueryRepository implements SearchQueryRepository {
  @override
  Future<SearchQuery> recordRecent(String query) async {
    final DateTime now = DateTime(2026);
    return SearchQuery(
      query: query,
      normalizedQuery: SearchQuery.normalize(query),
      createdAt: now,
      lastUsedAt: now,
    );
  }

  @override
  Future<SearchQuery> saveSearch(String query, {String? label}) async {
    final DateTime now = DateTime(2026);
    return SearchQuery(
      query: query,
      normalizedQuery: SearchQuery.normalize(query),
      label: label,
      isSaved: true,
      createdAt: now,
      lastUsedAt: now,
      savedAt: now,
    );
  }

  @override
  Future<SearchQuery?> findByNormalizedQuery(String normalizedQuery) async =>
      null;
  @override
  Future<List<SearchQuery>> getRecent({int limit = 10}) async =>
      <SearchQuery>[];
  @override
  Future<List<SearchQuery>> getSaved() async => <SearchQuery>[];
  @override
  Future<void> removeRecent(int id) async {}
  @override
  Future<void> unsave(int id) async {}
  @override
  Future<void> clearRecent() async {}
  @override
  Stream<List<SearchQuery>> watchRecent({int limit = 10}) =>
      Stream<List<SearchQuery>>.value(<SearchQuery>[]);
  @override
  Stream<List<SearchQuery>> watchSaved() =>
      Stream<List<SearchQuery>>.value(<SearchQuery>[]);
}

class _NoOpTagRepository implements TagRepository {
  @override
  Future<Tag> save(Tag tag) async => tag;
  @override
  Future<Tag> createFromName(String name, {int? colorArgb, String? icon}) {
    throw UnimplementedError();
  }

  @override
  Future<Tag?> getById(int id) async => null;
  @override
  Future<Tag?> findBySlug(String slug) async => null;
  @override
  Future<List<Tag>> getAll() async => <Tag>[];
  @override
  Future<List<Tag>> getByIds(List<int> ids) async => <Tag>[];
  @override
  Future<bool> delete(int id) async => false;
  @override
  Future<void> incrementUsageCount(int tagId) async {}
  @override
  Future<void> decrementUsageCount(int tagId) async {}
  @override
  Future<int> recomputeUsageCount(int tagId) async => 0;
  @override
  Future<Map<int, int>> recomputeAllUsageCounts() async => <int, int>{};
  @override
  Stream<List<Tag>> watchAll() => Stream<List<Tag>>.value(<Tag>[]);
  @override
  Stream<Tag?> watchById(int id) => Stream<Tag?>.value(null);
}

class _NoOpBookmarkCollectionRepository implements BookmarkCollectionRepository {
  @override
  Future<BookmarkCollection?> findBySlug(String slug) async => null;
  @override
  Future<BookmarkCollection> save(BookmarkCollection collection) async =>
      collection;
  @override
  Future<BookmarkCollection> createFromTitle(String title,
      {int? accentColorArgb, String? icon}) {
    throw UnimplementedError();
  }

  @override
  Future<BookmarkCollection> createSmartFromRule(
      String title, SmartCollectionRule rule,
      {int? accentColorArgb, String? icon}) {
    throw UnimplementedError();
  }

  @override
  Future<BookmarkCollection?> getById(int id) async => null;
  @override
  Future<List<BookmarkCollection>> getAll({bool includeArchived = false}) async =>
      <BookmarkCollection>[];
  @override
  Future<List<BookmarkCollection>> getByIds(List<int> ids) async =>
      <BookmarkCollection>[];
  @override
  Future<bool> delete(int id) async => false;
  @override
  Future<void> incrementItemCount(int collectionId) async {}
  @override
  Future<void> decrementItemCount(int collectionId) async {}
  @override
  Future<int> recomputeItemCount(int collectionId) async => 0;
  @override
  Future<Map<int, int>> recomputeAllItemCounts() async => <int, int>{};
  @override
  Stream<List<BookmarkCollection>> watchAll({bool includeArchived = false}) =>
      Stream<List<BookmarkCollection>>.value(<BookmarkCollection>[]);
  @override
  Stream<BookmarkCollection?> watchById(int id) =>
      Stream<BookmarkCollection?>.value(null);
}
