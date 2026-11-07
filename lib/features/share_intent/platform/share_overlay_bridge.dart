import 'package:flutter/services.dart';

class ShareOverlayBridge {
  const ShareOverlayBridge._();

  static const MethodChannel _channel = MethodChannel('marky/share_overlay');

  static Future<String?> getInitialPayload() {
    return _channel.invokeMethod<String>('getInitialPayload');
  }

  static Future<void> flutterReady() async {
    await _channel.invokeMethod<void>('flutterReady');
  }

  static Future<void> finish() async {
    await _channel.invokeMethod<void>('finishOverlay');
  }

  static Future<void> openMainApp() async {
    await _channel.invokeMethod<void>('openMainApp');
  }

  static void setPayloadHandler(void Function(String?) handler) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'newPayload') {
        final dynamic arg = call.arguments;
        handler(arg is String ? arg : null);
      }
    });
  }

  static void clearPayloadHandler() {
    _channel.setMethodCallHandler(null);
  }
}
