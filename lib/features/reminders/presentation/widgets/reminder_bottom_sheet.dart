import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/reminders/presentation/providers/reminder_providers.dart';

/// A preset option with a human-readable label and a computed target [DateTime].
typedef _Preset = ({String label, DateTime? target});

/// Bottom sheet for setting a reminder on a bookmark.
///
/// Displays preset time chips (1 hour, this evening, tomorrow 9am, 1 week,
/// custom), a repeat-mode toggle, and a title field. The save button is
/// disabled until a valid future date is selected.
class ReminderBottomSheet extends ConsumerStatefulWidget {
  /// Creates a [ReminderBottomSheet] for the given bookmark.
  const ReminderBottomSheet({
    required this.bookmarkId,
    required this.bookmarkTitle,
    super.key,
  });

  /// The bookmark to attach the reminder to.
  final int bookmarkId;

  /// Default title for the reminder.
  final String bookmarkTitle;

  /// Shows the sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required int bookmarkId,
    required String bookmarkTitle,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: AppShapes.bottomSheetShape,
      isScrollControlled: true,
      builder: (BuildContext ctx) => ReminderBottomSheet(
        bookmarkId: bookmarkId,
        bookmarkTitle: bookmarkTitle,
      ),
    );
  }

  @override
  ConsumerState<ReminderBottomSheet> createState() =>
      _ReminderBottomSheetState();
}

