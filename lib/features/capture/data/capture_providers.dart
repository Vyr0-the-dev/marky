import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/core/scraping/scraping_providers.dart';
import 'package:marky/core/url/dio_redirect_resolver.dart';
import 'package:marky/core/url/redirect_resolver.dart';
import 'package:marky/features/automation/data/automation_rule_providers.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/capture/data/capture_service_impl.dart';
import 'package:marky/features/capture/data/default_scraping_orchestrator.dart';
import 'package:marky/features/capture/data/default_upsert_merge_service.dart';
import 'package:marky/features/capture/data/isar_duplicate_detector.dart';
import 'package:marky/features/capture/domain/capture_service.dart';
import 'package:marky/features/capture/domain/duplicate_detector.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';
import 'package:marky/features/capture/domain/upsert_merge_service.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/data/unread_reminder_refreshing_capture_service.dart';
import 'package:marky/features/widgets/data/widget_providers.dart';
import 'package:marky/features/widgets/data/widget_refreshing_capture_service.dart';

/// Provides the [DuplicateDetector] backed by the bookmark repository.
final Provider<DuplicateDetector> duplicateDetectorProvider =
    Provider<DuplicateDetector>((Ref ref) {
  return IsarDuplicateDetector(ref.watch(bookmarkRepositoryProvider));
});

/// Provides the [RedirectResolver]. Defaults to [DioRedirectResolver] in
/// production. Tests can override with [NoOpRedirectResolver].
final Provider<RedirectResolver> redirectResolverProvider =
    Provider<RedirectResolver>((Ref ref) {
  return DioRedirectResolver();
});

/// Provides the [UpsertMergeService] for merging metadata on
/// duplicate captures.
final Provider<UpsertMergeService> upsertMergeServiceProvider =
    Provider<UpsertMergeService>((Ref ref) {
  return const DefaultUpsertMergeService();
});

/// Provides the [ScrapingOrchestrator] that runs after capture to
/// enrich the new bookmark with scraped metadata.
final Provider<ScrapingOrchestrator> scrapingOrchestratorProvider =
    Provider<ScrapingOrchestrator>((Ref ref) {
  return DefaultScrapingOrchestrator(
    bookmarkRepo: ref.watch(bookmarkRepositoryProvider),
    scraper: ref.watch(metadataScraperServiceProvider),
    merger: ref.watch(upsertMergeServiceProvider),
  );
});

/// Provides the [CaptureService] — the single entry-point for
/// saving a new URL from any capture surface (manual add, share
/// intent, clipboard monitor).
///
/// Feature code should call `ref.read(captureServiceProvider).capture(url)`
/// — never construct the service directly.
final Provider<CaptureService> captureServiceProvider =
    Provider<CaptureService>((Ref ref) {
  final CaptureService captureService = CaptureServiceImpl(
    bookmarkRepo: ref.watch(bookmarkRepositoryProvider),
    duplicateDetector: ref.watch(duplicateDetectorProvider),
    redirectResolver: ref.watch(redirectResolverProvider),
    scrapingOrchestrator: ref.watch(scrapingOrchestratorProvider),
    automationEngine: ref.watch(automationEngineProvider),
  );
  final CaptureService widgetRefreshingService = WidgetRefreshingCaptureService(
    delegate: captureService,
    snapshotService: () => ref.read(widgetFeedSnapshotServiceProvider.future),
  );
  return UnreadReminderRefreshingCaptureService(
    delegate: widgetRefreshingService,
    settings: () => ref.read(appSettingsProvider),
    scheduler: () => ref.read(unreadReminderSchedulerProvider),
  );
});
