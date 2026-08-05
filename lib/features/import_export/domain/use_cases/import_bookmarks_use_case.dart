import 'package:marky/features/import_export/data/services/import_bookmarks_service.dart'
    show ImportBookmarksService;
import 'package:marky/features/import_export/domain/models/import_result.dart'
    show ImportResult;

/// Thin domain wrapper around [ImportBookmarksService].
///
/// Delegates all work to the service and simply forwards parameters.
/// This use case exists so that the presentation layer depends on a
/// domain abstraction rather than a data service directly.
class ImportBookmarksUseCase {
  ImportBookmarksUseCase({
    required ImportBookmarksService service,
  }) : _service = service;

  final ImportBookmarksService _service;

  /// Imports bookmarks from browser-export HTML.
  ///
  /// See [ImportBookmarksService.importFromHtml] for details.
  Future<ImportResult> execute({
    required String htmlContent,
    required String importSource,
    void Function(int current, int total)? onProgress,
  }) {
    return _service.importFromHtml(
      htmlContent: htmlContent,
      importSource: importSource,
      onProgress: onProgress,
    );
  }
}
