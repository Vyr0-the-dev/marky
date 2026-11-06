import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/settings/app_settings_repository.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/core/database/database_providers.dart';
import 'package:marky/core/time/timezone_bootstrap.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/share_intent/data/share_intent_providers.dart';
import 'package:marky/features/share_intent/platform/share_overlay_bridge.dart';
import 'package:marky/features/share_intent/presentation/share_result_sheet.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String? payload;
  AppLocaleChoice localeChoice = AppLocaleChoice.system;
  try {
    payload = await ShareOverlayBridge.getInitialPayload();
  } on Object {
    payload = null;
  }
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SharedPreferencesAppSettingsRepository settingsRepository =
        SharedPreferencesAppSettingsRepository(prefs);
    final AppSettings settings = await settingsRepository.load();
    localeChoice = settings.locale;
  } on Object {
    localeChoice = AppLocaleChoice.system;
  }

  runApp(
    ShareOverlayApp(
      initialPayload: payload,
      localeChoice: localeChoice,
    ),
  );
}

class ShareOverlayApp extends StatelessWidget {
  const ShareOverlayApp({
    required this.initialPayload,
    this.autoCloseAfter = const Duration(seconds: 4),
    this.localeChoice = AppLocaleChoice.system,
    this.capturePayload,
    this.finishOverlay,
    this.openMainApp,
    super.key,
  });

  final String? initialPayload;
  final Duration autoCloseAfter;
  final AppLocaleChoice localeChoice;
  final ShareOverlayCapture? capturePayload;
  final Future<void> Function()? finishOverlay;
  final Future<void> Function()? openMainApp;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ReadingRoomTheme.build(ReadingRoomVariant.oled),
      locale: _resolveLocale(localeChoice),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _ShareOverlayHost(
        initialPayload: initialPayload,
        autoCloseAfter: autoCloseAfter,
        capturePayload: capturePayload ?? _captureSharedPayload,
        finishOverlay: finishOverlay,
        openMainApp: openMainApp,
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
    required this.capturePayload,
    required this.finishOverlay,
    required this.openMainApp,
  });

  final String? initialPayload;
  final Duration autoCloseAfter;
  final ShareOverlayCapture capturePayload;
  final Future<void> Function()? finishOverlay;
  final Future<void> Function()? openMainApp;

  @override
  State<_ShareOverlayHost> createState() => _ShareOverlayHostState();
}

class _ShareOverlayHostState extends State<_ShareOverlayHost> {
  late final Future<CaptureResult> _resultFuture;
  late final Completer<CaptureResult> _resultCompleter;
  Timer? _captureStartTimer;
  bool _closing = false;
  bool _openAppRequested = false;
  bool _flutterReadyNotified = false;

  @override
  void initState() {
    super.initState();
    _resultCompleter = Completer<CaptureResult>();
    _resultFuture = _resultCompleter.future;
    _captureStartTimer = Timer(const Duration(milliseconds: 150), () {
      unawaited(_capturePayload());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyFlutterReady();
    });
  }

  @override
  void dispose() {
    _captureStartTimer?.cancel();
    if (!_resultCompleter.isCompleted) {
      _resultCompleter.complete(CaptureResult.error('share_overlay_disposed'));
    }
    super.dispose();
  }

  Future<void> _capturePayload() async {
    try {
      final CaptureResult result =
          await widget.capturePayload(widget.initialPayload);
      if (!_resultCompleter.isCompleted) {
        _resultCompleter.complete(result);
      }
    } on Object catch (error, stackTrace) {
      if (!_resultCompleter.isCompleted) {
        _resultCompleter.completeError(error, stackTrace);
      }
    }
  }

  void _notifyFlutterReady() {
    if (_flutterReadyNotified) return;
    _flutterReadyNotified = true;
    unawaited(
      ShareOverlayBridge.flutterReady().catchError((Object _) {}),
    );
  }

  void _requestClose() {
    if (_closing || _openAppRequested) return;
    _closing = true;
    unawaited(_finishOverlay());
  }

  void _requestOpenMainApp() {
    if (_openAppRequested) return;
    _openAppRequested = true;
    unawaited(_openMainApp());
  }

  Future<void> _finishOverlay() async {
    try {
      await (widget.finishOverlay ?? ShareOverlayBridge.finish)();
    } on Object {
      debugPrint('[ShareOverlay] Finish failed');
    }
  }

  Future<void> _openMainApp() async {
    try {
      await (widget.openMainApp ?? ShareOverlayBridge.openMainApp)();
    } on Object {
      debugPrint('[ShareOverlay] Open main app failed');
      await _finishOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _requestClose(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: MarkyShareResultPanel(
          resultFuture: _resultFuture,
          autoCloseAfter: widget.autoCloseAfter,
          onAutoClose: _requestClose,
          onOpenApp: _requestOpenMainApp,
          onDismiss: _requestClose,
        ),
      ),
    );
  }
}

Future<CaptureResult> _captureSharedPayload(String? payload) async {
  final String? text = payload?.trim();
  if (text == null || text.isEmpty) {
    return const CaptureResult.invalidUrl();
  }

  ProviderContainer? container;
  try {
    final databaseBootstrap = await markyDatabaseBootstrap();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SharedPreferencesAppSettingsRepository settingsRepository =
        SharedPreferencesAppSettingsRepository(prefs);
    await settingsRepository.load();
    container = ProviderContainer(
      overrides: <Override>[
        ...databaseBootstrap.overrides,
        ...appSettingsBootstrapOverrides(settingsRepository),
      ],
    );
    return await container
        .read(shareCaptureCoordinatorProvider)
        .captureSharedText(text);
  } on Object catch (error) {
    debugPrint('[ShareOverlay] Capture failed: $error');
    return CaptureResult.error('share_overlay_capture_failed: $error');
  } finally {
    final ProviderContainer? disposableContainer = container;
    if (disposableContainer != null) {
      unawaited(
        Future<void>.delayed(
          const Duration(seconds: 8),
          disposableContainer.dispose,
        ),
      );
    }
  }
}
