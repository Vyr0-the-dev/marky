import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/core/url/url_extractor.dart';
import 'package:marky/features/add/presentation/add_screen.dart';
import 'package:marky/features/add/presentation/qr_scanner_screen.dart';
import 'package:marky/features/add/presentation/quick_add_sheet.dart';
import 'package:marky/features/automation/presentation/automation_rule_editor_screen.dart';
import 'package:marky/features/automation/presentation/automation_rules_screen.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/dashboard/presentation/dashboard_screen.dart';
import 'package:marky/features/detail/presentation/detail_screen.dart';
import 'package:marky/features/home/presentation/home_screen.dart';
import 'package:marky/features/library/presentation/library_screen.dart';
import 'package:marky/features/reminders/presentation/reminders_screen.dart';
import 'package:marky/features/search/presentation/search_screen.dart';
import 'package:marky/features/settings/presentation/settings_screen.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/widgets/marky_bottom_nav.dart';
import 'package:marky/shared/widgets/marky_top_toast.dart';

/// Builds the app [GoRouter].
///
/// The router uses a [StatefulShellRoute.indexedStack] to give each tab
/// its own navigator (so Home's scroll position survives a Library
/// detour). Root-level routes (detail, settings, etc.) are stacked
/// *above* the shell so they hide the bottom nav without losing the
/// tab state behind them.
abstract final class MarkyAppRouter {
  /// Global root navigator key — used by the notification tap handler
  /// and share-intent coordinator to push routes from outside the
  /// widget tree.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  /// Builds the router. [initialLocation] is honoured on cold-start
  /// deep links (e.g. notification tap → `/detail/42`).
  static GoRouter build({String? initialLocation}) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation ?? Routes.home,
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return _RootShellScaffold(navigationShell: navigationShell);
          },
          branches: <StatefulShellBranch>[
            // Home
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.home,
                  builder: (_, __) => const HomeScreen(),
                ),
                GoRoute(
                  path: Routes.homeUnread,
                  builder: (_, __) => const HomeScreen(
                    initialFilter: BookmarkFeedFilter.unread,
                  ),
                ),
              ],
            ),
            // Search
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.search,
                  builder: (_, __) => const SearchScreen(),
                ),
              ],
            ),
            // Library
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.library,
                  builder: (_, __) => const LibraryScreen(),
                ),
              ],
            ),
            // Settings
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.settings,
                  builder: (_, __) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
        // ── Root-level routes (stacked above shell, hide bottom nav) ──
        GoRoute(
          path: Routes.bookmarkDetail,
          parentNavigatorKey: rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            final int id = int.parse(state.pathParameters['id']!);
            return DetailScreen(id: id);
          },
        ),
        GoRoute(
          path: Routes.add,
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, __) => const AddScreen(),
        ),
        GoRoute(
          path: Routes.addQr,
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, __) => const QrScannerScreen(),
        ),
        GoRoute(
          path: Routes.stats,
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, __) => const DashboardScreen(),
        ),
        GoRoute(
          path: Routes.reminders,
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, __) => const RemindersScreen(),
        ),
        GoRoute(
          path: Routes.automationRules,
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, __) => const AutomationRulesScreen(),
        ),
        GoRoute(
          path: Routes.automationRuleNew,
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, __) => const AutomationRuleEditorScreen(),
        ),
        GoRoute(
          path: Routes.automationRuleEdit,
          parentNavigatorKey: rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            final int id = int.parse(state.pathParameters['id']!);
            return AutomationRuleEditorScreen(ruleId: id);
          },
        ),
      ],
    );
  }
}

/// Shell scaffold hosting the [StatefulNavigationShell] and the bottom
/// nav.
///
/// Back-button policy:
/// - On any tab **other than Home** → jump to Home instead of popping
///   the shell (which on Android would kill the activity).
/// - On Home → require two taps within 2 seconds to exit (classic
///   "press back again to exit"). Prevents the common one-tap-kill
///   regression.
class _RootShellScaffold extends ConsumerStatefulWidget {
  const _RootShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<_RootShellScaffold> createState() => _RootShellScaffoldState();
}

class _RootShellScaffoldState extends ConsumerState<_RootShellScaffold> {
  DateTime? _lastBackPress;
  static const Duration _exitWindow = Duration(seconds: 2);

  bool get _isTurkish {
    return Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('tr');
  }

  Future<void> _openQuickAddSheet() async {
    final QuickAddAction? action = await showQuickAddSheet(context);
    if (!mounted || action == null) return;

    switch (action) {
      case QuickAddAction.qr:
        await _scanQrAndCapture();
        break;
      case QuickAddAction.manual:
        await context.push(Routes.add);
        break;
      case QuickAddAction.clipboard:
        await _captureFromClipboard();
        break;
    }
  }

