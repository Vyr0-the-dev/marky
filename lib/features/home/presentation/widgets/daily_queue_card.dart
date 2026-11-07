import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark.dart';
import 'package:marky/features/home/presentation/daily_queue_provider.dart';
import 'package:marky/features/reader/presentation/reader_screen.dart';

/// A calm, compact editorial card highlighting a daily goal of unread bookmarks.
class DailyQueueCard extends ConsumerWidget {
  const DailyQueueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DailyQueueState queueState = ref.watch(dailyQueueProvider);
    if (queueState.isHidden || queueState.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isTurkish = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('tr');
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final double progress = queueState.totalCount > 0
        ? (queueState.completedCount / queueState.totalCount).clamp(0.0, 1.0)
        : 0.0;

    if (queueState.isDismissed) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.lg,
          vertical: ReadingRoomSpacing.xs,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
            onTap: () =>
                ref.read(dailyQueueProvider.notifier).toggleDismissed(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ReadingRoomSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 14,
                    color: colors.primary,
                  ),
                  const SizedBox(width: ReadingRoomSpacing.xs),
                  Text(
                    isTurkish
                        ? 'Hedef: ${queueState.completedCount}/${queueState.totalCount}'
                        : 'Goal: ${queueState.completedCount}/${queueState.totalCount}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: ReadingRoomSpacing.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: colors.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          queueState.isAllCompleted
                              ? Colors.green
                              : colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: ReadingRoomSpacing.xs),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReadingRoomSpacing.lg,
        vertical: ReadingRoomSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.md,
          vertical: ReadingRoomSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // ── Header ──────────────────────────────────────────
            Row(
              children: <Widget>[
                Icon(
                  Icons.auto_stories_rounded,
                  size: 15,
                  color: colors.primary,
                ),
                const SizedBox(width: ReadingRoomSpacing.xs),
                Expanded(
                  child: Text(
                    isTurkish ? 'Günün Okuma Hedefi' : "Today's Reading Goal",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
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
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () =>
                      ref.read(dailyQueueProvider.notifier).toggleDismissed(),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // ── Progress Bar ─────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: colors.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  queueState.isAllCompleted ? Colors.green : colors.primary,
                ),
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.xs),

            // ── Items or Completed state ─────────────────────────
            if (queueState.isAllCompleted) ...<Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.celebration_rounded,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: ReadingRoomSpacing.xs),
                    Expanded(
                      child: Text(
                        isTurkish
                            ? 'Günün tüm okumaları tamamlandı! ✨'
                            : 'All daily reading completed! ✨',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...<Widget>[
              for (int i = 0; i < queueState.items.length; i++) ...<Widget>[
                if (i > 0)
                  Divider(
                    height: 6,
                    color: colors.outline.withValues(alpha: 0.2),
                  ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              unawaited(HapticFeedback.lightImpact());
              final Bookmark updated =
                  bookmark.copyWith(isRead: !bookmark.isRead);
              ref.read(bookmarkRepositoryProvider).save(updated);
            },
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                bookmark.isRead
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 16,
                color: bookmark.isRead ? Colors.green : colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: ReadingRoomSpacing.xs),
          Expanded(
            child: InkWell(
              onTap: () {
                unawaited(HapticFeedback.lightImpact());
                Navigator.of(context).push(ReaderScreen.route(bookmark));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    bookmark.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                      decoration: bookmark.isRead
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: bookmark.isRead
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                    ),
                  ),
                  if (timeText.isNotEmpty ||
                      (bookmark.normalizedHost?.isNotEmpty ??
                          false)) ...<Widget>[
                    Text(
                      <String>[
                        if (bookmark.normalizedHost != null)
                          bookmark.normalizedHost!,
                        if (timeText.isNotEmpty) '📖 $timeText',
                      ].join(' • '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: ReadingRoomSpacing.xs),
          InkWell(
            onTap: () {
              unawaited(HapticFeedback.lightImpact());
              Navigator.of(context).push(ReaderScreen.route(bookmark));
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(
                Icons.chrome_reader_mode_outlined,
                size: 15,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
