import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('share overlay activity is transient', () {
    final String manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final RegExpMatch? activityMatch = RegExp(
      r'<activity\s+[^>]*android:name="\.ShareOverlayActivity"[\s\S]*?</activity>',
    ).firstMatch(manifest);

    expect(activityMatch, isNotNull);
    final String activity = activityMatch!.group(0)!;

    expect(activity, contains('android:theme="@style/ShareOverlayTheme"'));
    expect(activity, contains('android:excludeFromRecents="true"'));
    expect(activity, contains('android:autoRemoveFromRecents="true"'));
    expect(activity, contains('android:noHistory="true"'));
    expect(activity, contains('android:finishOnTaskLaunch="true"'));
    expect(activity, contains('android:documentLaunchMode="never"'));
    expect(activity, contains('android:taskAffinity=""'));
    expect(activity, contains('android.intent.action.SEND'));
    expect(activity, contains('android.intent.action.SEND_MULTIPLE'));
  });

  test('share overlay theme uses a native startup host while Flutter starts',
      () {
    final String lightStyles =
        File('android/app/src/main/res/values/styles.xml').readAsStringSync();
    final String darkStyles = File(
      'android/app/src/main/res/values-night/styles.xml',
    ).readAsStringSync();
    final String api31Styles = File(
      'android/app/src/main/res/values-v31/styles.xml',
    ).readAsStringSync();
    final String dimBackground = File(
      'android/app/src/main/res/drawable/share_overlay_dim_background.xml',
    ).readAsStringSync();
    final String activitySource = File(
      'android/app/src/main/kotlin/com/marky/app/marky/ShareOverlayActivity.kt',
    ).readAsStringSync();
    final String flutterHostSource = File(
      'android/app/src/main/kotlin/com/marky/app/marky/ShareOverlayFlutterHost.kt',
    ).readAsStringSync();
    final String transparentSplashIcon = File(
      'android/app/src/main/res/drawable/share_overlay_transparent_splash_icon.xml',
    ).readAsStringSync();

    for (final String styles in <String>[
      lightStyles,
      darkStyles,
      api31Styles
    ]) {
      expect(styles, contains('name="ShareOverlayTheme"'));
      expect(styles, contains('android:windowIsTranslucent">true'));
      expect(
        styles,
        contains(
            'android:windowBackground">@drawable/share_overlay_dim_background'),
      );
      expect(styles, contains('android:backgroundDimEnabled">false'));
    }
    expect(dimBackground, contains('#B0000000'));
    expect(activitySource, contains('showStartupOverlay()'));
    expect(flutterHostSource, contains('FlutterUiDisplayListener'));
    expect(activitySource, contains('hideStartupOverlay()'));
    expect(activitySource, contains('ViewGroup'));
    expect(
      api31Styles,
      contains('android:windowSplashScreenBackground">#00000000'),
    );
    expect(transparentSplashIcon, contains('#00000000'));
  });
}
