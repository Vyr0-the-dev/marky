import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Quick-pick reminder bottom sheet.
///
/// Offers "Tonight", "Tomorrow", "This weekend", and "Pick date" options.
/// Persists the chosen reminder via [ReminderRepository].
class CreateReminderSheet extends ConsumerWidget {
  const CreateReminderSheet({
    required this.bookmarkId,
    required this.bookmarkTitle,
    super.key,
  });

  final int bookmarkId;
  final String bookmarkTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.lg,
          vertical: ReadingRoomSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
                AppLocalizations.of(context)?.reminderSheetTitle ?? 'Remind me',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: ReadingRoomSpacing.md),
            _QuickOption(
              icon: Icons.nightlight_round,
              label: AppLocalizations.of(context)?.reminderTonight ??
                  'Tonight (20:00)',
              onTap: () => _schedule(context, ref, _tonight()),
            ),
            _QuickOption(
              icon: Icons.wb_sunny_outlined,
              label: AppLocalizations.of(context)?.reminderTomorrow ??
                  'Tomorrow (09:00)',
              onTap: () => _schedule(context, ref, _tomorrowMorning()),
            ),
            _QuickOption(
              icon: Icons.weekend_outlined,
              label: AppLocalizations.of(context)?.reminderThisWeekend ??
                  'This weekend (Sat 10:00)',
              onTap: () => _schedule(context, ref, _thisWeekend()),
            ),
            _QuickOption(
              icon: Icons.calendar_today,
              label: AppLocalizations.of(context)?.reminderPickDateTime ??
                  'Pick a date & time…',
              onTap: () => _pickCustom(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _schedule(
    BuildContext context,
    WidgetRef ref,
    DateTime at,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    if (!at.isAfter(DateTime.now())) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
              content: Text(l10n?.reminderFutureTimeRequired ??
                  'Choose a future reminder time')),
        );
      return;
    }
    try {
      await ref.read(reminderSchedulerProvider).createReminder(
            bookmarkId: bookmarkId,
            title: bookmarkTitle,
            scheduledAt: at,
          );
    } on ReminderNotificationPermissionDeniedException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
              content: Text(l10n?.reminderPermissionRequired ??
                  'Notification permission is required')),
        );
      return;
    } on ReminderExactAlarmUnavailableException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
              content: Text(l10n?.reminderExactAlarmUnavailable ??
                  'Exact alarms are not available')),
        );
      return;
    }
    if (context.mounted) {
      Navigator.of(context).pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text(l10n?.reminderSet ?? 'Reminder set')));
    }
  }

  Future<void> _pickCustom(BuildContext context, WidgetRef ref) async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !context.mounted) return;

    final DateTime at = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    await _schedule(context, ref, at);
  }

  static DateTime _tonight() {
    final DateTime now = DateTime.now();
    final DateTime tonight = DateTime(now.year, now.month, now.day, 20);
    if (tonight.isAfter(now)) return tonight;
    return DateTime(now.year, now.month, now.day + 1, 20);
  }

  static DateTime _tomorrowMorning() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 9);
  }

  static DateTime _thisWeekend() {
    final DateTime now = DateTime.now();
    // Days until Saturday (6).
    final int daysUntilSat = (DateTime.saturday - now.weekday) % 7;
    final int offset = daysUntilSat == 0 ? 7 : daysUntilSat;
    return DateTime(now.year, now.month, now.day + offset, 10);
  }
}

class _QuickOption extends StatelessWidget {
  const _QuickOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
