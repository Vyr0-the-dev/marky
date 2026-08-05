import 'package:dio/dio.dart';

/// Factory that returns a pre-configured [Dio] instance for redirect
/// resolution and lightweight HTTP operations.
///
/// The client is configured with:
/// - [connectTimeout] and [receiveTimeout] of 10 seconds to prevent
///   hanging on slow or unresponsive hosts.
/// - [followRedirects] set to `false` so callers can manually inspect
///   `Location` headers and control redirect chains (hop counting,
///   cycle detection, etc.).
///
/// Use [create] to obtain a fresh instance. The factory holds no
/// mutable state and is safe to call from any isolate.
class DioClient {
  DioClient._();

  static const Duration _timeout = Duration(seconds: 10);

  /// Returns a new [Dio] instance with Marky's default network
  /// configuration.
  static Dio create() {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        followRedirects: false,
      ),
    );
    return dio;
  }
}
