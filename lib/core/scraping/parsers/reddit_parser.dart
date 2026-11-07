import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/source_parser.dart';

/// Enhanced Reddit-specific metadata parser.
///
/// Features:
/// 1. Shortlink resolution (`/s/xyz` and `redd.it/xyz`) via redirect tracking.
/// 2. Whitelisted Reddit User-Agent to prevent 429 rate limiting.
/// 3. Image gallery (`media_metadata`) and preview decoding (`&amp;` -> `&`).
/// 4. Full text extraction into snippet for Reader Mode support.
/// 5. Fallback to Reddit oEmbed and HTML scraping when JSON API is blocked.
class RedditParser implements SourceParser {
  RedditParser({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                headers: <String, dynamic>{
                  'User-Agent':
                      'android:com.marky.app:v1.0.0 (by /u/marky_reader)',
                  'Accept': 'application/json,text/plain,*/*',
                },
              ),
            );

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

    // 1. Resolve redirect if it's a shortlink (e.g. reddit.com/r/.../s/... or redd.it/...)
    final String targetUrl =
        await _resolveShortlink(url, cancelToken: cancelToken);

    // 2. Try JSON endpoint
    final MetadataResult jsonResult =
        await _parseJsonEndpoint(targetUrl, cancelToken: cancelToken);
    if (!jsonResult.isEmpty) return jsonResult;

    if (cancelToken?.isCancelled ?? false) {
      return const MetadataResult(siteName: 'Reddit', faviconUrl: _faviconUrl);
    }

    // 3. Try official Reddit oEmbed
    final MetadataResult embedResult =
        await _parseOEmbed(targetUrl, cancelToken: cancelToken);
    if (!embedResult.isEmpty) return embedResult;

    // 4. Try HTML scraping fallback
    final MetadataResult htmlResult =
        await _parseRedditHtml(targetUrl, html: html, cancelToken: cancelToken);
    if (!htmlResult.isEmpty) return htmlResult;

    return const MetadataResult(
      siteName: 'Reddit',
      faviconUrl: _faviconUrl,
    );
  }

  Future<String> _resolveShortlink(
    String url, {
    CancelToken? cancelToken,
  }) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return url;
    final String host = uri.host.toLowerCase();
    final bool isShort = host == 'redd.it' || uri.path.contains('/s/');
    if (!isShort) return url;

    try {
      final Response<dynamic> res = await _dio.get<dynamic>(
        url,
        options: Options(
          followRedirects: true,
          maxRedirects: 6,
          headers: <String, dynamic>{
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          },
          validateStatus: (int? s) => s != null && s < 400,
        ),
        cancelToken: cancelToken,
      );
      final String resolved = res.realUri.toString();
      if (resolved.isNotEmpty && resolved != url) {
        return resolved;
      }
    } catch (_) {
      try {
        final Response<dynamic> headRes = await _dio.head<dynamic>(
          url,
          options: Options(
            followRedirects: true,
            maxRedirects: 5,
            validateStatus: (int? s) => s != null && s < 400,
          ),
          cancelToken: cancelToken,
        );
        return headRes.realUri.toString();
      } catch (_) {}
    }
    return url;
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

      // Try gallery images, then preview images, then outbound direct image, then thumbnail
      final String? galleryImage = _extractGalleryImage(postData);
      final String? heroImageUrl = galleryImage ??
          _imageUrl(outboundUrl) ??
          _previewImageUrl(postData) ??
          thumbnail;

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
        snippet: selftext, // Full body for Reader Mode!
        canonicalUrl: canonicalUrl,
        author: author,
        siteName: subredditPrefixed ??
            (subredditName == null ? 'Reddit' : 'r/$subredditName'),
        publisher: 'Reddit',
        publishDate: publishDate,
        heroImageUrl: heroImageUrl,
        faviconUrl: _faviconUrl,
      );
    } catch (_) {
      return const MetadataResult();
    }
  }

  Future<MetadataResult> _parseOEmbed(
    String url, {
    CancelToken? cancelToken,
  }) async {
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

  Future<MetadataResult> _parseRedditHtml(
    String url, {
    String? html,
    CancelToken? cancelToken,
  }) async {
    try {
      String pageHtml = html ?? '';
      if (pageHtml.isEmpty) {
        final Response<dynamic> res = await _dio.get<dynamic>(
          url,
          options: Options(
            responseType: ResponseType.plain,
            headers: <String, dynamic>{
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
            },
          ),
          cancelToken: cancelToken,
        );
        pageHtml = res.data?.toString() ?? '';
      }
      if (pageHtml.isEmpty) return const MetadataResult();

      final dom.Document doc = html_parser.parse(pageHtml);
      final dom.Element? shreddit = doc.querySelector('shreddit-post');
      final String? title = shreddit?.attributes['post-title'] ??
          doc
              .querySelector('meta[property="og:title"]')
              ?.attributes['content'] ??
          doc.querySelector('h1')?.text.trim();
      final String? author = shreddit?.attributes['author'];
      final String? subreddit =
          shreddit?.attributes['subreddit-prefixed-name'];
      final String? text = doc
              .querySelector('div[slot="text-body"]')
              ?.text
              .trim() ??
          doc
              .querySelector('meta[property="og:description"]')
              ?.attributes['content'];
      final String? image = shreddit?.attributes['content-href'] ??
          doc
              .querySelector('meta[property="og:image"]')
              ?.attributes['content'];

      if (title == null || title.isEmpty) return const MetadataResult();

      return MetadataResult(
        title: title,
        description: text,
        snippet: text,
        author: author,
        siteName: subreddit ?? 'Reddit',
        publisher: 'Reddit',
        heroImageUrl:
            image != null && image.startsWith('http') ? image : null,
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

  static String? _extractGalleryImage(Map<String, dynamic> data) {
    final Map<String, dynamic>? mediaMetadata =
        data['media_metadata'] as Map<String, dynamic>?;
    if (mediaMetadata == null || mediaMetadata.isEmpty) return null;

    for (final dynamic item in mediaMetadata.values) {
      if (item is Map<String, dynamic>) {
        final Map<String, dynamic>? s = item['s'] as Map<String, dynamic>?;
        final String? u = s?['u'] as String?;
        if (u != null && u.isNotEmpty) {
          return _decodeRedditUrl(u);
        }
        final List<dynamic>? p = item['p'] as List<dynamic>?;
        final Map<String, dynamic>? lastPreview =
            p?.lastOrNull as Map<String, dynamic>?;
        final String? previewU = lastPreview?['u'] as String?;
        if (previewU != null && previewU.isNotEmpty) {
          return _decodeRedditUrl(previewU);
        }
      }
    }
    return null;
  }

  static String? _imageUrl(String? value) {
    if (value == null || !value.startsWith('http')) return null;
    final Uri? uri = Uri.tryParse(value);
    final String path = (uri?.path ?? value).toLowerCase();
    if (!path.endsWith('.jpg') &&
        !path.endsWith('.jpeg') &&
        !path.endsWith('.png') &&
        !path.endsWith('.gif') &&
        !path.endsWith('.webp')) {
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
