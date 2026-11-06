import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/theme/reading_room_theme.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_feed_query.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/home/presentation/feed_notifier.dart';
import 'package:marky/features/home/presentation/feed_state.dart';
import 'package:marky/features/home/presentation/widgets/batch_action_bar.dart';
import 'package:marky/features/home/presentation/widgets/bookmark_card.dart';
import 'package:marky/features/home/presentation/widgets/feed_filter_bar.dart';
import 'package:marky/features/home/presentation/widgets/feed_skeleton.dart';
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
    if (feedState.viewMode == FeedViewMode.grid) {
      return _BookmarkGrid(
        bookmarks: bookmarks,
        feedState: feedState,
      );
    }

    return Scrollbar(
      interactive: true,
      child: ListView.separated(
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
  });

  final List<Bookmark> bookmarks;
  final FeedState feedState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scrollbar(
      interactive: true,
      child: GridView.builder(
        cacheExtent: 360,
        padding: const EdgeInsets.all(ReadingRoomSpacing.sm),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: ReadingRoomSpacing.sm,
          crossAxisSpacing: ReadingRoomSpacing.sm,
          childAspectRatio: 0.75,
        ),
        itemCount: bookmarks.length,
        itemBuilder: (BuildContext context, int index) {
          final Bookmark bookmark = bookmarks[index];
          return RepaintBoundary(
            child: _GridCard(
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
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({
    required this.bookmark,
    required this.isSelected,
    required this.selectionMode,
    this.onTap,
    this.onLongPress,
  });

  final Bookmark bookmark;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? imageUrl = bookmark.heroImageUrl ?? bookmark.faviconUrl;

    return Semantics(
      button: onTap != null || onLongPress != null,
      selected: selectionMode && isSelected,
      label: _gridSemanticsLabel(bookmark),
      child: ExcludeSemantics(
        child: Card(
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Hero image
                    Expanded(
                      flex: 3,
                      child: LayoutBuilder(
                        builder: (
                          BuildContext context,
                          BoxConstraints constraints,
                        ) {
                          final int? cacheWidth = constraints.maxWidth.isFinite
                              ? (constraints.maxWidth *
                                      MediaQuery.devicePixelRatioOf(context))
                                  .round()
                              : null;
                          final int? cacheHeight = constraints
                                  .maxHeight.isFinite
                              ? (constraints.maxHeight *
                                      MediaQuery.devicePixelRatioOf(context))
                                  .round()
                              : null;
                          return imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  cacheWidth: cacheWidth,
                                  cacheHeight: cacheHeight,
                                  filterQuality: FilterQuality.low,
                                  errorBuilder: (_, __, ___) =>
                                      _gridPlaceholder(
                                    context,
                                    bookmark,
                                  ),
                                )
                              : _gridPlaceholder(context, bookmark);
                        },
                      ),
                    ),
                    // Text
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(ReadingRoomSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              bookmark.displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(height: ReadingRoomSpacing.xs),
                            Text(
                              bookmark.normalizedHost ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ReadingRoomTextStyles.metadata(context),
                            ),
                            if (bookmark.tagIds.isNotEmpty) ...<Widget>[
                              const SizedBox(height: ReadingRoomSpacing.xs),
                              Flexible(
                                child: TagChipsRow(
                                  tagIds: bookmark.tagIds,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Selection overlay
                if (selectionMode)
                  Positioned(
                    top: ReadingRoomSpacing.xs,
                    right: ReadingRoomSpacing.xs,
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 22,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _gridPlaceholder(BuildContext context, Bookmark bookmark) {
    final ThemeData theme = Theme.of(context);
    final String domain = bookmark.normalizedHost ?? '';
    final String letter = domain.isNotEmpty ? domain[0].toUpperCase() : '?';

    return ColoredBox(
      color: theme.colorScheme.outlineVariant,
      child: Center(
        child: Text(
          letter,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  static String _gridSemanticsLabel(Bookmark bookmark) {
    final String host = bookmark.normalizedHost ?? '';
    final List<String> parts = <String>[
      'Bookmark',
      bookmark.displayTitle,
      if (host.isNotEmpty) host,
      if (bookmark.isRead) 'read' else 'unread',
      if (bookmark.isFavorite) 'favorite',
      if (bookmark.isPinned) 'pinned',
      if (bookmark.isArchived) 'archived',
    ];
    return parts.join(', ');
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

    return Dismissible(
      key: ValueKey<int>(bookmark.id!),
      confirmDismiss: (DismissDirection direction) async {
        final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
        if (direction == DismissDirection.startToEnd) {
          // Swipe right → toggle archive
          await repo.save(bookmark.copyWith(isArchived: !bookmark.isArchived));
          return false;
        }
        // Swipe left → delete with undo
        await repo.delete(bookmark.id!);
        if (context.mounted) {
          final ScaffoldMessengerState messenger =
              ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
              controller = messenger.showSnackBar(
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
          unawaited(
            Future<void>.delayed(const Duration(seconds: 4), () {
              if (messenger.mounted) controller.close();
            }),
          );
        }
        return false;
      },
      background: Container(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: ReadingRoomSpacing.xl),
        child: Icon(
          bookmark.isArchived ? Icons.unarchive : Icons.archive_outlined,
          color: theme.colorScheme.primary,
        ),
      ),
      secondaryBackground: Container(
        color: theme.colorScheme.error.withValues(alpha: 0.12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: ReadingRoomSpacing.xl),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.error,
        ),
      ),
      child: child,
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
