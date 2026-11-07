import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/home/presentation/daily_queue_provider.dart';
import 'package:marky/features/reader/presentation/reader_screen.dart';

/// A calm, literary card highlighting a daily goal of 3 unread bookmarks.
class DailyQueueCard extends ConsumerWidget {
  const DailyQueueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DailyQueueState queueState = ref.watch(dailyQueueProvider);
    if (queueState.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isTurkish = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('tr');
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    if (queueState.isDismissed) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.lg,
          vertical: ReadingRoomSpacing.xs,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          onTap: () =>
              ref.read(dailyQueueProvider.notifier).toggleDismissed(),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ReadingRoomSpacing.md,
              vertical: ReadingRoomSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.auto_stories_rounded,
                  size: 16,
                  color: colors.primary,
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Text(
                  isTurkish
                      ? 'Günün Okuma Hedefi (${queueState.completedCount}/${queueState.totalCount})'
                      : "Today's Reading Goal (${queueState.completedCount}/${queueState.totalCount})",
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final double progress = queueState.totalCount > 0
        ? (queueState.completedCount / queueState.totalCount).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReadingRoomSpacing.lg,
        vertical: ReadingRoomSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.5),
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.all(ReadingRoomSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Header ──────────────────────────────────────────
            Row(
              children: <Widget>[
                Icon(
                  Icons.auto_stories_rounded,
                  size: 18,
                  color: colors.primary,
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Expanded(
                  child: Text(
                    isTurkish ? 'Günün Okuma Hedefi' : "Today's Reading Goal",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: queueState.isAllCompleted
                        ? Colors.green.withValues(alpha: 0.15)
                        : colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(ReadingRoomRadii.chip),
                  ),
                  child: Text(
                    '${queueState.completedCount}/${queueState.totalCount}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: queueState.isAllCompleted
                          ? Colors.green
                          : colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: isTurkish ? 'Daralt' : 'Collapse',
                  onPressed: () =>
                      ref.read(dailyQueueProvider.notifier).toggleDismissed(),
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),

            // ── Progress Bar ─────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: colors.outline.withValues(alpha: 0.25),
                valueColor: AlwaysStoppedAnimation<Color>(
                  queueState.isAllCompleted ? Colors.green : colors.primary,
                ),
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.md),

            // ── Items or Completed state ─────────────────────────
            if (queueState.isAllCompleted) ...<Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.celebration_rounded,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: ReadingRoomSpacing.sm),
                    Text(
                      isTurkish
                          ? 'Günün tüm okumaları tamamlandı! ✨'
                          : 'All daily reading completed! ✨',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...<Widget>[
              for (int i = 0; i < queueState.items.length; i++) ...<Widget>[
                if (i > 0) const Divider(height: 12),
                _DailyQueueItemRow(
                  bookmark: queueState.items[i],
                  isTurkish: isTurkish,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DailyQueueItemRow extends ConsumerWidget {
  const _DailyQueueItemRow({
    required this.bookmark,
    required this.isTurkish,
  });

  final Bookmark bookmark;
  final bool isTurkish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final int? minutes = bookmark.readingTimeMinutes;
    final String timeText = minutes != null && minutes > 0
        ? (isTurkish ? '$minutes dk' : '${minutes}m')
        : '';

    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(
            bookmark.isRead
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 20,
            color: bookmark.isRead ? Colors.green : colors.onSurfaceVariant,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: bookmark.isRead
              ? (isTurkish ? 'Okunmadı olarak işaretle' : 'Mark as unread')
              : (isTurkish ? 'Okundu olarak işaretle' : 'Mark as read'),
          onPressed: () {
            unawaited(HapticFeedback.lightImpact());
            final Bookmark updated = bookmark.copyWith(isRead: !bookmark.isRead);
            ref.read(bookmarkRepositoryProvider).save(updated);
          },
        ),
        const SizedBox(width: ReadingRoomSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                bookmark.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: bookmark.isRead
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: bookmark.isRead
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                ),
              ),
              if (timeText.isNotEmpty || (bookmark.normalizedHost?.isNotEmpty ?? false)) ...<Widget>[
                Text(
                  <String>[
                    if (bookmark.normalizedHost != null) bookmark.normalizedHost!,
                    if (timeText.isNotEmpty) '📖 $timeText',
                  ].join(' • '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: ReadingRoomSpacing.sm),
        IconButton(
          icon: Icon(
            Icons.chrome_reader_mode_outlined,
            size: 18,
            color: colors.primary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: isTurkish ? 'Oku' : 'Read',
          onPressed: () {
            unawaited(HapticFeedback.lightImpact());
            Navigator.of(context).push(ReaderScreen.route(bookmark));
          },
        ),
      ],
    );
  }
}
