import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/database/enums/reminder_status.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/reminder.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:marky/shared/errors/safe_error_details.dart';
import 'package:marky/shared/widgets/marky_empty_state.dart';
import 'package:marky/shared/widgets/marky_error_state.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Reminder>> remindersAsync =
        ref.watch(activeRemindersProvider);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.remindersAppBarTitle ?? 'Reminders'),
      ),
      body: remindersAsync.when(
        data: (List<Reminder> reminders) {
          if (reminders.isEmpty) {
            return MarkyEmptyState(
              icon: Icons.notifications_none_rounded,
              title: l10n?.emptyRemindersTitle ?? 'No reminders scheduled',
              body: l10n?.emptyRemindersSubtitle ??
                  'Create reminders to revisit important links later.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              ReadingRoomSpacing.lg,
              ReadingRoomSpacing.md,
              ReadingRoomSpacing.lg,
              ReadingRoomSpacing.xxl,
            ),
            itemCount: reminders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final Reminder reminder = reminders[index];
              final bool isSnoozed = reminder.status == ReminderStatus.snoozed;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: ReadingRoomSpacing.xs,
                ),
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.14),
                  child: Icon(
                    isSnoozed
                        ? Icons.snooze_rounded
                        : Icons.notifications_active_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  reminder.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${_formatDate(reminder.effectiveFireAt)}'
                  '${isSnoozed ? ' • ${l10n?.reminderStatusSnoozed ?? 'Snoozed'}' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () => context.push(
                  Routes.bookmarkDetailPath(reminder.bookmarkId),
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  onSelected: (String action) =>
                      _handleAction(context, ref, reminder, action),
                  itemBuilder: (_) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'open',
                      child: Text(l10n?.actionOpen ?? 'Open'),
                    ),
                    PopupMenuItem<String>(
                      value: 'snooze_1h',
                      child: Text(l10n?.reminderSnooze1h ?? '+1 hour'),
                    ),
                    PopupMenuItem<String>(
                      value: 'snooze_tomorrow',
                      child: Text(
                        l10n?.reminderTomorrow ?? 'Tomorrow (09:00)',
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'cancel',
                      child: Text(l10n?.actionCancel ?? 'Cancel'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (Object error, _) => MarkyErrorState(
          title: l10n?.errorGenericTitle ?? 'Could not load reminders',
          body: l10n?.errorLoadFeedMessage ?? 'Try again in a moment.',
          detail: debugOnlyErrorDetails(error),
          onRetry: () => ref.invalidate(activeRemindersProvider),
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
    String action,
  ) async {
    if (action == 'open') {
      await context.push(Routes.bookmarkDetailPath(reminder.bookmarkId));
      return;
    }
    final int? id = reminder.id;
    if (id == null) return;
    final scheduler = ref.read(reminderSchedulerProvider);
    final DateTime now = DateTime.now();

    if (action == 'snooze_1h') {
      await scheduler.snoozeReminder(
        id,
        until: now.add(const Duration(hours: 1)),
      );
    } else if (action == 'snooze_tomorrow') {
      final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
      await scheduler.snoozeReminder(id, until: tomorrow);
    } else if (action == 'cancel') {
      await scheduler.cancelReminder(id);
    }
    ref.invalidate(activeRemindersProvider);
  }

  static String _formatDate(DateTime value) {
    String two(int input) => input.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
