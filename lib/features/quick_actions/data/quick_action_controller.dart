import 'package:flutter/services.dart';
import 'package:marky/features/quick_actions/domain/quick_action_route.dart';

typedef QuickActionRouteHandler = void Function(String route);

class QuickActionController {
  QuickActionController({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('marky/quick_actions');

  final MethodChannel _channel;
  bool _registered = false;

  void registerRouteHandler(QuickActionRouteHandler onRoute) {
    if (_registered) return;
    _registered = true;
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method != 'onShortcutRoute') return null;
      final String? route = QuickActionRoute.normalize(call.arguments);
      if (route != null) onRoute(route);
      return null;
    });
  }

  Future<String?> consumeInitialRoute() async {
    try {
      final Object? route = await _channel.invokeMethod<Object?>(
        'getInitialShortcutRoute',
      );
      return QuickActionRoute.normalize(route);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
