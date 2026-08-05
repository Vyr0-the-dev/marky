/// Result of canonical URL extraction from a known platform.
///
/// Immutable data class that carries both the canonical (normalized) URL
/// and the platform-specific external content identifier.
class CanonicalExtractionResult {
  const CanonicalExtractionResult({
    required this.canonicalUrl,
    required this.externalContentId,
  });

  /// The normalized, canonical URL for this piece of content.
  final String canonicalUrl;

  /// Platform-specific identifier (video ID, tweet ID, ASIN, etc.).
  final String externalContentId;

  @override
  String toString() =>
      'CanonicalExtractionResult(canonicalUrl: $canonicalUrl, '
      'externalContentId: $externalContentId)';
}
