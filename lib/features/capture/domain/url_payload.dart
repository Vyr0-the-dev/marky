import 'package:flutter/foundation.dart';

import 'package:marky/core/database/enums/bookmark_content_type.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';

/// The product of the URL intelligence pipeline.
///
/// Created by running the raw user input through [UrlNormalizer],
/// [UrlHasher], [ContentTypeDetector], and
/// [ExternalContentIdExtractor].  The [CaptureService] then feeds
/// this into duplicate detection and — if new — into
/// [BookmarkRepository.save].
///
/// This is an intermediate value object, not persisted directly.
@immutable
class UrlPayload {
  const UrlPayload({
    required this.rawInput,
    required this.normalizedUrl,
    required this.normalizedHost,
    required this.urlHash,
    required this.contentType,
    required this.sourceType,
    this.externalContentId,
  });

  /// The exact string the user typed / shared / clipboard-pasted.
  final String rawInput;

  /// Output of [UrlNormalizer.normalize].
  final String normalizedUrl;

  /// Output of [UrlNormalizer.extractNormalizedHost].
  final String normalizedHost;

  /// SHA-256 of [normalizedUrl].
  final String urlHash;

  /// Best-guess content type from the URL pattern.
  final BookmarkContentType contentType;

  /// How the URL entered the system (manual, share, clipboard, …).
  final BookmarkSourceType sourceType;

  /// Platform-specific content ID, e.g. `youtube:dQw4w9WgXcQ`.
  /// Null for generic web pages.
  final String? externalContentId;

  @override
  String toString() => 'UrlPayload('
      'raw: $rawInput, '
      'normalized: $normalizedUrl, '
      'host: $normalizedHost, '
      'content: $contentType, '
      'source: $sourceType, '
      'extId: $externalContentId)';
}
