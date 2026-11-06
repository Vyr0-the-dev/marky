import 'package:marky/features/capture/domain/duplicate_check_result.dart';

/// Boundary for the duplicate detection subsystem.
///
/// The capture service asks this interface "is this URL already saved?"
/// before committing a new bookmark.  The implementation queries the
/// Isar database through [BookmarkRepository]'s lookup methods.
abstract interface class DuplicateDetector {
  /// Checks whether a bookmark with the same identity already exists.
  ///
  /// The caller provides all three candidate keys; the implementation
  /// tries them from strongest to weakest:
  ///   1. [urlHash] — SHA-256 of the canonical URL (fastest, indexed).
  ///   2. [canonicalUrl] — string equality fallback.
  ///   3. [externalContentId] — platform-specific ID (YouTube video ID,
  ///      tweet ID, etc.). Can be `null` for generic URLs.
  ///
  /// Returns a [DuplicateCheckResult] indicating either "fresh" or
  /// "duplicate found at match level X".
  Future<DuplicateCheckResult> check({
    required String urlHash,
    required String canonicalUrl,
    String? externalContentId,
  });
}
