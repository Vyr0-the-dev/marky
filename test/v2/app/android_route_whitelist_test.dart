import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:marky/features/quick_actions/domain/quick_action_route.dart';

void main() {
  test('Android OPEN_ROUTE intent uses the same supported route whitelist', () {
    final File mainActivity = File(
      'android/app/src/main/kotlin/com/marky/app/marky/MainActivity.kt',
    );
    final String kotlin = mainActivity.readAsStringSync();

    expect(kotlin, contains('supportedShortcutRoutes.contains(route)'));

    for (final String route in QuickActionRoute.supportedRoutes) {
      expect(kotlin, contains('"$route"'));
    }

    expect(kotlin, isNot(contains('"/settings"')));
    expect(kotlin, isNot(contains('"/detail/')));
  });
}
