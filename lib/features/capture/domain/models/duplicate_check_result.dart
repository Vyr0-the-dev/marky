import 'package:marky/shared/models/bookmark_item.dart';

/// Indicates how a duplicate was detected.
enum DuplicateMatchType {
  /// Matched by SHA-256 hash of the canonical URL.
  urlHash,

  /// Matched by the canonical URL string itself.
  canonicalUrl,

  /// Matched by external platform content ID (e.g. YouTube video ID).
  externalContentId,

  /// Matched by existing duplicate group assignment.
  duplicateGroupId,

  /// Matched by normalized URL comparison (fallback).
  normalizedUrl,
}

/// Result of running duplicate detection against a candidate bookmark.
sealed class DuplicateCheckResult {
  const DuplicateCheckResult();
}

/// No existing bookmark matches the candidate.
final class NoDuplicate extends DuplicateCheckResult {
  const NoDuplicate();
}

/// An existing bookmark matches the candidate.
///
/// [matchType] describes the detection path, [existing] is the
/// already-stored item that should be treated as the canonical record,
/// and [duplicateGroupId] is the group ID that should be assigned to
/// both the existing and the new bookmark (generated deterministically
/// if the existing item does not already have one).
final class DuplicateFound extends DuplicateCheckResult {
  const DuplicateFound({
    required this.matchType,
    required this.existing,
    this.duplicateGroupId,
  });

  final DuplicateMatchType matchType;
  final BookmarkItem existing;

  /// The duplicate group ID to assign. Non-null when a duplicate is found.
  final String? duplicateGroupId;
}
