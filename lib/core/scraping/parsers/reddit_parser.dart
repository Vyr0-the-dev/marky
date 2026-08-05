import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/models/parsed_metadata.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';

/// Extracts metadata from Reddit links via the `.json` endpoint.
///
/// Supported hosts:
/// - reddit.com / www.reddit.com
/// - old.reddit.com
/// - np.reddit.com
/// - redd.it
///
/// The parser appends `.json` to the post URL and reads
/// `[0].data.children[0].data` for title, subreddit, author,
/// thumbnail, and selftext.
///
/// Returns `null` on all failure paths — network errors, invalid JSON,
/// missing fields, or non-2xx responses. Never throws.
class RedditParser extends SourceParser {
  RedditParser({required this.dio});

  /// Lazy singleton using a default [Dio] from [DioClient].
  static RedditParser? _instance;
  static RedditParser get instance {
    _instance ??= RedditParser(dio: DioClient.create());
    return _instance!;
  }

  final Dio dio;

  /// Request-level timeout (send + receive).
  static const Duration _requestTimeout = Duration(seconds: 5);

  /// Overall timeout wrapping the entire fetch + parse operation.
  static const Duration _overallTimeout = Duration(seconds: 10);

  @override
  Set<String> get hosts => const <String>{
        'reddit.com',
        'www.reddit.com',
        'old.reddit.com',
        'np.reddit.com',
        'redd.it',
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

    // Ensure the URL is actually a Reddit link we claim to handle.
    final String bareHost = _stripWww(normalizedHost);
    if (!hosts.any((h) => _stripWww(h) == bareHost)) return null;

    // Build the .json URL.
    final String jsonUrl = _buildJsonUrl(url);

    try {
      final Response<String> response = await dio
          .get<String>(
            jsonUrl,
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

      final List<dynamic> json;
      try {
        json = jsonDecode(jsonText) as List<dynamic>;
      } on FormatException {
        return null;
      } on TypeError {
        return null;
      }

      if (json.isEmpty) return null;

      final Map<String, dynamic>? listing = json[0] as Map<String, dynamic>?;
      if (listing == null) return null;

      final Map<String, dynamic>? data = listing['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      final List<dynamic>? children = data['children'] as List<dynamic>?;
      if (children == null || children.isEmpty) return null;

      final Map<String, dynamic>? child =
          children[0] as Map<String, dynamic>?;
      if (child == null) return null;

      final Map<String, dynamic>? postData =
          child['data'] as Map<String, dynamic>?;
      if (postData == null) return null;

      final String? title = _readString(postData, 'title');
      if (title == null || title.isEmpty) return null;

      final String? subreddit = _readString(postData, 'subreddit_name_prefixed') ??
          _readString(postData, 'subreddit');
      final String? author = _readString(postData, 'author');
      final String? thumbnail = _readString(postData, 'thumbnail');
      final String? selftext = _readString(postData, 'selftext');
      final String? postUrl = _readString(postData, 'url');

      // Reddit returns 'self' or empty string as thumbnail for text posts.
      final String? cleanThumbnail =
          (thumbnail == null || thumbnail == 'self' || thumbnail == 'default')
              ? null
              : thumbnail;

      // If the post links to an external image, use it as hero image.
      final String? heroImage = _isImageUrl(postUrl) ? postUrl : cleanThumbnail;

      return ParsedMetadata(
        title: title,
        description: selftext,
        thumbnailUrl: cleanThumbnail,
        heroImageUrl: heroImage,
        siteName: subreddit,
        author: author,
        publisher: 'Reddit',
        contentType: 'article',
      );
    } on DioException {
      return null;
    } on TimeoutException {
      return null;
    } on Exception {
      return null;
    }
  }

  /// Appends `.json` to the given [url].
  ///
  /// If the URL already ends with `.json`, it is returned as-is.
  /// For redd.it short links, the URL is returned as-is since they
  /// already redirect to the canonical post URL.
  static String _buildJsonUrl(String url) {
    if (url.endsWith('.json')) return url;
    // Append .json before any query or fragment.
    final int queryIndex = url.indexOf('?');
    final int fragmentIndex = url.indexOf('#');
    final int cutIndex = queryIndex != -1
        ? (fragmentIndex != -1 ? queryIndex : queryIndex)
        : fragmentIndex;

    if (cutIndex != -1) {
      return '${url.substring(0, cutIndex)}.json${url.substring(cutIndex)}';
    }
    return '$url.json';
  }

  /// Checks whether [url] looks like a direct image link.
  static bool _isImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final String lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
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
  static String _stripWww(String host) {
    if (host.startsWith('www.')) {
      return host.substring(4);
    }
    return host;
  }
}
