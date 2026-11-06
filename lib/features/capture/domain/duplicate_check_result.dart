import 'package:flutter/foundation.dart';

import 'package:marky/features/bookmarks/domain/bookmark.dart';

/// Outcome of a duplicate check during the capture pipeline.
///
/// [isNew] means no existing bookmark matched — the capture should
/// proceed with an insert.  Otherwise [existingBookmark] points to
/// the row that matched and [matchLevel] indicates *how* strong
/// the match was (useful for UI copy: "already saved" vs "similar
/// content found").
@immutable
class DuplicateCheckResult {
  const DuplicateCheckResult._({
    required this.isNew,
    this.existingBookmark,
    this.matchLevel,
  });

  /// Factory for when no duplicate was found.
  const DuplicateCheckResult.fresh()
      : isNew = true,
        existingBookmark = null,
        matchLevel = null;

  /// Factory for when a duplicate was found.
  factory DuplicateCheckResult.duplicate(
    Bookmark existing,
    DuplicateMatchLevel level,
  ) =>
      DuplicateCheckResult._(
        isNew: false,
        existingBookmark: existing,
        matchLevel: level,
      );

  /// `true` when no existing bookmark matches the incoming URL.
  final bool isNew;

  /// The existing bookmark that matched.  `null` when [isNew].
  final Bookmark? existingBookmark;

  /// How the match was determined.  `null` when [isNew].
  final DuplicateMatchLevel? matchLevel;

  @override
  String toString() => isNew
      ? 'DuplicateCheckResult.fresh'
      : 'DuplicateCheckResult.duplicate('
          'id: ${existingBookmark?.id}, level: $matchLevel)';
}

/// The strength of a duplicate match, ordered from strongest to
/// weakest.  The dedupe service tries each level in order and
/// returns the first hit.
enum DuplicateMatchLevel {
  /// SHA-256 of the canonical URL matched.
  urlHash,

  /// Canonical URL strings are identical (fallback for bookmarks
  /// that pre-date the urlHash column).
  canonicalUrl,

  /// Platform-specific content ID matched (e.g. same YouTube
  /// video ID arrived via a different URL variant).
  externalContentId,
}
