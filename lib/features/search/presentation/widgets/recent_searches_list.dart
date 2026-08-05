import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/search/presentation/providers/search_providers.dart';

/// Displays a list of recent searches when the search bar is focused
/// and the current query is empty.
///
/// Tapping a recent search replays the query into the search field.
class RecentSearchesList extends ConsumerWidget {
  /// Creates a [RecentSearchesList].
  const RecentSearchesList({
    required this.onQuerySelected,
    super.key,
  });

  /// Called when the user taps a recent search entry.
  final ValueChanged<String> onQuerySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> recentSearches = ref.watch(recentSearchesProvider);

    if (recentSearches.isEmpty) {
      return const _EmptyRecentSearches();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: AppShapes.horizontalScreenPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Recent Searches',
                style: AppTypography.sectionTitle.copyWith(fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  ref.read(recentSearchesProvider.notifier).clear();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: AppShapes.horizontalScreenPadding,
            itemCount: recentSearches.length,
            separatorBuilder: (_, __) => const Divider(
              color: AppColors.border,
              height: 1,
              indent: 40,
            ),
            itemBuilder: (BuildContext context, int index) {
              final String query = recentSearches[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.history,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                title: Text(
                  query,
                  style: AppTypography.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.north_west,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
                  onPressed: () => onQuerySelected(query),
                  tooltip: 'Search this',
                ),
                onTap: () => onQuerySelected(query),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Shown when there are no recent searches to display.
class _EmptyRecentSearches extends StatelessWidget {
  const _EmptyRecentSearches();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.search,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Start typing to search',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your recent searches will appear here',
            style: AppTypography.metadata,
          ),
        ],
      ),
    );
  }
}
