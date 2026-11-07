import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marky/app/routing/app_router.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/onboarding/presentation/onboarding_screen.dart';
import 'package:marky/features/quick_actions/data/quick_action_providers.dart';
import 'package:marky/features/quick_actions/domain/quick_action_route.dart';
import 'package:marky/features/share_intent/data/share_intent_providers.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/widgets/marky_error_boundary.dart';
import 'package:marky/shared/widgets/marky_top_toast.dart';

/// Riverpod provider exposing the app [GoRouter].
///
/// Router is rebuilt only when [initialLocation] changes, which is
/// rare (cold-start share / notification tap). Hot reload keeps the
/// same instance so navigation state survives.
final Provider<GoRouter> markyRouterProvider = Provider<GoRouter>((Ref ref) {
  return MarkyAppRouter.build();
});

/// Root widget for Marky.
///
/// Wires the router, theme, and locale to the user's persisted
/// settings via Riverpod. Feature phases only care about
/// `Theme.of(context)` and `AppLocalizations.of(context)` — they
/// never look at the variant or locale directly.
///
/// Theme logic:
/// - Both light and dark `ThemeData` are always supplied so the OS
///   can resolve [ThemeMode.system] correctly.
/// - When the user picks OLED explicitly, we substitute the OLED
///   palette in the `darkTheme` slot so switching to dark mode at the
///   OS level also upgrades to OLED (the user's preference).
class MarkyApp extends ConsumerStatefulWidget {
  const MarkyApp({super.key});

  @override
  ConsumerState<MarkyApp> createState() => _MarkyAppState();
}

