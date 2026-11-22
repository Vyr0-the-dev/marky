import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/settings/app_settings.dart';
import 'package:marky/app/settings/app_settings_providers.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/storage/cache_management_service.dart';
import 'package:marky/core/utils/l10n_extension.dart';
import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/capture/domain/scraping_orchestrator.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/dashboard/data/dashboard_providers.dart';
import 'package:marky/features/home/presentation/feed_notifier.dart';
import 'package:marky/features/import_export/data/import_export_providers.dart';
import 'package:marky/features/import_export/domain/import_service.dart';
import 'package:marky/features/reminders/data/reminder_providers.dart';
import 'package:marky/features/reminders/domain/reminder_scheduler.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final FutureProvider<String> _appVersionProvider =
    FutureProvider<String>((Ref ref) async {
  try {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.buildNumber.isNotEmpty
        ? 'v${info.version} (${info.buildNumber})'
        : 'v${info.version}';
  } on Object {
    return 'v1.0.0';
  }
});

enum _ExportFormat { json, html }

/// Settings screen — appearance, gestures, capture, reminders, automation,
/// data tools, cache management, and app metadata.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final AppSettings settings = ref.watch(appSettingsProvider);
    final AppSettingsNotifier notifier = ref.read(appSettingsProvider.notifier);
    final AsyncValue<int> cacheSizeAsync = ref.watch(cacheSizeBytesProvider);
    final AsyncValue<String> versionAsync = ref.watch(_appVersionProvider);
    final ThemeData theme = Theme.of(context);
    final bool unreadRemindersEnabled =
        settings.unreadReminderCadence != UnreadReminderCadence.off;

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
        padding: const EdgeInsets.only(bottom: 88),
        children: <Widget>[
          // ── Appearance ───────────────────────────────────────
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
          SwitchListTile(
            secondary: const Icon(Icons.animation_rounded),
            title: Text(l10n?.settingsAnimationsLabel ?? 'Animations'),
            subtitle: Text(
              l10n?.settingsAnimationsSubtitle ??
                  'Smooth screen and card transitions',
            ),
            value: settings.animationsEnabled,
            onChanged: (bool value) =>
                unawaited(notifier.setAnimationsEnabled(enabled: value)),
          ),

          // ── Gestures ─────────────────────────────────────────
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

          // ── Capture ──────────────────────────────────────────
          _SectionTitle(l10n?.settingsSectionCapture ?? 'Capture'),
          SwitchListTile(
            secondary: const Icon(Icons.content_paste_search_rounded),
            title: Text(
              l10n?.settingsClipboardLabel ?? 'Auto-detect clipboard links',
            ),
            subtitle: Text(
              l10n?.settingsClipboardSubtitle ??
                  'Offer to save copied links when returning to Marky',
            ),
            value: settings.clipboardDetectionEnabled,
            onChanged: (bool value) => unawaited(
              notifier.setClipboardDetectionEnabled(enabled: value),
            ),
          ),

          // ── Reminders ────────────────────────────────────────
          _SectionTitle(l10n?.settingsSectionReminders ?? 'Reminders'),
          ListTile(
            leading: const Icon(Icons.auto_awesome_motion_rounded),
            title: Text(
              l10n?.settingsUnreadRemindersTitle ?? 'Unread reminders',
            ),
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
            enabled: unreadRemindersEnabled,
            leading: const Icon(Icons.access_time_rounded),
            title: Text(
              l10n?.settingsReminderScheduleTitle ?? 'Reminder schedule',
            ),
            subtitle: Text(
              unreadRemindersEnabled
                  ? _unreadReminderScheduleLabel(context, settings)
                  : (l10n?.settingsOffLabel ?? 'Off'),
            ),
            onTap: unreadRemindersEnabled
                ? () => _pickUnreadReminderSchedule(
                      context,
                      ref,
                      notifier,
                      settings,
                    )
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(
              l10n?.settingsManageRemindersTitle ?? 'Manage active reminders',
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () => context.push(Routes.reminders),
          ),

          // ── Automation ───────────────────────────────────────
          _SectionTitle(l10n?.settingsSectionAutomation ?? 'Automation'),
          ListTile(
            leading: const Icon(Icons.auto_fix_high),
            title: Text(l10n?.settingsAutomationLabel ?? 'Automation rules'),
            subtitle: Text(
              l10n?.settingsAutomationSubtitle ??
                  'Auto-tag, archive, and more',
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () => context.push(Routes.automationRules),
          ),

          // ── Data & Tools ─────────────────────────────────────
          _SectionTitle(l10n?.settingsSectionTools ?? 'Data & Tools'),
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: Text(l10n?.settingsDashboardLabel ?? 'Dashboard'),
            subtitle: Text(
              l10n?.settingsDashboardSubtitle ?? 'Stats & analytics',
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () => context.push(Routes.stats),
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined),
            title: Text(l10n?.brokenLinksTitle ?? 'Broken Link Checker'),
            subtitle: Text(
              l10n?.brokenLinksSubtitle ?? 'Audit and clean up 404/dead links',
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () => context.push(Routes.brokenLinks),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(
              l10n?.settingsExportFormatTitle ?? 'Export backup',
            ),
            subtitle: Text(
              '${l10n?.settingsExportJsonOption ?? 'JSON'} · '
              '${l10n?.settingsExportHtmlOption ?? 'HTML'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _showExportFormatSheet(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(
              l10n?.settingsImportTitle ?? 'Restore / Import (JSON, HTML)',
            ),
            subtitle: Text(
              l10n?.settingsImportSubtitle ??
                  'Marky backup or browser bookmarks (Chrome, Firefox, Pocket)',
            ),
            onTap: () => _import(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(l10n?.settingsCacheTitle ?? 'Cache & storage'),
            subtitle: Text(
              cacheSizeAsync.when(
                data: (int bytes) =>
                    l10n?.settingsCacheSubtitle(
                      CacheManagementService.formatBytes(bytes),
                    ) ??
                    'Offline articles & cached thumbnails: '
                        '${CacheManagementService.formatBytes(bytes)}',
                loading: () => '…',
                error: (_, __) => '—',
              ),
            ),
            trailing: TextButton(
              onPressed: () => _clearCache(context, ref),
              child: Text(l10n?.settingsCacheClearAction ?? 'Clear cache'),
            ),
          ),

          // ── About ────────────────────────────────────────────
          _SectionTitle(l10n?.settingsSectionAbout ?? 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Marky'),
            subtitle: Text(versionAsync.valueOrNull ?? 'v1.0.0'),
          ),
          ListTile(
            leading: Icon(Icons.restore, color: theme.colorScheme.error),
            title: Text(
              l10n?.settingsResetDefaultsTitle ?? 'Reset to defaults',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _confirmReset(context, notifier),
          ),
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
              if (v != null) unawaited(notifier.setThemeMode(v));
              Navigator.of(ctx).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppThemeMode.values
                  .map(
                    (AppThemeMode mode) => RadioListTile<AppThemeMode>(
                      title: Text(
                        _themeModeLabel(
                          mode,
                          AppLocalizations.of(context),
                        ),
                      ),
                      value: mode,
                    ),
                  )
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
              if (v != null) unawaited(notifier.setLocale(v));
              Navigator.of(ctx).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppLocaleChoice.values
                  .map(
                    (AppLocaleChoice choice) => RadioListTile<AppLocaleChoice>(
                      title: Text(
                        _localeLabel(
                          choice,
                          AppLocalizations.of(context),
                        ),
                      ),
                      value: choice,
                    ),
                  )
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
      case SwipeAction.openReader:
        return l10n?.swipeActionOpenReader ?? 'Open in Reader';
      case SwipeAction.togglePin:
        return l10n?.swipeActionTogglePin ?? 'Pin / Unpin';
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
                  .map(
                    (SwipeAction action) => RadioListTile<SwipeAction>(
                      title: Text(_swipeActionLabel(action, l10n)),
                      value: action,
                    ),
                  )
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
    final AppLocalizations? l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => SimpleDialog(
        title: Text(l10n?.settingsUnreadRemindersTitle ?? 'Unread reminders'),
        children: <Widget>[
          RadioGroup<UnreadReminderCadence>(
            groupValue: settings.unreadReminderCadence,
            onChanged: (UnreadReminderCadence? v) {
              if (v == null) return;
              Navigator.of(ctx).pop();
              unawaited(
                _applyUnreadReminderCadence(
                  context,
                  ref,
                  notifier,
                  settings,
                  v,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: UnreadReminderCadence.values
                  .map(
                    (UnreadReminderCadence cadence) =>
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
                    ),
                  )
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
    final AppLocalizations? l10n = AppLocalizations.of(context);
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
          SnackBar(
            content: Text(
              l10n?.reminderPermissionRequired ??
                  'Notification permission is required',
            ),
          ),
        );
    } on ReminderExactAlarmUnavailableException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n?.reminderExactAlarmUnavailable ??
                  'Exact alarms are not available',
            ),
          ),
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
    if (cadence == UnreadReminderCadence.off) return;

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
          SnackBar(content: Text(context.l10n.reminderPermissionRequired)),
        );
    } on ReminderExactAlarmUnavailableException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.reminderExactAlarmUnavailable)),
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
        return context.l10n.settingsOffLabel;
      case UnreadReminderCadence.dailyEvening:
        return context.l10n.settingsUnreadReminderDaily(formattedTime);
      case UnreadReminderCadence.weekly:
        return context.l10n.settingsUnreadReminderWeekly(
          _weekdayLabel(context, weekday),
          formattedTime,
        );
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
        return context.l10n.settingsUnreadReminderOffMsg;
      case UnreadReminderCadence.dailyEvening:
        if (unreadCount == 0) {
          return context.l10n.settingsUnreadReminderEmptyMsg;
        }
        return context.l10n.settingsUnreadReminderDailySet(formattedTime);
      case UnreadReminderCadence.weekly:
        if (unreadCount == 0) {
          return context.l10n.settingsUnreadReminderEmptyMsg;
        }
        return context.l10n.settingsUnreadReminderWeeklySet(
          _weekdayLabel(context, weekday),
          formattedTime,
        );
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
      return context.l10n.settingsUnreadReminderWeekly(
        _weekdayLabel(context, settings.unreadReminderWeekday),
        formattedTime,
      );
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
        title: Text(context.l10n.remindersTitle),
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
                      title: Text(_weekdayLabel(context, weekday)),
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

  static String _weekdayLabel(BuildContext context, int weekday) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime sampleDate = DateTime(2026, 1, 4 + weekday);
    return DateFormat.EEEE(locale).format(sampleDate);
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

  // ── Export (JSON or Netscape HTML) ──────────────────────────────

  Future<void> _showExportFormatSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final _ExportFormat? choice = await showModalBottomSheet<_ExportFormat>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (BuildContext ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ReadingRoomSpacing.lg,
                0,
                ReadingRoomSpacing.lg,
                ReadingRoomSpacing.sm,
              ),
              child: Text(
                l10n?.settingsExportFormatTitle ?? 'Export format',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.data_object_rounded),
              title: Text(
                l10n?.settingsExportJsonOption ?? 'Full Marky Backup (JSON)',
              ),
              onTap: () => Navigator.of(ctx).pop(_ExportFormat.json),
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(
                l10n?.settingsExportHtmlOption ??
                    'Browser Bookmarks (Netscape HTML)',
              ),
              onTap: () => Navigator.of(ctx).pop(_ExportFormat.html),
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    await _export(context, ref, choice);
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    _ExportFormat format,
  ) async {
    final String shareText =
        AppLocalizations.of(context)?.settingsBackupShareText ?? 'Marky backup';
    try {
      final int ts = DateTime.now().millisecondsSinceEpoch;
      final Directory dir = await getTemporaryDirectory();
      final String path;
      final String payload;
      switch (format) {
        case _ExportFormat.json:
          payload = await ref.read(exportServiceProvider).exportAll();
          path = '${dir.path}/marky_backup_$ts.json';
        case _ExportFormat.html:
          payload = await ref.read(exportServiceProvider).exportNetscapeHtml();
          path = '${dir.path}/marky_bookmarks_$ts.html';
      }
      await File(path).writeAsString(payload);
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

  // ── Cache cleanup ───────────────────────────────────────────────

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    await ref.read(cacheManagementServiceProvider).clearAll();
    ref.invalidate(cacheSizeBytesProvider);
    if (!context.mounted) return;
    final AppLocalizations? l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n?.settingsCacheCleared ?? 'Cache cleared'),
        ),
      );
  }

  // ── Import ──────────────────────────────────────────────────────

  static const int _maxImmediateEnrichCount = 24;
  static const int _importEnrichConcurrency = 4;

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    bool progressDialogOpen = false;
    try {
      final FilePickerResult? picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json', 'html', 'htm'],
      );
      if (picked == null || picked.files.isEmpty) return;

      final String? path = picked.files.single.path;
      if (path == null) return;

      if (context.mounted) {
        progressDialogOpen = true;
        final AppLocalizations? l10n = AppLocalizations.of(context);
        unawaited(
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) => PopScope(
              canPop: false,
              child: AlertDialog(
                content: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: ReadingRoomSpacing.lg),
                    Expanded(
                      child: Text(
                        l10n?.settingsImportingProgress ??
                            'Importing bookmarks…',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final String content = await File(path).readAsString();
      final String trimmed = content.trim().toLowerCase();
      final bool isHtml = path.toLowerCase().endsWith('.html') ||
          path.toLowerCase().endsWith('.htm') ||
          trimmed.startsWith('<!doctype') ||
          trimmed.startsWith('<dl') ||
          trimmed.startsWith('<html') ||
          trimmed.startsWith('<title>bookmarks');

      final ImportResult result = isHtml
          ? await ref.read(importServiceProvider).importHtmlBookmarks(content)
          : await ref.read(importServiceProvider).importAll(content);

      // Force-refresh all feed, library, and dashboard providers so newly
      // imported bookmarks and folders appear immediately with zero lag.
      ref.invalidate(bookmarkFeedProvider);
      ref.invalidate(bookmarkCountProvider);
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(tagsProvider);
      ref.invalidate(bookmarkCollectionsProvider);
      ref.invalidate(bookmarkCollectionsWithArchivedProvider);

      if (result.importedBookmarkIds.isNotEmpty) {
        final ScrapingOrchestrator orchestrator =
            ref.read(scrapingOrchestratorProvider);
        unawaited(
          _enrichImportedBookmarks(
            orchestrator,
            result.importedBookmarkIds,
          ),
        );
      }

      if (progressDialogOpen && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        progressDialogOpen = false;
      }

      if (!context.mounted) return;
      final AppLocalizations? l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(
              l10n?.settingsImportSummary(
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
            action: (result.bookmarksImported > 0 || result.bookmarksMerged > 0)
                ? SnackBarAction(
                    label: l10n?.settingsImportViewAction ?? 'View',
                    onPressed: () {
                      if (!context.mounted) return;
                      ref
                          .read(feedNotifierProvider.notifier)
                          .clearNarrowing();
                      context.go(Routes.home);
                    },
                  )
                : null,
          ),
        );
    } catch (e) {
      if (progressDialogOpen && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        progressDialogOpen = false;
      }
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

  /// Background bounded-concurrency enrichment for freshly imported browser
  /// bookmarks so hero images, descriptions, and reading times populate
  /// smoothly without blocking the UI or saturating network sockets.
  static Future<void> _enrichImportedBookmarks(
    ScrapingOrchestrator orchestrator,
    List<int> ids,
  ) async {
    final List<int> targets = ids.take(_maxImmediateEnrichCount).toList();
    int cursor = 0;

    Future<void> worker() async {
      while (cursor < targets.length) {
        final int id = targets[cursor++];
        try {
          await orchestrator.enrich(id);
        } on Object {
          // Best-effort enrichment; individual site failures must not halt batch.
        }
      }
    }

    final int workerCount = targets.length < _importEnrichConcurrency
        ? targets.length
        : _importEnrichConcurrency;
    await Future.wait<void>(
      List<Future<void>>.generate(workerCount, (_) => worker()),
    );
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
