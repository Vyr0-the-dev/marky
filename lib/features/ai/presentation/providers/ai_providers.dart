import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/ai/domain/services/ai_enrichment_service.dart';
import 'package:marky/core/ai/domain/services/keyword_extraction_service.dart';
import 'package:marky/core/ai/domain/services/smart_tag_engine_service.dart';
import 'package:marky/core/ai/domain/services/summary_generation_service.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/features/tags/presentation/providers/tag_providers.dart';

// ─── Simple providers ──────────────────────────────────────────────────

/// Provider for [SmartTagEngineService], wired to live repositories.
final Provider<SmartTagEngineService> smartTagEngineServiceProvider =
    Provider<SmartTagEngineService>((Ref ref) {
  return SmartTagEngineServiceImpl(
    tagRepository: ref.watch(tagRepositoryProvider),
    assignTagsUseCase: ref.watch(assignTagsUseCaseProvider),
  );
});

/// Provider for [SummaryGenerationService].
final Provider<SummaryGenerationService> summaryGenerationServiceProvider =
    Provider<SummaryGenerationService>((Ref ref) {
  return HeuristicSummaryGenerationService();
});

/// Provider for [AiEnrichmentService], wired to live repositories and
/// local heuristic keyword extraction.
final Provider<AiEnrichmentService> aiEnrichmentServiceProvider =
    Provider<AiEnrichmentService>((Ref ref) {
  return AiEnrichmentServiceImpl(
    appSettingsRepository: ref.watch(appSettingsRepositoryProvider),
    bookmarkRepository: ref.watch(bookmarkRepositoryProvider),
    keywordExtractionService: HeuristicKeywordExtractionService(),
    smartTagEngineService: ref.watch(smartTagEngineServiceProvider),
    summaryGenerationService: ref.watch(summaryGenerationServiceProvider),
  );
});
