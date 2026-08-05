import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/models/parsed_metadata.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';

/// Extracts metadata from YouTube links via the YouTube oEmbed API.
///
/// Supported hosts:
/// - youtube.com / www.youtube.com
/// - youtu.be
/// - m.youtube.com
/// - music.youtube.com
///
/// The parser calls `https://www.youtube.com/oembed?url=<url>&format=json`
/// and maps the JSON response into a [ParsedMetadata] instance.
///
/// Returns `null` on all failure paths — network errors, invalid JSON,
/// missing fields, or non-2xx responses. Never throws.
class YouTubeParser extends SourceParser {
  YouTubeParser({required this.dio});

  /// Lazy singleton using a default [Dio] from [DioClient].
  static YouTubeParser? _instance;
  static YouTubeParser get instance {
    _instance ??= YouTubeParser(dio: DioClient.create());
    return _instance!;
  }

  final Dio dio;

  /// Request-level timeout (send + receive).
  static const Duration _requestTimeout = Duration(seconds: 5);

  /// Overall timeout wrapping the entire fetch + parse operation.
  static const Duration _overallTimeout = Duration(seconds: 10);

  @override
  Set<String> get hosts => const <String>{
        'youtube.com',
        'youtu.be',
        'm.youtube.com',
        'music.youtube.com',
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

    // Ensure the URL is actually a YouTube link we claim to handle.
    final String bareHost = _stripWww(normalizedHost);
    if (!hosts.any((h) => _stripWwww(h) == bareHost)) return null;

    final String oEmbedUrl =
        'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

    try {
      final Response<String> response = await dio
          .get<String>(
            oEmbedUrl,
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

      final String? jsonText = response.data;
      if (jsonText == null || jsonText.isEmpty) return null;

      final Map<String, dynamic> json;
      try {
        json = jsonDecode(jsonText) as Map<String, dynamic>;
      } on FormatException {
        return null;
      } on TypeError {
        return null;
      }

      final String? title = _readString(json, 'title');
      final String? authorName = _readString(json, 'author_name');
      final String? thumbnailUrl = _readString(json, 'thumbnail_url');

      // oEmbed must at least return a title for the metadata to be useful.
      if (title == null || title.isEmpty) {
        return null;
      }

      return ParsedMetadata(
        title: title,
        thumbnailUrl: thumbnailUrl,
        heroImageUrl: thumbnailUrl,
        siteName: 'YouTube',
        author: authorName,
        publisher: 'YouTube',
        contentType: 'video',
      );
    } on DioException {
      return null;
    } on TimeoutException {
      return null;
    } on Exception {
      return null;
    }
  }

  /// Reads a string value from [json] by [key], returning `null` if the
  /// value is missing or not a string.
  static String? _readString(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  /// Normalizes a host to lower-case with `www.` stripped.
  static String _normalizeHost(String host) {
    return _stripWww(host.toLowerCase().trim());
  }

  /// Strips the leading `www.` prefix from a host.
  static String _stripWwww(String host) {
    if (host.startsWith('www.')) {
      return host.substring(4);
    }
    return host;
  }

  static String _stripWww(String host) => _stripWwww(host);
}
