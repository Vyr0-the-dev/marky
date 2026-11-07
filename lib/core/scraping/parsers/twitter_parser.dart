import 'package:dio/dio.dart';
import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/source_parser.dart';

/// Twitter / X metadata parser.
///
/// Uses official publish.twitter.com oEmbed, api.fxtwitter.com, and
/// api.vxtwitter.com fallback to fetch tweet text, author, X articles, and media
/// without requiring Twitter API developer credentials.
class TwitterParser implements SourceParser {
  const TwitterParser({Dio? dio}) : _customDio = dio;

  final Dio? _customDio;

  Dio get _dio =>
      _customDio ??
      Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: <String, dynamic>{
            'User-Agent': 'Mozilla/5.0 (compatible; MarkyBot/1.0)',
            'Accept': 'application/json',
          },
        ),
      );

  static final RegExp _statusOrArticlePattern = RegExp(
    r'\/(?:status|statuses|article)\/(\d+)',
    caseSensitive: false,
  );

  static const String _favicon = 'https://abs.twimg.com/favicons/twitter.3.ico';

  @override
  bool canHandle(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return false;
    final String host = uri.host.toLowerCase();
    return host == 'twitter.com' ||
        host == 'x.com' ||
        host.endsWith('.twitter.com') ||
        host.endsWith('.x.com');
  }

  @override
  Future<MetadataResult> parse(
    String url, {
    String? html,
    CancelToken? cancelToken,
  }) async {
    final String? statusId = _extractStatusId(url);

    // 1. Try FxTwitter API for rich metadata (media, full text, author, articles)
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
    return _statusOrArticlePattern.firstMatch(url)?.group(1);
  }

  Future<MetadataResult> _parseFxTwitter(
    String url,
    String statusId, {
    CancelToken? cancelToken,
  }) async {
    final Uri? uri = Uri.tryParse(url);
    final List<String> segments = uri?.pathSegments ?? <String>[];
    String user = 'i';
    if (segments.isNotEmpty &&
        segments.first.isNotEmpty &&
        segments.first != 'i' &&
        segments.first != 'status' &&
        segments.first != 'article') {
      user = segments.first;
    }

    final List<String> endpoints = <String>[
      'https://api.fxtwitter.com/$user/status/$statusId',
      'https://api.vxtwitter.com/$user/status/$statusId',
    ];

    for (final String endpoint in endpoints) {
      if (cancelToken?.isCancelled ?? false) break;
      try {
        final Response<dynamic> response = await _dio.get<dynamic>(
          endpoint,
          cancelToken: cancelToken,
        );

        final dynamic data = response.data;
        if (data is! Map<String, dynamic>) continue;
        final Map<String, dynamic>? tweet =
            (data['tweet'] ?? data) as Map<String, dynamic>?;
        if (tweet == null) continue;

        final String? rawText = tweet['text'] as String?;
        final Map<String, dynamic>? authorMap =
            tweet['author'] as Map<String, dynamic>?;
        final String? authorName = authorMap?['name'] as String?;
        final String? screenName = authorMap?['screen_name'] as String?;
        final String? authorAvatar = authorMap?['avatar_url'] as String?;

        // 1. Check for X Article / Long-form article
        final Map<String, dynamic>? article =
            tweet['article'] as Map<String, dynamic>?;
        final String? articleTitle = article?['title'] as String?;
        final String? articleContent =
            (article?['content'] ?? article?['preview_text']) as String?;
        final String? articleCover = article?['cover_image'] as String?;

        // 2. Media
        final Map<String, dynamic>? media =
            tweet['media'] as Map<String, dynamic>?;
        final List<dynamic>? photos = media?['photos'] as List<dynamic>?;
        final Map<String, dynamic>? firstPhoto =
            photos?.firstOrNull as Map<String, dynamic>?;
        final List<dynamic>? videos = media?['videos'] as List<dynamic>?;
        final Map<String, dynamic>? firstVideo =
            videos?.firstOrNull as Map<String, dynamic>?;

        final String? heroImageUrl = articleCover ??
            (firstPhoto?['url'] as String?) ??
            (firstVideo?['thumbnail_url'] as String?) ??
            authorAvatar;

        // 3. Quotes
        String fullSnippet = articleContent ?? rawText ?? '';
        final Map<String, dynamic>? quote =
            tweet['quote'] as Map<String, dynamic>?;
        if (quote != null) {
          final String? quoteText = quote['text'] as String?;
          final Map<String, dynamic>? qAuthor =
              quote['author'] as Map<String, dynamic>?;
          final String qName = qAuthor?['name'] as String? ?? 'X';
          if (quoteText != null && quoteText.isNotEmpty) {
            fullSnippet = fullSnippet.isEmpty
                ? '[$qName: $quoteText]'
                : '$fullSnippet\n\n[$qName: $quoteText]';
          }
        }

        final String authorDisplay = authorName != null && screenName != null
            ? '$authorName (@$screenName)'
            : (authorName ??
                (screenName != null ? '@$screenName' : 'Twitter User'));

        String displayTitle = articleTitle ?? '';
        if (displayTitle.isEmpty) {
          if (rawText != null && rawText.isNotEmpty) {
            displayTitle =
                rawText.length > 80 ? '${rawText.substring(0, 80)}…' : rawText;
          } else {
            displayTitle = 'Post by $authorDisplay';
          }
        }

        return MetadataResult(
          title: displayTitle,
          description: fullSnippet.isNotEmpty ? fullSnippet : null,
          snippet: fullSnippet.isNotEmpty ? fullSnippet : null,
          author: authorDisplay,
          siteName: 'X (Twitter)',
          publisher: 'X',
          heroImageUrl: heroImageUrl,
          faviconUrl: _favicon,
        );
      } catch (_) {
        continue;
      }
    }

    return const MetadataResult();
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
      final String? plainText = htmlContent
          ?.replaceAll(RegExp('<[^>]*>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

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
