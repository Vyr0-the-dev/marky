import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/core/time/timezone_bootstrap.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/share_intent/presentation/share_overlay_controller.dart';
import 'package:marky/features/share_intent/presentation/share_result_sheet.dart';
import 'package:marky/l10n/app_localizations.dart';

typedef ShareOverlayCapture = Future<CaptureResult> Function(String? payload);

Future<void> runShareOverlayApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(ensureTimezoneInitialized());
  unawaited(
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).catchError((Object _) {}),
  );

  final ShareSessionGateway gateway = DefaultShareSessionGateway();
  unawaited(gateway.warmUp());

  runApp(ShareOverlayApp(gateway: gateway));
}

class ShareOverlayApp extends StatefulWidget {
  const ShareOverlayApp({
    this.initialPayload,
    this.autoCloseAfter = const Duration(seconds: 4),
    this.exitAnimationDuration = const Duration(milliseconds: 240),
    this.localeChoice = AppLocaleChoice.system,
    this.capturePayload,
    this.finishOverlay,
    this.openMainApp,
    this.gateway,
    super.key,
  });

  final String? initialPayload;
  final Duration autoCloseAfter;
  final Duration exitAnimationDuration;
  final AppLocaleChoice localeChoice;
  final ShareOverlayCapture? capturePayload;
  final Future<void> Function()? finishOverlay;
  final Future<void> Function()? openMainApp;
  final ShareSessionGateway? gateway;

  @override
  State<ShareOverlayApp> createState() => _ShareOverlayAppState();
}

class _ShareOverlayAppState extends State<ShareOverlayApp> {
  late AppLocaleChoice _localeChoice = widget.localeChoice;
  late ShareSessionGateway _gateway = _resolveGateway();

  @override
  void initState() {
    super.initState();
    if (widget.localeChoice == AppLocaleChoice.system) {
      _loadSavedLocale();
    }
  }

  @override
  void didUpdateWidget(ShareOverlayApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.localeChoice != oldWidget.localeChoice) {
      _localeChoice = widget.localeChoice;
    }
    if (widget.gateway != oldWidget.gateway ||
        widget.capturePayload != oldWidget.capturePayload ||
        widget.finishOverlay != oldWidget.finishOverlay ||
        widget.openMainApp != oldWidget.openMainApp) {
      _gateway = _resolveGateway();
    }
  }

  ShareSessionGateway _resolveGateway() {
    return widget.gateway ??
        DefaultShareSessionGateway(
          capturePayload: widget.capturePayload,
          finishOverlay: widget.finishOverlay,
          openMainApp: widget.openMainApp,
        );
  }

  void _loadSavedLocale() {
    _gateway.loadSavedLocale().then((AppLocaleChoice savedLocale) {
      if (mounted && _localeChoice != savedLocale) {
        setState(() {
          _localeChoice = savedLocale;
        });
      }
    }).catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ReadingRoomTheme.build(ReadingRoomVariant.oled),
      locale: _resolveLocale(_localeChoice),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _ShareOverlayHost(
        initialPayload: widget.initialPayload,
        autoCloseAfter: widget.autoCloseAfter,
        exitAnimationDuration: widget.exitAnimationDuration,
        gateway: _gateway,
      ),
    );
  }

  static Locale _resolveLocale(AppLocaleChoice choice) {
    final Locale? explicitLocale = choice.toLocale();
    if (explicitLocale != null) return explicitLocale;
    final List<Locale> platformLocales =
        WidgetsBinding.instance.platformDispatcher.locales;
    for (final Locale locale in platformLocales) {
      switch (locale.languageCode.toLowerCase()) {
        case 'tr':
          return const Locale('tr');
        case 'en':
          return const Locale('en');
      }
    }
    return const Locale('en');
  }
}

class _ShareOverlayHost extends StatefulWidget {
  const _ShareOverlayHost({
    required this.initialPayload,
    required this.autoCloseAfter,
    required this.exitAnimationDuration,
    required this.gateway,
  });

  final String? initialPayload;
  final Duration autoCloseAfter;
  final Duration exitAnimationDuration;
  final ShareSessionGateway gateway;

  @override
  State<_ShareOverlayHost> createState() => _ShareOverlayHostState();
}

class _ShareOverlayHostState extends State<_ShareOverlayHost> {
  final GlobalKey<MarkyShareResultPanelState> _panelKey =
      GlobalKey<MarkyShareResultPanelState>();
  late final ShareOverlayController _controller;
  void Function()? _removeControllerListener;
  ShareOverlayState _state = const ShareOverlayState.idle();

  @override
  void initState() {
    super.initState();
    _controller = ShareOverlayController(
      gateway: widget.gateway,
      initialPayload: widget.initialPayload,
    );
    _removeControllerListener = _controller.addListener((ShareOverlayState s) {
      if (!mounted) return;
      setState(() {
        _state = s;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.notifyFlutterReady();
    });
  }

  @override
  void dispose() {
    _removeControllerListener?.call();
    _controller.dispose();
    super.dispose();
  }

  void _handleBackPress() {
    final MarkyShareResultPanelState? state = _panelKey.currentState;
    if (state != null) {
      state.animateDismiss();
    } else {
      unawaited(_controller.requestClose());
    }
  }

  @override
  Widget build(BuildContext context) {
    final CaptureResult? result = _state.result;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _handleBackPress(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: result == null
            ? const SizedBox.expand()
            : MarkyShareResultPanel(
                key: _panelKey,
                result: result,
                autoCloseAfter: widget.autoCloseAfter,
                exitDuration: widget.exitAnimationDuration,
                onAutoClose: () => unawaited(_controller.requestClose()),
                onOpenApp: () => unawaited(_controller.requestOpenMainApp()),
                onDismiss: () => unawaited(_controller.requestClose()),
              ),
      ),
    );
  }
}
