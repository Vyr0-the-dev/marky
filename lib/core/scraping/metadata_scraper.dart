import 'package:marky/core/scraping/metadata_result.dart';

/// Contract for metadata scrapers.
///
/// Implementations must never throw — return an empty
/// [MetadataResult] on failure so callers can proceed.
abstract interface class MetadataScraper {
  Future<MetadataResult> scrape(String url);
}
