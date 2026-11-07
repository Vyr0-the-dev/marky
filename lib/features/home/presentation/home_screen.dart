import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/home/presentation/feed_notifier.dart';
import 'package:marky/features/home/presentation/feed_state.dart';
import 'package:marky/features/home/presentation/widgets/batch_action_bar.dart';
import 'package:marky/features/home/presentation/widgets/bookmark_card.dart';
import 'package:marky/features/home/presentation/widgets/editorial_grid_card.dart';
import 'package:marky/features/home/presentation/widgets/feed_filter_bar.dart';
import 'package:marky/features/home/presentation/widgets/feed_skeleton.dart';
import 'package:marky/features/reader/presentation/reader_screen.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/errors/safe_error_details.dart';
import 'package:marky/shared/widgets/marky_empty_state.dart';
import 'package:marky/shared/widgets/marky_error_state.dart';

/// The main library feed screen.
///
/// Displays the user's bookmarks as a scrollable list (or grid) with
/// filter chips, sort controls, and selection mode. The feed is
/// reactive — adding, editing, or scraping a bookmark will
/// automatically update the visible list.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    this.initialFilter,
    super.key,
  });

  final BookmarkFeedFilter? initialFilter;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _initialFilterApplied = false;

  @override
  void initState() {
    super.initState();
    _applyInitialFilter();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter) {
      _initialFilterApplied = false;
      _applyInitialFilter();
    }
  }

  void _applyInitialFilter() {
    final BookmarkFeedFilter? initialFilter = widget.initialFilter;
    if (_initialFilterApplied || initialFilter == null) return;
    _initialFilterApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(feedNotifierProvider.notifier).setFilter(initialFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final FeedState feedState = ref.watch(feedNotifierProvider);
    final BookmarkFeedQuery query = feedState.query;
    final AsyncValue<List<Bookmark>> feedAsync =
        ref.watch(bookmarkFeedProvider(query));

    return Scaffold(
      appBar: _buildAppBar(context, ref, feedState),
      body: Column(
        children: <Widget>[
          // ── Filter bar ─────────────────────────────────────
          const FeedFilterBar(),

          // ── Active narrowing indicator ─────────────────────
          if (query.tagId != null || query.collectionId != null)
            _NarrowingChip(query: query),

          const _UnreadReminderNudge(),

          // ── Feed body ──────────────────────────────────────
          Expanded(
            child: feedAsync.when(
              data: (List<Bookmark> bookmarks) {
                if (bookmarks.isEmpty) {
                  return _emptyState(context, ref, feedState.query.filter);
                }
                return _BookmarkList(
                  bookmarks: bookmarks,
                  feedState: feedState,
                );
              },
              loading: () => const FeedSkeleton(),
              error: (Object error, _) => MarkyErrorState(
                title: l10n?.errorGenericTitle ?? 'Something went wrong',
                body: l10n?.errorLoadFeedMessage ?? 'Could not load feed.',
                detail: debugOnlyErrorDetails(error),
                onRetry: () => ref.invalidate(bookmarkFeedProvider(query)),
              ),
            ),
          ),

          // ── Batch action bar (selection mode) ──────────
          const BatchActionBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    FeedState feedState,
  ) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    if (feedState.selectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n?.actionClose ?? 'Close',
          onPressed: () =>
              ref.read(feedNotifierProvider.notifier).exitSelectionMode(),
        ),
        title: Text(
          l10n?.homeSelectionCount(feedState.selectedCount) ??
              '${feedState.selectedCount} selected',
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: l10n?.homeSelectAllTooltip ?? 'Select all',
            onPressed: () {
              final AsyncValue<List<Bookmark>> feed =
                  ref.read(bookmarkFeedProvider(feedState.query));
              feed.whenData((List<Bookmark> bookmarks) {
                ref.read(feedNotifierProvider.notifier).selectAll(
                      bookmarks
                          .where((Bookmark b) => b.id != null)
                          .map((Bookmark b) => b.id!)
                          .toList(),
                    );
              });
            },
          ),
        ],
      );
    }

    return AppBar(
      title: const Text(
        'Marky',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            feedState.viewMode == FeedViewMode.list
                ? Icons.grid_view_rounded
                : Icons.view_list_rounded,
          ),
          tooltip: feedState.viewMode == FeedViewMode.list
              ? l10n?.homeGridTooltip ?? 'Grid'
              : l10n?.homeListTooltip ?? 'List',
          onPressed: () =>
              ref.read(feedNotifierProvider.notifier).toggleViewMode(),
        ),
        const _SortMenu(),
      ],
    );
  }

  static Widget _emptyState(
    BuildContext context,
    WidgetRef ref,
    BookmarkFeedFilter filter,
  ) {
    void browseAll() => ref
        .read(feedNotifierProvider.notifier)
        .setFilter(BookmarkFeedFilter.all);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    switch (filter) {
      case BookmarkFeedFilter.all:
        return MarkyEmptyState(
          icon: Icons.auto_stories_outlined,
          title: l10n?.homeEmptyTitle ?? 'Your library is quiet',
          body: l10n?.homeEmptyBody ??
              'Save a link from anywhere — paste, share, or add manually.',
          actionLabel: l10n?.homeAddLinkAction ?? 'Add a link',
          onAction: () => context.go(Routes.add),
        );
      case BookmarkFeedFilter.favorites:
        return MarkyEmptyState(
          icon: Icons.favorite_outline,
          title: l10n?.homeNoFavoritesTitle ?? 'No favorites yet',
          body: l10n?.homeNoFavoritesBody ??
              'Tap the heart on any bookmark to save it here.',
          actionLabel: l10n?.homeBrowseAllAction ?? 'Browse all',
          onAction: browseAll,
        );
      case BookmarkFeedFilter.unread:
        return MarkyEmptyState(
          icon: Icons.auto_stories_outlined,
          title: l10n?.homeAllCaughtUpTitle ?? 'All caught up',
          body: l10n?.homeAllCaughtUpBody ?? 'Everything has been read.',
        );
      case BookmarkFeedFilter.archived:
        return MarkyEmptyState(
          icon: Icons.archive_outlined,
          title: l10n?.homeArchiveEmptyTitle ?? 'Archive is empty',
          body: l10n?.homeArchiveEmptyBody ??
              'Swipe to archive bookmarks you want to keep but hide.',
          actionLabel: l10n?.homeBrowseAllAction ?? 'Browse all',
          onAction: browseAll,
        );
    }
  }
}

