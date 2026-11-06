import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/routing/routes.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/automation/data/automation_rule_providers.dart';
import 'package:marky/features/automation/domain/automation_debug_log.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';
import 'package:marky/features/automation/domain/automation_rule_repository.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Lists all automation rules with toggle and delete.
class AutomationRulesScreen extends ConsumerWidget {
  const AutomationRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AutomationRule>> rulesAsync =
        ref.watch(automationRulesProvider);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.settingsAutomationLabel ?? 'Automation Rules',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: l10n?.automationGuideTooltip ?? 'Automation guide',
            onPressed: () => _showGuide(context),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Debug logs',
            onPressed: () => _showDebugLogs(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create rule',
            onPressed: () => context.push(Routes.automationRuleNew),
          ),
        ],
      ),
      body: rulesAsync.when(
        data: (List<AutomationRule> rules) {
          if (rules.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
              children: <Widget>[
                _AutomationGuideCard(
                  onCreate: () => context.push(Routes.automationRuleNew),
                  onGuide: () => _showGuide(context),
                ),
                const SizedBox(height: ReadingRoomSpacing.xl),
                Text(
                  l10n?.automationRulesEmpty ??
                      'No automation rules yet.\nTap + to create one.',
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: ReadingRoomSpacing.lg),
            itemCount: rules.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
                  child: _AutomationGuideCard(
                    onCreate: () => context.push(Routes.automationRuleNew),
                    onGuide: () => _showGuide(context),
                  ),
                );
              }
              final AutomationRule rule = rules[index - 1];
              return _RuleTile(rule: rule);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (Object e, _) => Center(
            child: Text(
                AppLocalizations.of(context)?.detailInlineError(e.toString()) ??
                    'Error: $e')),
      ),
    );
  }

  void _showGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _AutomationGuideSheet(),
    );
  }

  void _showDebugLogs(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _AutomationDebugLogSheet(),
    );
  }
}

class _AutomationDebugLogSheet extends ConsumerWidget {
  const _AutomationDebugLogSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AutomationDebugLogEntry>> logsAsync =
        ref.watch(automationDebugLogsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
        child: logsAsync.when(
          data: (List<AutomationDebugLogEntry> logs) {
            if (logs.isEmpty) {
              return Center(
                  child: Text(AppLocalizations.of(context)?.automationNoLogs ??
                      'No automation logs yet.'));
            }
            return ListView.separated(
              itemCount: logs.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: ReadingRoomSpacing.lg),
              itemBuilder: (BuildContext context, int index) {
                final AutomationDebugLogEntry log = logs[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bolt_rounded),
                  title: Text(log.ruleName),
                  subtitle: Text(
                    '${_formatTime(log.timestamp)} • bookmark '
                    '${log.bookmarkId ?? 'unknown'}\n${log.message}',
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (Object error, _) => Center(
              child: Text(AppLocalizations.of(context)
                      ?.detailInlineError(error.toString()) ??
                  'Error: $error')),
        ),
      ),
    );
  }

  static String _formatTime(DateTime value) {
    String two(int input) => input.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }
}

class _AutomationGuideCard extends StatelessWidget {
  const _AutomationGuideCard({
    required this.onCreate,
    required this.onGuide,
  });