class _ReminderBottomSheetState extends ConsumerState<ReminderBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final Logger _logger = Logger();

  DateTime? _selectedDate;
  String _repeatMode = 'none';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.bookmarkTitle;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  List<_Preset> _buildPresets() {
    final DateTime now = DateTime.now();
    return <_Preset>[
      (label: '1 hour', target: now.add(const Duration(hours: 1))),
      (
        label: 'This evening',
        target: DateTime(now.year, now.month, now.day, 18).isAfter(now)
            ? DateTime(now.year, now.month, now.day, 18)
            : DateTime(now.year, now.month, now.day, 18)
                .add(const Duration(days: 1))
      ),
      (
        label: 'Tomorrow 9am',
        target: DateTime(now.year, now.month, now.day, 9)
            .add(const Duration(days: 1))
      ),
      (
        label: '1 week',
        target: now.add(const Duration(days: 7))
      ),
      (label: 'Custom', target: null),
    ];
  }

  bool get _canSave {
    if (_isSaving) return false;
    if (_selectedDate == null) return false;
    if (_selectedDate!.isBefore(DateTime.now())) return false;
    return true;
  }

  Future<void> _onSave() async {
    if (!_canSave) return;

    setState(() => _isSaving = true);

    final bool hasExactAlarmPermission =
        await ref.read(notificationServiceProvider).canScheduleExactNotifications();

    if (!hasExactAlarmPermission && mounted) {
      setState(() => _isSaving = false);
      _logger.w('Exact alarm permission denied — showing dialog');
      await _showExactAlarmPermissionDialog();
      return;
    }

    try {
      await ref.read(reminderManagerNotifierProvider.notifier).create(
            bookmarkId: widget.bookmarkId,
            title: _titleController.text.trim().isEmpty
                ? widget.bookmarkTitle
                : _titleController.text.trim(),
            scheduledAt: _selectedDate!,
            repeatMode: _repeatMode,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder set'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on Object catch (e, stackTrace) {
      _logger.e('Failed to save reminder', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set reminder: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _showExactAlarmPermissionDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
        ),
        title: const Text(
          'Exact Alarm Permission Required',
          style: AppTypography.sectionTitle,
        ),
        content: const Text(
          'To schedule reminders at the exact time you choose, Marky needs permission to set exact alarms. Please enable this in system settings.',
          style: AppTypography.body,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.label
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Open system alarm settings.
              // ignore: deprecated_member_use
              // We use a settings intent via platform channel or url_launcher.
              // For now, direct the user manually.
            },
            child: Text(
              'Open Settings',
              style: AppTypography.label
                  .copyWith(color: AppColors.accentPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onCustomPressed() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = now.add(const Duration(days: 1));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentPrimary,
              surface: AppColors.surface2,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay initialTime = TimeOfDay.fromDateTime(
      now.add(const Duration(minutes: 30)),
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentPrimary,
              surface: AppColors.surface2,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    final DateTime combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() => _selectedDate = combined);
  }

  @override
  Widget build(BuildContext context) {
    final List<_Preset> presets = _buildPresets();
    final bool isPast = _selectedDate != null &&
        _selectedDate!.isBefore(DateTime.now());

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Drag handle ─────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Title ───────────────────────────────────────────────
            const Padding(
              padding: AppShapes.horizontalScreenPadding,
              child: Text(
                'Set Reminder',
                style: AppTypography.sectionTitle,
              ),
            ),
            const SizedBox(height: 16),

            // ── Title text field ────────────────────────────────────
            Padding(
              padding: AppShapes.horizontalScreenPadding,
              child: TextField(
                controller: _titleController,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Reminder title',
                  hintStyle: AppTypography.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppShapes.radiusStandard),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Preset chips ────────────────────────────────────────
            Padding(
              padding: AppShapes.horizontalScreenPadding,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presets.map((_Preset preset) {
                  final bool isSelected = _selectedDate != null &&
                      preset.target != null &&
                      _selectedDate!.isAtSameMomentAs(preset.target!);
                  final bool isCustom = preset.target == null;

                  return _PresetChip(
                    label: preset.label,
                    isSelected: isSelected ||
                        (isCustom &&
                            _selectedDate != null &&
                            !_isPresetMatch(_selectedDate!, presets)),
                    onTap: () {
                      if (isCustom) {
                        _onCustomPressed();
                      } else {
                        setState(() => _selectedDate = preset.target);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Selected date display ───────────────────────────────
            if (_selectedDate != null)
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: Text(
                  _formatSelectedDate(_selectedDate!),
                  style: AppTypography.metadata.copyWith(
                    color: isPast ? AppColors.danger : AppColors.accentPrimary,
                  ),
                ),
              ),

            // ── Past-date error ─────────────────────────────────────
            if (isPast)
              Padding(
                padding: AppShapes.horizontalScreenPadding,
                child: Text(
                  'Please select a future time',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // ── Repeat mode toggle ──────────────────────────────────
            Padding(
              padding: AppShapes.horizontalScreenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Repeat',
                    style: AppTypography.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      _RepeatOption(
                        label: 'None',
                        isSelected: _repeatMode == 'none',
                        onTap: () => setState(() => _repeatMode = 'none'),
                      ),
                      const SizedBox(width: 8),
                      _RepeatOption(
                        label: 'Daily',
                        isSelected: _repeatMode == 'daily',
                        onTap: () => setState(() => _repeatMode = 'daily'),
                      ),
                      const SizedBox(width: 8),
                      _RepeatOption(
                        label: 'Weekly',
                        isSelected: _repeatMode == 'weekly',
                        onTap: () => setState(() => _repeatMode = 'weekly'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Save button ─────────────────────────────────────────
            Padding(
              padding: AppShapes.horizontalScreenPadding,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canSave ? _onSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    disabledBackgroundColor: AppColors.surface3,
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textTertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppShapes.radiusStandard),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : const Text(
                          'Save Reminder',
                          style: AppTypography.label,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _isPresetMatch(DateTime selected, List<_Preset> presets) {
    for (final _Preset preset in presets) {
      if (preset.target != null && selected.isAtSameMomentAs(preset.target!)) {
        return true;
      }
    }
    return false;
  }

  String _formatSelectedDate(DateTime dt) {
    final DateTime now = DateTime.now();
    final String timeStr =
        '${dt.hour.toString().padLeft(2)}:${dt.minute.toString().padLeft(2)}';

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime dtDay = DateTime(dt.year, dt.month, dt.day);
    final int dayDiff = dtDay.difference(today).inDays;

    if (dayDiff == 0) return 'Today at $timeStr';
    if (dayDiff == 1) return 'Tomorrow at $timeStr';
    if (dayDiff == -1) return 'Yesterday at $timeStr';

    return '${dt.day.toString().padLeft(2)}.${dt.month.toString().padLeft(2)}.${dt.year} $timeStr';
  }
}

// ─── Preset chip widget ────────────────────────────────────────────────

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.accentPrimary : AppColors.surface2,
      borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusCapsule),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Repeat option widget ──────────────────────────────────────────────

class _RepeatOption extends StatelessWidget {
  const _RepeatOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isSelected ? AppColors.accentPrimary : AppColors.surface2,
        borderRadius: BorderRadius.circular(AppShapes.radiusMini),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppShapes.radiusMini),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTypography.label.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
