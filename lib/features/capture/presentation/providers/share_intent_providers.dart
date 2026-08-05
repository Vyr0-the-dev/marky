import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:marky/features/capture/domain/services/share_intent_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

// ─── Handler provider ──────────────────────────────────────────────────

/// Provider that exposes the live [ShareIntentHandler] wired to the
/// platform's [ReceiveSharingIntent] plugin.
///
/// This is the canonical instance used by the UI. Override in tests
/// with a handler that uses injected fakes.
final Provider<ShareIntentHandler> shareIntentHandlerProvider =
    Provider<ShareIntentHandler>((Ref ref) {
  return ShareIntentHandler(
    mediaStream: ReceiveSharingIntent.instance.getMediaStream(),
    initialMediaGetter: ReceiveSharingIntent.instance.getInitialMedia,
    reset: ReceiveSharingIntent.instance.reset,
    logger: Logger(),
  );
});

// ─── Derived async providers ───────────────────────────────────────────

/// A [FutureProvider] that resolves to the initial shared URL on app
/// launch (cold-start share intent), or `null` if none was shared.
///
/// Automatically resets the consumed intent so it is not replayed.
final FutureProvider<String?> shareIntentInitialUrlProvider =
    FutureProvider<String?>((Ref ref) async {
  final ShareIntentHandler handler = ref.watch(shareIntentHandlerProvider);
  return handler.getInitialUrl();
});

/// A [StreamProvider] that emits validated URLs from the live share
/// intent stream (warm-start / while-app-is-running shares).
///
/// Emits `null` when the shared content is not a valid URL.
final StreamProvider<String?> shareIntentStreamProvider =
    StreamProvider<String?>((Ref ref) {
  final ShareIntentHandler handler = ref.watch(shareIntentHandlerProvider);
  return handler.urlStream;
});
