/// Immutable data transfer object representing metadata extracted from a URL.
///
/// This is the canonical result shape produced by every [SourceParser]
/// implementation, regardless of the underlying platform.
class ParsedMetadata {
  const ParsedMetadata({
    this.title,
    this.description,
    this.thumbnailUrl,
    this.heroImageUrl,
    this.faviconUrl,
    this.siteName,
    this.author,
    this.publisher,
    this.contentType,
    this.languageCode,
    this.publishDate,
  });

  /// Page or content title (OG:title or <title>).
  final String? title;

  /// Short description or excerpt (OG:description or meta description).
  final String? description;

  /// Primary thumbnail / preview image URL (OG:image).
  final String? thumbnailUrl;

  /// Large featured image URL, if distinct from thumbnail.
  final String? heroImageUrl;

  /// Site favicon URL, typically resolved from <link rel="icon">.
  final String? faviconUrl;

  /// Brand / site name (OG:site_name).
  final String? siteName;

  /// Content author, if available.
  final String? author;

  /// Publishing entity, if available.
  final String? publisher;

  /// Detected content type, e.g. 'article', 'video', 'product'.
  final String? contentType;

  /// ISO 639-1 language code, e.g. 'en', 'tr'.
  final String? languageCode;

  /// Original publication date, if present in metadata.
  final DateTime? publishDate;
}
