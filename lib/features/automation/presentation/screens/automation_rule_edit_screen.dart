import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marky/app/providers/app_providers.dart';
import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/automation/domain/models/rule_action.dart';
import 'package:marky/features/automation/domain/models/rule_trigger.dart';
import 'package:marky/features/automation/presentation/providers/automation_providers.dart';
import 'package:marky/features/automation/presentation/widgets/action_builder.dart';
import 'package:marky/features/automation/presentation/widgets/trigger_builder.dart';
import 'package:marky/shared/models/automation_rule.dart';

/// Screen for creating or editing an automation rule.
class AutomationRuleEditScreen extends ConsumerStatefulWidget {
  /// Creates an [AutomationRuleEditScreen] for creating a new rule.
  const AutomationRuleEditScreen({super.key}) : ruleId = null;

  /// Creates an [AutomationRuleEditScreen] for editing an existing rule.
  const AutomationRuleEditScreen.edit({required this.ruleId, super.key});

  /// The ID of the rule to edit, or null for create mode.
  final int? ruleId;

  @override
  ConsumerState<AutomationRuleEditScreen> createState() =>
      _AutomationRuleEditScreenState();
}

class _AutomationRuleEditScreenState
    extends ConsumerState<AutomationRuleEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();

  RuleTrigger _trigger = const RuleTrigger(
    triggerType: RuleTriggerType.domainEquals,
    config: <String, dynamic>{},
  );
  List<RuleAction> _actions = <RuleAction>[];

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.ruleId != null) {
      _loadRule();
    } else {
      _priorityController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  Future<void> _loadRule() async {
    setState(() => _isLoading = true);
    try {
      final AutomationRule? rule = await ref
          .read(automationRuleRepositoryProvider)
          .getById(widget.ruleId!);
      if (rule != null && mounted) {
        setState(() {
          _nameController.text = rule.name;
          _descriptionController.text = rule.description ?? '';
          _priorityController.text = rule.priority.toString();
          final Map<String, dynamic> triggerJson =
              jsonDecode(rule.triggerConfig) as Map<String, dynamic>;
          _trigger = RuleTrigger.fromJson(triggerJson);
          final List<dynamic> rawActions =
              jsonDecode(rule.actions) as List<dynamic>;
          _actions = rawActions
              .cast<Map<String, dynamic>>()
              .map(RuleAction.fromJson)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _save() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Rule name is required');
      return;
    }

    if (_actions.isEmpty) {
      _showError('At least one action is required');
      return;
    }

    final int priority = int.tryParse(_priorityController.text.trim()) ?? 0;

    setState(() => _isSaving = true);

    try {
      if (widget.ruleId != null) {
        // Update existing rule
        final AutomationRule? existing = await ref
            .read(automationRuleRepositoryProvider)
            .getById(widget.ruleId!);
        if (existing == null) {
          _showError('Rule not found');
          setState(() => _isSaving = false);
          return;
        }

        existing
          ..name = name
          ..description = _descriptionController.text.trim()
          ..triggerType = _trigger.triggerType.name
          ..triggerConfig = jsonEncode(_trigger.toJson())
          ..actions = jsonEncode(_actions.map((RuleAction a) => a.toJson()).toList())
          ..priority = priority
          ..updatedAt = DateTime.now();

        await ref
            .read(automationRuleNotifierProvider.notifier)
            .update(existing);
      } else {
        // Create new rule
        await ref.read(automationRuleNotifierProvider.notifier).create(
              name: name,
              description: _descriptionController.text.trim(),
              triggerType: _trigger.triggerType,
              triggerConfig: _trigger.config,
              actions: _actions,
              priority: priority,
            );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to save rule: $e');
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.ruleId != null ? 'Edit Rule' : 'New Rule';

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.base,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(title),
        actions: <Widget>[
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: AppTypography.label.copyWith(
                  color: AppColors.accentPrimary,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: AppShapes.screenPaddingInsets.copyWith(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Name ──
          _buildSectionTitle('Rule Name'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: _inputDecoration(
              hint: 'e.g. Auto-archive YouTube links',
            ),
          ),

          // ── Description ──
          const SizedBox(height: 20),
          _buildSectionTitle('Description'),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: _inputDecoration(
              hint: 'What does this rule do?',
            ),
            maxLines: 2,
          ),

          // ── Trigger ──
          const SizedBox(height: 20),
          _buildSectionTitle('Trigger'),
          const SizedBox(height: 8),
          TriggerBuilder(
            triggerType: _trigger.triggerType,
            config: _trigger.config,
            onChanged: (RuleTrigger trigger) {
              setState(() => _trigger = trigger);
            },
          ),

          // ── Actions ──
          const SizedBox(height: 20),
          _buildSectionTitle('Actions'),
          const SizedBox(height: 8),
          ActionBuilder(
            actions: _actions,
            onChanged: (List<RuleAction> actions) {
              setState(() => _actions = actions);
            },
          ),

          // ── Priority ──
          const SizedBox(height: 20),
          _buildSectionTitle('Priority'),
          const SizedBox(height: 8),
          TextField(
            controller: _priorityController,
            keyboardType: TextInputType.number,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: _inputDecoration(
              hint: 'Lower numbers run first',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rules are evaluated in priority order (0 first).',
            style: AppTypography.metadata,
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPrimary,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Rule'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.sectionTitle.copyWith(fontSize: 16),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.surface3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
