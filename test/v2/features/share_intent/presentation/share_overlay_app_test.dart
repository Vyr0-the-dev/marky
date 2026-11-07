import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/capture/domain/duplicate_check_result.dart';
import 'package:marky/features/share_intent/presentation/share_overlay_app.dart';
import 'package:marky/features/share_intent/presentation/share_result_sheet.dart';

void main() {
  testWidgets(
    'shows the share sheet immediately and finishes on close',
    (WidgetTester tester) async {
      final Completer<CaptureResult> captureCompleter =
          Completer<CaptureResult>();
      String? capturedPayload;
      var finishCalls = 0;
      var openMainAppCalls = 0;

      await tester.pumpWidget(
        ShareOverlayApp(
          initialPayload: 'Shared text https://example.com/article',
          autoCloseAfter: const Duration(minutes: 1),
          localeChoice: AppLocaleChoice.en,
          capturePayload: (String? payload) {
            capturedPayload = payload;
            return captureCompleter.future;
          },
          finishOverlay: () async {
            finishCalls++;
          },
          openMainApp: () async {
            openMainAppCalls++;
          },
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Saving'), findsOneWidget);
      expect(
        capturedPayload,
        'Shared text https://example.com/article',
      );

      captureCompleter.complete(const CaptureResult.invalidUrl());
      await tester.pumpAndSettle();

      expect(find.text('Could not save'), findsOneWidget);

      await tester.tap(find.text('Open app'));
      await tester.pumpAndSettle();

      expect(finishCalls, 0);
      expect(openMainAppCalls, 1);
    },
  );

  testWidgets(
    'finishes the overlay after the result auto close duration',
    (WidgetTester tester) async {
      var finishCalls = 0;

      await tester.pumpWidget(
        ShareOverlayApp(
          initialPayload: 'Shared text https://example.com/article',
          autoCloseAfter: const Duration(milliseconds: 250),
          localeChoice: AppLocaleChoice.en,
          capturePayload: (_) async => const CaptureResult.invalidUrl(),
          finishOverlay: () async {
            finishCalls++;
          },
          openMainApp: () async {},
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Could not save'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 251));

      expect(finishCalls, 1);
    },
  );

  testWidgets('uses explicit Turkish locale when requested',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ShareOverlayApp(
        initialPayload: 'Paylaşım https://example.com/article',
        autoCloseAfter: const Duration(minutes: 1),
        localeChoice: AppLocaleChoice.tr,
        capturePayload: (_) async => const CaptureResult.invalidUrl(),
        finishOverlay: () async {},
        openMainApp: () async {},
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Kaydedilemedi'), findsOneWidget);
    expect(find.text('Uygulamayı aç'), findsOneWidget);
  });

  testWidgets('resolves system locale from the platform locale list',
      (WidgetTester tester) async {
    tester.binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('en'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ShareOverlayApp(
        initialPayload: 'Shared text https://example.com/article',
        autoCloseAfter: const Duration(minutes: 1),
        capturePayload: (_) async => const CaptureResult.invalidUrl(),
        finishOverlay: () async {},
        openMainApp: () async {},
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Could not save'), findsOneWidget);
    expect(find.text('Open app'), findsOneWidget);
    expect(find.text('Kaydedilemedi'), findsNothing);
  });

  testWidgets('finishes the overlay when back is requested',
      (WidgetTester tester) async {
    var finishCalls = 0;

    await tester.pumpWidget(
      ShareOverlayApp(
        initialPayload: 'Shared text https://example.com/article',
        autoCloseAfter: const Duration(minutes: 1),
        capturePayload: (_) async => const CaptureResult.invalidUrl(),
        finishOverlay: () async {
          finishCalls++;
        },
        openMainApp: () async {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(finishCalls, 1);
  });

  testWidgets('finishes the overlay when dragged down',
      (WidgetTester tester) async {
    var finishCalls = 0;

    await tester.pumpWidget(
      ShareOverlayApp(
        initialPayload: 'Shared text https://example.com/article',
        autoCloseAfter: const Duration(minutes: 1),
        capturePayload: (_) async => const CaptureResult.invalidUrl(),
        finishOverlay: () async {
          finishCalls++;
        },
        openMainApp: () async {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.drag(find.byType(MarkyShareResultPanel), const Offset(0, 90));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(finishCalls, 1);
  });

  testWidgets('finishes the overlay when scrim is tapped',
      (WidgetTester tester) async {
    var finishCalls = 0;

    await tester.pumpWidget(
      ShareOverlayApp(
        initialPayload: 'Shared text https://example.com/article',
        autoCloseAfter: const Duration(minutes: 1),
        capturePayload: (_) async => const CaptureResult.invalidUrl(),
        finishOverlay: () async {
          finishCalls++;
        },
        openMainApp: () async {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Tap outside sheet (top of screen on scrim)
    await tester.tapAt(const Offset(100, 50));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(finishCalls, 1);
  });

  testWidgets('shows duplicate icon and already saved title for duplicate status',
      (WidgetTester tester) async {
    final DateTime now = DateTime.now();
    final Bookmark bookmark = Bookmark(
      id: 1,
      originalUrl: 'https://example.com/article',
      normalizedHost: 'example.com',
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ShareOverlayApp(
        initialPayload: 'Shared text https://example.com/article',
        autoCloseAfter: const Duration(minutes: 1),
        localeChoice: AppLocaleChoice.en,
        capturePayload: (_) async => CaptureResult.duplicate(
          bookmark,
          DuplicateMatchLevel.canonicalUrl,
        ),
        finishOverlay: () async {},
        openMainApp: () async {},
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Already saved'), findsOneWidget);
    expect(find.byKey(const ValueKey('duplicate')), findsOneWidget);
  });
}
