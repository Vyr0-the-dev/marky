import 'package:flutter/foundation.dart';

/// Uniform output produced by every metadata parser.
///
/// Each field is nullable because not every page (or parser)
/// can fill every slot.  The [MetadataScraperService] feeds
/// this into [UpsertMergeService] which applies the "fill gaps,
/// don't overwrite" policy against the existing bookmark.
@immutable
class MetadataResult {
  const MetadataResult({
    this.title,
    this.description,
    this.canonicalUrl,
    this.author,
    this.siteName,
    this.publisher,
    this.publishDate,
    this.languageCode,
    this.heroImageUrl,
    this.faviconUrl,
    this.readingTimeMinutes,
    this.snippet,
  });

  /// Page title — from `<title>`, OG title, or platform-specific source.
  final String? title;

  /// Short description — from meta description, OG description, etc.
  final String? description;

  /// Canonical URL extracted from `<link rel="canonical">` or OG URL.
  final String? canonicalUrl;

  /// Content author when available.
  final String? author;

  /// Site name — from `og:site_name` or platform name.
  final String? siteName;

  /// Publisher organization when different from siteName.
  final String? publisher;

  /// Date the content was published.
  final DateTime? publishDate;

  /// ISO 639-1 language code (e.g. "en", "tr").
  final String? languageCode;

  /// Primary image URL — from `og:image`, Twitter card, etc.
  final String? heroImageUrl;

  /// Favicon URL.
  final String? faviconUrl;

  /// Estimated reading time in minutes.
  final int? readingTimeMinutes;

  /// Short text excerpt / snippet.
  final String? snippet;

  /// True when every field is null — parser found nothing useful.
  bool get isEmpty =>
      title == null &&
      description == null &&
      canonicalUrl == null &&
      author == null &&
      siteName == null &&
      publisher == null &&
      publishDate == null &&
      languageCode == null &&
      heroImageUrl == null &&
      faviconUrl == null &&
      readingTimeMinutes == null &&
      snippet == null;

  /// Merges two results — `this` takes priority, [other] fills gaps.
  MetadataResult mergeWith(MetadataResult other) => MetadataResult(
        title: title ?? other.title,
        description: description ?? other.description,
        canonicalUrl: canonicalUrl ?? other.canonicalUrl,
        author: author ?? other.author,
        siteName: siteName ?? other.siteName,
        publisher: publisher ?? other.publisher,
        publishDate: publishDate ?? other.publishDate,
        languageCode: languageCode ?? other.languageCode,
        heroImageUrl: heroImageUrl ?? other.heroImageUrl,
        faviconUrl: faviconUrl ?? other.faviconUrl,
        readingTimeMinutes: readingTimeMinutes ?? other.readingTimeMinutes,
        snippet: snippet ?? other.snippet,
      );

  @override
  String toString() => 'MetadataResult(title: $title, site: $siteName, '
      'image: ${heroImageUrl != null ? "yes" : "no"})';
}