class _MarkyAppState extends ConsumerState<MarkyApp>
    with WidgetsBindingObserver {
  bool _coldStartShareHandled = false;
  ErrorWidgetBuilder? _previousErrorWidgetBuilder;

  @override
  void initState() {
    super.initState();
    _previousErrorWidgetBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return MarkyErrorBoundary(
        error: details.exception,
        stackTrace: details.stack,
      );
    };
    ref.read(quickActionControllerProvider).registerRouteHandler(_openRoute);
    NotificationServiceImpl.instance.payloadHandler = _openNotificationPayload;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_showOnboardingIfNeeded());
      unawaited(_consumeInitialQuickActionRoute());
      unawaited(_consumeInitialNotificationPayload());
      unawaited(_enrichPendingBookmarks());
    });
  }

  @override
  void dispose() {
    final ErrorWidgetBuilder? previous = _previousErrorWidgetBuilder;
    if (previous != null) {
      ErrorWidget.builder = previous;
    }
    NotificationServiceImpl.instance.payloadHandler = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_enrichPendingBookmarks());
        return;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String?>>(
      shareIntentInitialTextProvider,
      (AsyncValue<String?>? previous, AsyncValue<String?> next) {
        next.whenData((String? text) {
          if (text == null || text.isEmpty || _coldStartShareHandled) return;
          _coldStartShareHandled = true;
          unawaited(_handleSharedText(text));
        });
      },
    );
    ref.listen<AsyncValue<String?>>(
      shareIntentTextStreamProvider,
      (AsyncValue<String?>? previous, AsyncValue<String?> next) {
        next.whenData((String? text) {
          if (text == null || text.isEmpty) return;
          unawaited(_handleSharedText(text));
        });
      },
    );

    final GoRouter router = ref.watch(markyRouterProvider);
    final AppThemeMode themeMode = ref.watch(themeModeProvider);
    final AppLocaleChoice localeChoice = ref.watch(localeChoiceProvider);
    final bool animationsEnabled = ref.watch(animationsEnabledProvider);

    // Use the OLED palette in place of vanilla dark whenever the
    // user has opted in — otherwise stay on the warm-dark reading
    // surface.
    final ReadingRoomVariant darkVariant = themeMode == AppThemeMode.oled
        ? ReadingRoomVariant.oled
        : ReadingRoomVariant.dark;

    return MaterialApp.router(
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        final TextScaler textScaler = mediaQuery.textScaler.clamp(
          maxScaleFactor: 2,
        );
        final bool largeTextWasClamped =
            mediaQuery.textScaler.scale(10) > textScaler.scale(10);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: textScaler,
            disableAnimations: mediaQuery.disableAnimations ||
                !animationsEnabled ||
                largeTextWasClamped,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      title: 'Marky',
      debugShowCheckedModeBanner: false,
      theme: ReadingRoomTheme.build(ReadingRoomVariant.light),
      darkTheme: ReadingRoomTheme.build(darkVariant),
      themeMode: _toFlutterThemeMode(themeMode),
      locale: localeChoice.toLocale(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }

  /// Converts our four-way enum into Flutter's three-way ThemeMode.
  /// OLED is a dark sub-variant, so both map to [ThemeMode.dark].
  static ThemeMode _toFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.oled:
        return ThemeMode.dark;
    }
  }

  Future<void> _showOnboardingIfNeeded() async {
    if (!mounted) return;
    final bool seen = await hasSeenOnboarding();
    if (!mounted || seen) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? navigatorContext =
          MarkyAppRouter.rootNavigatorKey.currentContext;
      if (navigatorContext == null) return;
      unawaited(
        showModalBottomSheet<void>(
          context: navigatorContext,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const OnboardingScreen(),
        ),
      );
    });
  }

  Future<void> _consumeInitialQuickActionRoute() async {
    final String? route =
        await ref.read(quickActionControllerProvider).consumeInitialRoute();
    if (!mounted || route == null) return;
    _openRoute(route);
  }

  void _openRoute(String route) {
    if (!mounted) return;
    GoRouter.of(context).go(route);
  }

  Future<void> _enrichPendingBookmarks() async {
    if (!mounted) return;
    try {
      await ref.read(scrapingOrchestratorProvider).enrichIncomplete();
    } on Object {
      return;
    }
  }

  Future<void> _consumeInitialNotificationPayload() async {
    try {
      await NotificationServiceImpl.instance.initialize();
    } on Object {
      return;
    }
    final details = await NotificationServiceImpl.instance.getLaunchDetails();
    if (!mounted || details?.didNotificationLaunchApp != true) return;
    final String? payload = details?.notificationResponse?.payload;
    if (payload == null || payload.trim().isEmpty) return;
    _openNotificationPayload(payload);
  }

  void _openNotificationPayload(String payload) {
    if (!mounted) return;
    final String trimmed = payload.trim();
    if (trimmed.startsWith('bookmark_detail:')) {
      final int? id =
          int.tryParse(trimmed.substring('bookmark_detail:'.length));
      if (id != null) {
        GoRouter.of(context).go(Routes.bookmarkDetailPath(id));
      }
      return;
    }
    final String? route = QuickActionRoute.normalize(trimmed);
    if (route != null) _openRoute(route);
  }

  Future<void> _handleSharedText(String text) async {
    final CaptureResult result =
        await ref.read(shareCaptureCoordinatorProvider).captureSharedText(text);
    if (!mounted) return;

    final AppLocalizations? l10n = AppLocalizations.of(context);
    final int? bookmarkId = result.bookmark?.id;
    switch (result.status) {
      case CaptureStatus.saved:
        MarkyTopToast.show(
          context,
          icon: Icons.bookmark_added_rounded,
          message: l10n?.shareLinkSaved ?? 'Shared link saved',
          actionLabel:
              bookmarkId != null ? (l10n?.shareOpenBookmark ?? 'Open') : null,
          onAction: bookmarkId != null
              ? () =>
                  GoRouter.of(context).go(Routes.bookmarkDetailPath(bookmarkId))
              : null,
        );
        break;
      case CaptureStatus.duplicate:
        MarkyTopToast.show(
          context,
          icon: Icons.bookmark_outline_rounded,
          message: l10n?.shareLinkAlreadySaved ?? 'Link already saved',
          actionLabel:
              bookmarkId != null ? (l10n?.shareOpenBookmark ?? 'Open') : null,
          onAction: bookmarkId != null
              ? () =>
                  GoRouter.of(context).go(Routes.bookmarkDetailPath(bookmarkId))
              : null,
        );
        break;
      case CaptureStatus.invalidUrl:
        MarkyTopToast.show(
          context,
          icon: Icons.link_off_rounded,
          message: l10n?.shareNoLinkFound ?? 'No link found to save',
          iconColor: Theme.of(context).colorScheme.error,
        );
        break;
      case CaptureStatus.error:
        MarkyTopToast.show(
          context,
          icon: Icons.error_outline_rounded,
          message: l10n?.shareCouldNotSave ?? 'Could not save shared link',
          iconColor: Theme.of(context).colorScheme.error,
        );
        break;
    }
  }
}
