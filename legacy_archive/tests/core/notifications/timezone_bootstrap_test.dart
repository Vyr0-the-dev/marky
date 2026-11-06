import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/notifications/timezone_bootstrap.dart';
import 'package:timezone/timezone.dart' as tz;

/// Unit tests for [TimezoneBootstrap].
///
/// The platform channel used by `flutter_timezone` is intercepted via
/// the Flutter test harness's default binary messenger so we can assert
/// both success and failure paths without a real device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_timezone');

  Future<void> installStub(Object? Function(MethodCall) handler) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      return handler(call);
    });
  }

  setUp(() {
    TimezoneBootstrap.resetForTests();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('TimezoneBootstrap.initialize', () {
    test('binds tz.local to the IANA zone the platform returns', () async {
      await installStub((_) => 'Europe/Istanbul');

      await TimezoneBootstrap.initialize();

      expect(TimezoneBootstrap.resolvedZone, 'Europe/Istanbul');
      expect(TimezoneBootstrap.isLocalZoneResolved, isTrue);
      expect(tz.local.name, 'Europe/Istanbul');
    });

    test('falls back to UTC when the platform throws', () async {
      await installStub((_) {
        throw PlatformException(code: 'ERR', message: 'boom');
      });

      await TimezoneBootstrap.initialize();

      expect(TimezoneBootstrap.resolvedZone, 'UTC');
      expect(TimezoneBootstrap.isLocalZoneResolved, isFalse);
      expect(tz.local.name, 'UTC');
    });

    test('falls back to UTC when the returned name is not in the IANA db',
        () async {
      // `"EEST"` is exactly the kind of garbage DateTime.timeZoneName
      // used to feed tz.getLocation before this bootstrapper existed.
      await installStub((_) => 'EEST');

      await TimezoneBootstrap.initialize();

      expect(TimezoneBootstrap.resolvedZone, 'UTC');
      expect(TimezoneBootstrap.isLocalZoneResolved, isFalse);
      expect(tz.local.name, 'UTC');
    });

    test('is idempotent — second call is a no-op', () async {
      int calls = 0;
      await installStub((_) {
        calls++;
        return 'Europe/Istanbul';
      });

      await TimezoneBootstrap.initialize();
      await TimezoneBootstrap.initialize();
      await TimezoneBootstrap.initialize();

      expect(calls, 1, reason: 'platform channel must only be hit once');
    });

    test('a "1 hour from now" local DateTime is correctly bound to tz.local',
        () async {
      // This is the scenario that used to blow up for UTC+3 users:
      // without the bootstrapper, tz.local would be UTC, and the
      // TZDateTime for "local 13:00 Istanbul" would be interpreted as
      // "UTC 13:00", which is 3 hours in the future of the cached
      // `now` — but a previous catch-block had converted it *backwards*
      // into UTC, ending up in the past. Here we assert the right
      // mapping.
      await installStub((_) => 'Europe/Istanbul');
      await TimezoneBootstrap.initialize();

      final DateTime localOneHourFromNow =
          DateTime.now().add(const Duration(hours: 1));
      final tz.TZDateTime scheduled =
          tz.TZDateTime.from(localOneHourFromNow, tz.local);

      expect(scheduled.isAfter(tz.TZDateTime.now(tz.local)), isTrue,
          reason: 'Scheduled time must land in the future after bootstrap');
      expect(scheduled.location.name, 'Europe/Istanbul');
    });
  });
}
