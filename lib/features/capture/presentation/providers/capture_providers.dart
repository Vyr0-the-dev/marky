import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/scraping/metadata_scraper_service.dart';
import 'package:marky/features/ai/presentation/providers/ai_providers.dart';
import 'package:marky/features/automation/domain/services/automation_engine_service.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart';

// ─── Use-case provider ─────────────────────────────────────────────────

/// Provider for the [SaveBookmarkUseCase], wired to the live repository.
final Provider<SaveBookmarkUseCase> saveBookmarkUseCaseProvider =
    Provider<SaveBookmarkUseCase>((Ref ref) {
  final BookmarkItemRepository repository = ref.watch(bookmarkRepositoryProvider);
  final automationEngineService = AutomationEngineService(
    ruleRepository: ref.watch(automationRuleRepositoryProvider),
    bookmarkRepository: repository,
    tagRepository: ref.watch(tagRepositoryProvider),
    collectionRepository: ref.watch(collectionRepositoryProvider),
    reminderRepository: ref.watch(reminderRepositoryProvider),
  );
  return SaveBookmarkUseCase(
    repository: repository,
    metadataScraperService: MetadataScraperService.instanceOrNull,
    automationEngineService: automationEngineService,
    aiEnrichmentService: ref.watch(aiEnrichmentServiceProvider),
  );
});

// ─── Capture form state ────────────────────────────────────────────────

/// Immutable state of the capture form.
class CaptureFormState {
  const CaptureFormState({
    this.url = '',
    this.submission = const AsyncValue<SaveResult?>.data(null),
  });

  final String url;
  final AsyncValue<SaveResult?> submission;

  /// Returns a copy with selected fields replaced.
  CaptureFormState copyWith({
    String? url,
    AsyncValue<SaveResult?>? submission,
  }) {
    return CaptureFormState(
      url: url ?? this.url,
      submission: submission ?? this.submission,
    );
  }
}

// ─── Capture form notifier ─────────────────────────────────────────────

/// Notifier that drives the capture form UI state.
///
/// Holds the current URL input and the async submission state so widgets
/// can show loading / success / error / duplicate feedback.
class CaptureFormNotifier extends StateNotifier<CaptureFormState> {
  CaptureFormNotifier({required SaveBookmarkUseCase useCase})
      : _useCase = useCase,
        super(const CaptureFormState());

  final SaveBookmarkUseCase _useCase;

  /// Updates the URL input field.
  void setUrl(String url) {
    state = state.copyWith(url: url);
  }

  /// Attempts to save the current URL.
  ///
  /// Emits [AsyncValue.loading] while the use case runs, then
  /// [AsyncValue.data] with the [SaveResult] on completion.
  Future<void> save() async {
    if (state.url.trim().isEmpty) {
      state = state.copyWith(
        submission: const AsyncValue<SaveResult?>.data(
          SaveInvalid('URL is empty or malformed'),
        ),
      );
      return;
    }

    state = state.copyWith(submission: const AsyncValue<SaveResult?>.loading());

    try {
      final SaveResult result = await _useCase.execute(state.url.trim());
      state = state.copyWith(submission: AsyncValue<SaveResult?>.data(result));
    } on Object catch (e, stackTrace) {
      state = state.copyWith(
        submission: AsyncValue<SaveResult?>.error(e, stackTrace),
      );
    }
  }

  /// Resets the form to its initial state.
  void clear() {
    state = const CaptureFormState();
  }
}

// ─── Capture form provider ─────────────────────────────────────────────

/// Provider that exposes the capture form state and notifier.
final StateNotifierProvider<CaptureFormNotifier, CaptureFormState>
    captureFormProvider =
    StateNotifierProvider<CaptureFormNotifier, CaptureFormState>((Ref ref) {
  final SaveBookmarkUseCase useCase = ref.watch(saveBookmarkUseCaseProvider);
  return CaptureFormNotifier(useCase: useCase);
});
