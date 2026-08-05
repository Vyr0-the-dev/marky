import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/core/search/query_parser.dart';
import 'package:marky/features/search/domain/use_cases/search_bookmarks_use_case.dart';
import 'package:marky/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/shared/models/app_settings.dart';
import 'package:marky/shared/models/bookmark_item.dart';

// ─── Search query notifier ─────────────────────────────────────────────

/// Notifier that holds the current parsed [SearchQuery] and debounces
/// raw input so Isar is not hammered on every keystroke.
class SearchQueryNotifier extends StateNotifier<SearchQuery> {
  SearchQueryNotifier() : super(const SearchQuery());

  Timer? _debounceTimer;

  /// Updates the raw query after a [debounceMs] delay.
  ///
  /// If called again before the timer fires, the previous timer is cancelled
  /// and the countdown restarts.
  void setQuery(String raw, {int debounceMs = 300}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: debounceMs), () {
      state = QueryParser.parse(raw);
    });
  }

  /// Cancels any pending debounce timer.
  void cancelDebounce() {
    _debounceTimer?.cancel();
  }

  /// Toggles an operator key/value pair in the current query.
  ///
  /// If the pair already exists it is removed; otherwise it is added.
  void toggleOperator(String key, String value) {
    final normalizedKey = key.toLowerCase();
    final currentOperators = Map<String, List<String>>.from(state.operators);
    final values = List<String>.from(currentOperators[normalizedKey] ?? <String>[]);

    if (values.contains(value)) {
      values.remove(value);
      if (values.isEmpty) {
        currentOperators.remove(normalizedKey);
      } else {
        currentOperators[normalizedKey] = values;
      }
    } else {
      currentOperators[normalizedKey] = <String>[...values, value];
    }

    state = state.copyWith(operators: currentOperators);
  }

  /// Replaces the free-text tokens while preserving operators.
  void setFreeText(List<String> freeText) {
    state = state.copyWith(freeText: freeText);
  }

  /// Replaces the entire operators map while preserving free text.
  void setOperators(Map<String, List<String>> operators) {
    state = state.copyWith(operators: operators);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider that exposes the parsed [SearchQuery] with debounced updates.
final StateNotifierProvider<SearchQueryNotifier, SearchQuery>
    searchQueryProvider =
    StateNotifierProvider<SearchQueryNotifier, SearchQuery>((Ref ref) {
  return SearchQueryNotifier();
});

// ─── Search results provider ───────────────────────────────────────────

/// Provider that executes the search for a given [SearchQuery].
///
/// Uses [FutureProvider.family] so each distinct query gets its own
/// async lifecycle and auto-disposes when the query changes.
final FutureProviderFamily<List<BookmarkItem>, SearchQuery>
    searchResultsProvider =
    FutureProvider.family<List<BookmarkItem>, SearchQuery>(
        (Ref ref, SearchQuery query) async {
  final SearchBookmarksUseCase useCase = ref.watch(searchBookmarksUseCaseProvider);
  return useCase.execute(query);
});

// ─── Recent searches notifier ──────────────────────────────────────────

/// Notifier that manages the list of recent search queries.
///
/// Loads persisted queries from [AppSettingsRepository] on construction,
/// dedupes new entries, caps at [maxCount], and persists back to the
/// repository on every mutation.
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier({required AppSettingsRepository repository})
      : _repository = repository,
        super(const <String>[]) {
    unawaited(_load());
  }

  final AppSettingsRepository _repository;
  static const int maxCount = 20;

  Future<void> _load() async {
    try {
      final settings = await _repository.getSettings();
      final List<String>? stored = settings?.recentSearches;
      if (stored != null && stored.isNotEmpty) {
        state = List<String>.unmodifiable(stored);
      }
    } on Object {
      // Silently skip persistence failures per Q5.
    }
  }

  /// Adds [rawQuery] to the front of the list, deduping and capping.
  void addQuery(String rawQuery) {
    final trimmed = rawQuery.trim();
    if (trimmed.isEmpty) return;

    final updated = <String>[
      trimmed,
      ...state.where((q) => q != trimmed),
    ].take(maxCount).toList();

    state = List<String>.unmodifiable(updated);
    unawaited(_persist());
  }

  /// Clears all recent searches.
  void clear() {
    state = const <String>[];
    unawaited(_persist());
  }

  Future<void> _persist() async {
    try {
      final settings = await _repository.getSettings() ??
          AppSettings(themeMode: 'dark');
      await _repository.saveSettings(
        settings.copyWith(recentSearches: List<String>.from(state)),
      );
    } on Object {
      // Silently skip persistence failures per Q5.
    }
  }
}

/// Provider that exposes the recent searches list.
final StateNotifierProvider<RecentSearchesNotifier, List<String>>
    recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((Ref ref) {
  final AppSettingsRepository repository = ref.watch(appSettingsRepositoryProvider);
  return RecentSearchesNotifier(repository: repository);
});
