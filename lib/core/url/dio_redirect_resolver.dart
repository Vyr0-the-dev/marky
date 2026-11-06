import 'package:dio/dio.dart';

import 'package:marky/core/url/redirect_resolver.dart';

/// Dio-backed [RedirectResolver].
///
/// Uses a HEAD request with `followRedirects: false` and manually
/// follows the `Location` header so we can inspect every hop.
///
/// Falls back to the original URL on any error — the capture
/// pipeline is offline-first, so a failed resolve must never
/// block the save.
class DioRedirectResolver implements RedirectResolver {
  DioRedirectResolver({Dio? dio, this.maxRedirects = 10})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
              followRedirects: false,
              validateStatus: (int? status) => status != null && status < 400,
            ));

  final Dio _dio;
  final int maxRedirects;

  @override
  Future<String> resolve(String url) async {
    String current = url;

    try {
      for (int i = 0; i < maxRedirects; i++) {
        final Response<void> response = await _dio.head<void>(
          current,
          options: Options(
            followRedirects: false,
            validateStatus: (int? status) =>
                status != null && status >= 200 && status < 400,
          ),
        );

        final int? statusCode = response.statusCode;
        if (statusCode == null) break;

        // Not a redirect → we've reached the final destination.
        if (statusCode < 300 || statusCode >= 400) break;

        final String? location = response.headers.value('location');
        if (location == null || location.isEmpty) break;

        // Resolve relative redirects.
        final Uri base = Uri.parse(current);
        final Uri resolved = base.resolve(location);
        current = resolved.toString();
      }
    } catch (_) {
      // Network failure, timeout, DNS error, etc.
      // Return the best URL we got so far.
    }

    return current;
  }
}

/// A fake [RedirectResolver] that returns the URL as-is.
///
/// Used in tests and offline mode to skip network calls.
class NoOpRedirectResolver implements RedirectResolver {
  const NoOpRedirectResolver();

  @override
  Future<String> resolve(String url) async => url;
}
