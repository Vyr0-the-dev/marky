import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/shared/widgets/marky_bottom_nav.dart';

void main() {
  GoRouter buildTestRouter() {
    return GoRouter(
      initialLocation: '/home',
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return Scaffold(
              body: navigationShell,
              bottomNavigationBar: MarkyBottomNav(
                navigationShell: navigationShell,
                items: const <MarkyNavItem>[
                  MarkyNavItem(
                    icon: Icons.auto_stories_outlined,
                    selectedIcon: Icons.auto_stories_outlined,
                    label: 'Home',
                  ),
                  MarkyNavItem(
                    icon: Icons.search_outlined,
                    selectedIcon: Icons.search_outlined,
                    label: 'Search',
                  ),
                  MarkyNavItem(
                    icon: Icons.add_rounded,
                    selectedIcon: Icons.add_rounded,
                    label: 'Quick Add',
                    role: MarkyNavItemRole.quickAdd,
                  ),
                  MarkyNavItem(
                    icon: Icons.collections_bookmark_outlined,
                    selectedIcon: Icons.collections_bookmark_outlined,
                    label: 'Library',
                  ),
                  MarkyNavItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_outlined,
                    label: 'Settings',
                  ),
                ],
              ),
            );
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/home',
                  builder: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/search',
                  builder: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/library',
                  builder: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/settings',
                  builder: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  group('ReadingRoomTheme NavigationBarThemeData', () {
    testWidgets(
      'neutralizes M3 indicator and enforces 22px icons and 11px Inter',
      (WidgetTester tester) async {
        final ThemeData darkTheme = ReadingRoomTheme.build(
          ReadingRoomVariant.dark,
        );
        final NavigationBarThemeData navTheme = darkTheme.navigationBarTheme;

        expect(navTheme.indicatorColor, Colors.transparent);
        expect(
          navTheme.overlayColor?.resolve(<WidgetState>{WidgetState.pressed}),
          Colors.transparent,
        );

        final IconThemeData? selectedIcon = navTheme.iconTheme?.resolve(
          <WidgetState>{WidgetState.selected},
        );
        final IconThemeData? unselectedIcon = navTheme.iconTheme?.resolve(
          <WidgetState>{},
        );
        expect(selectedIcon?.color, const Color(0xFFEDEDEC));
        expect(selectedIcon?.size, 22);
        expect(unselectedIcon?.color, const Color(0xFF6E6E6C));
        expect(unselectedIcon?.size, 22);

        final TextStyle? selectedLabel = navTheme.labelTextStyle?.resolve(
          <WidgetState>{WidgetState.selected},
        );
        final TextStyle? unselectedLabel = navTheme.labelTextStyle?.resolve(
          <WidgetState>{},
        );
        expect(selectedLabel?.fontSize, 11);
        expect(selectedLabel?.fontWeight, FontWeight.w500);
        expect(selectedLabel?.color, const Color(0xFFEDEDEC));
        expect(unselectedLabel?.fontSize, 11);
        expect(unselectedLabel?.fontWeight, FontWeight.w500);
        expect(unselectedLabel?.color, const Color(0xFF6E6E6C));
      },
    );
  });

  group('MarkyBottomNav', () {
    testWidgets(
      'uses outlined icons without size jump, color-only selection, and graphite quick-add in dark mode',
      (WidgetTester tester) async {
        final GoRouter router = buildTestRouter();
        await tester.pumpWidget(
          MaterialApp.router(
            theme: ReadingRoomTheme.build(ReadingRoomVariant.dark),
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        final Icon homeIcon = tester.widget<Icon>(
          find.byIcon(Icons.auto_stories_outlined),
        );
        final Icon searchIcon = tester.widget<Icon>(
          find.byIcon(Icons.search_outlined),
        );
        expect(homeIcon.size, 22);
        expect(homeIcon.color, const Color(0xFFEDEDEC));
        expect(searchIcon.size, 22);
        expect(searchIcon.color, const Color(0xFF6E6E6C));

        final Text homeLabel = tester.widget<Text>(find.text('Home'));
        final Text searchLabel = tester.widget<Text>(find.text('Search'));
        expect(homeLabel.style?.fontSize, 11);
        expect(homeLabel.style?.fontWeight, FontWeight.w500);
        expect(homeLabel.style?.color, const Color(0xFFEDEDEC));
        expect(searchLabel.style?.fontSize, 11);
        expect(searchLabel.style?.fontWeight, FontWeight.w500);
        expect(searchLabel.style?.color, const Color(0xFF6E6E6C));

        final DecoratedBox quickAddBox = tester.widget<DecoratedBox>(
          find.byKey(const ValueKey<String>('quick_add_button')),
        );
        final BoxDecoration decoration =
            quickAddBox.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotEmpty);

        final Icon quickAddIcon = tester.widget<Icon>(
          find.byIcon(Icons.add_rounded),
        );
        expect(quickAddIcon.size, 28);
        expect(quickAddIcon.color, Colors.white);

        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();

        final Icon updatedHomeIcon = tester.widget<Icon>(
          find.byIcon(Icons.auto_stories_outlined),
        );
        final Icon updatedSearchIcon = tester.widget<Icon>(
          find.byIcon(Icons.search_outlined),
        );
        expect(updatedHomeIcon.color, const Color(0xFF6E6E6C));
        expect(updatedSearchIcon.color, const Color(0xFFEDEDEC));
        expect(updatedSearchIcon.size, 22);
      },
    );

    testWidgets('uses primary dark ink in light mode for active state', (
      WidgetTester tester,
    ) async {
      final GoRouter router = buildTestRouter();
      await tester.pumpWidget(
        MaterialApp.router(
          theme: ReadingRoomTheme.build(ReadingRoomVariant.light),
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      final Icon homeIcon = tester.widget<Icon>(
        find.byIcon(Icons.auto_stories_outlined),
      );
      final Icon searchIcon = tester.widget<Icon>(
        find.byIcon(Icons.search_outlined),
      );
      expect(homeIcon.color, ReadingRoomColors.lightInk);
      expect(searchIcon.color, const Color(0xFF6E6E6C));
    });
  });
}
