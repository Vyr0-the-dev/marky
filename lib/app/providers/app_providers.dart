import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';

import 'package:marky/app/routing/app_router.dart';
import 'package:marky/core/ai/domain/services/semantic_search_service.dart';
import 'package:marky/core/database/isar_service.dart';
import 'package:marky/core/notifications/notification_service.dart';
import 'package:marky/features/ai/presentation/providers/embedding_providers.dart';
import 'package:marky/features/automation/data/repositories/automation_rule_repository_impl.dart';
import 'package:marky/features/automation/domain/repositories/automation_rule_repository.dart';
import 'package:marky/features/bookmarks/data/repositories/bookmark_item_repository_impl.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/features/collections/data/repositories/collection_repository_impl.dart';
import 'package:marky/features/collections/domain/repositories/collection_repository.dart';
import 'package:marky/features/notes/data/repositories/note_repository_impl.dart';
import 'package:marky/features/notes/domain/repositories/note_repository.dart';
import 'package:marky/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:marky/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:marky/features/search/domain/use_cases/search_bookmarks_use_case.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/features/tags/data/repositories/tag_repository_impl.dart';
import 'package:marky/features/tags/domain/repositories/tag_repository.dart';
import 'package:marky/features/vault/domain/use_cases/move_bookmark_to_vault_use_case.dart';
import 'package:marky/features/vault/domain/use_cases/remove_bookmark_from_vault_use_case.dart';
import 'package:marky/shared/models/app_settings.dart';

/// Injects the [GoRouter] instance so it is testable and overridable.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>(
  (Ref<GoRouter> ref) => AppRouter.createRouter(),
);

/// Global provider for runtime app-settings state.
///
/// Depends on [appSettingsRepositoryProvider] from
/// `app_settings_provider.dart`.
final StateNotifierProvider<AppSettingsNotifier, AppSettings>
    appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (Ref ref) => AppSettingsNotifier(
    repository: ref.watch(appSettingsRepositoryProvider),
  ),
);

/// Provider that exposes the live [TagRepository].
///
/// Throws [StateError] if the database has not been opened yet.
final Provider<TagRepository> tagRepositoryProvider =
    Provider<TagRepository>((Ref ref) {
  final Isar? isar = IsarService.instance.isar;
  if (isar == null) {
    throw StateError(
      'Isar database not initialized. '
      'Ensure IsarService.instance.open() is called during app bootstrap.',
    );
  }
  return TagRepositoryImpl(isar: isar);
});

/// Provider that exposes the live [CollectionRepository].
///
/// Throws [StateError] if the database has not been opened yet.
final Provider<CollectionRepository> collectionRepositoryProvider =
    Provider<CollectionRepository>((Ref ref) {
  final Isar? isar = IsarService.instance.isar;
  if (isar == null) {
    throw StateError(
      'Isar database not initialized. '
      'Ensure IsarService.instance.open() is called during app bootstrap.',
    );
  }
  return CollectionRepositoryImpl(isar: isar);
});

/// Provider that exposes the live [NoteRepository].
///
/// Throws [StateError] if the database has not been opened yet.
final Provider<NoteRepository> noteRepositoryProvider =
    Provider<NoteRepository>((Ref ref) {
  final Isar? isar = IsarService.instance.isar;
  if (isar == null) {
    throw StateError(
      'Isar database not initialized. '
      'Ensure IsarService.instance.open() is called during app bootstrap.',
    );
  }
  return NoteRepositoryImpl(isar: isar);
});

/// Provider that exposes the live [BookmarkItemRepository].
///
/// Throws [StateError] if the database has not been opened yet.
final Provider<BookmarkItemRepository> bookmarkRepositoryProvider =
    Provider<BookmarkItemRepository>((Ref ref) {
  final Isar? isar = IsarService.instance.isar;
  if (isar == null) {
    throw StateError(
      'Isar database not initialized. '
      'Ensure IsarService.instance.open() is called during app bootstrap.',
    );
  }
  final TagRepository tagRepository = ref.watch(tagRepositoryProvider);
  final CollectionRepository collectionRepository = ref.watch(collectionRepositoryProvider);
  return BookmarkItemRepositoryImpl(
    isar: isar,
    tagRepository: tagRepository,
    collectionRepository: collectionRepository,
  );
});

