import 'package:dio/dio.dart';

import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/source_parser.dart';

/// Reddit-specific metadata parser.
///
/// Uses the `.json` endpoint appended to the post URL (no API key
/// required) to extract post metadata. Falls back gracefully when
/// the endpoint is blocked or rate-limited.
class RedditParser implements SourceParser {
  RedditParser({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: <String, dynamic>{
                'User-Agent':
                    'Mozilla/5.0 (Android 13; Mobile) Marky/1.0 link-manager',
                'Accept': 'application/json,text/plain,*/*',
              },
            ));

  final Dio _dio;

  static const String _faviconUrl = 'https://www.reddit.com/favicon.ico';

  @override
  bool canHandle(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return false;
    final String host = uri.host.toLowerCase();
    return host == 'redd.it' ||
        host == 'reddit.com' ||
        host.endsWith('.reddit.com');
  }

  @override
  Future<MetadataResult> parse(
    String url, {
    String? html,
    CancelToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled ?? false) {
      return const MetadataResult(siteName: 'Reddit', faviconUrl: _faviconUrl);
    }
    final MetadataResult jsonResult =
        await _parseJsonEndpoint(url, cancelToken: cancelToken);
    if (!jsonResult.isEmpty) return jsonResult;
    if (cancelToken?.isCancelled ?? false) {
      return const MetadataResult(siteName: 'Reddit', faviconUrl: _faviconUrl);
    }
    final MetadataResult embedResult =
        await _parseOEmbed(url, cancelToken: cancelToken);
    if (!embedResult.isEmpty) return embedResult;
    return const MetadataResult(
      siteName: 'Reddit',
      faviconUrl: _faviconUrl,
    );
  }

  Future<MetadataResult> _parseJsonEndpoint(
    String url, {
    CancelToken? cancelToken,
  }) async {
    try {
      final Response<dynamic> response = await _dio.getUri<dynamic>(
        _jsonUriFor(url),
        cancelToken: cancelToken,
      );

      final dynamic data = response.data;
      final Map<String, dynamic>? postData = _firstPostData(data);
      if (postData == null) return const MetadataResult();

      final String? subredditName = _readString(postData, 'subreddit');
      final String? subredditPrefixed =
          _readString(postData, 'subreddit_name_prefixed');
      final String? selftext = _readString(postData, 'selftext');
      final String? outboundUrl = _readString(
            postData,
            'url_overridden_by_dest',
          ) ??
          _readString(postData, 'url');
      final String? thumbnail = _cleanThumbnail(
        _readString(postData, 'thumbnail'),
      );
      final String? heroImageUrl =
          _imageUrl(outboundUrl) ?? _previewImageUrl(postData) ?? thumbnail;
      final String? canonicalUrl = _canonicalUrl(postData);
      final String? title = _readString(postData, 'title');
      final String? author = _readString(postData, 'author');
      final DateTime? publishDate = _publishDate(postData);
      final String? description =
          selftext == null ? null : _truncate(selftext, 300);

      if (title == null &&
          description == null &&
          canonicalUrl == null &&
          author == null &&
          heroImageUrl == null &&
          publishDate == null) {
        return const MetadataResult();
      }

      return MetadataResult(
        title: title,
        description: description,
        canonicalUrl: canonicalUrl,
        author: author,
        siteName: subredditPrefixed ??
            (subredditName == null ? 'Reddit' : 'r/$subredditName'),
        publisher: 'Reddit',
        publishDate: publishDate,
        heroImageUrl: heroImageUrl,
        faviconUrl: _faviconUrl,
        snippet: description,
      );
    } catch (_) {
      return const MetadataResult();
    }
  }

  Future<MetadataResult> _parseOEmbed(String url, {CancelToken? cancelToken}) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        'https://www.reddit.com/oembed',
        queryParameters: <String, dynamic>{'url': url},
        cancelToken: cancelToken,
      );
      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) return const MetadataResult();
      final String? thumbnail = data['thumbnail_url'] as String?;
      final String? title = data['title'] as String?;
      if (title == null || title.trim().isEmpty) return const MetadataResult();
      return MetadataResult(
        title: title,
        author: data['author_name'] as String?,
        siteName: 'Reddit',
        publisher: 'Reddit',
        heroImageUrl: thumbnail != null && thumbnail.startsWith('http')
            ? thumbnail
            : null,
        faviconUrl: _faviconUrl,
      );
    } catch (_) {
      return const MetadataResult();
    }
  }

  static Uri _jsonUriFor(String url) {
    final Uri uri = Uri.parse(url);
    final String path = uri.path.endsWith('/') && uri.path.length > 1
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    final String jsonPath = path.endsWith('.json') ? path : '$path.json';
    final Map<String, String> queryParameters =
        Map<String, String>.from(uri.queryParameters);
    queryParameters['limit'] = '1';
    queryParameters['raw_json'] = '1';
    return uri.replace(
      path: jsonPath,
      queryParameters: queryParameters,
      fragment: '',
    );
  }

  static Map<String, dynamic>? _firstPostData(dynamic data) {
    final Map<String, dynamic>? listing = switch (data) {
      <dynamic>[final Map<String, dynamic> first, ...] => first,
      final Map<String, dynamic> map => map,
      _ => null,
    };
    final Map<String, dynamic>? listingData =
        listing?['data'] as Map<String, dynamic>?;
    final List<dynamic>? children = listingData?['children'] as List<dynamic>?;
    final Map<String, dynamic>? firstChild =
        children?.firstOrNull as Map<String, dynamic>?;
    return firstChild?['data'] as Map<String, dynamic>?;
  }

  static String? _readString(Map<String, dynamic> data, String key) {
    final dynamic value = data[key];
    if (value is! String) return null;
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  static String? _cleanThumbnail(String? value) {
    if (value == null || !value.startsWith('http')) return null;
    if (value.endsWith('/self') ||
        value.endsWith('/default') ||
        value.endsWith('/nsfw') ||
        value.endsWith('/spoiler')) {
      return null;
    }
    return _decodeRedditUrl(value);
  }

  static String? _imageUrl(String? value) {
    if (value == null || !value.startsWith('http')) return null;
    final String lower = value.toLowerCase();
    if (!lower.endsWith('.jpg') &&
        !lower.endsWith('.jpeg') &&
        !lower.endsWith('.png') &&
        !lower.endsWith('.gif') &&
        !lower.endsWith('.webp')) {
      return null;
    }
    return _decodeRedditUrl(value);
  }

  static String? _previewImageUrl(Map<String, dynamic> data) {
    final Map<String, dynamic>? preview =
        data['preview'] as Map<String, dynamic>?;
    final List<dynamic>? images = preview?['images'] as List<dynamic>?;
    final Map<String, dynamic>? firstImage =
        images?.firstOrNull as Map<String, dynamic>?;
    final Map<String, dynamic>? source =
        firstImage?['source'] as Map<String, dynamic>?;
    return _decodeRedditUrl(source?['url'] as String?);
  }

  static String? _canonicalUrl(Map<String, dynamic> data) {
    final String? permalink = _readString(data, 'permalink');
    if (permalink == null) return null;
    final Uri? uri = Uri.tryParse(permalink);
    if (uri == null) return null;
    if (uri.hasScheme) return uri.toString();
    return 'https://www.reddit.com$permalink';
  }

  static DateTime? _publishDate(Map<String, dynamic> data) {
    final dynamic value = data['created_utc'];
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value * 1000).round(),
        isUtc: true,
      );
    }
    return null;
  }

  static String? _decodeRedditUrl(String? value) {
    return value?.replaceAll('&amp;', '&');
  }

  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }
}
