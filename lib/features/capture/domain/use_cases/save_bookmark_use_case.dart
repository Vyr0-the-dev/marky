import 'dart:async';

import 'package:marky/core/ai/domain/services/ai_enrichment_service.dart';
import 'package:marky/core/scraping/metadata_scraper_service.dart';
import 'package:marky/features/automation/domain/services/automation_engine_service.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/models/duplicate_check_result.dart';
import 'package:marky/features/capture/domain/models/save_bookmark_params.dart';
import 'package:marky/features/capture/domain/services/canonical_extractors/canonical_extraction_result.dart';
import 'package:marky/features/capture/domain/services/canonical_url_service.dart';
import 'package:marky/features/capture/domain/services/duplicate_detection_service.dart';
import 'package:marky/features/capture/domain/services/redirect_resolver_service.dart';
import 'package:marky/features/capture/domain/services/upsert_merge_service.dart';
import 'package:marky/features/capture/domain/services/url_normalization_service.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Result of attempting to save a bookmark.
sealed class SaveResult {
  const SaveResult();
}

/// Bookmark was saved successfully.
final class SaveSuccess extends SaveResult {
  const SaveSuccess(this.bookmarkId);

  final int bookmarkId;
}

/// A bookmark with the same canonical URL already exists.
final class SaveDuplicate extends SaveResult {
  const SaveDuplicate(this.existing);

  final BookmarkItem existing;
}

/// The provided URL is invalid or empty.
final class SaveInvalid extends SaveResult {
  const SaveInvalid(this.reason);

  final String reason;
}

/// Use case for saving a bookmark from a raw URL string.
///
/// Encapsulates normalization, redirect resolution, canonical extraction,
/// duplicate detection, and persistence.
class SaveBookmarkUseCase {
  SaveBookmarkUseCase({
    required BookmarkItemRepository repository,
    UrlNormalizationService? normalizationService,
    RedirectResolverService? redirectResolverService,
    CanonicalUrlService? canonicalUrlService,
    DuplicateDetectionService? duplicateDetectionService,
    UpsertMergeService? upsertMergeService,
    MetadataScraperService? metadataScraperService,
    AutomationEngineService? automationEngineService,
    AiEnrichmentService? aiEnrichmentService,
  })  : _repository = repository,
        _normalizationService =
            normalizationService ?? UrlNormalizationService.instance,
        _redirectResolverService = redirectResolverService,
        _canonicalUrlService = canonicalUrlService,
        _duplicateDetectionService = duplicateDetectionService,
        _upsertMergeService =
            upsertMergeService ?? UpsertMergeService.instance,
        _metadataScraperService = metadataScraperService,
        _automationEngineService = automationEngineService,
        _aiEnrichmentService = aiEnrichmentService;

  final BookmarkItemRepository _repository;
  final UrlNormalizationService _normalizationService;
  final RedirectResolverService? _redirectResolverService;
  final CanonicalUrlService? _canonicalUrlService;
  final DuplicateDetectionService? _duplicateDetectionService;
  final UpsertMergeService? _upsertMergeService;
  final MetadataScraperService? _metadataScraperService;
  final AutomationEngineService? _automationEngineService;
  final AiEnrichmentService? _aiEnrichmentService;

  DuplicateDetectionService get _effectiveDuplicateDetectionService {
    return _duplicateDetectionService ?? DuplicateDetectionService.instance;
  }