/// Provider for [SearchBookmarksUseCase], wired to the live repository
/// and optionally to the semantic search service.
final Provider<SearchBookmarksUseCase> searchBookmarksUseCaseProvider =
    Provider<SearchBookmarksUseCase>((Ref ref) {
  final BookmarkItemRepository repository = ref.watch(bookmarkRepositoryProvider);
  return SearchBookmarksUseCase(
    repository: repository,
    semanticSearchService: ref.watch(semanticSearchServiceProvider),
  );
});

// ─── Embedding / semantic-search providers ─────────────────────────────

/// Provider for [SemanticSearchService], wired to live repositories.
///
/// Uses [NaiveSemanticSearchService] with keyword overlap as the
/// similarity signal until embedding vectors are populated by the
/// capture pipeline.
final Provider<SemanticSearchService> semanticSearchServiceProvider =
    Provider<SemanticSearchService>((Ref ref) {
  return NaiveSemanticSearchService(
    repository: ref.watch(bookmarkRepositoryProvider),
    similarityService: ref.watch(embeddingSimilarityServiceProvider),
  );
});

/// Provider that exposes the live [AutomationRuleRepository].
///
/// Throws [StateError] if the database has not been opened yet.
final Provider<AutomationRuleRepository> automationRuleRepositoryProvider =
    Provider<AutomationRuleRepository>((Ref ref) {
  final Isar? isar = IsarService.instance.isar;
  if (isar == null) {
    throw StateError(
      'Isar database not initialized. '
      'Ensure IsarService.instance.open() is called during app bootstrap.',
    );
  }
  return AutomationRuleRepositoryImpl(isar: isar);
});

/// Provider that exposes the live [ReminderRepository].
///
/// Throws [StateError] if the database has not been opened yet.
final Provider<ReminderRepository> reminderRepositoryProvider =
    Provider<ReminderRepository>((Ref ref) {
  final Isar? isar = IsarService.instance.isar;
  if (isar == null) {
    throw StateError(
      'Isar database not initialized. '
      'Ensure IsarService.instance.open() is called during app bootstrap.',
    );
  }
  return ReminderRepositoryImpl(isar: isar);
});

/// Provider that exposes the singleton [NotificationService].
final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((Ref ref) {
  return NotificationServiceImpl.instance;
});

/// Provider for [MoveBookmarkToVaultUseCase], wired to the live repository.
final Provider<MoveBookmarkToVaultUseCase> moveBookmarkToVaultUseCaseProvider =
    Provider<MoveBookmarkToVaultUseCase>((Ref ref) {
  final BookmarkItemRepository repository = ref.watch(bookmarkRepositoryProvider);
  return MoveBookmarkToVaultUseCase(repository: repository);
});

/// Provider for [RemoveBookmarkFromVaultUseCase], wired to the live repository.
final Provider<RemoveBookmarkFromVaultUseCase> removeBookmarkFromVaultUseCaseProvider =
    Provider<RemoveBookmarkFromVaultUseCase>((Ref ref) {
  final BookmarkItemRepository repository = ref.watch(bookmarkRepositoryProvider);
  return RemoveBookmarkFromVaultUseCase(repository: repository);
});

/// Derived provider that exposes only the current [ThemeMode] enum.
///
/// Widgets that only need theme information (e.g. [MaterialApp]) can watch
/// this instead of the full [AppSettings] object, avoiding rebuilds when
/// unrelated settings change.
final Provider<ThemeMode> themeProvider = Provider<ThemeMode>(
  (Ref ref) => AppSettingsNotifier.themeModeFromString(
    ref.watch(appSettingsProvider.select((AppSettings s) => s.themeMode)),
  ),
);