  final VoidCallback onCreate;
  final VoidCallback onGuide;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.auto_fix_high_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Text(
                  l10n?.automationGuideCardTitle ?? 'How rules work',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.sm),
            Text(
              l10n?.automationGuideCardBody ??
                  'Rules run after a link is saved. Start with one trigger '
                      'and one action, then test with a single link.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            const Wrap(
              spacing: ReadingRoomSpacing.xs,
              runSpacing: ReadingRoomSpacing.xs,
              children: <Widget>[
                _TemplateChip(label: 'YouTube → Watch later'),
                _TemplateChip(label: 'GitHub → Code tag'),
                _TemplateChip(label: 'Pricing → Archive'),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            Row(
              children: <Widget>[
                FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create rule'),
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                TextButton(
                  onPressed: onGuide,
                  child: Text(l10n?.automationGuideTitle ?? 'Guide'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AutomationGuideSheet extends StatefulWidget {
  const _AutomationGuideSheet();

  @override
  State<_AutomationGuideSheet> createState() => _AutomationGuideSheetState();
}

class _AutomationGuideSheetState extends State<_AutomationGuideSheet> {
  late final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    final List<_GuidePage> pages = <_GuidePage>[
      _GuidePage(
        icon: Icons.travel_explore_rounded,
        title: l10n?.automationGuideTriggerTitle ?? '1. Choose a trigger',
        body: l10n?.automationGuideTriggerBody ??
            'Use domain equals for exact sites like youtube.com, '
                'domain contains for broader matches like github, or URL '
                'contains for folders such as /blog/.',
      ),
      _GuidePage(
        icon: Icons.auto_fix_high_rounded,
        title: l10n?.automationGuideActionTitle ?? '2. Choose an action',
        body: l10n?.automationGuideActionBody ??
            'Add a tag, add to a collection, archive, mark read, '
                'pin, favorite, or add a reminder.',
      ),
      _GuidePage(
        icon: Icons.science_rounded,
        title: l10n?.automationGuideTestTitle ?? '3. Test with one link',
        body: l10n?.automationGuideTestBody ??
            'Save a matching link, then open Debug logs from this screen '
                'to see whether the rule matched and what it changed.',
      ),
      _GuidePage(
        icon: Icons.lightbulb_rounded,
        title: l10n?.automationGuideExamplesTitle ?? 'Examples',
        body: l10n?.automationGuideExamplesBody ??
            'github → add tag "Code"; youtube.com → add to collection '
                '"Watch later"; /pricing → archive; unread for 30 days → '
                'add tag "Review".',
      ),
    ];

    return SafeArea(
      child: SizedBox(
        height: 420,
        child: Column(
          children: <Widget>[
            const SizedBox(height: ReadingRoomSpacing.sm),
            Text(
              l10n?.automationGuideTitle ?? 'Automation guide',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.lg),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ReadingRoomSpacing.xl,
                    ),
                    child: pages[index],
                  );
                },
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(pages.length, (int index) {
                final bool active = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
            const SizedBox(height: ReadingRoomSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
      side: BorderSide(
        color: theme.colorScheme.primary.withValues(alpha: 0.18),
      ),
    );
  }
}

class _GuidePage extends StatelessWidget {
  const _GuidePage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Icon(
              icon,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: ReadingRoomSpacing.xl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: ReadingRoomSpacing.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _RuleTile extends ConsumerWidget {
  const _RuleTile({required this.rule});

  final AutomationRule rule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return SwitchListTile(
      title: Text(rule.name),
      subtitle: Text(
        '${_logicLabel(rule)} ${rule.conditions.length} condition(s)  •  '
        '${rule.actions.length} action(s)',
        style: theme.textTheme.bodySmall,
      ),
      secondary: PopupMenuButton<String>(
        onSelected: (String value) => _onAction(context, ref, value),
        itemBuilder: (_) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'edit',
            child: Text(AppLocalizations.of(context)?.actionEdit ?? 'Edit'),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Text(AppLocalizations.of(context)?.actionDelete ?? 'Delete'),
          ),
        ],
      ),
      value: rule.enabled,
      onChanged: (bool enabled) => _toggleEnabled(ref, enabled),
    );
  }

  static String _logicLabel(AutomationRule rule) {
    return switch (rule.triggerLogic) {
      AutomationTriggerLogic.all => 'AND',
      AutomationTriggerLogic.any => 'OR',
    };
  }

  Future<void> _toggleEnabled(WidgetRef ref, bool enabled) async {
    final AutomationRuleRepository repo =
        ref.read(automationRuleRepositoryProvider);
    await repo.save(rule.copyWith(enabled: enabled));
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (rule.id == null) return;

    if (action == 'edit') {
      if (context.mounted) {
        await context.push(Routes.automationRuleEditPath(rule.id!));
      }
      return;
    }

    if (action != 'delete') return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)
                ?.automationDeleteRuleTitle(rule.name) ??
            'Delete "${rule.name}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context)?.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(context)?.actionDelete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(automationRuleRepositoryProvider).delete(rule.id!);
    }
  }
}
