import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/core/search/models/search_query.dart';
import 'package:marky/features/search/presentation/providers/search_providers.dart';
import 'package:marky/features/search/presentation/widgets/filter_bottom_sheet.dart';
import 'package:marky/features/search/presentation/widgets/recent_searches_list.dart';
import 'package:marky/features/search/presentation/widgets/search_result_row.dart';
import 'package:marky/shared/models/bookmark_item.dart';

/// Production-quality search screen for Marky.
///
/// Features a hero search bar, debounced live results, filter chips,
/// a filter bottom sheet, and recent searches. Replaces the previous
/// placeholder implementation.
class SearchScreen extends ConsumerStatefulWidget {
  /// Creates a [SearchScreen].
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  /// Whether the search field currently has focus.
  bool _isFocused = false;

  /// Tracks the last query that was added to recent searches to avoid
  /// duplicates on rapid re-submissions.
  String _lastSavedQuery = '';

  static const List<_FilterChipDef> _chipDefs = <_FilterChipDef>[
    _FilterChipDef(label: 'Favorite', icon: Icons.star, key: 'is', value: 'favorite'),
    _FilterChipDef(label: 'Archived', icon: Icons.archive, key: 'is', value: 'archived'),
    _FilterChipDef(label: 'Unread', icon: Icons.mark_email_unread, key: 'is', value: 'unread'),
    _FilterChipDef(label: 'Has Note', icon: Icons.note, key: 'has', value: 'note'),
    _FilterChipDef(label: 'In Vault', icon: Icons.lock, key: 'in', value: 'vault'),
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Returns `true` if the given operator key/value is present in [query].
  bool _isChipActive(SearchQuery query, String key, String value) {
    return query.operatorValues(key).any(
      (String v) => v.toLowerCase() == value.toLowerCase(),
    );
  }

  void _onChipTapped(String key, String value) {
    ref.read(searchQueryProvider.notifier).toggleOperator(key, value);
    // Clear the text field so chips are the primary query mechanism
    // when tapped; free text remains if the user typed something.
  }

  void _onSearchSubmitted(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isNotEmpty && trimmed != _lastSavedQuery) {
      _lastSavedQuery = trimmed;
      ref.read(recentSearchesProvider.notifier).addQuery(trimmed);
    }
    _focusNode.unfocus();
  }

  void _onRecentSearchSelected(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    ref.read(searchQueryProvider.notifier).setQuery(query);
    _onSearchSubmitted(query);
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).setQuery('');
    _focusNode.requestFocus();
  }

  Future<void> _openFilterSheet() async {
    final SearchQuery currentQuery = ref.read(searchQueryProvider);
    final Map<String, List<String>>? result = await FilterBottomSheet.show(
      context,
      initialFilters: currentQuery.operators,
    );

    if (result != null && mounted) {
      ref.read(searchQueryProvider.notifier).setOperators(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SearchQuery query = ref.watch(searchQueryProvider);
    final AsyncValue<List<BookmarkItem>> results =
        ref.watch(searchResultsProvider(query));

    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── Hero search bar ───────────────────────────────────────
            Padding(
              padding: AppShapes.screenPaddingInsets,
              child: _SearchBar(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (String value) {
                  ref.read(searchQueryProvider.notifier).setQuery(value);
                },
                onSubmitted: _onSearchSubmitted,
                onClear: _clearSearch,
                onFilterTap: _openFilterSheet,
              ),
            ),

            // ── Filter chip bar ───────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: AppShapes.horizontalScreenPadding,
                itemCount: _chipDefs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final _FilterChipDef def = _chipDefs[index];
                  final bool isActive = _isChipActive(query, def.key, def.value);

                  return _FilterChip(
                    label: def.label,
                    icon: def.icon,
                    isActive: isActive,
                    onTap: () => _onChipTapped(def.key, def.value),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // ── Main content area ─────────────────────────────────────
            Expanded(
              child: _buildBody(query, results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SearchQuery query, AsyncValue<List<BookmarkItem>> results) {
    // Show recent searches when focused and query is empty.
    if (_isFocused && query.isEmpty) {
      return RecentSearchesList(
        onQuerySelected: _onRecentSearchSelected,
      );
    }

    return results.when(
      loading: () => const _LoadingState(),
      error: (Object error, StackTrace? stack) => _ErrorState(
        error: error,
        onRetry: () {
          // Force a refresh by re-setting the query.
          ref.read(searchQueryProvider.notifier).setQuery(
                _controller.text,
              );
        },
      ),
      data: (List<BookmarkItem> items) {
        if (items.isEmpty) {
          return _EmptyState(query: query);
        }
        return _ResultsList(
          items: items,
          onTapItem: (BookmarkItem item) {
            _onSearchSubmitted(_controller.text);
            context.push(Routes.bookmarkDetail.replaceFirst(':id', '${item.id}'));
          },
        );
      },
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────

/// The hero search bar at the top of the screen.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 12),
          const Icon(
            Icons.search,
            color: AppColors.textTertiary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search bookmarks...',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          // Clear button (visible when text is present)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (
              BuildContext context,
              TextEditingValue value,
              Widget? child,
            ) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear, size: 20),
                color: AppColors.textTertiary,
                onPressed: onClear,
                tooltip: 'Clear',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              );
            },
          ),
          // Filter button
          IconButton(
            icon: const Icon(Icons.tune, size: 20),
            color: AppColors.textTertiary,
            onPressed: onFilterTap,
            tooltip: 'Filters',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// A single filter chip in the horizontal chip bar.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.accentPrimary.withValues(alpha: 0.2) : AppColors.surface3,
      borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 14,
                color: isActive ? AppColors.accentPrimary : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.metadata.copyWith(
                  color: isActive ? AppColors.accentPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading state shown while search results are fetching.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}

/// Error state with a retry affordance.
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppShapes.screenPaddingInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTypography.sectionTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.metadata,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state shown when a search returns no results.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final SearchQuery query;

  @override
  Widget build(BuildContext context) {
    final bool hasFilters = query.operators.isNotEmpty;

    return Center(
      child: Padding(
        padding: AppShapes.screenPaddingInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.search_off,
              size: 56,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 20),
            Text(
              'No results found',
              style: AppTypography.sectionTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try removing some filters or changing your search terms'
                  : 'Try a different search term',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// List of search result rows.
class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.items,
    required this.onTapItem,
  });

  final List<BookmarkItem> items;
  final ValueChanged<BookmarkItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(
        color: AppColors.border,
        height: 1,
        indent: 68,
      ),
      itemBuilder: (BuildContext context, int index) {
        final BookmarkItem item = items[index];
        return SearchResultRow(
          bookmark: item,
          onTap: () => onTapItem(item),
        );
      },
    );
  }
}

// ─── Data helpers ──────────────────────────────────────────────────────

class _FilterChipDef {
  const _FilterChipDef({
    required this.label,
    required this.icon,
    required this.key,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String key;
  final String value;
}
