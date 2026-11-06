import 'package:dio/dio.dart';

import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/source_parser.dart';

/// YouTube-specific metadata parser.
///
/// Uses the oEmbed endpoint (no API key required) to extract video
/// metadata. Falls back to OG parsing via the provided [html] if
/// oEmbed fails.
class YouTubeParser implements SourceParser {
  YouTubeParser({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ));

  final Dio _dio;

  static final RegExp _hostPattern = RegExp(
    r'(youtube\.com|youtu\.be|m\.youtube\.com)',
    caseSensitive: false,
  );

  @override
  bool canHandle(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return false;
    return _hostPattern.hasMatch(uri.host);
  }

  @override
  Future<MetadataResult> parse(String url, {String? html}) async {
    try {
      final String oEmbedUrl =
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';

      final Response<Map<String, dynamic>> response =
          await _dio.get<Map<String, dynamic>>(oEmbedUrl);

      final Map<String, dynamic>? data = response.data;
      if (data == null) return const MetadataResult();

      return MetadataResult(
        title: data['title'] as String?,
        author: data['author_name'] as String?,
        siteName: 'YouTube',
        heroImageUrl: data['thumbnail_url'] as String?,
        faviconUrl: 'https://www.youtube.com/favicon.ico',
      );
    } catch (_) {
      // oEmbed failed — return minimal result, let generic parser
      // fill from OG tags if html is available.
      return const MetadataResult(
        siteName: 'YouTube',
        faviconUrl: 'https://www.youtube.com/favicon.ico',
      );
    }
  }
}
