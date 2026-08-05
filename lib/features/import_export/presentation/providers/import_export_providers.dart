import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/features/capture/presentation/providers/capture_providers.dart';
import 'package:marky/features/import_export/data/services/export_service.dart';
import 'package:marky/features/import_export/data/services/import_bookmarks_service.dart';
import 'package:marky/features/import_export/data/services/share_platform.dart';
import 'package:marky/features/import_export/domain/models/import_result.dart';
import 'package:marky/features/import_export/domain/use_cases/export_bookmarks_use_case.dart';
import 'package:marky/features/import_export/domain/use_cases/import_bookmarks_use_case.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:path_provider/path_provider.dart';

/// Provider that exposes the [ExportBookmarksUseCase] wired to all
/// repository providers.
final Provider<ExportBookmarksUseCase> exportUseCaseProvider =
    Provider<ExportBookmarksUseCase>((Ref ref) {
  return ExportBookmarksUseCase(
    bookmarkRepository: ref.watch(bookmarkRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    collectionRepository: ref.watch(collectionRepositoryProvider),
    noteRepository: ref.watch(noteRepositoryProvider),
    reminderRepository: ref.watch(reminderRepositoryProvider),
    settingsRepository: ref.watch(appSettingsRepositoryProvider),
  );
});

/// Provider that exposes the production [SharePlatform] implementation.
final Provider<SharePlatform> sharePlatformProvider =
    Provider<SharePlatform>((Ref ref) => const SharePlatformImpl());

/// Provider that exposes the [ExportService] wired to the share platform
/// and temp directory callback.
final Provider<ExportService> exportServiceProvider =
    Provider<ExportService>((Ref ref) {
  return ExportService(
    sharePlatform: ref.watch(sharePlatformProvider),
    getTempDirectory: () async => getTemporaryDirectory(),
  );
});

/// Notifier that orchestrates the export operation and exposes its state.
///
/// State transitions:
/// - `AsyncValue.loading()` while export is in progress.
/// - `AsyncValue.data(filePath)` on success (holds the generated file path).
/// - `AsyncValue.error(err, stack)` on failure.
class ExportNotifier extends StateNotifier<AsyncValue<String?>> {
  ExportNotifier({
    required ExportBookmarksUseCase exportUseCase,
    required ExportService exportService,
  })  : _exportUseCase = exportUseCase,
        _exportService = exportService,
        super(const AsyncValue.data(null));

  final ExportBookmarksUseCase _exportUseCase;
  final ExportService _exportService;

  /// Triggers the full export → JSON → share flow.
  ///
  /// On success the generated file path is emitted as `AsyncValue.data`.
  /// On failure the exception is emitted as `AsyncValue.error`.
  Future<void> export() async {
    state = const AsyncValue.loading();
    try {
      final exportData = await _exportUseCase.execute();
      final filePath = await _exportService.exportAndShare(exportData);
      state = AsyncValue.data(filePath);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  /// Resets the notifier to its idle state.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider that exposes the [ExportNotifier] state.
final StateNotifierProvider<ExportNotifier, AsyncValue<String?>>
    exportNotifierProvider =
    StateNotifierProvider<ExportNotifier, AsyncValue<String?>>(
  (Ref ref) => ExportNotifier(
    exportUseCase: ref.watch(exportUseCaseProvider),
    exportService: ref.watch(exportServiceProvider),
  ),
);

// ═══════════════════════════════════════════════════════════════════════════
// IMPORT
// ═══════════════════════════════════════════════════════════════════════════

/// Provider that exposes the [ImportBookmarksService] wired to all
/// repository providers.
final Provider<ImportBookmarksService> importServiceProvider =
    Provider<ImportBookmarksService>((Ref ref) {
  return ImportBookmarksService(
    saveBookmarkUseCase: ref.watch(saveBookmarkUseCaseProvider),
    collectionRepository: ref.watch(collectionRepositoryProvider),
  );
});

/// Provider that exposes the [ImportBookmarksUseCase] wired to the import
/// service.
final Provider<ImportBookmarksUseCase> importUseCaseProvider =
    Provider<ImportBookmarksUseCase>((Ref ref) {
  return ImportBookmarksUseCase(
    service: ref.watch(importServiceProvider),
  );
});

/// Notifier that orchestrates the import operation and exposes its state.
///
/// State transitions:
/// - `AsyncValue.data(null)` when idle.
/// - `AsyncValue.loading()` while import is in progress.
/// - `AsyncValue.data(ImportResult)` on success.
/// - `AsyncValue.error(err, stack)` on failure.
class ImportNotifier extends StateNotifier<AsyncValue<ImportResult?>> {
  ImportNotifier({
    required ImportBookmarksUseCase importUseCase,
  })  : _importUseCase = importUseCase,
        super(const AsyncValue.data(null));

  final ImportBookmarksUseCase _importUseCase;

  /// Triggers the full file-pick → read → import flow.
  ///
  /// On success the [ImportResult] is emitted as `AsyncValue.data`.
  /// On failure the exception is emitted as `AsyncValue.error`.
  /// If the user cancels the file picker, the state remains idle.
  Future<void> importFromFile() async {
    if (state.isLoading) return;

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['html', 'htm'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      // User cancelled — remain idle.
      return;
    }

    final PlatformFile file = result.files.first;
    final Uint8List? bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      state = AsyncValue.error(
        Exception('Cannot read file: ${file.name}'),
        StackTrace.current,
      );
      return;
    }

    final String htmlContent = String.fromCharCodes(bytes);

    state = const AsyncValue.loading();
    try {
      final ImportResult importResult = await _importUseCase.execute(
        htmlContent: htmlContent,
        importSource: 'browser_bookmarks',
      );
      state = AsyncValue.data(importResult);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  /// Resets the notifier to its idle state.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider that exposes the [ImportNotifier] state.
final StateNotifierProvider<ImportNotifier, AsyncValue<ImportResult?>>
    importNotifierProvider =
    StateNotifierProvider<ImportNotifier, AsyncValue<ImportResult?>>(
  (Ref ref) => ImportNotifier(
    importUseCase: ref.watch(importUseCaseProvider),
  ),
);
