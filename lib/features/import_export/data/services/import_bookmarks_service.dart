import 'dart:async';

import 'package:marky/features/capture/domain/models/save_bookmark_params.dart'
    show SaveBookmarkParams;
import 'package:marky/features/capture/domain/use_cases/save_bookmark_use_case.dart'
    show
        SaveBookmarkUseCase,
        SaveDuplicate,
        SaveInvalid,
        SaveResult,
        SaveSuccess;
import 'package:marky/features/collections/domain/repositories/collection_repository.dart'
    show CollectionRepository;
import 'package:marky/features/import_export/data/services/bookmark_html_parser.dart'
    show BookmarkHtmlParser;
import 'package:marky/features/import_export/domain/models/import_result.dart'
    show ImportResult;
import 'package:marky/features/import_export/domain/models/parsed_bookmark.dart'
    show ParsedBookmark;
import 'package:marky/shared/models/collection.dart' show BookmarkCollection;

/// Orchestrates importing browser bookmarks from Netscape Bookmark File
/// Format HTML into Marky.
///
/// Processes bookmarks sequentially (one Isar transaction per bookmark via
/// [SaveBookmarkUseCase]), maps top-level folders to collections, and
/// reports aggregated results.
class ImportBookmarksService {
  ImportBookmarksService({
    required SaveBookmarkUseCase saveBookmarkUseCase,
    required CollectionRepository collectionRepository,
    BookmarkHtmlParser? parser,
  })  : _saveBookmarkUseCase = saveBookmarkUseCase,
        _collectionRepository = collectionRepository,
        _parser = parser ?? const BookmarkHtmlParser();

  final SaveBookmarkUseCase _saveBookmarkUseCase;
  final CollectionRepository _collectionRepository;
  final BookmarkHtmlParser _parser;

  /// Imports bookmarks from [htmlContent].
  ///
  /// [importSource] is stored on each imported bookmark (e.g. 'chrome',
  /// 'firefox', 'safari') via [BookmarkItem.importSource].
  ///
  /// [onProgress] is called after each item with `(current, total)`.
  ///
  /// Bookmarks are processed sequentially with a yield between items
  /// (`await Future.delayed(Duration.zero)`) to keep the UI responsive.
  Future<ImportResult> importFromHtml({
    required String htmlContent,
    required String importSource,
    void Function(int current, int total)? onProgress,
  }) async {
    final DateTime start = DateTime.now();
    final List<ParsedBookmark> bookmarks = _parser.parse(htmlContent);

    if (bookmarks.isEmpty) {
      return ImportResult(
        totalFound: 0,
        imported: 0,
        duplicatesSkipped: 0,
        failed: 0,
        elapsed: DateTime.now().difference(start),
      );
    }

    int imported = 0;
    int duplicatesSkipped = 0;
    int failed = 0;
    final List<String> failureReasons = <String>[];

    // Cache collections by folder name to avoid repeated lookups.
    final Map<String, int> collectionCache = <String, int>{};

    for (int i = 0; i < bookmarks.length; i++) {
      final ParsedBookmark parsed = bookmarks[i];

      try {
        final int? collectionId = await _resolveCollectionId(
          parsed,
          collectionCache,
        );

        final SaveResult result = await _saveBookmarkUseCase.execute(
          parsed.url,
          params: SaveBookmarkParams(
            sourceType: 'import',
            importSource: importSource,
            collectionIds:
                collectionId != null ? <int>[collectionId] : null,
          ),
        );

        switch (result) {
          case SaveSuccess():
            imported++;
          case SaveDuplicate():
            duplicatesSkipped++;
          case SaveInvalid():
            failed++;
            failureReasons.add(
              'Invalid: ${parsed.url} — ${result.reason}',
            );
        }
      } on Object catch (e) {
        failed++;
        failureReasons.add(
          'Error: ${parsed.url} — $e',
        );
      }

      onProgress?.call(i + 1, bookmarks.length);

      // Yield control to avoid blocking the UI thread.
      await Future<void>.delayed(Duration.zero);
    }

    return ImportResult(
      totalFound: bookmarks.length,
      imported: imported,
      duplicatesSkipped: duplicatesSkipped,
      failed: failed,
      failureReasons: List<String>.unmodifiable(failureReasons),
      elapsed: DateTime.now().difference(start),
    );
  }

  /// Resolves a collection ID from the first folder in [parsed.folderPath].
  ///
  /// Returns `null` when the bookmark has no folder path.
  /// Uses [cache] to avoid redundant DB round-trips.
  Future<int?> _resolveCollectionId(
    ParsedBookmark parsed,
    Map<String, int> cache,
  ) async {
    if (parsed.folderPath.isEmpty) {
      return null;
    }

    final String folderName = parsed.folderPath.first;
    if (cache.containsKey(folderName)) {
      return cache[folderName];
    }

    final String slug = _toSlug(folderName);
    final BookmarkCollection? existing =
        await _collectionRepository.getBySlug(slug);

    if (existing != null) {
      cache[folderName] = existing.id;
      return existing.id;
    }

    // Create a new collection.
    final String uniqueSlug = await _generateUniqueSlug(slug);
    final DateTime now = DateTime.now();

    final BookmarkCollection collection = BookmarkCollection(
      title: folderName.trim().isEmpty ? 'Untitled' : folderName.trim(),
      slug: uniqueSlug,
      createdAt: now,
      updatedAt: now,
    );

    final int id = await _collectionRepository.insert(collection);
    cache[folderName] = id;
    return id;
  }

  /// Converts a name into a URL-safe slug.
  static String _toSlug(String name) {
    var normalized = name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp('-+'), '-');

    while (normalized.startsWith('-')) {
      normalized = normalized.substring(1);
    }
    while (normalized.endsWith('-')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    return normalized;
  }

  /// Ensures [baseSlug] is unique by appending `-1`, `-2`, etc.
  Future<String> _generateUniqueSlug(String baseSlug) async {
    var candidate = baseSlug.isEmpty ? 'collection' : baseSlug;
    int counter = 1;

    while (await _collectionRepository.getBySlug(candidate) != null) {
      candidate = '$baseSlug-$counter';
      counter++;
    }

    return candidate;
  }
}
