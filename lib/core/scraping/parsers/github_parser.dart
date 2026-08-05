import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/models/parsed_metadata.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';

/// Extracts metadata from GitHub repository links via the REST API.
///
/// Supported hosts:
/// - github.com / www.github.com
///
/// The parser extracts the owner and repository name from the URL path,
/// calls `api.github.com/repos/{owner}/{repo}`, and maps the JSON
/// response into a [ParsedMetadata] instance.
///
/// Returns `null` on all failure paths — network errors, invalid JSON,
/// missing fields, non-2xx responses, or URLs that do not point to a
/// repository (e.g. user profiles, gists, raw files). Never throws.
class GitHubParser extends SourceParser {
  GitHubParser({required this.dio});

  /// Lazy singleton using a default [Dio] from [DioClient].
  static GitHubParser? _instance;
  static GitHubParser get instance {
    _instance ??= GitHubParser(dio: DioClient.create());
    return _instance!;
  }

  final Dio dio;

  /// Request-level timeout (send + receive).
  static const Duration _requestTimeout = Duration(seconds: 5);

  /// Overall timeout wrapping the entire fetch + parse operation.
  static const Duration _overallTimeout = Duration(seconds: 10);

  @override
  Set<String> get hosts => const <String>{
        'github.com',
        'www.github.com',
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

    // Ensure the URL is actually a GitHub link we claim to handle.
    final String bareHost = _stripWww(normalizedHost);
    if (!hosts.any((h) => _stripWww(h) == bareHost)) return null;

    // Extract owner and repo from path.
    final (String? owner, String? repo) = _extractOwnerRepo(uri.pathSegments);
    if (owner == null || repo == null || owner.isEmpty || repo.isEmpty) {
      return null;
    }

    final String apiUrl = 'https://api.github.com/repos/$owner/$repo';

    try {
      final Response<String> response = await dio
          .get<String>(
            apiUrl,
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

      final String? name = _readString(json, 'name');
      if (name == null || name.isEmpty) return null;

      final String? description = _readString(json, 'description');
      final String? fullName = _readString(json, 'full_name');
      final String? language = _readString(json, 'language');

      final Map<String, dynamic>? ownerData =
          json['owner'] as Map<String, dynamic>?;
      final String? ownerLogin = _readString(ownerData, 'login');
      final String? ownerAvatar = _readString(ownerData, 'avatar_url');

      final List<dynamic>? topics = json['topics'] as List<dynamic>?;
      final String? topicsString = topics != null && topics.isNotEmpty
          ? topics.whereType<String>().join(', ')
          : null;

      return ParsedMetadata(
        title: name,
        description: description,
        thumbnailUrl: ownerAvatar,
        heroImageUrl: ownerAvatar,
        siteName: fullName,
        author: ownerLogin,
        publisher: language ?? topicsString ?? 'GitHub',
        contentType: 'repository',
      );
    } on DioException {
      return null;
    } on TimeoutException {
      return null;
    } on Exception {
      return null;
    }
  }

  /// Extracts `(owner, repo)` from URL path segments.
  ///
  /// Returns `(null, null)` when the path does not contain at least
  /// two non-empty segments (i.e. not a repository URL).
  static (String?, String?) _extractOwnerRepo(List<String> segments) {
    final List<String> nonEmpty =
        segments.where((s) => s.isNotEmpty).toList();
    if (nonEmpty.length < 2) return (null, null);

    final String owner = nonEmpty[0];
    final String repo = nonEmpty[1];

    // Reject special GitHub paths that are not repositories.
    const Set<String> reservedPaths = <String>{
      'settings',
      'marketplace',
      'explore',
      'topics',
      'trending',
      'search',
      'notifications',
      'login',
      'logout',
      'signup',
      'new',
      'import',
      'organizations',
      'users',
      'teams',
      'apps',
      'pulls',
      'issues',
      'gist',
      'raw',
    };

    if (reservedPaths.contains(owner.toLowerCase())) return (null, null);

    return (owner, repo);
  }

  /// Reads a string value from [json] by [key], returning `null` if the
  /// value is missing or not a string.
  static String? _readString(Map<String, dynamic>? json, String key) {
    if (json == null) return null;
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
