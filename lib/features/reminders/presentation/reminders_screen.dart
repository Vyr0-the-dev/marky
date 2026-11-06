import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
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

    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.remindersAppBarTitle ??
              'Reminders')),
      body: remindersAsync.when(
        data: (List<Reminder> reminders) {
          if (reminders.isEmpty) {
            return const MarkyEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No active reminders',
              body: 'Create reminders from a bookmark detail page.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
            itemCount: reminders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final Reminder reminder = reminders[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.alarm_rounded),
                title: Text(reminder.title),
                subtitle: Text(_formatDate(reminder.effectiveFireAt)),
                trailing: Text(reminder.status.name),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (Object error, _) => MarkyErrorState(
          title: 'Could not load reminders',
          body: 'Try again in a moment.',
          detail: debugOnlyErrorDetails(error),
          onRetry: () => ref.invalidate(activeRemindersProvider),
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    String two(int input) => input.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
