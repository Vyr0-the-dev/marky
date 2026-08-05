import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/models/parsed_metadata.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';

/// Extracts metadata from Medium links by parsing OpenGraph tags and
/// JSON-LD structured data.
///
/// Supported hosts:
/// - medium.com / www.medium.com
/// - Any `*.medium.com` subdomain (publication domains)
///
/// The parser fetches the HTML page, reads OG tags for title,
/// description, image, site name, and type, then attempts to extract
/// the author name from JSON-LD `@type: Person` or
/// `@type: Organization` objects.
///
/// Returns `null` on all failure paths — network errors, invalid HTML,
/// missing fields, or non-2xx responses. Never throws.
class MediumParser extends SourceParser {
  MediumParser({required this.dio});

  /// Lazy singleton using a default [Dio] from [DioClient].
  static MediumParser? _instance;
  static MediumParser get instance {
    _instance ??= MediumParser(dio: DioClient.create());
    return _instance!;
  }

  final Dio dio;

  /// Request-level timeout (send + receive).
  static const Duration _requestTimeout = Duration(seconds: 5);

  /// Overall timeout wrapping the entire fetch + parse operation.
  static const Duration _overallTimeout = Duration(seconds: 10);

  @override
  Set<String> get hosts => const <String>{
        'medium.com',
        'www.medium.com',
        '*.medium.com',
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

    // Accept medium.com / www.medium.com and any *.medium.com subdomain.
    final String bareHost = _stripWww(normalizedHost);
    if (!hosts.any((h) => _stripWww(h) == bareHost) &&
        !bareHost.endsWith('.medium.com')) {
      return null;
    }

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
    final String? title = _og(document, 'og:title');

    final String? description = _og(document, 'og:description');

    final String? image = _og(document, 'og:image');

    final String? siteName = _og(document, 'og:site_name');

    final String? contentType = _og(document, 'og:type');

    final String? languageCode = _og(document, 'og:locale');

    final DateTime? publishDate = _parseDateTime(
      _og(document, 'article:published_time'),
    );

    final String? author = _extractJsonLdAuthor(document) ??
        _og(document, 'article:author');

    final String? resolvedImage = _resolveUrl(baseUri, image);

    // Medium articles without a title are not useful.
    if (title == null || title.isEmpty) {
      return null;
    }

    return ParsedMetadata(
      title: title,
      description: description,
      thumbnailUrl: resolvedImage,
      heroImageUrl: resolvedImage,
      siteName: siteName ?? 'Medium',
      author: author,
      publisher: siteName ?? 'Medium',
      contentType: contentType ?? 'article',
      languageCode: languageCode,
      publishDate: publishDate,
    );
  }

  /// Reads an OpenGraph meta property.
  String? _og(Document document, String property) {
    final Element? el = document.querySelector('meta[property="$property"]');
    return el?.attributes['content']?.trim();
  }

  /// Attempts to extract the author name from JSON-LD script tags.
  String? _extractJsonLdAuthor(Document document) {
    final List<Element> scripts = document.querySelectorAll(
      'script[type="application/ld+json"]',
    );

    for (final Element script in scripts) {
      final String jsonText = script.text.trim();
      if (jsonText.isEmpty) continue;

      try {
        final dynamic json = jsonDecode(jsonText);

        // Single object.
        if (json is Map<String, dynamic>) {
          final String? author = _readAuthorFromJsonLd(json);
          if (author != null && author.isNotEmpty) return author;
        }

        // Array of objects (some pages embed multiple JSON-LD blocks
        // in a single script tag as an array).
        if (json is List<dynamic>) {
          for (final dynamic item in json) {
            if (item is Map<String, dynamic>) {
              final String? author = _readAuthorFromJsonLd(item);
              if (author != null && author.isNotEmpty) return author;
            }
          }
        }
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }

    return null;
  }

  /// Reads the author name from a single JSON-LD object.
  static String? _readAuthorFromJsonLd(Map<String, dynamic> json) {
    // Direct Person / Organization.
    final String? type = _readString(json, '@type');
    if (type == 'Person' || type == 'Organization') {
      final String? name = _readString(json, 'name');
      if (name != null && name.isNotEmpty) return name;
    }

    // Author field pointing to an object.
    final dynamic author = json['author'];
    if (author is Map<String, dynamic>) {
      final String? authorName = _readString(author, 'name');
      if (authorName != null && authorName.isNotEmpty) return authorName;
    }
    if (author is String && author.isNotEmpty) {
      return author;
    }

    // Creator field.
    final dynamic creator = json['creator'];
    if (creator is Map<String, dynamic>) {
      final String? creatorName = _readString(creator, 'name');
      if (creatorName != null && creatorName.isNotEmpty) return creatorName;
    }
    if (creator is String && creator.isNotEmpty) {
      return creator;
    }

    return null;
  }

  /// Reads a string value from [json] by [key].
  static String? _readString(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
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

  /// Parses an ISO-8601-ish datetime string.
  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value.trim());
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
