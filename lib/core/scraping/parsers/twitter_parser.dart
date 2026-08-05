import 'dart:async';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/models/parsed_metadata.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';

/// Extracts metadata from X / Twitter links by parsing Twitter Card meta tags.
///
/// Supported hosts:
/// - twitter.com / www.twitter.com
/// - x.com / www.x.com
/// - mobile.twitter.com / mobile.x.com
/// - t.co (short links)
///
/// The parser fetches the HTML page and reads `twitter:*` meta tags,
/// falling back to `x:*` tags where Twitter has migrated to the new
/// branding. Title, description, image, creator (author), and site
/// (publisher) are extracted.
///
/// Returns `null` on all failure paths — network errors, invalid HTML,
/// missing fields, or non-2xx responses. Never throws.
class TwitterParser extends SourceParser {
  TwitterParser({required this.dio});

  /// Lazy singleton using a default [Dio] from [DioClient].
  static TwitterParser? _instance;
  static TwitterParser get instance {
    _instance ??= TwitterParser(dio: DioClient.create());
    return _instance!;
  }

  final Dio dio;

  /// Request-level timeout (send + receive).
  static const Duration _requestTimeout = Duration(seconds: 5);

  /// Overall timeout wrapping the entire fetch + parse operation.
  static const Duration _overallTimeout = Duration(seconds: 10);

  @override
  Set<String> get hosts => const <String>{
        'twitter.com',
        'www.twitter.com',
        'x.com',
        'www.x.com',
        'mobile.twitter.com',
        'mobile.x.com',
        't.co',
      };

  @override
  Future<ParsedMetadata?> parse(String url) async {
    if (url.isEmpty) return null;

    final Uri? uri = Uri.tryParse(url.trim());
    if (uri == null) return null;

    final String normalizedHost = _normalizeHost(uri.host);
    if (normalizedHost.isEmpty) return null;

    // Validate scheme.
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    // Ensure the URL is actually a Twitter/X link we claim to handle.
    final String bareHost = _stripWww(normalizedHost);
    if (!hosts.any((h) => _stripWww(h) == bareHost)) return null;

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
    final String? title = _twitterMeta(document, 'twitter:title') ??
        _twitterMeta(document, 'x:title') ??
        _og(document, 'og:title');

    final String? description = _twitterMeta(document, 'twitter:description') ??
        _twitterMeta(document, 'x:description') ??
        _og(document, 'og:description');

    final String? image = _twitterMeta(document, 'twitter:image') ??
        _twitterMeta(document, 'x:image') ??
        _twitterMeta(document, 'twitter:image:src') ??
        _twitterMeta(document, 'x:image:src') ??
        _og(document, 'og:image');

    final String? creator = _twitterMeta(document, 'twitter:creator') ??
        _twitterMeta(document, 'x:creator');

    final String? site = _twitterMeta(document, 'twitter:site') ??
        _twitterMeta(document, 'x:site');

    final String? resolvedImage = _resolveUrl(baseUri, image);

    // Twitter/X pages without a title are not useful.
    if (title == null || title.isEmpty) {
      return null;
    }

    return ParsedMetadata(
      title: title,
      description: description,
      thumbnailUrl: resolvedImage,
      heroImageUrl: resolvedImage,
      siteName: site ?? 'X',
      author: creator,
      publisher: site ?? 'X',
      contentType: 'article',
    );
  }

  /// Reads a Twitter Card meta property (`twitter:*` or `x:*`).
  String? _twitterMeta(Document document, String property) {
    final Element? el = document.querySelector('meta[name="$property"]');
    if (el != null) {
      final String? content = el.attributes['content']?.trim();
      if (content != null && content.isNotEmpty) return content;
    }
    // Some pages use property instead of name.
    final Element? elProp =
        document.querySelector('meta[property="$property"]');
    return elProp?.attributes['content']?.trim();
  }

  /// Reads an OpenGraph meta property.
  String? _og(Document document, String property) {
    final Element? el = document.querySelector('meta[property="$property"]');
    return el?.attributes['content']?.trim();
  }

  /// Resolves a possibly-relative URL against the request base URI.
  String? _resolveUrl(Uri baseUri, String? url) {
    if (url == null || url.isEmpty) return null;
    final String trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    final Uri resolved = baseUri.resolve(trimmed);

    if (!resolved.hasScheme && resolved.hasAuthority) {
      return '${baseUri.scheme}:$resolved';
    }

    return resolved.toString();
  }

  /// Normalizes a host to lower-case with `www.` stripped.
  static String _normalizeHost(String host) {
    return _stripWww(host.toLowerCase().trim());
  }

  /// Strips the leading `www.` prefix from a host.
  static String _stripWww(String host) {
    if (host.startsWith('www.')) {
      return host.substring(4);
    }
    return host;
  }
}