class _UnreadReminderNudge extends ConsumerWidget {
  const _UnreadReminderNudge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UnreadReminderCadence cadence =
        ref.watch(unreadReminderCadenceProvider);
    if (cadence != UnreadReminderCadence.off) return const SizedBox.shrink();

    const BookmarkFeedQuery unreadProbe = BookmarkFeedQuery(
      filter: BookmarkFeedFilter.unread,
      limit: 1,
    );
    final AsyncValue<List<Bookmark>> unreadAsync =
        ref.watch(bookmarkFeedProvider(unreadProbe));
    final bool hasUnread = unreadAsync.maybeWhen(
      data: (List<Bookmark> bookmarks) => bookmarks.isNotEmpty,
      orElse: () => false,
    );
    if (!hasUnread) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ReadingRoomSpacing.lg,
        ReadingRoomSpacing.xs,
        ReadingRoomSpacing.lg,
        ReadingRoomSpacing.sm,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          ReadingRoomSpacing.md,
          ReadingRoomSpacing.sm,
          ReadingRoomSpacing.sm,
          ReadingRoomSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.auto_awesome_motion_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: ReadingRoomSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Unread reminders',
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Bring saved links back automatically.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: ReadingRoomSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: () => _enable(
                    context,
                    ref,
                    UnreadReminderCadence.dailyEvening,
                  ),
                  icon: const Icon(Icons.nightlight_round, size: 16),
                  label: const Text('Evening'),
                ),
                IconButton(
                  onPressed: () => _enable(
                    context,
                    ref,
                    UnreadReminderCadence.weekly,
                  ),
                  icon: const Icon(Icons.calendar_view_week_rounded),
                  tooltip: 'Weekly',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enable(
    BuildContext context,
    WidgetRef ref,
    UnreadReminderCadence cadence,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppSettings settings = ref.read(appSettingsProvider);
    try {
      await ref.read(unreadReminderSchedulerProvider).schedule(
            cadence,
            weekday: settings.unreadReminderWeekday,
            hour: settings.unreadReminderHour,
            minute: settings.unreadReminderMinute,
          );
      await ref
          .read(appSettingsProvider.notifier)
          .setUnreadReminderCadence(cadence);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(_message(cadence))),
        );
    } on ReminderNotificationPermissionDeniedException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Notification permission is required')),
        );
    } on ReminderExactAlarmUnavailableException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Exact alarms are not available')),
        );
    }
  }

  static String _message(UnreadReminderCadence cadence) {
    switch (cadence) {
      case UnreadReminderCadence.off:
        return 'Unread reminders turned off';
      case UnreadReminderCadence.dailyEvening:
        return 'Unread reminders set for every evening';
      case UnreadReminderCadence.weekly:
        return 'Unread reminders set for weekly reading';
    }
  }
}

