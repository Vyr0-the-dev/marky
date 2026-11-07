import 'package:dio/dio.dart';

import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/source_parser.dart';

/// GitHub-specific metadata parser.
///
/// Uses the public GitHub API (no token required for public repos)
/// to extract repository metadata. Falls back to OG tags when the
/// URL is not a repo root or the API call fails.
class GitHubParser implements SourceParser {
  GitHubParser({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: <String, dynamic>{
                'Accept': 'application/vnd.github.v3+json',
                'User-Agent': 'Marky/1.0',
              },
            ));

  final Dio _dio;

  /// Matches `github.com/owner/repo` with optional trailing segments.
  static final RegExp _repoPattern = RegExp(
    '^/([^/]+)/([^/]+)',
  );

  @override
  bool canHandle(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host == 'github.com' || uri.host == 'www.github.com';
  }

  @override
  Future<MetadataResult> parse(
    String url, {
    String? html,
    CancelToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled ?? false) {
      return const MetadataResult(siteName: 'GitHub');
    }
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return const MetadataResult(siteName: 'GitHub');

    final RegExpMatch? match = _repoPattern.firstMatch(uri.path);
    if (match == null) {
      return const MetadataResult(
        siteName: 'GitHub',
        faviconUrl: 'https://github.com/favicon.ico',
      );
    }

    final String owner = match.group(1)!;
    final String repo = match.group(2)!;

    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/$owner/$repo',
        cancelToken: cancelToken,
      );

      final Map<String, dynamic>? data = response.data;
      if (data == null) return const MetadataResult(siteName: 'GitHub');

      return MetadataResult(
        title: data['full_name'] as String?,
        description: data['description'] as String?,
        author: (data['owner'] as Map<String, dynamic>?)?['login'] as String?,
        siteName: 'GitHub',
        heroImageUrl:
            (data['owner'] as Map<String, dynamic>?)?['avatar_url'] as String?,
        faviconUrl: 'https://github.com/favicon.ico',
        languageCode: data['language'] != null
            ? null // language here is programming language, not locale
            : null,
      );
    } catch (_) {
      return const MetadataResult(
        siteName: 'GitHub',
        faviconUrl: 'https://github.com/favicon.ico',
      );
    }
  }
}
