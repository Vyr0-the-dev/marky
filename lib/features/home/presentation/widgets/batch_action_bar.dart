import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/home/presentation/feed_notifier.dart';
import 'package:marky/features/home/presentation/feed_state.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Sticky bottom bar shown when selection mode is active.
///
/// Provides quick batch actions: archive, favorite, mark-read, delete.
/// Each action mutates the bookmarks via [BookmarkRepository], then
/// exits selection mode.
class BatchActionBar extends ConsumerWidget {
  const BatchActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FeedState feedState = ref.watch(feedNotifierProvider);
    if (!feedState.selectionMode) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      padding: EdgeInsets.only(
        left: ReadingRoomSpacing.lg,
        right: ReadingRoomSpacing.lg,
        top: ReadingRoomSpacing.sm,
        bottom: MediaQuery.paddingOf(context).bottom + ReadingRoomSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _ActionButton(
            icon: Icons.archive_outlined,
            label: 'Archive',
            onTap: () => _batchToggle(
              ref,
              feedState.selectedIds,
              (Bookmark b) => b.copyWith(isArchived: !b.isArchived),
              resyncUnreadReminder: true,
            ),
          ),
          _ActionButton(
            icon: Icons.favorite_outline,
            label: 'Favorite',
            onTap: () => _batchToggle(
              ref,
              feedState.selectedIds,
              (Bookmark b) => b.copyWith(isFavorite: !b.isFavorite),
            ),
          ),
          _ActionButton(
            icon: Icons.check_circle_outline,
            label: 'Read',
            onTap: () => _batchToggle(
              ref,
              feedState.selectedIds,
              (Bookmark b) => b.copyWith(isRead: !b.isRead),
              resyncUnreadReminder: true,
            ),
          ),
          _ActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: theme.colorScheme.error,
            onTap: () => _batchDelete(context, ref, feedState.selectedIds),
          ),
        ],
      ),
    );
  }

  Future<void> _batchToggle(
    WidgetRef ref,
    Set<int> ids,
    Bookmark Function(Bookmark) transform, {
    bool resyncUnreadReminder = false,
  }) async {
    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    final List<Bookmark> bookmarks = await repo.getByIds(ids.toList());
    final List<Bookmark> updated =
        bookmarks.map(transform).toList(growable: false);
    await repo.saveAll(updated);
    if (resyncUnreadReminder) {
      await _syncUnreadReminder(ref);
    }
    ref.read(feedNotifierProvider.notifier).exitSelectionMode();
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

    final BookmarkRepository repo = ref.read(bookmarkRepositoryProvider);
    await repo.deleteAll(ids.toList());
    await _syncUnreadReminder(ref);
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
          horizontal: ReadingRoomSpacing.md,
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
