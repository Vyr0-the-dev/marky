import 'package:dio/dio.dart';

import 'package:marky/core/scraping/metadata_result.dart';
import 'package:marky/core/scraping/metadata_scraper.dart';
import 'package:marky/core/scraping/parsers/generic_html_parser.dart';
import 'package:marky/core/scraping/source_parser.dart';
import 'package:marky/core/scraping/source_parser_registry.dart';

/// Orchestrates metadata extraction for a given URL.
///
/// Pipeline:
/// 1. Resolve the best [SourceParser] from the registry.
/// 2. If it's a platform-specific parser, run it (may use API).
/// 3. Always run [GenericHtmlParser] as fallback / supplement.
/// 4. Merge results: platform-specific wins, generic fills gaps.
///
/// Returns a [MetadataResult] that the capture service converts
/// into bookmark field updates via [UpsertMergeService].
class MetadataScraperService implements MetadataScraper {
  MetadataScraperService({
    required SourceParserRegistry registry,
    GenericHtmlParser? genericParser,
    Dio? dio,
  })  : _registry = registry,
        _genericParser = genericParser ?? GenericHtmlParser(dio: dio),
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              followRedirects: true,
              maxRedirects: 5,
              headers: GenericHtmlParser.browserNavigationHeaders(),
            ));

  final SourceParserRegistry _registry;
  final GenericHtmlParser _genericParser;
  final Dio _dio;

  /// Scrapes metadata for [url].
  ///
  /// Never throws — returns an empty [MetadataResult] on total
  /// failure or cancellation so the capture pipeline can proceed
  /// with a bare bookmark.
  @override
  Future<MetadataResult> scrape(String url, {CancelToken? cancelToken}) async {
    try {
      if (cancelToken?.isCancelled ?? false) {
        return const MetadataResult();
      }

      // Step 1: Fetch HTML once (with charset sniffing & redirect tracking).
      final ({String? html, String effectiveUrl}) fetched =
          await _fetchHtml(url, cancelToken: cancelToken);
      final String? html = fetched.html;
      final String effectiveUrl = fetched.effectiveUrl;

      if (cancelToken?.isCancelled ?? false) {
        return const MetadataResult();
      }

      // Step 2: Find the best platform-specific parser.
      final SourceParser? platformParser =
          _registry.resolve(effectiveUrl) ?? _registry.resolve(url);

      MetadataResult platformResult = const MetadataResult();
      if (platformParser != null && platformParser is! GenericHtmlParser) {
        platformResult = await platformParser.parse(
          effectiveUrl,
          html: html,
          cancelToken: cancelToken,
        );
      }

      if (cancelToken?.isCancelled ?? false) {
        return const MetadataResult();
      }

      // Step 3: Always run generic multi-tier extraction.
      final MetadataResult genericResult = await _genericParser.parse(
        effectiveUrl,
        html: html,
        cancelToken: cancelToken,
      );

      // Step 4: Platform-specific wins, generic fills gaps.
      return platformResult.mergeWith(genericResult);
    } catch (_) {
      return const MetadataResult();
    }
  }

  Future<({String? html, String effectiveUrl})> _fetchHtml(
    String url, {
    CancelToken? cancelToken,
  }) async {
    try {
      final Response<List<int>> response = await _dio.get<List<int>>(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          maxRedirects: 5,
          headers: GenericHtmlParser.browserNavigationHeaders(url: url),
        ),
      );
      final String effectiveUrl =
          response.realUri.toString().isNotEmpty && response.realUri.hasScheme
              ? response.realUri.toString()
              : url;
      final List<int>? bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        return (html: null, effectiveUrl: effectiveUrl);
      }
      final String? contentType =
          response.headers.value(Headers.contentTypeHeader);
      final String decoded = GenericHtmlParser.decodeHtmlBytes(
        bytes,
        contentTypeHeader: contentType,
      );
      return (html: decoded, effectiveUrl: effectiveUrl);
    } catch (_) {
      try {
        final Response<String> fallbackResponse = await _dio.get<String>(
          url,
          cancelToken: cancelToken,
        );
        final String effectiveUrl =
            fallbackResponse.realUri.toString().isNotEmpty &&
                    fallbackResponse.realUri.hasScheme
                ? fallbackResponse.realUri.toString()
                : url;
        return (html: fallbackResponse.data, effectiveUrl: effectiveUrl);
      } catch (_) {
        return (html: null, effectiveUrl: url);
      }
    }
  }
}
