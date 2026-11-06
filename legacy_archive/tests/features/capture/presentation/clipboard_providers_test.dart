import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marky/features/capture/presentation/providers/clipboard_providers.dart';

void main() {
  group('ClipboardNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has null detectedUrl and lastSeenHash', () {
      final ClipboardState state = container.read(clipboardUrlProvider);

      expect(state.detectedUrl, isNull);
      expect(state.lastSeenHash, isNull);
    });

    test('setDetectedUrl updates both detectedUrl and lastSeenHash', () {
      final ClipboardNotifier notifier = container.read(clipboardUrlProvider.notifier);

      notifier.setDetectedUrl('https://example.com', 'hash-a');

      final ClipboardState state = container.read(clipboardUrlProvider);
      expect(state.detectedUrl, 'https://example.com');
      expect(state.lastSeenHash, 'hash-a');
    });

    test('setDetectedUrl ignores duplicate hash', () {
      final ClipboardNotifier notifier = container.read(clipboardUrlProvider.notifier);

      notifier.setDetectedUrl('https://example.com', 'hash-a');
      notifier.setDetectedUrl('https://example.com/duplicate', 'hash-a');

      final ClipboardState state = container.read(clipboardUrlProvider);
      // Second call with same hash should be ignored.
      expect(state.detectedUrl, 'https://example.com');
      expect(state.lastSeenHash, 'hash-a');
    });

    test('setDetectedUrl allows new hash after previous detection', () {
      final ClipboardNotifier notifier = container.read(clipboardUrlProvider.notifier);

      notifier.setDetectedUrl('https://first.com', 'hash-a');
      notifier.setDetectedUrl('https://second.com', 'hash-b');

      final ClipboardState state = container.read(clipboardUrlProvider);
      expect(state.detectedUrl, 'https://second.com');
      expect(state.lastSeenHash, 'hash-b');
    });

    test('dismiss clears detectedUrl but preserves lastSeenHash', () {
      final ClipboardNotifier notifier = container.read(clipboardUrlProvider.notifier);

      notifier.setDetectedUrl('https://example.com', 'hash-a');
      notifier.dismiss();

      final ClipboardState state = container.read(clipboardUrlProvider);
      expect(state.detectedUrl, isNull);
      expect(state.lastSeenHash, 'hash-a');
    });

    test('dismiss prevents re-prompting same URL', () {
      final ClipboardNotifier notifier = container.read(clipboardUrlProvider.notifier);

      notifier.setDetectedUrl('https://example.com', 'hash-a');
      notifier.dismiss();

      // Attempt to set the same URL again.
      notifier.setDetectedUrl('https://example.com', 'hash-a');

      final ClipboardState state = container.read(clipboardUrlProvider);
      expect(state.detectedUrl, isNull);
      expect(state.lastSeenHash, 'hash-a');
    });

    test('clear resets both detectedUrl and lastSeenHash', () {
      final ClipboardNotifier notifier = container.read(clipboardUrlProvider.notifier);

      notifier.setDetectedUrl('https://example.com', 'hash-a');
      notifier.clear();

      final ClipboardState state = container.read(clipboardUrlProvider);
      expect(state.detectedUrl, isNull);
      expect(state.lastSeenHash, isNull);
    });

    test('clear then setDetectedUrl works for previously seen hash', () {
      final ClipboardNotifier notifier = container.read(clipboardUrlProvider.notifier);

      notifier.setDetectedUrl('https://example.com', 'hash-a');
      notifier.dismiss();
      notifier.clear();

      // After clear, the same hash should be accepted again.
      notifier.setDetectedUrl('https://example.com', 'hash-a');

      final ClipboardState state = container.read(clipboardUrlProvider);
      expect(state.detectedUrl, 'https://example.com');
      expect(state.lastSeenHash, 'hash-a');
    });
  });

  group('clipboardUrlProvider', () {
    test('exposes ClipboardNotifier instance', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final ClipboardNotifier notifier = container.read(clipboardUrlProvider.notifier);
      expect(notifier, isA<ClipboardNotifier>());
    });
  });
}