  /// Attempts to save a bookmark from [rawUrl].
  ///
  /// Optional [params] carry metadata (tags, collections, shared text) that
  /// will be merged into an existing bookmark when a duplicate is detected.
  ///
  /// Flow:
  /// 1. Normalize the URL.
  /// 2. Resolve redirects (if resolver is available).
  /// 3. Extract canonical URL and external content ID (if service is available).
  /// 4. Check for duplicates via DuplicateDetectionService cascade.
  /// 5. If duplicate → merge [params] into existing record, persist, and
  ///    return [SaveDuplicate] with the freshly merged record.
  /// 6. If invalid → [SaveInvalid].
  /// 7. Create [BookmarkItem] and insert → [SaveSuccess].
  Future<SaveResult> execute(String rawUrl, {SaveBookmarkParams? params}) async {
    final String? normalizedUrl = _normalizationService.normalizeUrl(rawUrl);

    if (normalizedUrl == null || normalizedUrl.isEmpty) {
      return const SaveInvalid('URL is empty or malformed');
    }

    // Resolve redirects when a resolver is injected.
    final String? resolvedUrl =
        await _redirectResolverService?.resolve(normalizedUrl);

    final String urlForExtraction = resolvedUrl ?? normalizedUrl;

    // Extract canonical URL and external content ID.
    final CanonicalExtractionResult? extractionResult =
        await _canonicalUrlService?.extract(urlForExtraction);

    final String canonicalUrl =
        extractionResult?.canonicalUrl ?? normalizedUrl;
    final String? externalContentId = extractionResult?.externalContentId;

    final String urlHash =
        _normalizationService.computeUrlHash(canonicalUrl);

    // Multi-level duplicate detection via service.
    final DuplicateCheckResult duplicateResult =
        await _effectiveDuplicateDetectionService.checkDuplicate(
      canonicalUrl: canonicalUrl,
      resolvedUrl: resolvedUrl,
      originalUrl: rawUrl.trim(),
      externalContentId: externalContentId,
    );

    if (duplicateResult is DuplicateFound) {
      final BookmarkItem existing = duplicateResult.existing;
      final String? groupId = duplicateResult.duplicateGroupId;

      // Assign group ID to existing item if it doesn't have one yet.
      if (groupId != null &&
          (existing.duplicateGroupId == null ||
              existing.duplicateGroupId!.isEmpty)) {
        existing.duplicateGroupId = groupId;
      }

      // Merge incoming params into the existing record.
      final SaveBookmarkParams incomingParams =
          params ?? const SaveBookmarkParams();
      _upsertMergeService?.merge(existing, incomingParams);

      // Persist all mutations (group ID + merged metadata + timestamps).
      await _repository.update(existing);

      unawaited(
        _automationEngineService?.evaluateAndExecute(existing) ??
            Future<void>.value(),
      );

      unawaited(
        _aiEnrichmentService?.enrich(existing.id) ?? Future<void>.value(),
      );

      return SaveDuplicate(existing);
    }

    // Only store resolvedUrl when it differs from the canonical URL.
    final String? storedResolvedUrl =
        (resolvedUrl != null && resolvedUrl != canonicalUrl)
            ? resolvedUrl
            : null;

    final DateTime now = DateTime.now();

    final BookmarkItem bookmark = BookmarkItem(
      originalUrl: rawUrl.trim(),
      canonicalUrl: canonicalUrl,
      resolvedUrl: storedResolvedUrl,
      urlHash: urlHash,
      externalContentId: externalContentId,
      normalizedHost: _extractHost(canonicalUrl),
      sourceType: params?.sourceType ?? 'manual',
      importSource: params?.importSource,
      tagIds: params?.tagIds,
      collectionIds: params?.collectionIds,
      sharedText: params?.sharedText,
      createdAt: now,
      updatedAt: now,
    );

    final int bookmarkId = await _repository.insert(bookmark);

    unawaited(
      _metadataScraperService?.scrapeAndUpdate(bookmarkId, canonicalUrl) ??
          Future<void>.value(),
    );

    final BookmarkItem? saved = await _repository.getById(bookmarkId);
    if (saved != null) {
      unawaited(
        _automationEngineService?.evaluateAndExecute(saved) ??
            Future<void>.value(),
      );

      unawaited(
        _aiEnrichmentService?.enrich(saved.id) ?? Future<void>.value(),
      );
    }

    return SaveSuccess(bookmarkId);
  }

  String? _extractHost(String canonicalUrl) {
    final Uri? uri = Uri.tryParse(canonicalUrl);
    return uri?.host.toLowerCase();
  }
}
