import 'package:logger/logger.dart';
import 'package:marky/core/ai/domain/services/semantic_search_service.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/bookmarks/domain/repositories/bookmark_item_repository.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Use case for searching bookmarks with a parsed [SearchQuery].
///
/// Thin wrapper around [BookmarkItemRepository.search] that keeps the
/// domain layer explicit and testable. Optionally supports semantic
/// search via [SemanticSearchService] when available.
class SearchBookmarksUseCase {
  SearchBookmarksUseCase({
    required BookmarkItemRepository repository,
    SemanticSearchService? semanticSearchService,
  })  : _repository = repository,
        _semanticSearchService = semanticSearchService,
        _logger = Logger();

  final BookmarkItemRepository _repository;
  final SemanticSearchService? _semanticSearchService;
  final Logger _logger;

  /// Executes the search for [query].
  ///
  /// Returns an empty list when [query] is empty.
  ///
  /// Defaults to [limit] = 100 to keep all search paths bounded.
  Future<List<BookmarkItem>> execute(SearchQuery query, {int? limit = 100}) async {
    if (query.isEmpty) {
      return <BookmarkItem>[];
    }
    return _repository.search(query, limit: limit);
  }

  /// Executes a semantic search for the raw [query] string.
  ///
  /// Returns an empty list when [_semanticSearchService] is null
  /// (e.g. semantic search not yet enabled or provider not wired).
  Future<List<BookmarkItem>> executeSemantic(String query) async {
    final service = _semanticSearchService;
    if (service == null) {
      _logger.d(
        'SearchBookmarksUseCase.executeSemantic: '
        'semanticSearchService is null, returning empty list',
      );
      return <BookmarkItem>[];
    }

    _logger.d(
      'SearchBookmarksUseCase.executeSemantic: '
      'delegating to semantic search for query "$query"',
    );
    return service.semanticSearch(query);
  }
}
