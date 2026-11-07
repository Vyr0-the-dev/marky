import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/home/presentation/widgets/bookmark_card.dart';
import 'package:marky/features/search/data/search_query_providers.dart';
import 'package:marky/features/search/domain/search_query.dart';
import 'package:marky/features/search/presentation/search_notifier.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/widgets/marky_loading_state.dart';

/// Instant keyword search screen.
///
/// The search field auto-focuses on mount. Results are fetched with a
/// 300ms debounce and ranked by relevance (title > host > other).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SearchState searchState = ref.watch(searchNotifierProvider);
    final AsyncValue<List<SearchQuery>> recentSearches =
        ref.watch(recentSearchQueriesProvider);
    final AsyncValue<List<SearchQuery>> savedSearches =
        ref.watch(savedSearchQueriesProvider);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final SearchQuery? savedQuery = savedSearches.maybeWhen(
      data: (List<SearchQuery> items) =>
          _savedQueryFor(items, searchState.query),
      orElse: () => null,
    );
    final bool isCurrentSearchSaved = savedQuery?.id != null;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n?.searchHint ?? 'Search bookmarks...',
            floatingLabelBehavior: FloatingLabelBehavior.never,
            hintText: l10n?.searchHint ?? 'Search bookmarks...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          style: theme.textTheme.bodyLarge,
          onChanged: (String value) =>
              ref.read(searchNotifierProvider.notifier).updateQuery(value),
        ),
        actions: <Widget>[
          if (searchState.query.trim().isNotEmpty) ...<Widget>[
            IconButton(
              icon: Icon(
                isCurrentSearchSaved
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
              ),
              onPressed: () => _toggleCurrentSearch(context, savedQuery),
              tooltip: isCurrentSearchSaved
                  ? l10n?.searchRemoveSavedTooltip ?? 'Remove saved search'
                  : l10n?.actionSave ?? 'Save',
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: l10n?.actionClear ?? 'Clear',
              onPressed: () {
                _controller.clear();
                ref.read(searchNotifierProvider.notifier).clear();
              },
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _SearchOperatorChipsBar(
                currentQuery: searchState.query,
                onToggleOperator: _toggleOperator,
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
      body: _buildBody(searchState, recentSearches, savedSearches),
    );
  }

  void _toggleOperator(String op) {
    final String current = _controller.text;
    final RegExp regex =
        RegExp(r'(^|\s)' + RegExp.escape(op) + r'($|\s)', caseSensitive: false);
    String updated;
    if (regex.hasMatch(current)) {
      updated =
          current.replaceAll(regex, ' ').trim().replaceAll(RegExp(r'\s+'), ' ');
    } else {
      final String trimmed = current.trim();
      updated = trimmed.isEmpty ? op : '$trimmed $op';
    }
    _controller.text = updated;
    _controller.selection = TextSelection.collapsed(offset: updated.length);
    ref.read(searchNotifierProvider.notifier).updateQuery(updated);
  }

  Widget _buildBody(
    SearchState state,
    AsyncValue<List<SearchQuery>> recentSearches,
    AsyncValue<List<SearchQuery>> savedSearches,
  ) {
    if (!state.hasSearched && state.query.isEmpty) {
      return _SearchLanding(
        recentSearches: recentSearches,
        savedSearches: savedSearches,
        onQuerySelected: _applyQuery,
        onClearRecent: _clearRecentSearches,
      );
    }

    if (state.isLoading) {
      return const MarkyLoadingState(rowCount: 3);
    }

    if (state.hasSearched && state.results.isEmpty) {
      final AppLocalizations? l10n = AppLocalizations.of(context);
      return _SearchEmptyResults(
        title: l10n?.emptySearchTitle ?? 'No results found',
        body: l10n?.emptySearchSubtitle ??
            'Try a different keyword, tag, or filter.',
      );
    }

    return ListView.separated(
      itemCount: state.results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final Bookmark bookmark = state.results[index];
        return BookmarkCard(
          bookmark: bookmark,
          onTap: () {
            if (bookmark.id != null) {
              context.push(Routes.bookmarkDetailPath(bookmark.id!));
            }
          },
        );
      },
    );
  }

  void _applyQuery(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    ref.read(searchNotifierProvider.notifier).updateQuery(query);
  }

  Future<void> _toggleCurrentSearch(
    BuildContext context,
    SearchQuery? savedQuery,
  ) async {
    final String query = _controller.text.trim();
    if (query.isEmpty) return;
    final bool removing = savedQuery?.id != null;
    if (removing) {
      await ref.read(searchQueryRepositoryProvider).unsave(savedQuery!.id!);
    } else {
      await ref.read(searchQueryRepositoryProvider).saveSearch(query);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            removing
                ? AppLocalizations.of(context)?.searchRemovedSnackbar ??
                    'Search removed'
                : AppLocalizations.of(context)?.searchSavedSnackbar ??
                    'Search saved',
          ),
        ),
      );
  }

  Future<void> _clearRecentSearches(BuildContext context) async {
    await ref.read(searchQueryRepositoryProvider).clearRecent();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Recent searches cleared')),
      );
  }

  static SearchQuery? _savedQueryFor(List<SearchQuery> items, String query) {
    final String normalized = SearchQuery.normalize(query);
    if (normalized.isEmpty) return null;
    for (final SearchQuery item in items) {
      if (item.isSaved && item.normalizedQuery == normalized) return item;
    }
    return null;
  }
}

