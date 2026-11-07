import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/settings/app_settings_repository.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/core/database/database_providers.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/core/time/timezone_bootstrap.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/unread_reminder_scheduler.dart';
import 'package:marky/features/share_intent/data/share_intent_providers.dart';
import 'package:marky/features/share_intent/platform/share_overlay_bridge.dart';
import 'package:marky/features/share_intent/presentation/share_result_sheet.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

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
    this.exitAnimationDuration = const Duration(milliseconds: 240),
    this.localeChoice = AppLocaleChoice.system,
    this.capturePayload,
    this.finishOverlay,
    this.openMainApp,
    super.key,
  });

  final String? initialPayload;
  final Duration autoCloseAfter;
  final Duration exitAnimationDuration;
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
        exitAnimationDuration: exitAnimationDuration,
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
    required this.exitAnimationDuration,
    required this.capturePayload,
    required this.finishOverlay,
    required this.openMainApp,
  });

  final String? initialPayload;
  final Duration autoCloseAfter;
  final Duration exitAnimationDuration;
  final ShareOverlayCapture capturePayload;
  final Future<void> Function()? finishOverlay;
  final Future<void> Function()? openMainApp;

  @override
  State<_ShareOverlayHost> createState() => _ShareOverlayHostState();
}

class _ShareOverlayHostState extends State<_ShareOverlayHost> {
  final GlobalKey<MarkyShareResultPanelState> _panelKey =
      GlobalKey<MarkyShareResultPanelState>();
  CaptureResult? _resolvedResult;
  Timer? _captureTimeoutTimer;
  String? _activePayload;
  bool _isCapturing = false;
  bool _closing = false;
  bool _openAppRequested = false;
  bool _flutterReadyNotified = false;

  @override
  void initState() {
    super.initState();

    final String? payload = widget.initialPayload?.trim();
    if (payload != null && payload.isNotEmpty) {
      _activePayload = payload;
      unawaited(_executeCapture(payload));
    } else {
      _captureTimeoutTimer = Timer(const Duration(seconds: 4), () {
        if (_resolvedResult == null && mounted) {
          setState(() {
            _resolvedResult = const CaptureResult.invalidUrl();
          });
        }
      });
    }

    ShareOverlayBridge.setPayloadHandler(_handleIncomingPayload);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyFlutterReady();
    });
  }

  @override
  void dispose() {
    ShareOverlayBridge.clearPayloadHandler();
    _captureTimeoutTimer?.cancel();
    super.dispose();
  }

  void _handleIncomingPayload(String? payload) {
    if (!mounted) return;
    final String? trimmed = payload?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    // Prevent duplicate concurrent execution for the identical payload
    if (_activePayload == trimmed && (_isCapturing || _resolvedResult != null)) {
      return;
    }

    _captureTimeoutTimer?.cancel();
    _activePayload = trimmed;

    setState(() {
      _resolvedResult = null;
      _closing = false;
      _openAppRequested = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyFlutterReady();
    });

    unawaited(_executeCapture(trimmed));
  }

  Future<void> _executeCapture(String payload) async {
    if (_isCapturing) return;
    _isCapturing = true;
    try {
      final CaptureResult result = await widget.capturePayload(payload);
      if (!mounted) return;
      setState(() {
        _resolvedResult = result;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _resolvedResult =
            CaptureResult.error('share_overlay_capture_failed: $error');
      });
    } finally {
      _isCapturing = false;
    }
  }

  void _notifyFlutterReady() {
    if (_flutterReadyNotified) return;
    _flutterReadyNotified = true;
    unawaited(
      ShareOverlayBridge.flutterReady().catchError((Object _) {}),
    );
  }

  void _handleBackPress() {
    final MarkyShareResultPanelState? state = _panelKey.currentState;
    if (state != null) {
      state.animateDismiss();
    } else {
      _requestClose();
    }
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
    final CaptureResult? result = _resolvedResult;
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
                onAutoClose: _requestClose,
                onOpenApp: _requestOpenMainApp,
                onDismiss: _requestClose,
              ),
      ),
    );
  }
}

class _NoOpNotificationService implements NotificationService {
  const _NoOpNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> showInstantSaveNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isError = false,
  }) async {}

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    String repeatMode = 'none',
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async => null;

  @override
  Future<bool> canScheduleExactNotifications() async => true;
}

ProviderContainer? _cachedShareContainer;

Future<CaptureResult> _captureSharedPayload(String? payload) async {
  final String? text = payload?.trim();
  if (text == null || text.isEmpty) {
    return const CaptureResult.invalidUrl();
  }

  try {
    ProviderContainer? container = _cachedShareContainer;
    if (container == null) {
      final databaseBootstrap = await markyDatabaseBootstrap();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SharedPreferencesAppSettingsRepository settingsRepository =
          SharedPreferencesAppSettingsRepository(prefs);
      await settingsRepository.load();
      container = ProviderContainer(
        overrides: <Override>[
          ...databaseBootstrap.overrides,
          ...appSettingsBootstrapOverrides(settingsRepository),
          unreadReminderSchedulerProvider.overrideWith(
            (Ref ref) => UnreadReminderScheduler(
              bookmarkRepository: ref.watch(bookmarkRepositoryProvider),
              notificationService: const _NoOpNotificationService(),
              payload: Routes.homeUnread,
            ),
          ),
        ],
      );
      _cachedShareContainer = container;
    }
    return await container
        .read(shareCaptureCoordinatorProvider)
        .captureSharedText(text);
  } on Object catch (error) {
    _cachedShareContainer = null;
    debugPrint('[ShareOverlay] Capture failed: $error');
    return CaptureResult.error('share_overlay_capture_failed: $error');
  }
}
