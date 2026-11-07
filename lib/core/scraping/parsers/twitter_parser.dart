import 'package:dio/dio.dart';
import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/source_parser.dart';

/// Twitter / X metadata parser.
///
/// Uses official publish.twitter.com oEmbed and api.fxtwitter.com
/// fallback to fetch tweet text, author, and media without requiring
/// Twitter API developer credentials.
class TwitterParser implements SourceParser {
  const TwitterParser({Dio? dio}) : _customDio = dio;

  final Dio? _customDio;

  Dio get _dio =>
      _customDio ??
      Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: <String, dynamic>{
          'User-Agent': 'Mozilla/5.0 (compatible; MarkyBot/1.0)',
          'Accept': 'application/json',
        },
      ));

  static final RegExp _hostPattern = RegExp(
    r'(twitter\.com|x\.com|mobile\.twitter\.com)',
    caseSensitive: false,
  );

  static final RegExp _statusIdPattern = RegExp(
    r'\/status\/(\d+)',
    caseSensitive: false,
  );

  static const String _favicon = 'https://abs.twimg.com/favicons/twitter.3.ico';

  @override
  bool canHandle(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return false;
    return _hostPattern.hasMatch(uri.host);
  }

  @override
  Future<MetadataResult> parse(
    String url, {
    String? html,
    CancelToken? cancelToken,
  }) async {
    final String? statusId = _extractStatusId(url);

    // 1. Try FxTwitter API for rich metadata (media, full text, author)
    if (statusId != null) {
      final MetadataResult fxResult =
          await _parseFxTwitter(url, statusId, cancelToken: cancelToken);
      if (!fxResult.isEmpty) return fxResult;
    }

    // 2. Try official Twitter oEmbed
    final MetadataResult oembedResult =
        await _parseOEmbed(url, cancelToken: cancelToken);
    if (!oembedResult.isEmpty) return oembedResult;

    // 3. Fallback
    return const MetadataResult(
      siteName: 'X (Twitter)',
      faviconUrl: _favicon,
    );
  }

  String? _extractStatusId(String url) {
    return _statusIdPattern.firstMatch(url)?.group(1);
  }

  Future<MetadataResult> _parseFxTwitter(
    String url,
    String statusId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final Uri? uri = Uri.tryParse(url);
      final List<String> segments = uri?.pathSegments ?? <String>[];
      final String user = segments.isNotEmpty ? segments.first : 'i';
      final String endpoint =
          'https://api.fxtwitter.com/$user/status/$statusId';

      final Response<dynamic> response = await _dio.get<dynamic>(
        endpoint,
        cancelToken: cancelToken,
      );

      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) return const MetadataResult();
      final Map<String, dynamic>? tweet = data['tweet'] as Map<String, dynamic>?;
      if (tweet == null) return const MetadataResult();

      final String? text = tweet['text'] as String?;
      final Map<String, dynamic>? authorMap = tweet['author'] as Map<String, dynamic>?;
      final String? authorName = authorMap?['name'] as String?;
      final String? screenName = authorMap?['screen_name'] as String?;
      final String? authorAvatar = authorMap?['avatar_url'] as String?;

      // Media
      final Map<String, dynamic>? media = tweet['media'] as Map<String, dynamic>?;
      final List<dynamic>? photos = media?['photos'] as List<dynamic>?;
      final Map<String, dynamic>? firstPhoto =
          photos?.firstOrNull as Map<String, dynamic>?;
      final String? heroImageUrl =
          (firstPhoto?['url'] as String?) ?? authorAvatar;

      final String authorDisplay = authorName != null && screenName != null
          ? '$authorName (@$screenName)'
          : (authorName ?? (screenName != null ? '@$screenName' : 'Twitter User'));

      return MetadataResult(
        title: text != null && text.isNotEmpty
            ? (text.length > 80 ? '${text.substring(0, 80)}…' : text)
            : 'Post by $authorDisplay',
        description: text,
        snippet: text,
        author: authorDisplay,
        siteName: 'X (Twitter)',
        publisher: 'X',
        heroImageUrl: heroImageUrl,
        faviconUrl: _favicon,
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
        'https://publish.twitter.com/oembed',
        queryParameters: <String, dynamic>{
          'url': url,
          'omit_script': 'true',
        },
        cancelToken: cancelToken,
      );

      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) return const MetadataResult();

      final String? authorName = data['author_name'] as String?;
      final String? htmlContent = data['html'] as String?;
      final String? plainText = htmlContent != null
          ? htmlContent
              .replaceAll(RegExp(r'<[^>]*>'), ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim()
          : null;

      return MetadataResult(
        title: plainText != null && plainText.isNotEmpty
            ? (plainText.length > 80
                ? '${plainText.substring(0, 80)}…'
                : plainText)
            : (authorName != null ? 'Post by $authorName' : 'X Post'),
        description: plainText,
        snippet: plainText,
        author: authorName,
        siteName: 'X (Twitter)',
        publisher: 'X',
        faviconUrl: _favicon,
      );
    } catch (_) {
      return const MetadataResult();
    }
  }
}
