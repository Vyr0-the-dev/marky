import 'dart:async';

import 'package:marky/core/scraping/enums/scraping_status.dart';
import 'package:marky/core/scraping/models/parsed_metadata.dart';
import 'package:marky/core/scraping/parsers/generic_parser.dart';
import 'package:marky/core/scraping/parsers/github_parser.dart';
import 'package:marky/core/scraping/parsers/medium_parser.dart';
import 'package:marky/core/scraping/parsers/reddit_parser.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';
import 'package:marky/core/scraping/parsers/twitter_parser.dart';
import 'package:marky/core/scraping/parsers/youtube_parser.dart';
import 'package:marky/core/scraping/services/favicon_cache_service.dart';
import 'package:marky/core/scraping/services/image_cache_service.dart';
import 'package:marky/core/scraping/source_parser_registry.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Orchestrates metadata scraping for bookmarks after they are saved.
///
/// Fetches the bookmark, resolves the appropriate parser, extracts
/// metadata, and updates the bookmark record with the results.
class MetadataScraperService {
  MetadataScraperService({
    required SourceParserRegistry registry,
    required BookmarkItemRepository repository,
  })  : _registry = registry,
        _repository = repository;

  final SourceParserRegistry _registry;
  final BookmarkItemRepository _repository;

  static MetadataScraperService? _instance;

  /// The globally configured instance.
  ///
  /// Throws [StateError] if accessed before [initialize].
  static MetadataScraperService get instance {
    if (_instance == null) {
      throw StateError(
        'MetadataScraperService has not been initialized. '
        'Call MetadataScraperService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Returns the global instance if initialized, otherwise `null`.
  ///
  /// Safe for use in providers that may be accessed before bootstrap
  /// completes (e.g. during widget tests).
  static MetadataScraperService? get instanceOrNull => _instance;

  /// Creates and registers the global singleton, wiring all source parsers
  /// into the registry.
  static void initialize({
    required SourceParserRegistry registry,
    required BookmarkItemRepository repository,
  }) {
    registry
      ..register(YouTubeParser.instance)
      ..register(RedditParser.instance)
      ..register(GitHubParser.instance)
      ..register(TwitterParser.instance)
      ..register(MediumParser.instance);

    _instance = MetadataScraperService(
      registry: registry,
      repository: repository,
    );
  }

  /// Resets the global singleton. Useful in tests.
  static void reset() {
    _instance = null;
  }

  /// Scrapes metadata for the bookmark with [bookmarkId] and persists
  /// the enriched fields.
  ///
  /// The bookmark's [BookmarkItem.scrapingStatus] transitions through
  /// [ScrapingStatus.processing] → [ScrapingStatus.done] or
  /// [ScrapingStatus.failed].
  ///
  /// All errors are caught and recorded as [ScrapingStatus.failed];
  /// no exceptions escape this method.
  Future<void> scrapeAndUpdate(int bookmarkId, String url) async {
    final BookmarkItem? bookmark = await _repository.getById(bookmarkId);
    if (bookmark == null) {
      return;
    }

    final DateTime now = DateTime.now();

    try {
      bookmark
        ..scrapingStatus = ScrapingStatus.processing
        ..updatedAt = now;
      await _repository.update(bookmark);

      final SourceParser parser =
          _registry.resolve(url) ?? GenericParser.instance;
      final ParsedMetadata? metadata = await parser.parse(url);

      if (metadata != null) {
        bookmark
          ..title = metadata.title ?? bookmark.title
          ..description = metadata.description ?? bookmark.description
          ..thumbnailUrl = metadata.thumbnailUrl ?? bookmark.thumbnailUrl
          ..heroImageUrl = metadata.heroImageUrl ?? bookmark.heroImageUrl
          ..faviconUrl = metadata.faviconUrl ?? bookmark.faviconUrl
          ..siteName = metadata.siteName ?? bookmark.siteName
          ..author = metadata.author ?? bookmark.author
          ..publisher = metadata.publisher ?? bookmark.publisher
          ..contentType = metadata.contentType ?? bookmark.contentType
          ..languageCode = metadata.languageCode ?? bookmark.languageCode
          ..publishDate = metadata.publishDate ?? bookmark.publishDate
          ..scrapingStatus = ScrapingStatus.done
          ..updatedAt = DateTime.now();

        // Fallback to Google's favicon service if no favicon was discovered.
        if (bookmark.faviconUrl == null && bookmark.normalizedHost != null) {
          bookmark.faviconUrl =
              'https://www.google.com/s2/favicons?domain=${bookmark.normalizedHost}&sz=128';
        }
      } else {
        bookmark
          ..scrapingStatus = ScrapingStatus.failed
          ..updatedAt = DateTime.now();
      }

      await _repository.update(bookmark);

      if (bookmark.scrapingStatus == ScrapingStatus.done) {
        unawaited(
          ImageCacheService.instanceOrNull?.downloadAndCache(bookmarkId) ??
              Future<void>.value(),
        );
        unawaited(
          FaviconCacheService.instanceOrNull?.downloadAndCache(bookmarkId) ??
              Future<void>.value(),
        );
      }
    } on Exception {
      bookmark
        ..scrapingStatus = ScrapingStatus.failed
        ..updatedAt = DateTime.now();
      await _repository.update(bookmark);
    }
  }
}
