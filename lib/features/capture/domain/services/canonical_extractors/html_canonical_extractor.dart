import 'dart:async';

import 'package:dio/dio.dart';
import 'package:marky/core/network/dio_client.dart';

import 'package:marky/features/capture/domain/services/canonical_extractors/canonical_extraction_result.dart';

/// Pure Dart extractor that fetches a web page via [Dio] and extracts
/// canonical URLs from `<link rel="canonical">` and `<meta property="og:url">`
/// tags.
///
/// Host-validates extracted URLs to prevent cross-domain canonical hijacking.
/// Returns `null` on any failure, timeout, or validation rejection.
class HtmlCanonicalExtractor {
  HtmlCanonicalExtractor({
    required this.dio,
    this.requestTimeout = const Duration(seconds: 5),
    this.overallTimeout = const Duration(seconds: 10),
  });

  /// Shared singleton instance using a default [Dio] from [DioClient].
  //
  // Lazy-initialised to avoid eagerly creating a Dio instance before the
  // app has initialised Flutter bindings.
  static HtmlCanonicalExtractor? _instance;
  static HtmlCanonicalExtractor get instance {
    _instance ??= HtmlCanonicalExtractor(dio: DioClient.create());
    return _instance!;
  }

  final Dio dio;
  final Duration requestTimeout;
  final Duration overallTimeout;

  /// Attempts to fetch [url] and extract a canonical URL.
  ///
  /// Returns [CanonicalExtractionResult] when a canonical tag is found and
  /// passes host validation, otherwise `null`.
  Future<CanonicalExtractionResult?> extract(String url) async {
    if (url.isEmpty) return null;

    final Uri? uri = Uri.tryParse(url.trim());
    if (uri == null) return null;

    final String requestUrl = uri.toString();

    try {
      final Response<String> response = await dio
          .get<String>(
            requestUrl,
            options: Options(
              responseType: ResponseType.plain,
              validateStatus: (_) => true,
              sendTimeout: requestTimeout,
              receiveTimeout: requestTimeout,
            ),
          )
          .timeout(overallTimeout);

      // Non-2xx responses don't carry useful HTML for canonical extraction.
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        return null;
      }

      final String? html = response.data;
      if (html == null || html.isEmpty) return null;

      final String? canonical = _parseCanonical(html) ?? _parseOgUrl(html);
      if (canonical == null || canonical.isEmpty) return null;

      final Uri? canonicalUri = Uri.tryParse(canonical.trim());
      if (canonicalUri == null || !canonicalUri.hasAuthority) return null;

      // Resolve protocol-relative URLs (//host.com/path) by inheriting
      // the scheme from the request URL.
      final String resolvedCanonical;
      if (!canonicalUri.hasScheme && canonicalUri.hasAuthority) {
        resolvedCanonical = '${uri.scheme}:$canonicalUri';
      } else {
        resolvedCanonical = canonicalUri.toString();
      }

      final Uri? resolvedUri = Uri.tryParse(resolvedCanonical);
      if (resolvedUri == null || !resolvedUri.hasAuthority) return null;

      // Host validation: reject cross-domain canonicals to prevent hijacking.
      if (resolvedUri.host.toLowerCase() != uri.host.toLowerCase()) {
        return null;
      }

      return CanonicalExtractionResult(
        canonicalUrl: resolvedUri.toString(),
        externalContentId: '',
      );
    } on DioException {
      return null;
    } on TimeoutException {
      return null;
    } on FormatException {
      return null;
    } on Exception {
      return null;
    }
  }

  /// Parses `<link rel="canonical" href="...">` from raw HTML.
  ///
  /// Permissive regex handles extra spaces, single/double quotes, and
  /// additional attributes on the tag. Tries both attribute orderings.
  /// Requires the tag to be properly closed with `>`.
  String? _parseCanonical(String html) {
    // rel before href
    final RegExp relFirst = RegExp(
      '<link[^>]*\\srel\\s*=\\s*["\']?canonical["\']?[^>]*\\shref\\s*=\\s*["\']([^"\']+)["\'][^>]*>',
      caseSensitive: false,
    );
    final RegExpMatch? match1 = relFirst.firstMatch(html);
    if (match1 != null) return match1.group(1);

    // href before rel
    final RegExp hrefFirst = RegExp(
      '<link[^>]*\\shref\\s*=\\s*["\']([^"\']+)["\'][^>]*\\srel\\s*=\\s*["\']?canonical["\']?[^>]*>',
      caseSensitive: false,
    );
    final RegExpMatch? match2 = hrefFirst.firstMatch(html);
    if (match2 != null) return match2.group(1);

    return null;
  }

  /// Parses `<meta property="og:url" content="...">` from raw HTML.
  ///
  /// Permissive regex handles extra spaces, single/double quotes, and
  /// additional attributes on the tag. Tries both attribute orderings.
  /// Requires the tag to be properly closed with `>`.
  String? _parseOgUrl(String html) {
    // property before content
    final RegExp propFirst = RegExp(
      '<meta[^>]*\\sproperty\\s*=\\s*["\']?og:url["\']?[^>]*\\scontent\\s*=\\s*["\']([^"\']+)["\'][^>]*>',
      caseSensitive: false,
    );
    final RegExpMatch? match1 = propFirst.firstMatch(html);
    if (match1 != null) return match1.group(1);

    // content before property
    final RegExp contentFirst = RegExp(
      '<meta[^>]*\\scontent\\s*=\\s*["\']([^"\']+)["\'][^>]*\\sproperty\\s*=\\s*["\']?og:url["\']?[^>]*>',
      caseSensitive: false,
    );
    final RegExpMatch? match2 = contentFirst.firstMatch(html);
    if (match2 != null) return match2.group(1);

    return null;
  }
}
