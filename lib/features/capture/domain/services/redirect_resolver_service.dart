import 'dart:async';

import 'package:dio/dio.dart';
import 'package:marky/core/network/dio_client.dart';

/// Pure Dart service that resolves shortened URLs by manually following
/// HTTP redirect chains.
///
/// Zero Flutter imports — safe to use in isolates or pure Dart contexts.
///
/// The service sends HEAD requests (falling back to GET when HEAD is not
/// supported) with [followRedirects] disabled, inspects the `Location`
/// header on 3xx responses, and resolves relative URLs against the
/// request URI.
///
/// Safety limits:
/// - Max redirect hops (default 5)
/// - Per-request timeout (default 10s)
/// - Overall resolution timeout (default 30s)
/// - Cycle detection via a visited-URL set
class RedirectResolverService {
  RedirectResolverService({
    required Dio dio,
    int maxHops = 5,
    Duration requestTimeout = const Duration(seconds: 10),
    Duration overallTimeout = const Duration(seconds: 30),
  })  : _dio = dio,
        _maxHops = maxHops,
        _requestTimeout = requestTimeout,
        _overallTimeout = overallTimeout;

  /// Shared instance using the default [DioClient] configuration.
  static final RedirectResolverService instance = RedirectResolverService(
    dio: DioClient.create(),
  );

  final Dio _dio;
  final int _maxHops;
  final Duration _requestTimeout;
  final Duration _overallTimeout;

  static final Set<int> _redirectCodes = <int>{301, 302, 307, 308};
  static final Set<int> _headFallbackCodes = <int>{405, 501, 403};

  /// Resolves [url] to its final destination after following redirects.
  ///
  /// Returns `null` when:
  /// - [url] is empty or null.
  /// - A redirect loop is detected.
  /// - Max hops are exceeded.
  /// - Any request times out.
  /// - Any network or parsing error occurs.
  /// - The response is malformed (missing `Location` on 3xx).
  Future<String?> resolve(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    final String initial = url.trim();

    return _resolveWithTimeout(initial);
  }

  Future<String?> _resolveWithTimeout(String initial) async {
    try {
      return await _resolveChain(initial).timeout(_overallTimeout);
    } on TimeoutException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveChain(String initialUrl) async {
    String currentUrl = initialUrl;
    final Set<String> visited = <String>{};

    for (int hop = 0; hop < _maxHops; hop++) {
      if (visited.contains(currentUrl)) {
        return null; // Loop detected.
      }
      visited.add(currentUrl);

      final Uri? uri = Uri.tryParse(currentUrl);
      if (uri == null) {
        return null;
      }

      final Response<dynamic>? response =
          await _sendRequest(uri, useHead: true);

      if (response == null) {
        return null;
      }

      final int statusCode = response.statusCode ?? 0;

      if (_redirectCodes.contains(statusCode)) {
        final String? location = _extractLocation(response, uri);
        if (location == null) {
          return null;
        }
        currentUrl = location;
        continue;
      }

      if (_headFallbackCodes.contains(statusCode)) {
        // Server rejected HEAD; try GET on the same URL.
        final Response<dynamic>? getResponse =
            await _sendRequest(uri, useHead: false);
        if (getResponse == null) {
          return null;
        }

        final int getStatusCode = getResponse.statusCode ?? 0;
        if (_redirectCodes.contains(getStatusCode)) {
          final String? location = _extractLocation(getResponse, uri);
          if (location == null) {
            return null;
          }
          currentUrl = location;
          continue;
        }

        // GET returned a final (non-redirect) response.
        return currentUrl;
      }

      // Any other status code is treated as the final destination.
      return currentUrl;
    }

    // Max hops exceeded.
    return null;
  }

  Future<Response<dynamic>?> _sendRequest(Uri uri,
      {required bool useHead}) async {
    try {
      final Options options = Options(
        followRedirects: false,
        receiveDataWhenStatusError: true,
        validateStatus: (_) => true,
      );

      final Future<Response<dynamic>> request;
      if (useHead) {
        request = _dio.headUri(
          uri,
          options: options,
        );
      } else {
        request = _dio.getUri(
          uri,
          options: options,
        );
      }

      final Response<dynamic> response = await request.timeout(
        _requestTimeout,
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      return response;
    } on TimeoutException catch (_) {
      return null;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractLocation(Response<dynamic> response, Uri baseUri) {
    final dynamic rawLocation = response.headers.value('location');
    if (rawLocation == null) {
      return null;
    }

    final String location = rawLocation.toString().trim();
    if (location.isEmpty) {
      return null;
    }

    try {
      final Uri resolved = baseUri.resolve(location);
      return resolved.toString();
    } catch (_) {
      return null;
    }
  }
}