  Future<void> _scanQrAndCapture() async {
    final String? scannedUrl = await context.push<String>(Routes.addQr);
    if (!mounted || scannedUrl == null || scannedUrl.isEmpty) return;
    await _captureQuickInput(scannedUrl);
  }

  Future<void> _captureFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final String text = (data?.text ?? '').trim();
    if (text.isEmpty) {
      _showQuickAddMessage(
        _isTurkish ? 'Pano boş görünüyor' : 'Clipboard is empty',
      );
      return;
    }

    final String? extracted = const UrlExtractor().extractFirst(text);
    if (extracted == null || extracted.isEmpty) {
      _showQuickAddMessage(
        _isTurkish
            ? 'Panoda geçerli bağlantı yok'
            : 'No valid link in clipboard',
      );
      return;
    }

    await _captureQuickInput(extracted);
  }

  Future<void> _captureQuickInput(String input) async {
    CaptureResult result;
    try {
      result = await ref.read(captureServiceProvider).captureFromText(input);
    } on Object {
      if (!mounted) return;
      _showQuickAddMessage(
        _isTurkish ? 'Bağlantı kaydedilemedi' : 'Could not save the link',
      );
      return;
    }
    if (!mounted) return;

    _showQuickAddResult(result);
  }

  void _showQuickAddMessage(String message) {
    if (!mounted) return;
    MarkyTopToast.show(
      context,
      icon: Icons.info_outline_rounded,
      message: message,
    );
  }

  void _showQuickAddResult(CaptureResult result) {
    if (!mounted) return;
    final int? bookmarkId = result.bookmark?.id;
    final String? actionLabel =
        bookmarkId == null ? null : (_isTurkish ? 'Aç' : 'Open');
    final VoidCallback? onAction = bookmarkId == null
        ? null
        : () => context.push(Routes.bookmarkDetailPath(bookmarkId));
    switch (result.status) {
      case CaptureStatus.saved:
        MarkyTopToast.show(
          context,
          icon: Icons.bookmark_added_rounded,
          message: _isTurkish ? 'Bağlantı kaydedildi' : 'Link saved',
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;
      case CaptureStatus.duplicate:
        MarkyTopToast.show(
          context,
          icon: Icons.bookmark_added_outlined,
          message: _isTurkish
              ? 'Bu bağlantı zaten kayıtlı'
              : 'Already saved in your library',
          actionLabel: actionLabel,
          onAction: onAction,
        );
        break;
      case CaptureStatus.invalidUrl:
        MarkyTopToast.show(
          context,
          icon: Icons.link_off_rounded,
          message: _isTurkish
              ? 'Geçerli bağlantı bulunamadı'
              : 'No valid link found',
          iconColor: Theme.of(context).colorScheme.error,
        );
        break;
      case CaptureStatus.error:
        MarkyTopToast.show(
          context,
          icon: Icons.error_outline_rounded,
          message:
              _isTurkish ? 'Kaydetme sırasında hata oluştu' : 'Save failed',
          iconColor: Theme.of(context).colorScheme.error,
        );
        break;
    }
  }

  Future<void> _handlePop(bool didPop, Object? result) async {
    if (didPop) return;

    final int current = widget.navigationShell.currentIndex;

    if (current != 0) {
      widget.navigationShell.goBranch(0);
      return;
    }

    final DateTime now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > _exitWindow) {
      _lastBackPress = now;
      if (!mounted) return;
      // Localisation lookup is safe here — AppLocalizations.of never
      // returns null once MaterialApp's localizationsDelegates are
      // wired, and the shell is only built after that point.
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1800),
            content: Text(l10n.exitWarning),
          ),
        );
      return;
    }

    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePop,
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: MarkyBottomNav(
          navigationShell: widget.navigationShell,
          onQuickAddTap: _openQuickAddSheet,
          items: <MarkyNavItem>[
            MarkyNavItem(
              icon: Icons.auto_stories_outlined,
              selectedIcon: Icons.auto_stories_outlined,
              label: l10n?.navigationHome ?? 'Home',
            ),
            MarkyNavItem(
              icon: Icons.search_outlined,
              selectedIcon: Icons.search_outlined,
              label: l10n?.navigationSearch ?? 'Search',
            ),
            MarkyNavItem(
              icon: Icons.add_rounded,
              selectedIcon: Icons.add_rounded,
              label: _isTurkish ? 'Hızlı Ekle' : 'Quick Add',
              role: MarkyNavItemRole.quickAdd,
            ),
            MarkyNavItem(
              icon: Icons.collections_bookmark_outlined,
              selectedIcon: Icons.collections_bookmark_outlined,
              label: l10n?.navigationLibrary ?? 'Library',
            ),
            MarkyNavItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings_outlined,
              label: l10n?.settingsTitle ?? 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
