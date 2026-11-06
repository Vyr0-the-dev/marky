import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/features/capture/domain/services/clipboard_monitor.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/features/capture/presentation/providers/clipboard_providers.dart';
import 'package:marky/features/capture/presentation/widgets/clipboard_lifecycle_observer.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/shared/models/app_settings.dart';

import '../../../fakes/fake_app_settings_repository.dart';

// ─── Fake Helpers ──────────────────────────────────────────────────────

/// A fake [ClipboardMonitor] that returns a pre-configured result.
class _FakeClipboardMonitor extends ClipboardMonitor {
  _FakeClipboardMonitor({this.result})
      : super(
          urlNormalizationService: UrlNormalizationService.instance,
          clipboardReader: () async => null,
        );

  final ClipboardCheckResult? result;

  @override
  Future<ClipboardCheckResult?> checkClipboard() async => result;
}

// ─── Widget Tests ──────────────────────────────────────────────────────

void main() {
  group('ClipboardLifecycleObserver', () {
    late FakeAppSettingsRepository fakeSettingsRepo;

    setUp(() {
      fakeSettingsRepo = FakeAppSettingsRepository();
    });

    Widget buildObserver({
      required ClipboardMonitor monitor,
      required AppSettings settings,
    }) {
      return ProviderScope(
        overrides: <Override>[
          appSettingsProvider.overrideWith(
            (Ref ref) => AppSettingsNotifier(repository: fakeSettingsRepo)
              ..state = settings,
          ),
          clipboardMonitorProvider.overrideWithValue(monitor),
        ],
        child: const ClipboardLifecycleObserver(
          child: SizedBox(),
        ),
      );
    }

    testWidgets(
      'initState checks clipboard and updates provider when URL found',
      (WidgetTester tester) async {
        const ClipboardCheckResult result = ClipboardCheckResult(
          url: 'https://example.com',
          hash: 'abc123',
        );

        await tester.pumpWidget(
          buildObserver(
            monitor: _FakeClipboardMonitor(result: result),
            settings: AppSettings(),
          ),
        );
        await tester.pumpAndSettle();

        final ClipboardState state = ProviderScope.containerOf(
          tester.element(find.byType(ClipboardLifecycleObserver)),
        ).read(clipboardUrlProvider);

        expect(state.detectedUrl, 'https://example.com');
        expect(state.lastSeenHash, 'abc123');
      },
    );

    testWidgets(
      'initState does nothing when clipboard detection is disabled',
      (WidgetTester tester) async {
        const ClipboardCheckResult result = ClipboardCheckResult(
          url: 'https://example.com',
          hash: 'abc123',
        );

        await tester.pumpWidget(
          buildObserver(
            monitor: _FakeClipboardMonitor(result: result),
            settings: AppSettings(clipboardDetectionEnabled: false),
          ),
        );
        await tester.pumpAndSettle();

        final ClipboardState state = ProviderScope.containerOf(
          tester.element(find.byType(ClipboardLifecycleObserver)),
        ).read(clipboardUrlProvider);

        expect(state.detectedUrl, isNull);
        expect(state.lastSeenHash, isNull);
      },
    );

    testWidgets(
      'didChangeAppLifecycleState(resumed) checks clipboard and updates provider',
      (WidgetTester tester) async {
        const ClipboardCheckResult result = ClipboardCheckResult(
          url: 'https://resumed.com',
          hash: 'xyz789',
        );

        await tester.pumpWidget(
          buildObserver(
            monitor: _FakeClipboardMonitor(result: result),
            settings: AppSettings(),
          ),
        );
        await tester.pumpAndSettle();

        // Clear the initState result so we can verify resume triggers a new one.
        final ProviderContainer container = ProviderScope.containerOf(
          tester.element(find.byType(ClipboardLifecycleObserver)),
        );
        container.read(clipboardUrlProvider.notifier).clear();

        // Manually trigger lifecycle resumed.
        final dynamic state = tester.state(find.byType(ClipboardLifecycleObserver));
        // ignore: avoid_dynamic_calls
        state.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await tester.pumpAndSettle();

        final ClipboardState clipboardState = container.read(clipboardUrlProvider);
        expect(clipboardState.detectedUrl, 'https://resumed.com');
        expect(clipboardState.lastSeenHash, 'xyz789');
      },
    );

    testWidgets(
      'didChangeAppLifecycleState(paused) does not check clipboard',
      (WidgetTester tester) async {
        const ClipboardCheckResult result = ClipboardCheckResult(
          url: 'https://example.com',
          hash: 'abc123',
        );

        await tester.pumpWidget(
          buildObserver(
            monitor: _FakeClipboardMonitor(result: result),
            settings: AppSettings(),
          ),
        );
        await tester.pumpAndSettle();

        // Clear initState result.
        final ProviderContainer container = ProviderScope.containerOf(
          tester.element(find.byType(ClipboardLifecycleObserver)),
        );
        container.read(clipboardUrlProvider.notifier).clear();

        // Trigger paused lifecycle.
        final dynamic state = tester.state(find.byType(ClipboardLifecycleObserver));
        // ignore: avoid_dynamic_calls
        state.didChangeAppLifecycleState(AppLifecycleState.paused);
        await tester.pumpAndSettle();

        final ClipboardState clipboardState = container.read(clipboardUrlProvider);
        expect(clipboardState.detectedUrl, isNull);
        expect(clipboardState.lastSeenHash, isNull);
      },
    );

    testWidgets(
      'null clipboard result does not update provider',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildObserver(
            monitor: _FakeClipboardMonitor(),
            settings: AppSettings(),
          ),
        );
        await tester.pumpAndSettle();

        final ClipboardState state = ProviderScope.containerOf(
          tester.element(find.byType(ClipboardLifecycleObserver)),
        ).read(clipboardUrlProvider);

        expect(state.detectedUrl, isNull);
        expect(state.lastSeenHash, isNull);
      },
    );
  });
}
