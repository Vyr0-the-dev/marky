import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/models/duplicate_check_result.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Multi-level duplicate detection engine for bookmarks.
///
/// Checks candidates against existing bookmarks using a cascade of
/// matchers: URL hash → external content ID → canonical URL →
/// normalized URL comparison. The first hit wins.
///
/// When a duplicate is found, a deterministic [duplicateGroupId] is
/// either reused from the existing record or generated from the
/// canonical URL hash so that callers can link the new bookmark to
/// the same group.
///
/// Pure Dart — safe for isolates and synchronous unit tests.
class DuplicateDetectionService {
  DuplicateDetectionService({
    required BookmarkItemRepository repository,
    required UrlNormalizationService normalizationService,
  })  : _repository = repository,
        _normalizationService = normalizationService;

  final BookmarkItemRepository _repository;
  final UrlNormalizationService _normalizationService;

  static DuplicateDetectionService? _instance;

  /// The globally configured instance.
  ///
  /// Throws [StateError] if accessed before [initialize].
  static DuplicateDetectionService get instance {
    if (_instance == null) {
      throw StateError(
        'DuplicateDetectionService has not been initialized. '
        'Call DuplicateDetectionService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Creates and registers the global singleton.
  static void initialize({
    required BookmarkItemRepository repository,
    required UrlNormalizationService normalizationService,
  }) {
    _instance = DuplicateDetectionService(
      repository: repository,
      normalizationService: normalizationService,
    );
  }

  /// Resets the global singleton. Useful in tests.
  static void reset() {
    _instance = null;
  }

  /// Checks whether a bookmark matching the candidate already exists.
  ///
  /// The detection cascade runs in order of speed / specificity:
  ///
  /// 1. **urlHash exact match** — fastest O(1) lookup.
  /// 2. **externalContentId match** — catches same content on different
  ///    URLs (e.g. YouTube video ID).
  /// 3. **canonicalUrl exact match** — catches hash collisions or
  ///    pre-hash bookmarks.
  /// 4. **normalized URL comparison** — iterates all bookmarks,
  ///    normalizes both candidate and existing URLs, and compares.
  ///
  /// When a duplicate is found, the existing record's
  /// [BookmarkItem.duplicateGroupId] is reused if present; otherwise a
  /// deterministic group ID is computed from the canonical URL hash
  /// and returned in [DuplicateFound.duplicateGroupId].
  Future<DuplicateCheckResult> checkDuplicate({
    required String canonicalUrl,
    String? resolvedUrl,
    String? originalUrl,
    String? externalContentId,
  }) async {
    final String urlHash =
        _normalizationService.computeUrlHash(canonicalUrl);

    // ── 1. Exact URL hash match ──────────────────────────────────────
    final BookmarkItem? byHash =
        await _repository.getByUrlHash(urlHash);
    if (byHash != null) {
      final String? groupId = _resolveDuplicateGroupId(
        existing: byHash,
        candidateCanonicalUrl: canonicalUrl,
      );
      return DuplicateFound(
        matchType: DuplicateMatchType.urlHash,
        existing: byHash,
        duplicateGroupId: groupId,
      );
    }

    // ── 2. External content ID match ─────────────────────────────────
    if (externalContentId != null && externalContentId.isNotEmpty) {
      final BookmarkItem? byContentId =
          await _repository.getByExternalContentId(externalContentId);
      if (byContentId != null) {
        final String? groupId = _resolveDuplicateGroupId(
          existing: byContentId,
          candidateCanonicalUrl: canonicalUrl,
        );
        return DuplicateFound(
          matchType: DuplicateMatchType.externalContentId,
          existing: byContentId,
          duplicateGroupId: groupId,
        );
      }
    }

    // ── 3. Canonical URL exact match ─────────────────────────────────
    final BookmarkItem? byCanonical =
        await _repository.getByCanonicalUrl(canonicalUrl);
    if (byCanonical != null) {
      final String? groupId = _resolveDuplicateGroupId(
        existing: byCanonical,
        candidateCanonicalUrl: canonicalUrl,
      );
      return DuplicateFound(
        matchType: DuplicateMatchType.canonicalUrl,
        existing: byCanonical,
        duplicateGroupId: groupId,
      );
    }

    // ── 4. Normalized URL comparison (fallback) ──────────────────────
    final String? candidateNormalized = _normalizeCandidateUrl(
      resolvedUrl: resolvedUrl,
      originalUrl: originalUrl,
      canonicalUrl: canonicalUrl,
    );
    if (candidateNormalized != null && candidateNormalized.isNotEmpty) {
      final List<BookmarkItem> all = await _repository.getAll();
      for (final BookmarkItem existing in all) {
        final String? existingNormalized = _normalizeExistingUrls(existing);
        if (existingNormalized != null &&
            existingNormalized == candidateNormalized) {
          final String? groupId = _resolveDuplicateGroupId(
            existing: existing,
            candidateCanonicalUrl: canonicalUrl,
          );
          return DuplicateFound(
            matchType: DuplicateMatchType.normalizedUrl,
            existing: existing,
            duplicateGroupId: groupId,
          );
        }
      }
    }

    return const NoDuplicate();
  }

  /// Normalizes the candidate URL for level-4 comparison.
  ///
  /// Priority: [resolvedUrl] → [originalUrl] → [canonicalUrl].
  String? _normalizeCandidateUrl({
    String? resolvedUrl,
    String? originalUrl,
    required String canonicalUrl,
  }) {
    String? raw;
    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      raw = resolvedUrl;
    } else if (originalUrl != null && originalUrl.isNotEmpty) {
      raw = originalUrl;
    } else {
      raw = canonicalUrl;
    }
    return _normalizationService.normalizeUrl(raw);
  }

  /// Normalizes all URL fields of an [existing] bookmark and returns
  /// the first non-null result, or `null` if none can be normalized.
  String? _normalizeExistingUrls(BookmarkItem existing) {
    for (final String? url in <String?>[
      existing.canonicalUrl,
      existing.resolvedUrl,
      existing.originalUrl,
    ]) {
      if (url != null && url.isNotEmpty) {
        final String? normalized = _normalizationService.normalizeUrl(url);
        if (normalized != null && normalized.isNotEmpty) {
          return normalized;
        }
      }
    }
    return null;
  }

  /// Resolves the duplicate group ID for a detected duplicate.
  ///
  /// Reuses [existing.duplicateGroupId] if present. Otherwise generates
  /// a deterministic hash from [existing.canonicalUrl] (falling back to
  /// [candidateCanonicalUrl] when the existing item lacks one).
  String? _resolveDuplicateGroupId({
    required BookmarkItem existing,
    required String candidateCanonicalUrl,
  }) {
    if (existing.duplicateGroupId != null &&
        existing.duplicateGroupId!.isNotEmpty) {
      return existing.duplicateGroupId;
    }

    final String sourceUrl =
        (existing.canonicalUrl != null && existing.canonicalUrl!.isNotEmpty)
            ? existing.canonicalUrl!
            : candidateCanonicalUrl;

    return _normalizationService.computeUrlHash(sourceUrl);
  }
}