class _SearchEmptyResults extends StatelessWidget {
  const _SearchEmptyResults({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.search_off_rounded,
                size: 32,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: ReadingRoomSpacing.md),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ReadingRoomSpacing.sm),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchLanding extends StatelessWidget {
  const _SearchLanding({
    required this.recentSearches,
    required this.savedSearches,
    required this.onQuerySelected,
    required this.onClearRecent,
  });

  final AsyncValue<List<SearchQuery>> recentSearches;
  final AsyncValue<List<SearchQuery>> savedSearches;
  final ValueChanged<String> onQuerySelected;
  final ValueChanged<BuildContext> onClearRecent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            0,
            ReadingRoomSpacing.sm,
            0,
            ReadingRoomSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n?.searchLandingTitle ?? 'Find anything',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: ReadingRoomSpacing.sm),
              Text(
                l10n?.searchLandingBody ??
                    'Search titles, domains, tags, and operators like tag:dart or is:favorite.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        _SearchQuerySection(
          title: l10n?.searchSavedSearchesTitle ?? 'Saved searches',
          emptyText: l10n?.searchSavedSearchesEmpty ??
              'Save useful searches with the star button.',
          searches: savedSearches,
          icon: Icons.star_rounded,
          onQuerySelected: onQuerySelected,
        ),
        const SizedBox(height: ReadingRoomSpacing.lg),
        _SearchQuerySection(
          title: l10n?.searchRecentSearchesTitle ?? 'Recent searches',
          emptyText: l10n?.searchRecentSearchesEmpty ??
              'Recent searches appear after you search.',
          searches: recentSearches,
          icon: Icons.history_rounded,
          onQuerySelected: onQuerySelected,
          trailingBuilder: (BuildContext context, List<SearchQuery> items) {
            if (items.isEmpty) return null;
            return TextButton(
              onPressed: () => onClearRecent(context),
              child: const Text('Clear'),
            );
          },
        ),
        const SizedBox(height: ReadingRoomSpacing.xl),
        Text(
          l10n?.searchOperatorsHelp ??
              'Operators: tag:, is:favorite, domain:, before:, after:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SearchQuerySection extends StatelessWidget {
  const _SearchQuerySection({
    required this.title,
    required this.emptyText,
    required this.searches,
    required this.icon,
    required this.onQuerySelected,
    this.trailingBuilder,
  });

  final String title;
  final String emptyText;
  final AsyncValue<List<SearchQuery>> searches;
  final IconData icon;
  final ValueChanged<String> onQuerySelected;
  final Widget? Function(BuildContext context, List<SearchQuery> items)?
      trailingBuilder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return searches.when(
      data: (List<SearchQuery> items) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                if (trailingBuilder?.call(context, items) case final Widget w)
                  w,
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),
            if (items.isEmpty)
              Text(
                emptyText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (final SearchQuery item in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon, size: 18),
                  title: Text(
                    item.displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: item.label == null ? null : Text(item.query),
                  onTap: () => onQuerySelected(item.query),
                ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => Text(
        emptyText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _OperatorChipData {
  const _OperatorChipData({
    required this.operatorToken,
    required this.label,
    required this.icon,
  });

  final String operatorToken;
  final String label;
  final IconData icon;
}

const List<_OperatorChipData> _kDefaultOperatorChips = <_OperatorChipData>[
  _OperatorChipData(
    operatorToken: 'is:unread',
    label: 'Unread',
    icon: Icons.mark_email_unread_outlined,
  ),
  _OperatorChipData(
    operatorToken: 'is:favorite',
    label: 'Favorites',
    icon: Icons.star_outline_rounded,
  ),
  _OperatorChipData(
    operatorToken: 'type:article',
    label: 'Articles',
    icon: Icons.article_outlined,
  ),
  _OperatorChipData(
    operatorToken: 'type:video',
    label: 'Videos',
    icon: Icons.videocam_outlined,
  ),
  _OperatorChipData(
    operatorToken: 'has:notes',
    label: 'Has Notes',
    icon: Icons.note_alt_outlined,
  ),
  _OperatorChipData(
    operatorToken: 'is:archived',
    label: 'Archived',
    icon: Icons.archive_outlined,
  ),
];

class _SearchOperatorChipsBar extends StatelessWidget {
  const _SearchOperatorChipsBar({
    required this.currentQuery,
    required this.onToggleOperator,
  });

  final String currentQuery;
  final ValueChanged<String> onToggleOperator;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String queryLower = currentQuery.toLowerCase();

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.md,
          vertical: ReadingRoomSpacing.xs,
        ),
        itemCount: _kDefaultOperatorChips.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: ReadingRoomSpacing.xs),
        itemBuilder: (BuildContext context, int index) {
          final _OperatorChipData chip = _kDefaultOperatorChips[index];
          final bool isSelected = queryLower.contains(chip.operatorToken);

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(
              chip.icon,
              size: 15,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            label: Text(chip.label),
            labelStyle: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ReadingRoomRadii.chip),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            backgroundColor: Colors.transparent,
            selectedColor: theme.colorScheme.primaryContainer,
            onSelected: (_) => onToggleOperator(chip.operatorToken),
          );
        },
      ),
    );
  }
}
