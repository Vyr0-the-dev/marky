import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/theme.dart';
import 'package:marky/features/import_export/domain/models/import_result.dart';
import 'package:marky/features/import_export/presentation/providers/import_export_providers.dart';
import 'package:marky/features/import_export/presentation/widgets/import_result_dialog.dart';
import 'package:marky/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:marky/shared/models/app_settings.dart';

/// Settings screen with grouped setting tiles.
///
/// Lives in the settings feature folder per the build order.
class SettingsScreen extends ConsumerWidget {
  /// Creates the [SettingsScreen].
  const SettingsScreen({super.key});

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTypography.metadata.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.accentPrimary,
      activeTrackColor: AppColors.accentPrimary.withValues(alpha: 0.5),
      inactiveThumbColor: AppColors.textSecondary,
      inactiveTrackColor: AppColors.surface3,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            )
          : null,
      secondary: icon != null
          ? Icon(
              icon,
              color: AppColors.textSecondary,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(appSettingsProvider);
    final AppSettingsNotifier notifier = ref.read(appSettingsProvider.notifier);
    final ThemeMode currentMode =
        AppSettingsNotifier.themeModeFromString(settings.themeMode);
    final AsyncValue<String?> exportState = ref.watch(exportNotifierProvider);
    final AsyncValue<ImportResult?> importState = ref.watch(importNotifierProvider);

    // Listen for export completion / failure to show snackbars.
    ref.listen<AsyncValue<String?>>(
      exportNotifierProvider,
      (AsyncValue<String?>? previous, AsyncValue<String?> next) {
        next.when(
          data: (String? filePath) {
            if (filePath != null && filePath.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Exported to $filePath'),
                ),
              );
              // Reset so the same path doesn't trigger again on rebuild.
              ref.read(exportNotifierProvider.notifier).reset();
            }
          },
          loading: () {},
          error: (Object err, StackTrace stack) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Export failed: $err'),
                backgroundColor: Colors.redAccent,
              ),
            );
          },
        );
      },
    );

    // Listen for import state changes to show dialog / snackbar.
    ref.listen<AsyncValue<ImportResult?>>(
      importNotifierProvider,
      (AsyncValue<ImportResult?>? previous, AsyncValue<ImportResult?> next) {
        next.when(
          data: (ImportResult? result) {
            if (result != null) {
              // Show result dialog.
              showImportResultDialog(context, state: next);
              // Reset so the same result doesn't trigger again on rebuild.
              ref.read(importNotifierProvider.notifier).reset();
            }
          },
          loading: () {
            // Show progress dialog when loading starts.
            if (previous == null || !previous.isLoading) {
              showImportResultDialog(context, state: next);
            }
          },
          error: (Object err, StackTrace stack) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Import failed: $err'),
                backgroundColor: Colors.redAccent,
              ),
            );
            // Show error dialog as well.
            showImportResultDialog(context, state: next);
            ref.read(importNotifierProvider.notifier).reset();
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.base,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Appearance ──
            _buildSectionHeader('Appearance'),
            ListTile(
              leading: const Icon(
                Icons.palette_outlined,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'Theme',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Choose your preferred appearance',
                style: TextStyle(color: AppColors.textTertiary),
              ),
              trailing: SegmentedButton<ThemeMode>(
                segments: const <ButtonSegment<ThemeMode>>[
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.settings_suggest_outlined),
                  ),
                ],
                selected: <ThemeMode>{currentMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  notifier.setThemeMode(newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: AppColors.surface2,
                  selectedBackgroundColor: AppColors.accentPrimary,
                  selectedForegroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ),
            _buildSwitchTile(
              title: 'OLED pure black',
              subtitle: 'Use true black for dark backgrounds',
              value: settings.oledPureBlackEnabled,
              onChanged: notifier.setOledPureBlackEnabled,
              icon: Icons.contrast,
            ),

            // ── Behavior ──
            _buildSectionHeader('Behavior'),
            _buildSwitchTile(
              title: 'Haptic feedback',
              subtitle: 'Vibrate on interactions',
              value: settings.hapticsEnabled,
              onChanged: notifier.setHapticsEnabled,
              icon: Icons.vibration,
            ),
            _buildSwitchTile(
              title: 'Animations',
              subtitle: 'Enable transition animations',
              value: settings.animationsEnabled,
              onChanged: notifier.setAnimationsEnabled,
              icon: Icons.animation,
            ),
            _buildSwitchTile(
              title: 'Clipboard detection',
              subtitle: 'Suggest saving copied URLs',
              value: settings.clipboardDetectionEnabled,
              onChanged: notifier.setClipboardDetectionEnabled,
              icon: Icons.content_paste,
            ),

            // ── Organization ──
            _buildSectionHeader('Organization'),
            ListTile(
              leading: const Icon(
                Icons.label_outlined,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'Manage tags',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Create, edit, and organize your tags',
                style: TextStyle(color: AppColors.textTertiary),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
              onTap: () => context.push(Routes.tags),
            ),
            ListTile(
              leading: const Icon(
                Icons.folder_outlined,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'Manage collections',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Create, edit, and organize your collections',
                style: TextStyle(color: AppColors.textTertiary),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
              onTap: () => context.push(Routes.collections),
            ),
            ListTile(
              leading: const Icon(
                Icons.auto_fix_high,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'Automation rules',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Auto-organize bookmarks at capture time',
                style: TextStyle(color: AppColors.textTertiary),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
              onTap: () => context.push(Routes.automationRules),
            ),

            // ── Analytics ──
            _buildSectionHeader('Analytics'),
            ListTile(
              leading: const Icon(
                Icons.dashboard_outlined,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'Dashboard',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'View your bookmark insights and trends',
                style: TextStyle(color: AppColors.textTertiary),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
              onTap: () => context.push(Routes.dashboard),
            ),

            // ── Security ──
            _buildSectionHeader('Security'),
            ListTile(
              leading: const Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'Vault',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Biometric-protected bookmarks',
                style: TextStyle(color: AppColors.textTertiary),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
              onTap: () => context.push(Routes.vaultAuth),
            ),

            // ── Data ──
            _buildSectionHeader('Data'),
            ListTile(
              leading: const Icon(
                Icons.download_outlined,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'Export data',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Share a JSON backup of all your data',
                style: TextStyle(color: AppColors.textTertiary),
              ),
              trailing: exportState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
              onTap: exportState.isLoading
                  ? null
                  : () => ref.read(exportNotifierProvider.notifier).export(),
            ),
            ListTile(
              leading: const Icon(
                Icons.upload_file_outlined,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                'Import bookmarks',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Import bookmarks from browser HTML export',
                style: TextStyle(color: AppColors.textTertiary),
              ),
              trailing: importState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
              onTap: importState.isLoading
                  ? null
                  : () => ref.read(importNotifierProvider.notifier).importFromFile(),
            ),
          ],
        ),
      ),
    );
  }
}
