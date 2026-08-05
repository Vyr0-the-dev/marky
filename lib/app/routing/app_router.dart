import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/routing/routes.dart';
import 'package:marky/features/automation/presentation/screens/automation_rule_edit_screen.dart';
import 'package:marky/features/automation/presentation/screens/automation_rules_screen.dart';
import 'package:marky/features/capture/presentation/screens/capture_screen.dart';
import 'package:marky/features/collections/presentation/screens/collection_detail_screen.dart';
import 'package:marky/features/collections/presentation/screens/collections_screen.dart';
import 'package:marky/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:marky/features/feed/presentation/screens/bookmark_detail_screen.dart';
import 'package:marky/features/feed/presentation/screens/feed_screen.dart';
import 'package:marky/features/notes/presentation/screens/note_edit_screen.dart';
import 'package:marky/features/search/presentation/screens/search_screen.dart';
import 'package:marky/features/settings/presentation/screens/settings_screen.dart';
import 'package:marky/features/tags/presentation/screens/tag_detail_screen.dart';
import 'package:marky/features/tags/presentation/screens/tags_screen.dart';
import 'package:marky/features/vault/presentation/screens/vault_auth_screen.dart';
import 'package:marky/features/vault/presentation/screens/vault_feed_screen.dart';
import 'package:marky/shared/widgets/marky_bottom_nav.dart';

/// Creates and configures the [GoRouter] instance.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  /// Public accessor for the root navigator key (e.g. used by notification tap handler).
  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

  /// Builds the app's [GoRouter] with a [StatefulShellRoute].
  ///
  /// [initialLocation] overrides the default [Routes.home] when the app
  /// is launched from a notification deep-link.
  static GoRouter createRouter({String? initialLocation}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation ?? Routes.home,
      routes: <RouteBase>[
        // Detail screen — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.bookmarkDetail,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            final String idParam = state.pathParameters['id']!;
            return BookmarkDetailScreen(id: int.parse(idParam));
          },
        ),
        // Tag detail screen — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.tagDetail,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            final String idParam = state.pathParameters['id']!;
            return TagDetailScreen(id: int.parse(idParam));
          },
        ),
        // Tags manager screen — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.tags,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return const TagsScreen();
          },
        ),
        // Collection detail screen — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.collectionDetail,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            final String idParam = state.pathParameters['id']!;
            return CollectionDetailScreen(id: int.parse(idParam));
          },
        ),
        // Note edit screen (create) — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.noteEdit,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            final String bookmarkIdParam = state.uri.queryParameters['bookmarkId']!;
            return NoteEditScreen(bookmarkId: int.parse(bookmarkIdParam));
          },
        ),
        // Note edit screen (edit) — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.noteEditWithId,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            final String idParam = state.pathParameters['id']!;
            final String? bookmarkIdParam = state.uri.queryParameters['bookmarkId'];
            return NoteEditScreen(
              bookmarkId: bookmarkIdParam != null ? int.parse(bookmarkIdParam) : 0,
              noteId: int.parse(idParam),
            );
          },
        ),
        // Dashboard analytics screen — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.dashboard,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return const DashboardScreen();
          },
        ),
        // Automation rules list screen — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.automationRules,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return const AutomationRulesScreen();
          },
        ),
        // Automation rule edit screen (create) — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.automationRuleEdit,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return const AutomationRuleEditScreen();
          },
        ),
        // Automation rule edit screen (edit with ID) — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.automationRuleEditWithId,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            final String idParam = state.pathParameters['id']!;
            return AutomationRuleEditScreen.edit(ruleId: int.parse(idParam));
          },
        ),
        // Vault auth screen — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.vaultAuth,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return const VaultAuthScreen();
          },
        ),
        // Vault feed screen — rendered above the shell, hides bottom nav
        GoRoute(
          path: Routes.vaultFeed,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return const VaultFeedScreen();
          },
        ),
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
              ),
            );
          },
          branches: <StatefulShellBranch>[
            // Home / Feed
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.home,
                  builder: (BuildContext context, GoRouterState state) {
                    return const FeedScreen();
                  },
                ),
              ],
            ),
            // Search
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.search,
                  builder: (BuildContext context, GoRouterState state) {
                    return const SearchScreen();
                  },
                ),
              ],
            ),
            // Add / Capture
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.add,
                  builder: (BuildContext context, GoRouterState state) {
                    final String? url = state.uri.queryParameters['url'];
                    return CaptureScreen(initialUrl: url);
                  },
                ),
              ],
            ),
            // Collections
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.collections,
                  builder: (BuildContext context, GoRouterState state) {
                    return const CollectionsScreen();
                  },
                ),
              ],
            ),
            // Profile / Settings
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.profile,
                  builder: (BuildContext context, GoRouterState state) {
                    return const SettingsScreen();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
