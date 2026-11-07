import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/import_export/data/import_export_providers.dart';
import 'package:marky/features/import_export/domain/import_service.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Settings screen — theme, locale, export/import.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final AppSettings settings = ref.watch(appSettingsProvider);
    final AppSettingsNotifier notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.settingsTitle ?? 'Settings',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          _SectionTitle(l10n?.settingsSectionAppearance ?? 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n?.settingsThemeLabel ?? 'Theme'),
            subtitle: Text(_themeModeLabel(settings.themeMode, l10n)),
            onTap: () => _showThemePicker(context, notifier, settings),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n?.settingsLanguageLabel ?? 'Language'),
            subtitle: Text(_localeLabel(settings.locale, l10n)),
            onTap: () => _showLocalePicker(context, notifier, settings),
          ),
          _SectionTitle(l10n?.settingsSectionGestures ?? 'Gestures'),
          ListTile(
            leading: const Icon(Icons.swipe_right_rounded),
            title: Text(l10n?.settingsSwipeRightLabel ?? 'Swipe right'),
            subtitle: Text(_swipeActionLabel(settings.rightSwipeAction, l10n)),
            onTap: () => _showSwipeActionPicker(
              context,
              notifier,
              isRight: true,
              current: settings.rightSwipeAction,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.swipe_left_rounded),
            title: Text(l10n?.settingsSwipeLeftLabel ?? 'Swipe left'),
            subtitle: Text(_swipeActionLabel(settings.leftSwipeAction, l10n)),
            onTap: () => _showSwipeActionPicker(
              context,
              notifier,
              isRight: false,
              current: settings.leftSwipeAction,
            ),
          ),
          const _SectionTitle('Re-engagement'),
          ListTile(
            leading: const Icon(Icons.auto_awesome_motion_rounded),
            title: const Text('Unread reminders'),
            subtitle: Text(
              _unreadReminderCadenceLabel(
                context,
                settings.unreadReminderCadence,
                weekday: settings.unreadReminderWeekday,
                hour: settings.unreadReminderHour,
                minute: settings.unreadReminderMinute,
              ),
            ),
            onTap: () => _showUnreadReminderPicker(
              context,
              ref,
              notifier,
              settings,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time_rounded),
            title: const Text('Reminder schedule'),
            subtitle: Text(
              _unreadReminderScheduleLabel(context, settings),
            ),
            onTap: () => _pickUnreadReminderSchedule(
              context,
              ref,
              notifier,
              settings,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.auto_fix_high),
            title: Text(l10n?.settingsAutomationLabel ?? 'Automation Rules'),
            subtitle: Text(
              l10n?.settingsAutomationSubtitle ?? 'Auto-tag, archive, and more',
            ),
            onTap: () => context.push(Routes.automationRules),
          ),
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: ReadingRoomSpacing.lg,
            ),
            childrenPadding: EdgeInsets.zero,
            shape: const Border(),
            collapsedShape: const Border(),
            leading: const Icon(Icons.tune_rounded),
            title: const Text('Advanced'),
            subtitle: const Text('Backups, insights, app info'),
            children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ReadingRoomSpacing.lg,
                ),
                leading: const Icon(Icons.upload_file),
                title: Text(
                  l10n?.settingsExportBackupTitle ?? 'Export backup (JSON)',
                ),
                onTap: () => _export(context, ref),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ReadingRoomSpacing.lg,
                ),
                leading: const Icon(Icons.download),
                title: Text(
                  l10n?.settingsRestoreBackupTitle ?? 'Restore backup (JSON)',
                ),
                subtitle: Text(
                  l10n?.settingsRestoreBackupSubtitle ??
                      'Duplicates are merged safely',
                ),
                onTap: () => _import(context, ref),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ReadingRoomSpacing.lg,
                ),
                leading: const Icon(Icons.bar_chart_rounded),
                title: Text(l10n?.settingsDashboardLabel ?? 'Dashboard'),
                subtitle: Text(
                  l10n?.settingsDashboardSubtitle ?? 'Stats & analytics',
                ),
                onTap: () => context.push(Routes.stats),
              ),
              const ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ReadingRoomSpacing.lg,
                ),
                leading: Icon(Icons.info_outline),
                title: Text('Marky'),
                subtitle: Text('v2.0.0-dev'),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ReadingRoomSpacing.lg,
                ),
                leading: const Icon(Icons.restore),
                title: Text(
                  l10n?.settingsResetDefaultsTitle ?? 'Reset to defaults',
                ),
                onTap: () => _confirmReset(context, notifier),
              ),
            ],
          ),
          const SizedBox(height: ReadingRoomSpacing.huge),
        ],
      ),
    );
  }

  // ── Theme picker ────────────────────────────────────────────────

  void _showThemePicker(
    BuildContext context,
    AppSettingsNotifier notifier,
    AppSettings settings,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => SimpleDialog(
        title:
            Text(AppLocalizations.of(context)?.settingsThemeLabel ?? 'Theme'),
        children: <Widget>[
          RadioGroup<AppThemeMode>(
            groupValue: settings.themeMode,
            onChanged: (AppThemeMode? v) {
              if (v != null) notifier.setThemeMode(v);
              Navigator.of(ctx).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppThemeMode.values
                  .map((AppThemeMode mode) => RadioListTile<AppThemeMode>(
                        title: Text(
                          _themeModeLabel(
                            mode,
                            AppLocalizations.of(context),
                          ),
                        ),
                        value: mode,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  static String _themeModeLabel(AppThemeMode mode, AppLocalizations? l10n) {
    switch (mode) {
      case AppThemeMode.system:
        return l10n?.themeSystem ?? 'System';
      case AppThemeMode.light:
        return l10n?.themeLight ?? 'Light';
      case AppThemeMode.dark:
        return l10n?.themeDark ?? 'Dark';
      case AppThemeMode.oled:
        return l10n?.themeOled ?? 'OLED Black';
    }
  }

  // ── Locale picker ───────────────────────────────────────────────

  void _showLocalePicker(
    BuildContext context,
    AppSettingsNotifier notifier,
    AppSettings settings,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => SimpleDialog(
        title: Text(
          AppLocalizations.of(context)?.settingsLanguageLabel ?? 'Language',
        ),
        children: <Widget>[
          RadioGroup<AppLocaleChoice>(
            groupValue: settings.locale,
            onChanged: (AppLocaleChoice? v) {
              if (v != null) notifier.setLocale(v);
              Navigator.of(ctx).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppLocaleChoice.values
                  .map((AppLocaleChoice choice) =>
                      RadioListTile<AppLocaleChoice>(
                        title: Text(
                          _localeLabel(
                            choice,
                            AppLocalizations.of(context),
                          ),
                        ),
                        value: choice,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  static String _localeLabel(AppLocaleChoice choice, AppLocalizations? l10n) {
    switch (choice) {
      case AppLocaleChoice.system:
        return l10n?.themeSystem ?? 'System';
      case AppLocaleChoice.en:
        return l10n?.languageEnglish ?? 'English';
      case AppLocaleChoice.tr:
        return l10n?.languageTurkish ?? 'Türkçe';
    }
  }

  static String _swipeActionLabel(SwipeAction action, AppLocalizations? l10n) {
    switch (action) {
      case SwipeAction.toggleRead:
        return l10n?.swipeActionToggleRead ?? 'Read / Unread';
      case SwipeAction.toggleArchive:
        return l10n?.swipeActionToggleArchive ?? 'Archive / Unarchive';
      case SwipeAction.toggleFavorite:
        return l10n?.swipeActionToggleFavorite ?? 'Favorite / Unfavorite';
      case SwipeAction.delete:
        return l10n?.swipeActionDelete ?? 'Delete';
      case SwipeAction.none:
        return l10n?.swipeActionNone ?? 'None';
    }
  }

  void _showSwipeActionPicker(
    BuildContext context,
    AppSettingsNotifier notifier, {
    required bool isRight,
    required SwipeAction current,
  }) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final String title = isRight
        ? (l10n?.settingsSwipeRightLabel ?? 'Swipe right')
        : (l10n?.settingsSwipeLeftLabel ?? 'Swipe left');

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => SimpleDialog(
        title: Text(title),
        children: <Widget>[
          RadioGroup<SwipeAction>(
            groupValue: current,
            onChanged: (SwipeAction? v) {
              if (v != null) {
                if (isRight) {
                  unawaited(notifier.setRightSwipeAction(v));
                } else {
                  unawaited(notifier.setLeftSwipeAction(v));
                }
              }
              Navigator.of(ctx).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: SwipeAction.values
                  .map((SwipeAction action) => RadioListTile<SwipeAction>(
                        title: Text(_swipeActionLabel(action, l10n)),
                        value: action,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnreadReminderPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettingsNotifier notifier,
    AppSettings settings,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => SimpleDialog(
        title: const Text('Unread reminders'),
        children: <Widget>[
          RadioGroup<UnreadReminderCadence>(
            groupValue: settings.unreadReminderCadence,
            onChanged: (UnreadReminderCadence? v) {
              if (v == null) return;
              Navigator.of(ctx).pop();
              unawaited(_applyUnreadReminderCadence(
                context,
                ref,
                notifier,
                settings,
                v,
              ));
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: UnreadReminderCadence.values
                  .map((UnreadReminderCadence cadence) =>
                      RadioListTile<UnreadReminderCadence>(
                        title: Text(
                          _unreadReminderCadenceLabel(
                            context,
                            cadence,
                            weekday: settings.unreadReminderWeekday,
                            hour: settings.unreadReminderHour,
                            minute: settings.unreadReminderMinute,
                          ),
                        ),
                        value: cadence,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyUnreadReminderCadence(
    BuildContext context,
    WidgetRef ref,
    AppSettingsNotifier notifier,
    AppSettings settings,
    UnreadReminderCadence cadence,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      int unreadCount = 0;
      int weekday = settings.unreadReminderWeekday;
      int hour = settings.unreadReminderHour;
      int minute = settings.unreadReminderMinute;
      if (cadence == UnreadReminderCadence.weekly) {
        final int? pickedWeekday = await _pickUnreadReminderWeekday(
          context,
          initialWeekday: weekday,
        );
        if (pickedWeekday == null) return;
        if (!context.mounted) return;
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
        );
        if (pickedTime == null) return;
        weekday = pickedWeekday;
        hour = pickedTime.hour;
        minute = pickedTime.minute;
      }
      if (cadence == UnreadReminderCadence.off) {
        await ref.read(unreadReminderSchedulerProvider).cancel();
      } else {
        unreadCount = await ref.read(unreadReminderSchedulerProvider).schedule(
              cadence,
              weekday: weekday,
              hour: hour,
              minute: minute,
            );
      }
      await notifier.setUnreadReminderSchedule(
        cadence: cadence,
        weekday: weekday,
        hour: hour,
        minute: minute,
      );
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _unreadReminderSavedMessage(
                context,
                cadence,
                unreadCount,
                weekday: weekday,
                hour: hour,
                minute: minute,
              ),
            ),
          ),
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

  Future<void> _pickUnreadReminderSchedule(
    BuildContext context,
    WidgetRef ref,
    AppSettingsNotifier notifier,
    AppSettings settings,
  ) async {
    int weekday = settings.unreadReminderWeekday;
    if (settings.unreadReminderCadence == UnreadReminderCadence.weekly) {
      final int? pickedWeekday = await _pickUnreadReminderWeekday(
        context,
        initialWeekday: weekday,
      );
      if (pickedWeekday == null) return;
      weekday = pickedWeekday;
      if (!context.mounted) return;
    }
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.unreadReminderHour,
        minute: settings.unreadReminderMinute,
      ),
    );
    if (picked == null) return;

    await notifier.setUnreadReminderSchedule(
      cadence: settings.unreadReminderCadence,
      weekday: weekday,
      hour: picked.hour,
      minute: picked.minute,
    );

    if (!context.mounted) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final UnreadReminderCadence cadence = settings.unreadReminderCadence;
    if (cadence == UnreadReminderCadence.off) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Unread reminder time set to '
              '${_formatTime(context, hour: picked.hour, minute: picked.minute)}',
            ),
          ),
        );
      return;
    }

    try {
      final int unreadCount =
          await ref.read(unreadReminderSchedulerProvider).schedule(
                cadence,
                weekday: weekday,
                hour: picked.hour,
                minute: picked.minute,
              );
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _unreadReminderSavedMessage(
                context,
                cadence,
                unreadCount,
                weekday: weekday,
                hour: picked.hour,
                minute: picked.minute,
              ),
            ),
          ),
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

  String _unreadReminderCadenceLabel(
    BuildContext context,
    UnreadReminderCadence cadence, {
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final String formattedTime =
        _formatTime(context, hour: hour, minute: minute);
    switch (cadence) {
      case UnreadReminderCadence.off:
        return 'Off';
      case UnreadReminderCadence.dailyEvening:
        return 'Daily at $formattedTime';
      case UnreadReminderCadence.weekly:
        return 'Weekly on ${_weekdayLabel(weekday)} at $formattedTime';
    }
  }

  String _unreadReminderSavedMessage(
    BuildContext context,
    UnreadReminderCadence cadence,
    int unreadCount, {
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final String formattedTime =
        _formatTime(context, hour: hour, minute: minute);
    switch (cadence) {
      case UnreadReminderCadence.off:
        return 'Unread reminders turned off';
      case UnreadReminderCadence.dailyEvening:
        if (unreadCount == 0) {
          return 'Unread reminders will start when you save unread links';
        }
        return 'Unread reminders set for $formattedTime every day';
      case UnreadReminderCadence.weekly:
        if (unreadCount == 0) {
          return 'Unread reminders will start when you save unread links';
        }
        return 'Unread reminders set for ${_weekdayLabel(weekday)}s at $formattedTime';
    }
  }

  String _unreadReminderScheduleLabel(
    BuildContext context,
    AppSettings settings,
  ) {
    final String formattedTime = _formatTime(
      context,
      hour: settings.unreadReminderHour,
      minute: settings.unreadReminderMinute,
    );
    if (settings.unreadReminderCadence == UnreadReminderCadence.weekly) {
      return '${_weekdayLabel(settings.unreadReminderWeekday)} at $formattedTime';
    }
    return formattedTime;
  }

  Future<int?> _pickUnreadReminderWeekday(
    BuildContext context, {
    required int initialWeekday,
  }) {
    return showDialog<int>(
      context: context,
      builder: (BuildContext ctx) => SimpleDialog(
        title: const Text('Reminder day'),
        children: <Widget>[
          RadioGroup<int>(
            groupValue: initialWeekday,
            onChanged: (int? value) => Navigator.of(ctx).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <int>[
                DateTime.monday,
                DateTime.tuesday,
                DateTime.wednesday,
                DateTime.thursday,
                DateTime.friday,
                DateTime.saturday,
                DateTime.sunday,
              ]
                  .map(
                    (int weekday) => RadioListTile<int>(
                      title: Text(_weekdayLabel(weekday)),
                      value: weekday,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  static String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Saturday';
    }
  }

  String _formatTime(
    BuildContext context, {
    required int hour,
    required int minute,
  }) {
    final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
    return MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  // ── Export ──────────────────────────────────────────────────────

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final String shareText =
        AppLocalizations.of(context)?.settingsBackupShareText ?? 'Marky backup';
    try {
      final String json = await ref.read(exportServiceProvider).exportAll();
      final Directory dir = await getTemporaryDirectory();
      final String path =
          '${dir.path}/marky_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      await File(path).writeAsString(json);
      await Share.shareXFiles(
        <XFile>[XFile(path)],
        text: shareText,
      );
    } catch (e) {
      if (context.mounted) {
        final AppLocalizations? l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                l10n?.settingsExportFailed(e) ?? 'Export failed: $e',
              ),
            ),
          );
      }
    }
  }

  // ── Import ──────────────────────────────────────────────────────

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    try {
      final FilePickerResult? picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json'],
      );
      if (picked == null || picked.files.isEmpty) return;

      final String? path = picked.files.single.path;
      if (path == null) return;

      final String jsonString = await File(path).readAsString();
      final ImportResult result =
          await ref.read(importServiceProvider).importAll(jsonString);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.settingsImportSummary(
                    result.bookmarksImported,
                    result.bookmarksMerged,
                    result.bookmarksSkipped,
                    result.tagsImported,
                    result.collectionsImported,
                  ) ??
                  'Imported ${result.bookmarksImported} bookmarks '
                      '(${result.bookmarksMerged} merged, '
                      '${result.bookmarksSkipped} skipped), '
                      '${result.tagsImported} tags, '
                      '${result.collectionsImported} collections.',
            ),
          ),
        );
    } catch (e) {
      if (context.mounted) {
        final AppLocalizations? l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                l10n?.settingsImportFailed(e) ?? 'Import failed: $e',
              ),
            ),
          );
      }
    }
  }

  // ── Reset ──────────────────────────────────────────────────────

  Future<void> _confirmReset(
    BuildContext context,
    AppSettingsNotifier notifier,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.settingsResetDialogTitle ??
              'Reset settings?',
        ),
        content: Text(
          AppLocalizations.of(context)?.settingsResetDialogBody ??
              'This only resets preferences (theme, language, etc.) — '
                  'your bookmarks and data stay intact.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context)?.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppLocalizations.of(context)?.settingsResetAction ?? 'Reset',
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await notifier.replace(const AppSettings.defaults());
    }
  }
}

// ─── Section title ──────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ReadingRoomSpacing.lg,
        ReadingRoomSpacing.lg,
        ReadingRoomSpacing.lg,
        ReadingRoomSpacing.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
