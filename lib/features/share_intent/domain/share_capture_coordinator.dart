import 'package:marky/features/capture/domain/capture_result.dart';
import 'package:marky/features/capture/domain/capture_service.dart';

class ShareCaptureCoordinator {
  const ShareCaptureCoordinator({required CaptureService captureService})
      : _captureService = captureService;

  final CaptureService _captureService;

  Future<CaptureResult> captureSharedText(String text) {
    return _captureService.captureFromText(text);
  }
}
