import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/home/presentation/feed_notifier.dart';
import 'package:marky/features/home/presentation/feed_state.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/widgets/inline_chip.dart';

/// Horizontal chip strip for feed filter selection.
///
/// Sits just below the AppBar. Tapping a chip updates the feed
/// query through [FeedNotifier].
class FeedFilterBar extends ConsumerWidget {
  const FeedFilterBar({super.key});

  static const List<BookmarkFeedFilter> _filters = <BookmarkFeedFilter>[
    BookmarkFeedFilter.all,
    BookmarkFeedFilter.unread,
    BookmarkFeedFilter.favorites,
    BookmarkFeedFilter.archived,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FeedState feedState = ref.watch(feedNotifierProvider);
    final BookmarkFeedFilter activeFilter = feedState.query.filter;
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReadingRoomSpacing.md,
        vertical: ReadingRoomSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          for (final BookmarkFeedFilter filter in _filters) ...<Widget>[
            Expanded(
              child: Semantics(
                button: true,
                selected: filter == activeFilter,
                child: InlineChip(
                  label: _label(filter, l10n),
                  selected: filter == activeFilter,
                  expanded: true,
                  onTap: () =>
                      ref.read(feedNotifierProvider.notifier).setFilter(filter),
                ),
              ),
            ),
            if (filter != _filters.last)
              const SizedBox(width: ReadingRoomSpacing.xs),
          ],
        ],
      ),
    );
  }

  static String _label(BookmarkFeedFilter filter, AppLocalizations? l10n) {
    switch (filter) {
      case BookmarkFeedFilter.all:
        return l10n?.filterAll ?? 'All';
      case BookmarkFeedFilter.unread:
        return l10n?.filterUnread ?? 'Unread';
      case BookmarkFeedFilter.favorites:
        return l10n?.filterFavorites ?? 'Favorites';
      case BookmarkFeedFilter.archived:
        return l10n?.filterArchived ?? 'Archived';
    }
  }
}
