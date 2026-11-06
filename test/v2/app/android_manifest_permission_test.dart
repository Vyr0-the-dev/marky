import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android manifest keeps requested permissions minimal', () {
    final File manifest = File('android/app/src/main/AndroidManifest.xml');

    expect(manifest.existsSync(), isTrue);

    final String xml = manifest.readAsStringSync();

    expect(xml, contains('android.permission.INTERNET'));
    expect(xml, contains('android.permission.SCHEDULE_EXACT_ALARM'));
    expect(xml, contains('android.permission.POST_NOTIFICATIONS'));
    expect(xml, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    expect(
      xml,
      contains(
        'android:name="android.permission.VIBRATE" tools:node="remove"',
      ),
    );
    expect(
      xml,
      contains(
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
      ),
    );
    expect(
      xml,
      contains(
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
      ),
    );
    expect(xml, contains('android.intent.action.BOOT_COMPLETED'));
    expect(xml, contains('android.intent.action.MY_PACKAGE_REPLACED'));
  });
}
