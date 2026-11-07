import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/settings/app_settings_repository.dart';
import 'package:marky/core/database/database_providers.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/unread_reminder_scheduler.dart';
import 'package:marky/features/share_intent/data/share_intent_providers.dart';
import 'package:marky/features/share_intent/platform/share_overlay_bridge.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

abstract interface class ShareSessionGateway {
  Future<void> warmUp();

  Future<AppLocaleChoice> loadSavedLocale();

  Future<CaptureResult> capturePayload(String? payload);

  Future<String?> getInitialPayload();

  void setPayloadHandler(void Function(String? payload) handler);

  void clearPayloadHandler();

  Future<void> notifyFlutterReady();

  Future<void> finishOverlay();

  Future<void> openMainApp();
}

class DefaultShareSessionGateway implements ShareSessionGateway {
  DefaultShareSessionGateway({
    Future<CaptureResult> Function(String? payload)? capturePayload,
    Future<void> Function()? finishOverlay,
    Future<void> Function()? openMainApp,
  })  : _capturePayloadOverride = capturePayload,
        _finishOverlayOverride = finishOverlay,
        _openMainAppOverride = openMainApp;

  final Future<CaptureResult> Function(String? payload)?
      _capturePayloadOverride;
  final Future<void> Function()? _finishOverlayOverride;
  final Future<void> Function()? _openMainAppOverride;

  Future<ProviderContainer>? _containerFuture;

  @override
  Future<void> warmUp() async {
    try {
      await _getOrCreateContainer();
    } on Object catch (error) {
      debugPrint('[ShareOverlay] Warmup container failed: $error');
      _containerFuture = null;
    }
  }

  @override
  Future<AppLocaleChoice> loadSavedLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SharedPreferencesAppSettingsRepository repo =
        SharedPreferencesAppSettingsRepository(prefs);
    final AppSettings settings = await repo.load();
    return settings.locale;
  }

  @override
  Future<CaptureResult> capturePayload(String? payload) async {
    final Future<CaptureResult> Function(String? payload)? override =
        _capturePayloadOverride;
    if (override != null) {
      return override(payload);
    }

    final String? text = payload?.trim();
    if (text == null || text.isEmpty) {
      return const CaptureResult.invalidUrl();
    }

    try {
      final ProviderContainer container = await _getOrCreateContainer();
      return await container
          .read(shareCaptureCoordinatorProvider)
          .captureSharedText(text);
    } on Object catch (error) {
      _containerFuture = null;
      debugPrint('[ShareOverlay] Capture failed: $error');
      return CaptureResult.error('share_overlay_capture_failed: $error');
    }
  }

  @override
  Future<String?> getInitialPayload() {
    return ShareOverlayBridge.getInitialPayload();
  }

  @override
  void setPayloadHandler(void Function(String? payload) handler) {
    ShareOverlayBridge.setPayloadHandler(handler);
  }

  @override
  void clearPayloadHandler() {
    ShareOverlayBridge.clearPayloadHandler();
  }

  @override
  Future<void> notifyFlutterReady() {
    return ShareOverlayBridge.flutterReady();
  }

  @override
  Future<void> finishOverlay() {
    return (_finishOverlayOverride ?? ShareOverlayBridge.finish)();
  }

  @override
  Future<void> openMainApp() {
    return (_openMainAppOverride ?? ShareOverlayBridge.openMainApp)();
  }

  Future<ProviderContainer> _getOrCreateContainer() {
    final Future<ProviderContainer>? existing = _containerFuture;
    if (existing != null) return existing;

    final Future<ProviderContainer> future = () async {
      final databaseBootstrap = await markyDatabaseBootstrap();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SharedPreferencesAppSettingsRepository settingsRepository =
          SharedPreferencesAppSettingsRepository(prefs);
      await settingsRepository.load();
      return ProviderContainer(
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
    }();

    _containerFuture = future;
    return future;
  }
}

enum ShareOverlayStatus { idle, loading, success, failure }

class ShareOverlayState {
  const ShareOverlayState({
    required this.status,
    this.result,
    this.activePayload,
    this.isClosing = false,
    this.openAppRequested = false,
    this.errorMessage,
  });

  const ShareOverlayState.idle()
      : status = ShareOverlayStatus.idle,
        result = null,
        activePayload = null,
        isClosing = false,
        openAppRequested = false,
        errorMessage = null;

  final ShareOverlayStatus status;
  final CaptureResult? result;
  final String? activePayload;
  final bool isClosing;
  final bool openAppRequested;
  final String? errorMessage;

