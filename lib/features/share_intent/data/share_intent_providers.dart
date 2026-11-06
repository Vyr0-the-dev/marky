import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/capture/domain/capture_service.dart';
import 'package:marky/features/share_intent/domain/share_capture_coordinator.dart';
import 'package:marky/features/share_intent/domain/share_intent_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

final Provider<ShareIntentHandler> shareIntentHandlerProvider =
    Provider<ShareIntentHandler>((Ref ref) {
  return ShareIntentHandler(
    mediaStream: ReceiveSharingIntent.instance.getMediaStream(),
    initialMediaGetter: ReceiveSharingIntent.instance.getInitialMedia,
    reset: ReceiveSharingIntent.instance.reset,
  );
});

final FutureProvider<String?> shareIntentInitialTextProvider =
    FutureProvider<String?>((Ref ref) async {
  return ref.watch(shareIntentHandlerProvider).getInitialText();
});

final StreamProvider<String?> shareIntentTextStreamProvider =
    StreamProvider<String?>((Ref ref) {
  return ref.watch(shareIntentHandlerProvider).textStream;
});

final Provider<ShareCaptureCoordinator> shareCaptureCoordinatorProvider =
    Provider<ShareCaptureCoordinator>((Ref ref) {
  final CaptureService captureService = ref.watch(captureServiceProvider);
  return ShareCaptureCoordinator(captureService: captureService);
});