// ─── Bookmark list ──────────────────────────────────────────────

class _BookmarkList extends ConsumerWidget {
  const _BookmarkList({
    required this.bookmarks,
    required this.feedState,
  });

  final List<Bookmark> bookmarks;
  final FeedState feedState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedSwitcher(
      duration: reduceMotion ? Duration.zero : ReadingRoomMotion.standard,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: feedState.viewMode == FeedViewMode.grid
          ? _BookmarkGrid(
              key: const ValueKey<FeedViewMode>(FeedViewMode.grid),
              bookmarks: bookmarks,
              feedState: feedState,
            )
          : Scrollbar(
              key: const ValueKey<FeedViewMode>(FeedViewMode.list),
              interactive: true,
              child: ListView.separated(
                // ignore: deprecated_member_use
                cacheExtent: 360,
                itemCount: bookmarks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final Bookmark bookmark = bookmarks[index];
                  final Widget card = BookmarkCard(
                    bookmark: bookmark,
                    selectionMode: feedState.selectionMode,
                    isSelected: bookmark.id != null &&
                        feedState.selectedIds.contains(bookmark.id),
                    onTap: () => _onTap(context, ref, bookmark),
                    onLongPress: () => _onLongPress(ref, bookmark),
                  );

                  // Swipe disabled in selection mode.
                  if (feedState.selectionMode || bookmark.id == null) {
                    return RepaintBoundary(child: card);
                  }

                  return RepaintBoundary(
                    child: _SwipeableCard(
                      bookmark: bookmark,
                      child: card,
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref, Bookmark bookmark) {
    if (feedState.selectionMode && bookmark.id != null) {
      ref.read(feedNotifierProvider.notifier).toggleSelection(bookmark.id!);
      return;
    }
    if (bookmark.id != null) {
      context.push(Routes.bookmarkDetailPath(bookmark.id!));
    }
  }

  void _onLongPress(WidgetRef ref, Bookmark bookmark) {
    if (!feedState.selectionMode && bookmark.id != null) {
      ref.read(feedNotifierProvider.notifier).enterSelectionMode(bookmark.id!);
    }
  }
}

// ─── Grid view ──────────────────────────────────────────────────

class _BookmarkGrid extends ConsumerWidget {
  const _BookmarkGrid({
    required this.bookmarks,
    required this.feedState,
    super.key,
  });

  final List<Bookmark> bookmarks;
  final FeedState feedState;

  static int columnCountForWidth(double width) {
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final int crossAxisCount = columnCountForWidth(width);

        return Scrollbar(
          interactive: true,
          child: MasonryGridView.count(
            key: ValueKey<int>(crossAxisCount),
            cacheExtent: 360,
            padding: const EdgeInsets.all(ReadingRoomSpacing.md),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: ReadingRoomSpacing.md,
            crossAxisSpacing: ReadingRoomSpacing.md,
            itemCount: bookmarks.length,
            itemBuilder: (BuildContext context, int index) {
              final Bookmark bookmark = bookmarks[index];
              return RepaintBoundary(
                child: EditorialGridCard(
                  bookmark: bookmark,
                  isSelected: bookmark.id != null &&
                      feedState.selectedIds.contains(bookmark.id),
                  selectionMode: feedState.selectionMode,
                  onTap: () {
                    if (feedState.selectionMode && bookmark.id != null) {
                      ref
                          .read(feedNotifierProvider.notifier)
                          .toggleSelection(bookmark.id!);
                      return;
                    }
                    if (bookmark.id != null) {
                      context.push(Routes.bookmarkDetailPath(bookmark.id!));
                    }
                  },
                  onLongPress: () {
                    if (!feedState.selectionMode && bookmark.id != null) {
                      ref
                          .read(feedNotifierProvider.notifier)
                          .enterSelectionMode(bookmark.id!);
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Swipeable card ─────────────────────────────────────────────

class _SwipeableCard extends ConsumerWidget {
  const _SwipeableCard({
    required this.bookmark,
    required this.child,
  });

  final Bookmark bookmark;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    final SwipeAction rightAction = ref.watch(rightSwipeActionProvider);
    final SwipeAction leftAction = ref.watch(leftSwipeActionProvider);

    if (rightAction == SwipeAction.none && leftAction == SwipeAction.none) {
      return child;
    }

    final DismissDirection direction = rightAction == SwipeAction.none
        ? DismissDirection.endToStart
        : leftAction == SwipeAction.none
            ? DismissDirection.startToEnd
            : DismissDirection.horizontal;

    return Dismissible(
      key: ValueKey<int>(bookmark.id!),
      movementDuration: ReadingRoomMotion.quick,
      resizeDuration: ReadingRoomMotion.quick,
      direction: direction,
      confirmDismiss: (DismissDirection swipeDirection) async {
        final SwipeAction action = swipeDirection == DismissDirection.startToEnd
            ? rightAction
            : leftAction;
        return _handleAction(
          context: context,
          ref: ref,
          action: action,
          bookmark: bookmark,
          repo: repo,
          l10n: l10n,
        );
      },
      background: _buildBackground(
        context: context,
        action: rightAction,
        bookmark: bookmark,
        alignment: Alignment.centerLeft,
        theme: theme,
        l10n: l10n,
      ),
      secondaryBackground: _buildBackground(
        context: context,
        action: leftAction,
        bookmark: bookmark,
        alignment: Alignment.centerRight,
        theme: theme,
        l10n: l10n,
      ),
      child: child,
    );
  }

  Future<bool> _handleAction({
    required BuildContext context,
    required WidgetRef ref,
    required SwipeAction action,
    required Bookmark bookmark,
    required BookmarkRepository repo,
    required AppLocalizations? l10n,
  }) async {
    switch (action) {
      case SwipeAction.toggleRead:
        unawaited(HapticFeedback.lightImpact());
        final bool newRead = !bookmark.isRead;
        await repo.save(bookmark.copyWith(isRead: newRead));
        if (context.mounted) {
          final ScaffoldMessengerState messenger =
              ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          final String message = newRead
              ? (l10n?.snackbarMarkedAsRead ?? 'Marked as read')
              : (l10n?.snackbarMarkedAsUnread ?? 'Marked as unread');
          messenger.showSnackBar(
            SnackBar(
              content: Text(message),
              action: SnackBarAction(
                label: l10n?.actionUndo ?? 'Undo',
                onPressed: () => repo.save(bookmark.copyWith(isRead: !newRead)),
              ),
            ),
          );
        }
        return false;

      case SwipeAction.toggleArchive:
        unawaited(HapticFeedback.mediumImpact());
        if (bookmark.isArchived) {
          await repo.save(bookmark.copyWith(isArchived: false));
          if (context.mounted) {
            final ScaffoldMessengerState messenger =
                ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.snackbarBookmarkUnarchived ?? 'Bookmark unarchived',
                ),
                action: SnackBarAction(
                  label: l10n?.actionUndo ?? 'Undo',
                  onPressed: () =>
                      repo.save(bookmark.copyWith(isArchived: true)),
                ),
              ),
            );
          }
          return true;
        } else {
          await repo.save(bookmark.copyWith(isArchived: true));
          if (context.mounted) {
            final ScaffoldMessengerState messenger =
                ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.snackbarBookmarkArchived ?? 'Bookmark archived',
                ),
                action: SnackBarAction(
                  label: l10n?.actionUndo ?? 'Undo',
                  onPressed: () =>
                      repo.save(bookmark.copyWith(isArchived: false)),
                ),
              ),
            );
          }
          return true;
        }

      case SwipeAction.toggleFavorite:
        unawaited(HapticFeedback.lightImpact());
        final bool newFav = !bookmark.isFavorite;
        await repo.save(bookmark.copyWith(isFavorite: newFav));
        if (context.mounted) {
          final ScaffoldMessengerState messenger =
              ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          final String message = newFav
              ? (l10n?.snackbarMarkedAsFavorite ?? 'Added to favorites')
              : (l10n?.snackbarMarkedAsUnfavorite ?? 'Removed from favorites');
          messenger.showSnackBar(
            SnackBar(
              content: Text(message),
              action: SnackBarAction(
                label: l10n?.actionUndo ?? 'Undo',
                onPressed: () =>
                    repo.save(bookmark.copyWith(isFavorite: !newFav)),
              ),
            ),
          );
        }
        return false;

      case SwipeAction.delete:
        unawaited(HapticFeedback.heavyImpact());
        ref.read(scrapingOrchestratorProvider).cancel(bookmark.id!);
        await repo.delete(bookmark.id!);
        if (context.mounted) {
          final ScaffoldMessengerState messenger =
              ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                l10n?.snackbarBookmarkDeleted ?? 'Bookmark deleted',
              ),
              action: SnackBarAction(
                label: l10n?.actionUndo ?? 'Undo',
                onPressed: () => repo.save(bookmark),
              ),
            ),
          );
        }
        return true;

      case SwipeAction.openReader:
        unawaited(HapticFeedback.lightImpact());
        unawaited(Navigator.of(context).push(ReaderScreen.route(bookmark)));
        return false;

      case SwipeAction.togglePin:
        unawaited(HapticFeedback.lightImpact());
        final bool newPinned = !bookmark.isPinned;
        await repo.save(bookmark.copyWith(isPinned: newPinned));
        if (context.mounted) {
          final ScaffoldMessengerState messenger =
              ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          final String message = newPinned
              ? (l10n?.snackbarBookmarkPinned ?? 'Bookmark pinned')
              : (l10n?.snackbarBookmarkUnpinned ?? 'Bookmark unpinned');
          messenger.showSnackBar(
            SnackBar(
              content: Text(message),
              action: SnackBarAction(
                label: l10n?.actionUndo ?? 'Undo',
                onPressed: () =>
                    repo.save(bookmark.copyWith(isPinned: !newPinned)),
              ),
            ),
          );
        }
        return false;

      case SwipeAction.none:
        return false;
    }
  }

  Widget _buildBackground({
    required BuildContext context,
    required SwipeAction action,
    required Bookmark bookmark,
    required Alignment alignment,
    required ThemeData theme,
    required AppLocalizations? l10n,
  }) {
    if (action == SwipeAction.none) {
      return const SizedBox.shrink();
    }

    final bool isLeftAligned = alignment == Alignment.centerLeft;
    final Color actionColor;
    final IconData icon;
    final String label;

    switch (action) {
      case SwipeAction.toggleRead:
        actionColor = theme.colorScheme.primary;
        icon = bookmark.isRead
            ? Icons.mark_email_unread_outlined
            : Icons.check_circle_outline;
        label = bookmark.isRead
            ? (l10n?.detailActionUnread ?? 'Unread')
            : (l10n?.detailActionRead ?? 'Read');
        break;

      case SwipeAction.toggleArchive:
        if (bookmark.isArchived) {
          actionColor = theme.colorScheme.secondary;
          icon = Icons.unarchive_outlined;
          label = l10n?.actionUnarchive ?? 'Unarchive';
        } else {
          actionColor = theme.colorScheme.onSurfaceVariant;
          icon = Icons.archive_outlined;
          label = l10n?.actionArchive ?? 'Archive';
        }
        break;

      case SwipeAction.toggleFavorite:
        actionColor = Colors.pinkAccent;
        icon = bookmark.isFavorite ? Icons.favorite_outline : Icons.favorite;
        label = bookmark.isFavorite
            ? (l10n?.detailActionUnfavorite ?? 'Unfav')
            : (l10n?.labelFavorite ?? 'Favorite');
        break;

      case SwipeAction.delete:
        actionColor = theme.colorScheme.error;
        icon = Icons.delete_outline;
        label = l10n?.actionDelete ?? 'Delete';
        break;

      case SwipeAction.openReader:
        actionColor = theme.colorScheme.primary;
        icon = Icons.chrome_reader_mode_outlined;
        label = l10n?.swipeActionOpenReader ?? 'Reader';
        break;

      case SwipeAction.togglePin:
        actionColor = theme.colorScheme.tertiary;
        icon = bookmark.isPinned
            ? Icons.push_pin_outlined
            : Icons.push_pin_rounded;
        label = bookmark.isPinned
            ? (l10n?.detailActionUnpin ?? 'Unpin')
            : (l10n?.detailActionPin ?? 'Pin');
        break;

      case SwipeAction.none:
        return const SizedBox.shrink();
    }

    return Container(
      color: actionColor.withValues(alpha: 0.12),
      alignment: alignment,
      padding: EdgeInsets.only(
        left: isLeftAligned ? ReadingRoomSpacing.xl : 0,
        right: isLeftAligned ? 0 : ReadingRoomSpacing.xl,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isLeftAligned) ...<Widget>[
            Icon(icon, color: actionColor),
            const SizedBox(width: ReadingRoomSpacing.sm),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: actionColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...<Widget>[
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: actionColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: ReadingRoomSpacing.sm),
            Icon(icon, color: actionColor),
          ],
        ],
      ),
    );
  }
}

// ─── Sort menu ──────────────────────────────────────────────────

class _SortMenu extends ConsumerWidget {
  const _SortMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return PopupMenuButton<BookmarkSort>(
      icon: const Icon(Icons.sort),
      tooltip: l10n?.homeSortTooltip ?? 'Sort',
      onSelected: (BookmarkSort sort) =>
          ref.read(feedNotifierProvider.notifier).setSort(sort),
      itemBuilder: (_) => <PopupMenuEntry<BookmarkSort>>[
        PopupMenuItem<BookmarkSort>(
          value: BookmarkSort.newestFirst,
          child: Text(l10n?.sortNewest ?? 'Newest first'),
        ),
        PopupMenuItem<BookmarkSort>(
          value: BookmarkSort.oldestFirst,
          child: Text(l10n?.sortOldest ?? 'Oldest first'),
        ),
        PopupMenuItem<BookmarkSort>(
          value: BookmarkSort.recentlyOpened,
          child: Text(l10n?.sortRecentlyOpened ?? 'Recently opened'),
        ),
        PopupMenuItem<BookmarkSort>(
          value: BookmarkSort.titleAscending,
          child: Text(l10n?.sortTitle ?? 'Title'),
        ),
      ],
    );
  }
}