  ShareOverlayState copyWith({
    ShareOverlayStatus? status,
    CaptureResult? result,
    bool clearResult = false,
    String? activePayload,
    bool clearActivePayload = false,
    bool? isClosing,
    bool? openAppRequested,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ShareOverlayState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      activePayload:
          clearActivePayload ? null : (activePayload ?? this.activePayload),
      isClosing: isClosing ?? this.isClosing,
      openAppRequested: openAppRequested ?? this.openAppRequested,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ShareOverlayController extends StateNotifier<ShareOverlayState> {
  ShareOverlayController({
    required ShareSessionGateway gateway,
    String? initialPayload,
    Duration captureTimeout = const Duration(seconds: 4),
    Duration duplicateDebounceWindow = const Duration(milliseconds: 400),
    DateTime Function()? now,
  })  : _gateway = gateway,
        _initialPayload = initialPayload,
        _captureTimeout = captureTimeout,
        _duplicateDebounceWindow = duplicateDebounceWindow,
        _now = now ?? DateTime.now,
        super(const ShareOverlayState.idle()) {
    _initialize();
  }

  final ShareSessionGateway _gateway;
  final String? _initialPayload;
  final Duration _captureTimeout;
  final Duration _duplicateDebounceWindow;
  final DateTime Function() _now;

  Timer? _captureTimeoutTimer;
  bool _isCapturing = false;
  bool _flutterReadyNotified = false;
  DateTime _lastCaptureTime = DateTime.fromMillisecondsSinceEpoch(0);

  void _initialize() {
    final String? payload = _initialPayload?.trim();
    if (payload != null && payload.isNotEmpty) {
      _lastCaptureTime = _now();
      state = ShareOverlayState(
        status: ShareOverlayStatus.loading,
        activePayload: payload,
      );
      unawaited(_executeCapture(payload));
    } else {
      _gateway.getInitialPayload().then((String? bridgePayload) {
        if (!mounted) return;
        final String? trimmed = bridgePayload?.trim();
        if (trimmed != null && trimmed.isNotEmpty) {
          handleIncomingPayload(trimmed);
        }
      }).catchError((Object _) {});

      _captureTimeoutTimer = Timer(_captureTimeout, () {
        if (!mounted || state.result != null) return;
        state = state.copyWith(
          status: ShareOverlayStatus.failure,
          result: const CaptureResult.invalidUrl(),
        );
      });
    }

    _gateway.setPayloadHandler(handleIncomingPayload);
  }

  void notifyFlutterReady() {
    if (_flutterReadyNotified) return;
    _flutterReadyNotified = true;
    unawaited(_gateway.notifyFlutterReady().catchError((Object _) {}));
  }

  void handleIncomingPayload(String? payload) {
    if (!mounted) return;
    final String? trimmed = payload?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    final Duration elapsed = _now().difference(_lastCaptureTime);
    if (state.activePayload == trimmed &&
        (_isCapturing || elapsed < _duplicateDebounceWindow)) {
      return;
    }

    _captureTimeoutTimer?.cancel();
    _lastCaptureTime = _now();
    state = ShareOverlayState(
      status: ShareOverlayStatus.loading,
      activePayload: trimmed,
    );

    notifyFlutterReady();
    unawaited(_executeCapture(trimmed));
  }

  Future<void> _executeCapture(String payload) async {
    if (_isCapturing) return;
    _isCapturing = true;
    try {
      final CaptureResult result = await _gateway.capturePayload(payload);
      if (!mounted) return;
      final bool isFailure = result.status == CaptureStatus.error ||
          result.status == CaptureStatus.invalidUrl;
      state = state.copyWith(
        status:
            isFailure ? ShareOverlayStatus.failure : ShareOverlayStatus.success,
        result: result,
        isClosing: false,
        errorMessage: result.errorMessage,
      );
    } on Object catch (error) {
      if (!mounted) return;
      final String message = 'share_overlay_capture_failed: $error';
      state = state.copyWith(
        status: ShareOverlayStatus.failure,
        result: CaptureResult.error(message),
        isClosing: false,
        errorMessage: message,
      );
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> requestClose() {
    if (state.isClosing || state.openAppRequested) {
      return Future<void>.value();
    }
    state = state.copyWith(isClosing: true);
    return _finishOverlay();
  }

  Future<void> requestOpenMainApp() {
    if (state.openAppRequested) {
      return Future<void>.value();
    }
    state = state.copyWith(openAppRequested: true);
    return _openMainApp();
  }

  Future<void> _finishOverlay() async {
    try {
      await _gateway.finishOverlay();
    } on Object {
      debugPrint('[ShareOverlay] Finish failed');
    } finally {
      if (mounted) {
        state = const ShareOverlayState.idle();
      }
    }
  }

  Future<void> _openMainApp() async {
    try {
      await _gateway.openMainApp();
    } on Object {
      debugPrint('[ShareOverlay] Open main app failed');
      await _finishOverlay();
      return;
    }
    if (mounted) {
      state = const ShareOverlayState.idle();
    }
  }

  @override
  void dispose() {
    _gateway.clearPayloadHandler();
    _captureTimeoutTimer?.cancel();
    super.dispose();
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

  @override
  void setPayloadHandler(void Function(String payload)? handler) {}
}
