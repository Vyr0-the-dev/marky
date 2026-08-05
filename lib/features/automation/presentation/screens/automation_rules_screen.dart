import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/routing/routes.dart';
import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/automation/presentation/providers/automation_providers.dart';
import 'package:marky/features/automation/presentation/widgets/rule_card.dart';
import 'package:marky/shared/models/automation_rule.dart';

/// Full-screen automation rule manager showing all rules with toggles.
///
/// Watches [automationRuleNotifierProvider] for live CRUD state.
class AutomationRulesScreen extends ConsumerWidget {
  /// Creates an [AutomationRulesScreen].
  const AutomationRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AutomationRule>> rulesAsync =
        ref.watch(automationRuleNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.base,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('Automation Rules'),
      ),
      body: rulesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (Object error, StackTrace? stackTrace) => _ErrorState(
          onRetry: () =>
              ref.read(automationRuleNotifierProvider.notifier).load(),
        ),
        data: (List<AutomationRule> rules) {
          if (rules.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            padding: AppShapes.screenPaddingInsets,
            itemCount: rules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final AutomationRule rule = rules[index];
              return RuleCard(
                rule: rule,
                onTap: () => context.push(
                  Routes.automationRuleEditWithId
                      .replaceAll(':id', rule.id.toString()),
                ),
                onToggle: () => ref
                    .read(automationRuleNotifierProvider.notifier)
                    .toggleEnabled(rule),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.automationRuleEdit),
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.textPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.auto_fix_high,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No automation rules yet',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create rules to auto-organize bookmarks at capture time',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Error state ───────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          const Text(
            'Failed to load rules',
            style: AppTypography.body,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
