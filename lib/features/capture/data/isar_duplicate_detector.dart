import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/domain/duplicate_check_result.dart';
import 'package:marky/features/capture/domain/duplicate_detector.dart';

/// [DuplicateDetector] implementation that queries the [BookmarkRepository]
/// for existing bookmarks, checking in order of match strength:
///   1. urlHash (fastest — indexed SHA-256)
///   2. canonicalUrl (string equality fallback)
///   3. externalContentId (cross-variant dedup, e.g. same YouTube video)
class IsarDuplicateDetector implements DuplicateDetector {
  IsarDuplicateDetector(this._bookmarkRepo);

  final BookmarkRepository _bookmarkRepo;

  @override
  Future<DuplicateCheckResult> check({
    required String urlHash,
    required String canonicalUrl,
    String? externalContentId,
  }) async {
    // Level 1: hash match — near-instant via B-tree index.
    final Bookmark? byHash = await _bookmarkRepo.findByUrlHash(urlHash);
    if (byHash != null) {
      return DuplicateCheckResult.duplicate(
        byHash,
        DuplicateMatchLevel.urlHash,
      );
    }

    // Level 2: canonical URL string equality.
    final Bookmark? byCanonical =
        await _bookmarkRepo.findByCanonicalUrl(canonicalUrl);
    if (byCanonical != null) {
      return DuplicateCheckResult.duplicate(
        byCanonical,
        DuplicateMatchLevel.canonicalUrl,
      );
    }

    // Level 3: external content ID (e.g. youtube:dQw4w9WgXcQ).
    if (externalContentId != null && externalContentId.isNotEmpty) {
      final Bookmark? byExternal =
          await _bookmarkRepo.findByExternalContentId(externalContentId);
      if (byExternal != null) {
        return DuplicateCheckResult.duplicate(
          byExternal,
          DuplicateMatchLevel.externalContentId,
        );
      }
    }

    return const DuplicateCheckResult.fresh();
  }
}
