import 'package:flutter_test/flutter_test.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/share_intent/presentation/share_overlay_controller.dart';

void main() {
  group('ShareOverlayController', () {
    late _FakeShareSessionGateway gateway;
    late DateTime currentTime;

    setUp(() {
      currentTime = DateTime.utc(2026, 3, 1, 12);
      gateway = _FakeShareSessionGateway();
    });

    test(
      'captures initialPayload immediately and transitions loading -> success',
      () async {
        final ShareOverlayController controller = ShareOverlayController(
          gateway: gateway,
          initialPayload: '  https://example.com/shared  ',
          now: () => currentTime,
        );
        addTearDown(controller.dispose);

        await Future<void>.delayed(Duration.zero);

        expect(
            gateway.capturedPayloads, <String?>['https://example.com/shared']);
        expect(controller.state.status, ShareOverlayStatus.success);
        expect(controller.state.result?.status, CaptureStatus.saved);
      },
    );

    test(
      'debounces duplicate payload within 400ms window and allows capture after window',
      () async {
        final ShareOverlayController controller = ShareOverlayController(
          gateway: gateway,
          initialPayload: 'https://example.com/debounce',
          now: () => currentTime,
        );
        addTearDown(controller.dispose);

        await Future<void>.delayed(Duration.zero);
        expect(gateway.capturedPayloads.length, 1);

        // Within 400ms window -> ignored
        currentTime = currentTime.add(const Duration(milliseconds: 200));
        controller.handleIncomingPayload('https://example.com/debounce');
        await Future<void>.delayed(Duration.zero);
        expect(gateway.capturedPayloads.length, 1);

        // After 400ms window -> captured again
        currentTime = currentTime.add(const Duration(milliseconds: 300));
        controller.handleIncomingPayload('https://example.com/debounce');
        await Future<void>.delayed(Duration.zero);
        expect(gateway.capturedPayloads.length, 2);
      },
    );

    test(
      'emits invalidUrl after captureTimeout when no payload is provided',
      () async {
        final ShareOverlayController controller = ShareOverlayController(
          gateway: gateway,
          captureTimeout: const Duration(milliseconds: 20),
          now: () => currentTime,
        );
        addTearDown(controller.dispose);

        await Future<void>.delayed(const Duration(milliseconds: 40));

        expect(controller.state.status, ShareOverlayStatus.failure);
        expect(controller.state.result?.status, CaptureStatus.invalidUrl);
      },
    );

    test(
      'requestClose finishes overlay and resets state to idle; requestOpenMainApp falls back to finishOverlay on error',
      () async {
        final ShareOverlayController controller = ShareOverlayController(
          gateway: gateway,
          initialPayload: 'https://example.com/close',
          now: () => currentTime,
        );
        addTearDown(controller.dispose);
        await Future<void>.delayed(Duration.zero);

        await controller.requestClose();
        expect(gateway.finishCalls, 1);
        expect(controller.state.status, ShareOverlayStatus.idle);
        expect(controller.state.activePayload, isNull);

        gateway.throwOnOpenMainApp = true;
        await controller.requestOpenMainApp();
        expect(gateway.openMainAppCalls, 1);
        expect(gateway.finishCalls, 2);
        expect(controller.state.status, ShareOverlayStatus.idle);
      },
    );
  });
}

class _FakeShareSessionGateway implements ShareSessionGateway {
  final List<String?> capturedPayloads = <String?>[];
  void Function(String? payload)? payloadHandler;
  String? initialPayload;
  int finishCalls = 0;
  int openMainAppCalls = 0;
  int flutterReadyCalls = 0;
  bool throwOnOpenMainApp = false;

  @override
  Future<void> warmUp() async {}

  @override
  Future<AppLocaleChoice> loadSavedLocale() async => AppLocaleChoice.en;

  @override
  Future<CaptureResult> capturePayload(String? payload) async {
    capturedPayloads.add(payload);
    final DateTime now = DateTime.utc(2026, 3);
    return CaptureResult.saved(
      Bookmark(
        id: 1,
        originalUrl: payload ?? 'https://example.com',
        normalizedHost: 'example.com',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<String?> getInitialPayload() async => initialPayload;

  @override
  void setPayloadHandler(void Function(String? payload) handler) {
    payloadHandler = handler;
  }

  @override
  void clearPayloadHandler() {
    payloadHandler = null;
  }

  @override
  Future<void> notifyFlutterReady() async {
    flutterReadyCalls += 1;
  }

  @override
  Future<void> finishOverlay() async {
    finishCalls += 1;
  }

  @override
  Future<void> openMainApp() async {
    openMainAppCalls += 1;
    if (throwOnOpenMainApp) {
      throw StateError('cannot open main app');
    }
  }
}
