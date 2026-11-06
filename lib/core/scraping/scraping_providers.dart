import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/core/scraping/favicon_service.dart';
import 'package:marky/core/scraping/metadata_scraper_service.dart';
import 'package:marky/core/scraping/parsers/generic_html_parser.dart';
import 'package:marky/core/scraping/parsers/github_parser.dart';
import 'package:marky/core/scraping/parsers/reddit_parser.dart';
import 'package:marky/core/scraping/parsers/twitter_parser.dart';
import 'package:marky/core/scraping/parsers/youtube_parser.dart';
import 'package:marky/core/scraping/source_parser.dart';
import 'package:marky/core/scraping/source_parser_registry.dart';
import 'package:marky/core/scraping/thumbnail_service.dart';

/// Registry of all source parsers, platform-specific first,
/// generic last.
final Provider<SourceParserRegistry> sourceParserRegistryProvider =
    Provider<SourceParserRegistry>((Ref ref) {
  return SourceParserRegistry(<SourceParser>[
    YouTubeParser(),
    RedditParser(),
    const TwitterParser(),
    GitHubParser(),
    GenericHtmlParser(), // universal fallback — must be last
  ]);
});

/// The metadata scraping orchestrator.
final Provider<MetadataScraperService> metadataScraperServiceProvider =
    Provider<MetadataScraperService>((Ref ref) {
  return MetadataScraperService(
    registry: ref.watch(sourceParserRegistryProvider),
  );
});

/// Thumbnail download + local cache service.
final Provider<ThumbnailService> thumbnailServiceProvider =
    Provider<ThumbnailService>((Ref ref) {
  return ThumbnailService();
});

/// Favicon download + local cache service.
final Provider<FaviconService> faviconServiceProvider =
    Provider<FaviconService>((Ref ref) {
  return FaviconService();
});
