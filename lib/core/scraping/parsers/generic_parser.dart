import 'dart:async';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/models/parsed_metadata.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';

/// Catch-all metadata extractor that fetches a page via HTTP and parses
/// OpenGraph and standard HTML tags into [ParsedMetadata].
///
/// This parser is **not** registered in [SourceParserRegistry] by host;
/// callers should use it as an explicit fallback when [resolve] returns
/// `null`.
class GenericParser extends SourceParser {
  GenericParser({required this.dio});

  /// Shared singleton instance using a default [Dio] from [DioClient].
  //
  // Lazy-initialised to avoid eagerly creating a Dio instance before the
  // app has initialised Flutter bindings.
  static GenericParser? _instance;
  static GenericParser get instance {
    _instance ??= GenericParser(dio: DioClient.create());
    return _instance!;
  }

  final Dio dio;

  /// Request-level timeout (send + receive).
  static const Duration _requestTimeout = Duration(seconds: 5);

  /// Overall timeout wrapping the entire fetch + parse operation.
  static const Duration _overallTimeout = Duration(seconds: 10);

  /// No hosts are claimed — this parser is used as an explicit fallback.
  @override
  Set<String> get hosts => const <String>{};

  @override
  Future<ParsedMetadata?> parse(String url) async {
    if (url.isEmpty) return null;

    final Uri? uri = Uri.tryParse(url.trim());
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    final String requestUrl = uri.toString();

    try {
      final Response<String> response = await dio
          .get<String>(
            requestUrl,
            options: Options(
              responseType: ResponseType.plain,
              validateStatus: (_) => true,
              sendTimeout: _requestTimeout,
              receiveTimeout: _requestTimeout,
            ),
          )
          .timeout(_overallTimeout);

      // Non-2xx responses don't carry useful HTML for metadata extraction.
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        return null;
      }

      final String? htmlText = response.data;
      if (htmlText == null || htmlText.isEmpty) return null;

      final Document document;
      try {
        document = html_parser.parse(htmlText);
      } on Exception {
        return null;
      }

      return _extractMetadata(document, uri);
    } on DioException {
      return null;
    } on TimeoutException {
      return null;
    } on Exception {
      return null;
    }
  }

  /// Extracts metadata from the parsed [Document].
  ParsedMetadata? _extractMetadata(Document document, Uri baseUri) {
    final String? title = _og(document, 'og:title') ??
        _query(document, 'title')?.text.trim();

    final String? description = _og(document, 'og:description') ??
        _meta(document, 'description');

    final String? thumbnailUrl = _resolveUrl(
      baseUri,
      _og(document, 'og:image'),
    );

    final String? heroImageUrl = _resolveUrl(
      baseUri,
      _og(document, 'og:image:secure_url') ?? _og(document, 'og:image'),
    );

    final String? faviconUrl = _resolveUrl(
      baseUri,
      _linkHref(document, 'icon') ?? _linkHref(document, 'shortcut icon'),
    );

    final String? siteName = _og(document, 'og:site_name');
    final String? author = _og(document, 'article:author');
    final String? publisher = _og(document, 'og:site_name');
    final String? contentType = _og(document, 'og:type');
    final String? languageCode = _og(document, 'og:locale');
    final DateTime? publishDate = _parseDateTime(
      _og(document, 'article:published_time'),
    );

    // If we have absolutely nothing, treat it as a failure.
    if (title == null &&
        description == null &&
        thumbnailUrl == null &&
        faviconUrl == null) {
      return null;
    }

    return ParsedMetadata(
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      heroImageUrl: heroImageUrl,
      faviconUrl: faviconUrl,
      siteName: siteName,
      author: author,
      publisher: publisher,
      contentType: contentType,
      languageCode: languageCode,
      publishDate: publishDate,
    );
  }

  /// Reads an OpenGraph meta property.
  String? _og(Document document, String property) {
    final Element? el = document.querySelector(
      'meta[property="$property"]',
    );
    return el?.attributes['content']?.trim();
  }

  /// Reads a standard `<meta name="..." content="...">` value.
  String? _meta(Document document, String name) {
    final Element? el = document.querySelector(
      'meta[name="$name"]',
    );
    return el?.attributes['content']?.trim();
  }

  /// Reads an `<link rel="..." href="...">` value.
  String? _linkHref(Document document, String rel) {
    final Element? el = document.querySelector(
      'link[rel="$rel"]',
    );
    return el?.attributes['href']?.trim();
  }

  /// Queries a single element by CSS selector.
  Element? _query(Document document, String selector) {
    return document.querySelector(selector);
  }

  /// Resolves a possibly-relative URL against the request base URI.
  String? _resolveUrl(Uri baseUri, String? url) {
    if (url == null || url.isEmpty) return null;
    final String trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    final Uri resolved = baseUri.resolve(trimmed);

    // Protocol-relative URLs (//host.com/path) inherit the base scheme.
    if (!resolved.hasScheme && resolved.hasAuthority) {
      return '${baseUri.scheme}:$resolved';
    }

    return resolved.toString();
  }

  /// Parses an ISO-8601-ish datetime string.
  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }
}
