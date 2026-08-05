import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/bootstrap/app_bootstrap.dart';
import 'package:marky/app/errors/crash_rate_service.dart';
import 'package:marky/app/errors/error_boundary.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/routing/app_router.dart';
import 'package:marky/app/theme/app_theme.dart';
import 'package:marky/features/capture/presentation/providers/share_intent_providers.dart';
import 'package:marky/features/capture/presentation/widgets/clipboard_lifecycle_observer.dart';
import 'package:marky/l10n/app_localizations.dart';

final Logger _appLogger = Logger();

void main() {
  // Initialize crash-rate observability before any other handlers so
  // all uncaught errors are recorded for the <1% crash-rate metric.
  CrashRateService.instance.initialize();

  bootstrap(
    run: () {
      final String? pendingRoute = consumePendingNotificationRoute();

      // Replace default red-screen error widget with branded fallback.
      ErrorWidget.builder = (FlutterErrorDetails details) {
        _appLogger.w(
          'ErrorWidget.builder: widget crash — ${details.exception}',
          error: details.exception,
          stackTrace: details.stack,
        );
        return ErrorBoundary(
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      runApp(ProviderScope(
        overrides: <Override>[
          appRouterProvider.overrideWith((Ref<GoRouter> ref) {
            return AppRouter.createRouter(initialLocation: pendingRoute);
          }),
        ],
        child: const MarkyApp(),
      ));
    },
  );
}

/// Root application widget.
class MarkyApp extends ConsumerWidget {
  /// Creates the root [MarkyApp].
  const MarkyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cold-start share intent listener
    ref.listen<AsyncValue<String?>>(
      shareIntentInitialUrlProvider,
      (AsyncValue<String?>? previous, AsyncValue<String?> next) {
        next.whenData((String? url) {
          if (url != null && url.isNotEmpty) {
            _appLogger
                .i('MarkyApp: cold-start share intent URL received: $url');
            ref.read(appRouterProvider).go(
                  '/add?url=${Uri.encodeComponent(url)}',
                );
          }
        });
      },
    );

    // Warm-start share intent listener
    ref.listen<AsyncValue<String?>>(
      shareIntentStreamProvider,
      (AsyncValue<String?>? previous, AsyncValue<String?> next) {
        next.whenData((String? url) {
          if (url != null && url.isNotEmpty) {
            _appLogger
                .i('MarkyApp: warm-start share intent URL received: $url');
            ref.read(appRouterProvider).go(
                  '/add?url=${Uri.encodeComponent(url)}',
                );
          }
        });
      },
    );

    return ClipboardLifecycleObserver(
      child: MaterialApp.router(
        builder: (BuildContext context, Widget? child) {
          final MediaQueryData mediaQuery = MediaQuery.of(context);
          final TextScaler textScaler = mediaQuery.textScaler.clamp(
            maxScaleFactor: 2,
          );

          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: textScaler),
            child: child ?? const SizedBox.shrink(),
          );
        },
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)?.appTitle ?? 'Marky',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        themeMode: ref.watch(themeProvider),
        routerConfig: ref.watch(appRouterProvider),
      ),
    );
  }
}
