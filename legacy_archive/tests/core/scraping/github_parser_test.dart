// ignore_for_file: unnecessary_raw_strings

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/network/dio_client.dart';
import 'package:marky/core/scraping/parsers/github_parser.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';

import 'fixtures.dart';

void main() {
  late Dio dio;
  late GitHubParser parser;

  setUp(() {
    dio = DioClient.create();
    parser = GitHubParser(dio: dio);
  });

  tearDown(() {
    dio.close();
  });

  // -----------------------------------------------------------------
  // 1. Contract compliance
  // -----------------------------------------------------------------
  group('contract', () {
    test('implements SourceParser', () {
      expect(parser, isA<SourceParser>());
    });

    test('hosts contains github.com variants', () {
      expect(parser.hosts, contains('github.com'));
      expect(parser.hosts, contains('www.github.com'));
    });

    test('instance singleton returns same object', () {
      final GitHubParser a = GitHubParser.instance;
      final GitHubParser b = GitHubParser.instance;
      expect(a, same(b));
    });
  });

  // -----------------------------------------------------------------
  // 2. Happy path
  // -----------------------------------------------------------------
  group('happy path', () {
    test('extracts metadata from GitHub API response', () async {
      const String url = 'https://github.com/flutter/flutter';
      const String jsonBody = r'''
{
  "name": "flutter",
  "full_name": "flutter/flutter",
  "description": "Flutter makes it easy and fast to build beautiful apps for mobile and beyond.",
  "owner": {
    "login": "flutter",
    "avatar_url": "https://avatars.githubusercontent.com/u/14101776?v=4"
  },
  "language": "Dart",
  "topics": ["dart", "mobile", "framework", "sdk"],
  "html_url": "https://github.com/flutter/flutter"
}
''';
      const String apiUrl = 'https://api.github.com/repos/flutter/flutter';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(o, body: jsonBody),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'flutter');
      expect(result.description,
          'Flutter makes it easy and fast to build beautiful apps for mobile and beyond.');
      expect(result.siteName, 'flutter/flutter');
      expect(result.author, 'flutter');
      expect(result.thumbnailUrl,
          'https://avatars.githubusercontent.com/u/14101776?v=4');
      expect(result.heroImageUrl, result.thumbnailUrl);
      expect(result.publisher, 'Dart');
      expect(result.contentType, 'repository');
    });

    test('uses topics as publisher when language is null', () async {
      const String url = 'https://github.com/owner/repo';
      const String jsonBody = r'''
{
  "name": "repo",
  "full_name": "owner/repo",
  "description": "A project with no language.",
  "owner": {
    "login": "owner",
    "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4"
  },
  "language": null,
  "topics": ["config", "tools"],
  "html_url": "https://github.com/owner/repo"
}
''';
      const String apiUrl = 'https://api.github.com/repos/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(o, body: jsonBody),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.publisher, 'config, tools');
    });

    test('falls back to GitHub as publisher when language and topics missing',
        () async {
      const String url = 'https://github.com/owner/repo';
      const String jsonBody = r'''
{
  "name": "repo",
  "full_name": "owner/repo",
  "description": "Minimal repo.",
  "owner": {
    "login": "owner",
    "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4"
  },
  "language": null,
  "topics": [],
  "html_url": "https://github.com/owner/repo"
}
''';
      const String apiUrl = 'https://api.github.com/repos/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(o, body: jsonBody),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.publisher, 'GitHub');
    });

    test('works with www.github.com links', () async {
      const String url = 'https://www.github.com/facebook/react';
      const String jsonBody = r'''
{
  "name": "react",
  "full_name": "facebook/react",
  "description": "A declarative, efficient, and flexible JavaScript library.",
  "owner": {
    "login": "facebook",
    "avatar_url": "https://avatars.githubusercontent.com/u/69631?v=4"
  },
  "language": "JavaScript",
  "topics": ["javascript", "ui", "frontend"],
  "html_url": "https://github.com/facebook/react"
}
''';
      const String apiUrl = 'https://api.github.com/repos/facebook/react';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(o, body: jsonBody),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'react');
      expect(result.author, 'facebook');
    });

    test('handles URL with extra path segments (issues, pull requests)',
        () async {
      const String url = 'https://github.com/owner/repo/issues/123';
      const String jsonBody = r'''
{
  "name": "repo",
  "full_name": "owner/repo",
  "description": "A repo with issues.",
  "owner": {
    "login": "owner",
    "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4"
  },
  "language": "Python",
  "topics": [],
  "html_url": "https://github.com/owner/repo"
}
''';
      const String apiUrl = 'https://api.github.com/repos/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(o, body: jsonBody),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNotNull);
      expect(result!.title, 'repo');
    });
  });

  // -----------------------------------------------------------------
  // 3. Error cases
  // -----------------------------------------------------------------
  group('error cases', () {
    test('returns null on DioException (network error)', () async {
      const String url = 'https://github.com/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{},
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on 403 rate-limit response', () async {
      const String url = 'https://github.com/owner/repo';
      const String apiUrl = 'https://api.github.com/repos/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: r'{"message": "API rate limit exceeded"}',
                  statusCode: 403,
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on 404 response', () async {
      const String url = 'https://github.com/owner/nonexistent';
      const String apiUrl = 'https://api.github.com/repos/owner/nonexistent';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: r'{"message": "Not Found"}',
                  statusCode: 404,
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on non-2xx response (500)', () async {
      const String url = 'https://github.com/owner/repo';
      const String apiUrl = 'https://api.github.com/repos/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: r'{"error": "Internal Server Error"}',
                  statusCode: 500,
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on invalid JSON', () async {
      const String url = 'https://github.com/owner/repo';
      const String apiUrl = 'https://api.github.com/repos/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: 'this is not json',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null when name is missing in API response', () async {
      const String url = 'https://github.com/owner/repo';
      const String apiUrl = 'https://api.github.com/repos/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: r'{"description": "No name here"}',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null on timeout', () async {
      const String url = 'https://github.com/owner/repo';
      const String apiUrl = 'https://api.github.com/repos/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: r'{"name": "Too Late"}',
                ),
          },
          delayedFixtures: <String, Future<void>>{
            apiUrl: Future<void>.delayed(const Duration(milliseconds: 200)),
          },
        ),
      );

      final result = await parser.parse(url).timeout(
            const Duration(milliseconds: 50),
            onTimeout: () => null,
          );
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------
  // 4. Edge cases
  // -----------------------------------------------------------------
  group('edge cases', () {
    test('returns null for empty string', () async {
      final result = await parser.parse('');
      expect(result, isNull);
    });

    test('returns null for whitespace-only string', () async {
      final result = await parser.parse('   ');
      expect(result, isNull);
    });

    test('returns null for malformed URL', () async {
      final result = await parser.parse('ht!tp://[::1');
      expect(result, isNull);
    });

    test('returns null for non-GitHub URLs', () async {
      const String url = 'https://gitlab.com/owner/repo';

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null for file:// URLs', () async {
      final result = await parser.parse('file:///etc/passwd');
      expect(result, isNull);
    });

    test('returns null for javascript: URLs', () async {
      final result = await parser.parse('javascript:alert(1)');
      expect(result, isNull);
    });

    test('returns null for user profile URL (no repo)', () async {
      const String url = 'https://github.com/torvalds';

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null for reserved paths (settings, search, etc.)',
        () async {
      const String url = 'https://github.com/settings/profile';

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null when response body is empty', () async {
      const String url = 'https://github.com/owner/repo';
      const String apiUrl = 'https://api.github.com/repos/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: '',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });

    test('returns null when response is a JSON array', () async {
      const String url = 'https://github.com/owner/repo';
      const String apiUrl = 'https://api.github.com/repos/owner/repo';

      dio.interceptors.add(
        FixtureInterceptor(
          fixtures: <String, Response<String> Function(RequestOptions)>{
            apiUrl: (RequestOptions o) => jsonResponse(
                  o,
                  body: '[1, 2, 3]',
                ),
          },
        ),
      );

      final result = await parser.parse(url);
      expect(result, isNull);
    });
  });
}
