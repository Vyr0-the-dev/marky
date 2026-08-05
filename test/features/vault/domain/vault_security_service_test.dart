import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:marky/features/vault/domain/services/vault_security_service.dart';

/// Fake [LocalAuthAdapter] for unit testing [VaultSecurityService].
class _FakeLocalAuthAdapter implements LocalAuthAdapter {
  bool authenticateResult = true;
  bool deviceSupportedResult = true;
  List<BiometricType> availableBiometrics = <BiometricType>[];
  bool stopAuthenticationResult = true;

  dynamic authenticateError;
  dynamic deviceSupportedError;
  dynamic getAvailableBiometricsError;
  dynamic stopAuthenticationError;

  String? lastLocalizedReason;
  AuthenticationOptions? lastOptions;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    lastLocalizedReason = localizedReason;
    lastOptions = options;

    if (authenticateError != null) {
      throw authenticateError!;
    }
    return authenticateResult;
  }

  @override
  Future<bool> isDeviceSupported() async {
    if (deviceSupportedError != null) {
      throw deviceSupportedError!;
    }
    return deviceSupportedResult;
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (getAvailableBiometricsError != null) {
      throw getAvailableBiometricsError!;
    }
    return availableBiometrics;
  }

  @override
  Future<bool> stopAuthentication() async {
    if (stopAuthenticationError != null) {
      throw stopAuthenticationError!;
    }
    return stopAuthenticationResult;
  }
}

void main() {
  group('VaultSecurityService', () {
    late _FakeLocalAuthAdapter fakeAdapter;
    late VaultSecurityService service;

    setUp(() {
      fakeAdapter = _FakeLocalAuthAdapter();
      service = VaultSecurityService(localAuth: fakeAdapter);
    });

    tearDown(VaultSecurityService.reset);

    // ─── authenticate ─────────────────────────────────────────────────

    test('authenticate returns true when biometrics succeed', () async {
      fakeAdapter.authenticateResult = true;

      final bool result = await service.authenticate();

      expect(result, isTrue);
      expect(fakeAdapter.lastLocalizedReason, isNotNull);
    });

    test('authenticate returns false when biometrics fail', () async {
      fakeAdapter.authenticateResult = false;

      final bool result = await service.authenticate();

      expect(result, isFalse);
    });

    test('authenticate uses custom localizedReason', () async {
      const String customReason = 'Custom auth message';

      await service.authenticate(localizedReason: customReason);

      expect(fakeAdapter.lastLocalizedReason, customReason);
    });

    test('authenticate passes biometricOnly and stickyAuth options', () async {
      await service.authenticate();

      expect(fakeAdapter.lastOptions, isNotNull);
      expect(fakeAdapter.lastOptions!.biometricOnly, isTrue);
      expect(fakeAdapter.lastOptions!.stickyAuth, isTrue);
    });

    test('authenticate returns false on PlatformException', () async {
      fakeAdapter.authenticateError = PlatformException(
        code: 'noBiometricHardware',
        message: 'Device has no biometric hardware',
      );

      final bool result = await service.authenticate();

      expect(result, isFalse);
    });

    test('authenticate returns false on generic exception', () async {
      fakeAdapter.authenticateError = Exception('Something went wrong');

      final bool result = await service.authenticate();

      expect(result, isFalse);
    });

    // ─── isDeviceSupported ─────────────────────────────────────────────

    test('isDeviceSupported returns true when supported', () async {
      fakeAdapter.deviceSupportedResult = true;

      final bool result = await service.isDeviceSupported();

      expect(result, isTrue);
    });

    test('isDeviceSupported returns false when not supported', () async {
      fakeAdapter.deviceSupportedResult = false;

      final bool result = await service.isDeviceSupported();

      expect(result, isFalse);
    });

    test('isDeviceSupported returns false on PlatformException', () async {
      fakeAdapter.deviceSupportedError = PlatformException(
        code: 'error',
        message: 'Platform error',
      );

      final bool result = await service.isDeviceSupported();

      expect(result, isFalse);
    });

    test('isDeviceSupported returns false on generic exception', () async {
      fakeAdapter.deviceSupportedError = Exception('Unexpected');

      final bool result = await service.isDeviceSupported();

      expect(result, isFalse);
    });

    // ─── getAvailableBiometrics ────────────────────────────────────────

    test('getAvailableBiometrics returns enrolled types', () async {
      fakeAdapter.availableBiometrics = <BiometricType>[
        BiometricType.fingerprint,
        BiometricType.face,
      ];

      final List<BiometricType> result =
          await service.getAvailableBiometrics();

      expect(result, hasLength(2));
      expect(result, contains(BiometricType.fingerprint));
      expect(result, contains(BiometricType.face));
    });

    test('getAvailableBiometrics returns empty list when none enrolled',
        () async {
      fakeAdapter.availableBiometrics = <BiometricType>[];

      final List<BiometricType> result =
          await service.getAvailableBiometrics();

      expect(result, isEmpty);
    });

    test('getAvailableBiometrics returns empty list on PlatformException',
        () async {
      fakeAdapter.getAvailableBiometricsError = PlatformException(
        code: 'error',
        message: 'Platform error',
      );

      final List<BiometricType> result =
          await service.getAvailableBiometrics();

      expect(result, isEmpty);
    });

    test('getAvailableBiometrics returns empty list on generic exception',
        () async {
      fakeAdapter.getAvailableBiometricsError = Exception('Unexpected');

      final List<BiometricType> result =
          await service.getAvailableBiometrics();

      expect(result, isEmpty);
    });

    // ─── stopAuthentication ────────────────────────────────────────────

    test('stopAuthentication returns true on success', () async {
      fakeAdapter.stopAuthenticationResult = true;

      final bool result = await service.stopAuthentication();

      expect(result, isTrue);
    });

    test('stopAuthentication returns false on failure', () async {
      fakeAdapter.stopAuthenticationResult = false;

      final bool result = await service.stopAuthentication();

      expect(result, isFalse);
    });

    test('stopAuthentication returns false on PlatformException', () async {
      fakeAdapter.stopAuthenticationError = PlatformException(
        code: 'error',
        message: 'Platform error',
      );

      final bool result = await service.stopAuthentication();

      expect(result, isFalse);
    });

    test('stopAuthentication returns false on generic exception', () async {
      fakeAdapter.stopAuthenticationError = Exception('Unexpected');

      final bool result = await service.stopAuthentication();

      expect(result, isFalse);
    });

    // ─── Singleton ─────────────────────────────────────────────────────

    test('initialize and instance accessors work', () {
      VaultSecurityService.initialize(localAuth: fakeAdapter);
      expect(VaultSecurityService.instance, isA<VaultSecurityService>());
    });

    test('singleton throws when accessed before initialize', () {
      VaultSecurityService.reset();
      expect(
        () => VaultSecurityService.instance,
        throwsA(isA<StateError>()),
      );
    });

    test('reset clears the singleton', () {
      VaultSecurityService.initialize(localAuth: fakeAdapter);
      expect(VaultSecurityService.instance, isA<VaultSecurityService>());

      VaultSecurityService.reset();
      expect(
        () => VaultSecurityService.instance,
        throwsA(isA<StateError>()),
      );
    });

    test('default initialize uses LocalAuthAdapterImpl', () {
      // Should not throw — creates the real adapter internally.
      VaultSecurityService.initialize();
      expect(VaultSecurityService.instance, isA<VaultSecurityService>());
    });
  });
}
