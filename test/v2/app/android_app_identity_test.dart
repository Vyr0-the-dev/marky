import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android app identity is final for Marky 1.0', () {
    final String buildGradle =
        File('android/app/build.gradle.kts').readAsStringSync();
    final String manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final String strings = File(
      'android/app/src/main/res/values/strings.xml',
    ).readAsStringSync();
    final String pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('name: marky'));
    expect(
      pubspec,
      contains('description: Marky - Offline-first personal link vault'),
    );
    expect(pubspec, contains('version: 1.0.0+1'));
    expect(buildGradle, contains('namespace = "com.marky.app.marky"'));
    expect(buildGradle, contains('applicationId = "com.marky.app.marky"'));
    expect(manifest, contains('android:label="@string/app_name"'));
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    expect(strings, contains('<string name="app_name">Marky</string>'));
  });

  test('Android launcher and splash resources are final Marky assets', () {
    final String splash = File(
      'android/app/src/main/res/drawable/launch_background.xml',
    ).readAsStringSync();
    final String splashV21 = File(
      'android/app/src/main/res/drawable-v21/launch_background.xml',
    ).readAsStringSync();

    for (final String density in <String>[
      'mdpi',
      'hdpi',
      'xhdpi',
      'xxhdpi',
      'xxxhdpi',
    ]) {
      expect(
        File('android/app/src/main/res/mipmap-$density/ic_launcher.png')
            .existsSync(),
        isTrue,
      );
      expect(
        File('android/app/src/main/res/mipmap-$density/ic_launcher_round.png')
            .existsSync(),
        isTrue,
      );
      expect(
        File('android/app/src/main/res/mipmap-$density/ic_launcher.png')
            .readAsBytesSync(),
        File('android/app/src/main/res/mipmap-$density/ic_launcher_round.png')
            .readAsBytesSync(),
      );
    }
    expect(splash, contains('@android:color/black'));
    expect(splashV21, contains('@android:color/black'));
    expect(splash, isNot(contains('launch_image')));
    expect(splashV21, isNot(contains('launch_image')));
  });
}
