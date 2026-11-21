import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';
import 'package:marky/features/home/presentation/feed_notifier.dart';
import 'package:marky/features/home/presentation/feed_state.dart';
import 'package:marky/features/home/presentation/widgets/batch_taxonomy_sheet.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/widgets/data/widget_providers.dart';
import 'package:marky/features/widgets/domain/widget_feed_snapshot_service.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Sticky bottom bar shown when selection mode is active.
///
/// Provides batch actions: mark-read, tag, add to collection, archive,
/// favorite, and delete. Mixed-state toggles apply uniformly (if any selected
/// item is false, all are set to true; otherwise all are set to false).
class BatchActionBar extends ConsumerWidget {
  const BatchActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FeedState feedState = ref.watch(feedNotifierProvider);
    if (!feedState.selectionMode) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final Set<int> selectedIds = feedState.selectedIds;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      padding: EdgeInsets.only(
        left: ReadingRoomSpacing.sm,
        right: ReadingRoomSpacing.sm,
        top: ReadingRoomSpacing.sm,
        bottom: MediaQuery.paddingOf(context).bottom + ReadingRoomSpacing.sm,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _ActionButton(
                    icon: Icons.check_circle_outline,
                    label: l10n?.batchActionRead ?? 'Read',
                    onTap: () => _batchUniformToggle(
                      context,
                      ref,
                      selectedIds,
                      selector: (Bookmark b) => b.isRead,
                      apply: (Bookmark b, {required bool target}) =>
                          b.copyWith(isRead: target),
                      resyncUnreadReminder: true,
                      refreshWidget: true,
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.label_outline_rounded,
                    label: l10n?.batchActionTag ?? 'Tag',
                    onTap: () => _openTaxonomySheet(
                      context,
                      BatchTaxonomyMode.tags,
                      selectedIds,
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.create_new_folder_outlined,
                    label: l10n?.batchActionCollection ?? 'Collection',
                    onTap: () => _openTaxonomySheet(
                      context,
                      BatchTaxonomyMode.collections,
                      selectedIds,
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.archive_outlined,
                    label: l10n?.batchActionArchive ?? 'Archive',
                    onTap: () => _batchUniformToggle(
                      context,
                      ref,
                      selectedIds,
                      selector: (Bookmark b) => b.isArchived,
                      apply: (Bookmark b, {required bool target}) =>
                          b.copyWith(isArchived: target),
                      resyncUnreadReminder: true,
                      refreshWidget: true,
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.favorite_outline,
                    label: l10n?.batchActionFavorite ?? 'Favorite',
                    onTap: () => _batchUniformToggle(
                      context,
                      ref,
                      selectedIds,
                      selector: (Bookmark b) => b.isFavorite,
                      apply: (Bookmark b, {required bool target}) =>
                          b.copyWith(isFavorite: target),
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    label: l10n?.batchActionDelete ?? 'Delete',
                    color: theme.colorScheme.error,
                    onTap: () => _batchDelete(context, ref, selectedIds),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openTaxonomySheet(
    BuildContext context,
    BatchTaxonomyMode mode,
    Set<int> selectedIds,
  ) async {
    final int? count = await BatchTaxonomySheet.show(
      context,
      mode: mode,
      selectedBookmarkIds: selectedIds,
    );
    if (!context.mounted || count == null || count <= 0) return;
    final AppLocalizations? l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n?.batchUpdatedCount(count) ?? 'Updated $count bookmarks',
          ),
        ),
      );
  }

  Future<void> _batchUniformToggle(
    BuildContext context,
    WidgetRef ref,
    Set<int> ids, {
    required bool Function(Bookmark) selector,
    required Bookmark Function(Bookmark, {required bool target}) apply,
    bool resyncUnreadReminder = false,
    bool refreshWidget = false,
  }) async {
    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    final List<Bookmark> bookmarks = await repo.getByIds(ids.toList());
    if (bookmarks.isEmpty) {
      ref.read(feedNotifierProvider.notifier).exitSelectionMode();
      return;
    }
    final bool target = bookmarks.any((Bookmark b) => !selector(b));
    final List<Bookmark> updated = bookmarks
        .map((Bookmark b) => apply(b, target: target))
        .toList(growable: false);
    await repo.saveAll(updated);
    if (resyncUnreadReminder) {
      await _syncUnreadReminder(ref);
    }
    if (refreshWidget) {
      _refreshWidgetBestEffort(ref);
    }
    ref.read(feedNotifierProvider.notifier).exitSelectionMode();
    if (!context.mounted) return;
    final AppLocalizations? l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n?.batchUpdatedCount(updated.length) ??
                'Updated ${updated.length} bookmarks',
          ),
        ),
      );
  }

  Future<void> _batchDelete(
    BuildContext context,
    WidgetRef ref,
    Set<int> ids,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.batchDeleteTitle ??
            'Delete bookmarks?'),
        content: Text(
          AppLocalizations.of(context)?.batchDeleteMessage(ids.length) ??
              'This will permanently delete ${ids.length} '
                  '${ids.length == 1 ? 'bookmark' : 'bookmarks'}.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context)?.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(context)?.actionDelete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ScrapingOrchestrator orchestrator =
        ref.read(scrapingOrchestratorProvider);
    for (final int id in ids) {
      orchestrator.cancel(id);
    }

    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    await repo.deleteAll(ids.toList());
    await _syncUnreadReminder(ref);
    _refreshWidgetBestEffort(ref);
    ref.read(feedNotifierProvider.notifier).exitSelectionMode();
  }

  Future<void> _syncUnreadReminder(WidgetRef ref) async {
    final AppSettings settings = ref.read(appSettingsProvider);
    final UnreadReminderCadence cadence = settings.unreadReminderCadence;
    if (cadence == UnreadReminderCadence.off) return;
    try {
      await ref.read(unreadReminderSchedulerProvider).sync(
            cadence,
            weekday: settings.unreadReminderWeekday,
            hour: settings.unreadReminderHour,
            minute: settings.unreadReminderMinute,
          );
    } on Object {
      return;
    }
  }

  static void _refreshWidgetBestEffort(WidgetRef ref) {
    unawaited(
      Future<void>(() async {
        try {
          final WidgetFeedSnapshotService service =
              await ref.read(widgetFeedSnapshotServiceProvider.future);
          await service.refresh();
        } on Object {
          // Best-effort Android home widget refresh.
        }
      }),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color effectiveColor = color ?? theme.colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.sm,
          vertical: ReadingRoomSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(height: ReadingRoomSpacing.xs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
