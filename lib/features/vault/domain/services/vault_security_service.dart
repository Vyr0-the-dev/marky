import 'dart:async';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';

/// Abstract contract for local authentication operations.
///
/// Abstracts the concrete [LocalAuthentication] class so that
/// [VaultSecurityService] remains fully testable without platform
/// channels.
abstract class LocalAuthAdapter {
  /// Authenticates the user with biometrics or device credentials.
  Future<bool> authenticate({
    required String localizedReason,
    AuthenticationOptions options = const AuthenticationOptions(),
  });

  /// Returns true if the device supports biometric or credential auth.
  Future<bool> isDeviceSupported();

  /// Returns the list of enrolled biometric types on this device.
  Future<List<BiometricType>> getAvailableBiometrics();

  /// Cancels any in-progress authentication.
  Future<bool> stopAuthentication();
}

/// Production adapter that delegates to the [local_auth] plugin.
class LocalAuthAdapterImpl implements LocalAuthAdapter {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Future<bool> authenticate({
    required String localizedReason,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) {
    return _localAuth.authenticate(
      localizedReason: localizedReason,
      options: options,
    );
  }

  @override
  Future<bool> isDeviceSupported() => _localAuth.isDeviceSupported();

  @override
  Future<List<BiometricType>> getAvailableBiometrics() =>
      _localAuth.getAvailableBiometrics();

  @override
  Future<bool> stopAuthentication() => _localAuth.stopAuthentication();
}

/// Service that wraps local biometric authentication with graceful
/// degradation and structured logging.
///
/// When biometrics are unavailable, unsupported, or raise a platform
/// exception, every public method returns a safe default (`false` or
/// empty list) instead of propagating the error. All failures are
/// logged at `warning` level so that observability is preserved.
class VaultSecurityService {
  VaultSecurityService({
    required LocalAuthAdapter localAuth,
  }) : _localAuth = localAuth;

  final LocalAuthAdapter _localAuth;
  static final Logger _logger = Logger();

  static VaultSecurityService? _instance;

  /// The globally configured instance.
  ///
  /// Throws [StateError] if accessed before [initialize].
  static VaultSecurityService get instance {
    if (_instance == null) {
      throw StateError(
        'VaultSecurityService has not been initialized. '
        'Call VaultSecurityService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Creates and registers the global singleton.
  static void initialize({LocalAuthAdapter? localAuth}) {
    _instance = VaultSecurityService(
      localAuth: localAuth ?? LocalAuthAdapterImpl(),
    );
  }

  /// Resets the global singleton. Useful in tests.
  static void reset() {
    _instance = null;
  }

  // ─── Public API ──────────────────────────────────────────────────────

  /// Authenticates the user with biometrics.
  ///
  /// Returns `true` if the user successfully authenticated, `false` for
  /// any failure (including missing hardware, no enrolled biometrics,
  /// user cancellation, or platform exceptions).
  ///
  /// [localizedReason] is shown to the user in the system auth dialog.
  Future<bool> authenticate({
    String localizedReason = 'Authenticate to access your vault',
  }) async {
    _logger.i('Vault auth attempt');

    try {
      final bool result = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (result) {
        _logger.i('Vault auth succeeded');
      } else {
        _logger.w('Vault auth failed (user rejection or system)');
      }

      return result;
    } on PlatformException catch (e, stackTrace) {
      _logger.w(
        'Vault auth platform exception: ${e.code} — ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      _logger.w(
        'Vault auth unexpected error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Returns true if the device supports biometric authentication.
  ///
  /// Returns `false` on any platform exception.
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e, stackTrace) {
      _logger.w(
        'isDeviceSupported platform exception: ${e.code} — ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      _logger.w(
        'isDeviceSupported unexpected error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Returns the list of biometric types available on this device.
  ///
  /// Returns an empty list on any platform exception.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e, stackTrace) {
      _logger.w(
        'getAvailableBiometrics platform exception: ${e.code} — ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      return <BiometricType>[];
    } catch (e, stackTrace) {
      _logger.w(
        'getAvailableBiometrics unexpected error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return <BiometricType>[];
    }
  }

  /// Cancels any in-progress biometric authentication.
  ///
  /// Returns `false` on any platform exception.
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } on PlatformException catch (e, stackTrace) {
      _logger.w(
        'stopAuthentication platform exception: ${e.code} — ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      _logger.w(
        'stopAuthentication unexpected error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
