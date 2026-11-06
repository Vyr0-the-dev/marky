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
              headers: <String, dynamic>{
                'User-Agent':
                    'Mozilla/5.0 (compatible; MarkyBot/1.0; +https://marky.app)',
                'Accept': 'text/html,application/xhtml+xml',
              },
            ));

  final SourceParserRegistry _registry;
  final GenericHtmlParser _genericParser;
  final Dio _dio;

  /// Scrapes metadata for [url].
  ///
  /// Never throws — returns an empty [MetadataResult] on total
  /// failure so the capture pipeline can proceed with a bare
  /// bookmark.
  @override
  Future<MetadataResult> scrape(String url) async {
    try {
      // Step 1: Fetch HTML once, share with parsers.
      final String? html = await _fetchHtml(url);

      // Step 2: Find the best platform-specific parser.
      final SourceParser? platformParser = _registry.resolve(url);

      MetadataResult platformResult = const MetadataResult();
      if (platformParser != null && platformParser is! GenericHtmlParser) {
        platformResult = await platformParser.parse(url, html: html);
      }

      // Step 3: Always run generic OG/meta extraction.
      final MetadataResult genericResult =
          await _genericParser.parse(url, html: html);

      // Step 4: Platform-specific wins, generic fills gaps.
      return platformResult.mergeWith(genericResult);
    } catch (_) {
      return const MetadataResult();
    }
  }

  Future<String?> _fetchHtml(String url) async {
    try {
      final Response<String> response = await _dio.get<String>(url);
      return response.data;
    } catch (_) {
      return null;
    }
  }
}