// ─── Narrowing chip ─────────────────────────────────────────────

class _NarrowingChip extends ConsumerWidget {
  const _NarrowingChip({required this.query});

  final BookmarkFeedQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String label;
    if (query.tagId != null) {
      final AsyncValue<Tag?> tagAsync =
          ref.watch(tagByIdProvider(query.tagId!));
      label =
          tagAsync.whenData((Tag? t) => t?.name).value ?? 'Tag #${query.tagId}';
    } else if (query.collectionId != null) {
      final AsyncValue<BookmarkCollection?> colAsync =
          ref.watch(bookmarkCollectionByIdProvider(query.collectionId!));
      label = colAsync.whenData((BookmarkCollection? c) => c?.title).value ??
          'Collection #${query.collectionId}';
    } else if (query.host != null) {
      label = query.host!;
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReadingRoomSpacing.lg,
        vertical: ReadingRoomSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Chip(
            label: Text(
                AppLocalizations.of(context)?.homeFilteredLabel(label) ??
                    'Filtered: $label'),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              ref.read(feedNotifierProvider.notifier).setTagId(null);
              ref.read(feedNotifierProvider.notifier).setCollectionId(null);
              ref.read(feedNotifierProvider.notifier).setHost(null);
            },
          ),
        ],
      ),
    );
  }
}
