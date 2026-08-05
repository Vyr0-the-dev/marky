import 'package:logger/logger.dart';
import 'package:marky/core/ai/domain/models/keyword_extraction_result.dart';
import 'package:marky/core/ai/domain/services/keyword_extraction_service.dart';
import 'package:marky/core/ai/domain/services/smart_tag_engine_service.dart';
import 'package:marky/core/ai/domain/services/summary_generation_service.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/shared/models/app_settings.dart';

/// Contract for the AI enrichment orchestrator.
///
/// Implementations combine keyword extraction and smart-tag evaluation
/// into a single [enrich] call, gated by the user's [AppSettings.aiEnabled]
/// preference.  All errors are caught and logged so enrichment never
/// crashes the caller.
// ignore: one_member_abstracts
abstract class AiEnrichmentService {
  /// Enriches the bookmark identified by [bookmarkId] with AI-generated
  /// keywords, category, and smart-tag assignments.
  ///
  /// Returns immediately when AI is disabled or the bookmark cannot be
  /// found.  Any exception during enrichment is logged and swallowed.
  Future<void> enrich(int bookmarkId);
}

/// Default implementation of [AiEnrichmentService].
///
/// Orchestration order is intentional:
/// 1. Keyword extraction (synchronous, deterministic).
/// 2. Persist keyword results so smart-tag rules can reference them.
/// 3. Summary generation (synchronous, only when aiSummary is empty).
/// 4. Persist summary if generated.
/// 5. Smart-tag evaluation (asynchronous, may touch DB).
class AiEnrichmentServiceImpl implements AiEnrichmentService {
  AiEnrichmentServiceImpl({
    required AppSettingsRepository appSettingsRepository,
    required BookmarkItemRepository bookmarkRepository,
    required KeywordExtractionService keywordExtractionService,
    required SmartTagEngineService smartTagEngineService,
    SummaryGenerationService? summaryGenerationService,
    Logger? logger,
  })  : _appSettingsRepository = appSettingsRepository,
        _bookmarkRepository = bookmarkRepository,
        _keywordExtractionService = keywordExtractionService,
        _smartTagEngineService = smartTagEngineService,
        _summaryGenerationService = summaryGenerationService,
        _logger = logger ?? Logger();

  final AppSettingsRepository _appSettingsRepository;
  final BookmarkItemRepository _bookmarkRepository;
  final KeywordExtractionService _keywordExtractionService;
  final SmartTagEngineService _smartTagEngineService;
  final SummaryGenerationService? _summaryGenerationService;
  final Logger _logger;

  @override
  Future<void> enrich(int bookmarkId) async {
    try {
      _logger.i('AiEnrichment: starting enrichment for bookmark $bookmarkId');

      // ── 1. Settings gate ─────────────────────────────────────────────
      final settings = await _appSettingsRepository.getSettings();
      if (settings?.aiEnabled != true) {
        _logger.d(
          'AiEnrichment: AI disabled — skipping bookmark $bookmarkId',
        );
        return;
      }

      // ── 2. Load bookmark ─────────────────────────────────────────────
      final bookmark = await _bookmarkRepository.getById(bookmarkId);
      if (bookmark == null) {
        _logger.w(
          'AiEnrichment: bookmark $bookmarkId not found — skipping',
        );
        return;
      }

      // ── 3. Keyword extraction (local error handling) ─────────────────
      KeywordExtractionResult? extractionResult;
      try {
        extractionResult = _keywordExtractionService.extract(bookmark);
      } catch (e, stack) {
        _logger.w(
          'AiEnrichment: keyword extraction failed for bookmark '
          '$bookmarkId: $e',
          error: e,
          stackTrace: stack,
        );
      }

      if (extractionResult != null) {
        bookmark
          ..aiKeywords = extractionResult.keywords
          ..aiCategory = extractionResult.category
          ..updatedAt = DateTime.now();

        // ── 4. Persist so smart tags can see AI fields ─────────────────
        await _bookmarkRepository.update(bookmark);
        _logger.d(
          'AiEnrichment: bookmark $bookmarkId updated with '
          '${extractionResult.keywords.length} keywords, '
          'category=${extractionResult.category}',
        );
      }

      // ── 5. Summary generation (local error handling) ────────────────
      if (_summaryGenerationService != null) {
        try {
          _logger.d(
            'AiEnrichment: summary stage starting for bookmark $bookmarkId',
          );
          final summary = _summaryGenerationService.generate(bookmark);
          if (summary != null &&
              (bookmark.aiSummary == null || bookmark.aiSummary!.isEmpty)) {
            bookmark
              ..aiSummary = summary
              ..updatedAt = DateTime.now();
            await _bookmarkRepository.update(bookmark);
            _logger.d(
              'AiEnrichment: bookmark $bookmarkId updated with summary',
            );
          } else {
            _logger.d(
              'AiEnrichment: bookmark $bookmarkId — summary skipped '
              '(already has summary or generation returned null)',
            );
          }
          _logger.d(
            'AiEnrichment: summary stage complete for bookmark $bookmarkId',
          );
        } catch (e, stack) {
          _logger.w(
            'AiEnrichment: summary generation failed for bookmark '
            '$bookmarkId: $e',
            error: e,
            stackTrace: stack,
          );
        }
      }

      // ── 6. Smart-tag evaluation (local error handling) ───────────────
      try {
        await _smartTagEngineService.evaluate(bookmark);
      } catch (e, stack) {
        _logger.w(
          'AiEnrichment: smart tag evaluation failed for bookmark '
          '$bookmarkId: $e',
          error: e,
          stackTrace: stack,
        );
      }

      _logger.i(
        'AiEnrichment: enrichment complete for bookmark $bookmarkId',
      );
    } catch (e, stack) {
      _logger.e(
        'AiEnrichment: unexpected error enriching bookmark $bookmarkId: $e',
        error: e,
        stackTrace: stack,
      );
      // Swallow — enrichment must never crash the caller.
    }
  }
}
