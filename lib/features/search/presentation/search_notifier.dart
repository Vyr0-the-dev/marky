import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/search/data/search_query_providers.dart';
import 'package:marky/features/search/domain/bookmark_search_service.dart';
import 'package:marky/features/search/domain/search_query_repository.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

/// Search state: query string + async results.
class SearchState {
  const SearchState({
    this.query = '',
    this.results = const <Bookmark>[],
    this.isLoading = false,
    this.hasSearched = false,
  });

  final String query;
  final List<Bookmark> results;
  final bool isLoading;
  final bool hasSearched;

  SearchState copyWith({
    String? query,
    List<Bookmark>? results,
    bool? isLoading,
    bool? hasSearched,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

/// Manages keyword search with debounce.
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._searchService, this._searchQueryRepository)
      : super(const SearchState());

  final BookmarkSearchService _searchService;
  final SearchQueryRepository? _searchQueryRepository;
  Timer? _debounce;

  void updateQuery(String query) {
    state = state.copyWith(query: query);
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(
        results: const <Bookmark>[],
        isLoading: false,
        hasSearched: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    _debounce = Timer(const Duration(milliseconds: 300), _executeSearch);
  }

  Future<void> _executeSearch() async {
    final String q = state.query;
    if (q.trim().isEmpty) return;

    try {
      final List<Bookmark> results = await _searchService.search(q);
      // Guard against stale results from an older query.
      if (state.query == q) {
        unawaited(_searchQueryRepository?.recordRecent(q));
        state = state.copyWith(
          results: results,
          isLoading: false,
          hasSearched: true,
        );
      }
    } catch (_) {
      if (state.query == q) {
        state = state.copyWith(isLoading: false, hasSearched: true);
      }
    }
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<SearchNotifier, SearchState>
    searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((Ref ref) {
  final BookmarkRepository repo = ref.watch(bookmarkRepositoryProvider);
  final TagRepository tagRepo = ref.watch(tagRepositoryProvider);
  final searchQueryRepo = ref.watch(searchQueryRepositoryProvider);
  return SearchNotifier(
      BookmarkSearchService(
        bookmarkRepository: repo,
        tagRepository: tagRepo,
      ),
      searchQueryRepo);
});
