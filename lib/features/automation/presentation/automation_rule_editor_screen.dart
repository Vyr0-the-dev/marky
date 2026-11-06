import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';
import 'package:marky/features/automation/data/automation_rule_providers.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Create / edit screen for a single automation rule.
class AutomationRuleEditorScreen extends ConsumerStatefulWidget {
  const AutomationRuleEditorScreen({this.ruleId, super.key});

  /// `null` → create mode, otherwise edit.
  final int? ruleId;

  @override
  ConsumerState<AutomationRuleEditorScreen> createState() =>
      _AutomationRuleEditorScreenState();
}

class _AutomationRuleEditorScreenState
    extends ConsumerState<AutomationRuleEditorScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _priorityCtrl =
      TextEditingController(text: '100');
  final List<_ConditionDraft> _conditions = <_ConditionDraft>[
    _ConditionDraft(),
  ];
  final List<_ActionDraft> _actions = <_ActionDraft>[_ActionDraft()];

  AutomationTriggerLogic _triggerLogic = AutomationTriggerLogic.all;
  AutomationRule? _loadedRule;
  bool _enabled = true;
  bool _saving = false;

  bool get _isEdit => widget.ruleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final AutomationRule? rule = await ref
        .read(automationRuleRepositoryProvider)
        .getById(widget.ruleId!);
    if (rule == null || !mounted) return;
    setState(() {
      _loadedRule = rule;
      _nameCtrl.text = rule.name;
      _descriptionCtrl.text = rule.description ?? '';
      _triggerLogic = rule.triggerLogic;
      _enabled = rule.enabled;
      _priorityCtrl.text = rule.priority.toString();
      for (final _ConditionDraft condition in _conditions) {
        condition.dispose();
      }
      _conditions
        ..clear()
        ..addAll(rule.conditions.map(_ConditionDraft.fromCondition));
      for (final _ActionDraft action in _actions) {
        action.dispose();
      }
      _actions
        ..clear()
        ..addAll(
          rule.actions.isEmpty
              ? <_ActionDraft>[_ActionDraft()]
              : rule.actions.map(_ActionDraft.fromAction),
        );
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priorityCtrl.dispose();
    for (final _ConditionDraft condition in _conditions) {
      condition.dispose();
    }
    for (final _ActionDraft action in _actions) {
      action.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit
            ? (l10n?.automationEditRule ?? 'Edit Rule')
            : (l10n?.automationNewRule ?? 'New Rule')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
        children: <Widget>[
          // ── Name ──────────────────────────────────────────
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: l10n?.automationRuleName ?? 'Rule name',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          TextField(
            controller: _descriptionCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText:
                  l10n?.automationRuleDescription ?? 'Description (optional)',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n?.automationRuleEnabled ?? 'Enabled'),
            value: _enabled,
            onChanged: (bool value) => setState(() => _enabled = value),
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          TextField(
            controller: _priorityCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n?.automationRulePriority ?? 'Priority',
              helperText: l10n?.automationRulePriorityHint ??
                  'Lower numbers run first.',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.lg),

          Text(l10n?.automationWhen ?? 'When…',
              style: theme.textTheme.titleSmall),
          const SizedBox(height: ReadingRoomSpacing.sm),
          SegmentedButton<AutomationTriggerLogic>(
            segments: const <ButtonSegment<AutomationTriggerLogic>>[
              ButtonSegment<AutomationTriggerLogic>(
                value: AutomationTriggerLogic.all,
                label: Text('AND'),
              ),
              ButtonSegment<AutomationTriggerLogic>(
                value: AutomationTriggerLogic.any,
                label: Text('OR'),
              ),
            ],
            selected: <AutomationTriggerLogic>{_triggerLogic},
            onSelectionChanged: (Set<AutomationTriggerLogic> selected) {
              setState(() => _triggerLogic = selected.first);
            },
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          for (int i = 0; i < _conditions.length; i++)
            _buildConditionEditor(context, i),
          TextButton.icon(
            onPressed: _addCondition,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add condition'),
          ),
          const SizedBox(height: ReadingRoomSpacing.lg),

          // ── Action ────────────────────────────────────────
          Text(l10n?.automationThen ?? 'Then…',
              style: theme.textTheme.titleSmall),
          const SizedBox(height: ReadingRoomSpacing.sm),
          for (int i = 0; i < _actions.length; i++)
            _buildActionEditor(context, i),
          TextButton.icon(
            onPressed: _addAction,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n?.automationAddAction ?? 'Add action'),
          ),
          const SizedBox(height: ReadingRoomSpacing.xl),

          // ── Save ──────────────────────────────────────────
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_isEdit
                ? (l10n?.actionUpdate ?? 'Update')
                : (l10n?.actionCreate ?? 'Create')),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final String name = _nameCtrl.text.trim();
    final String description = _descriptionCtrl.text.trim();
    final int priority = int.tryParse(_priorityCtrl.text.trim()) ?? 100;
    final List<AutomationCondition> conditions = <AutomationCondition>[
      for (final _ConditionDraft condition in _conditions)
        AutomationCondition(
          type: condition.type,
          value: condition.value.text.trim(),
        ),
    ];
    final List<AutomationAction> actions = <AutomationAction>[
      for (final _ActionDraft action in _actions)
        AutomationAction(
          type: action.type,
          arg: _actionRequiresArg(action.type) ? action.arg.text.trim() : '',
        ),
    ];

    if (name.isEmpty ||
        conditions.any(
          (AutomationCondition condition) => condition.value.isEmpty,
        ) ||
        actions.isEmpty ||
        actions.any(
          (AutomationAction action) =>
              _actionRequiresArg(action.type) && action.arg.isEmpty,
        )) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.automationAllFieldsRequired ??
                  'All fields are required.',
            ),
          ),
        );
      return;
    }

    setState(() => _saving = true);

    try {
      final DateTime now = DateTime.now();
      final AutomationCondition primaryCondition = conditions.first;
      final AutomationRule rule = AutomationRule(
        id: widget.ruleId,
        name: name,
        description: description.isEmpty ? null : description,
        enabled: _enabled,
        triggerType: primaryCondition.type,
        triggerValue: primaryCondition.value,
        triggerLogic: _triggerLogic,
        conditions: conditions,
        actions: actions,
        priority: priority,
        executionCount: _loadedRule?.executionCount ?? 0,
        lastExecutedAt: _loadedRule?.lastExecutedAt,
        createdAt: _loadedRule?.createdAt ?? now,
        updatedAt: now,
      );

      await ref.read(automationRuleRepositoryProvider).save(rule);

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.automationSaveFailed(
                      e.toString(),
                    ) ??
                    'Save failed: $e',
              ),
            ),
          );
      }
    }
  }

  Widget _buildConditionEditor(BuildContext context, int index) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final _ConditionDraft condition = _conditions[index];
    return Card(
      margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.md),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<AutomationTriggerType>(
                    initialValue: condition.type,
                    decoration: InputDecoration(
                      labelText: l10n?.automationTriggerType ?? 'Trigger type',
                      border: const OutlineInputBorder(),
                    ),
                    items: AutomationTriggerType.values
                        .map(
                          (AutomationTriggerType t) =>
                              DropdownMenuItem<AutomationTriggerType>(
                            value: t,
                            child: Text(_triggerLabel(t)),
                          ),
                        )
                        .toList(),
                    onChanged: (AutomationTriggerType? value) {
                      if (value == null) return;
                      setState(() => condition.type = value);
                    },
                  ),
                ),
                if (_conditions.length > 1) ...<Widget>[
                  const SizedBox(width: ReadingRoomSpacing.sm),
                  IconButton(
                    tooltip: l10n?.actionDelete ?? 'Delete',
                    onPressed: () => _removeCondition(index),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            TextField(
              controller: condition.value,
              decoration: InputDecoration(
                labelText: _triggerHint(condition.type),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionEditor(BuildContext context, int index) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final _ActionDraft action = _actions[index];
    final bool requiresArg = _actionRequiresArg(action.type);
    return Card(
      margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.md),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<AutomationActionType>(
                    initialValue: action.type,
                    decoration: InputDecoration(
                      labelText: l10n?.automationActionType ?? 'Action type',
                      border: const OutlineInputBorder(),
                    ),
                    items: AutomationActionType.values
                        .map(
                          (AutomationActionType a) =>
                              DropdownMenuItem<AutomationActionType>(
                            value: a,
                            child: Text(_actionLabel(a)),
                          ),
                        )
                        .toList(),
                    onChanged: (AutomationActionType? value) {
                      if (value == null) return;
                      setState(() => action.type = value);
                    },
                  ),
                ),
                if (_actions.length > 1) ...<Widget>[
                  const SizedBox(width: ReadingRoomSpacing.sm),
                  IconButton(
                    tooltip: l10n?.actionDelete ?? 'Delete',
                    onPressed: () => _removeAction(index),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ],
            ),
            if (requiresArg) ...<Widget>[
              const SizedBox(height: ReadingRoomSpacing.md),
              TextField(
                controller: action.arg,
                decoration: InputDecoration(
                  labelText: _actionArgHint(action.type),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addCondition() {
    setState(() => _conditions.add(_ConditionDraft()));
  }

  void _removeCondition(int index) {
    if (_conditions.length <= 1) return;
    final _ConditionDraft removed = _conditions.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  void _addAction() {
    setState(() => _actions.add(_ActionDraft()));
  }

  void _removeAction(int index) {
    if (_actions.length <= 1) return;
    final _ActionDraft removed = _actions.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  // ── Labels ──────────────────────────────────────────────────────

  static String _triggerLabel(AutomationTriggerType t) {
    switch (t) {
      case AutomationTriggerType.domainEquals:
        return 'Domain equals';
      case AutomationTriggerType.domainContains:
        return 'Domain contains';
      case AutomationTriggerType.urlContains:
        return 'URL contains';
      case AutomationTriggerType.sourceTypeEquals:
        return 'Source type equals';
      case AutomationTriggerType.tagContains:
        return 'Tag contains';
      case AutomationTriggerType.unreadForDays:
        return 'Unread for days';
      case AutomationTriggerType.addedWithinDays:
        return 'Added within days';
    }
  }

  static String _triggerHint(AutomationTriggerType t) {
    switch (t) {
      case AutomationTriggerType.domainEquals:
        return 'e.g. youtube.com';
      case AutomationTriggerType.domainContains:
        return 'e.g. github';
      case AutomationTriggerType.urlContains:
        return 'e.g. /blog/';
      case AutomationTriggerType.sourceTypeEquals:
        return 'e.g. share';
      case AutomationTriggerType.tagContains:
        return 'Tag ID';
      case AutomationTriggerType.unreadForDays:
        return 'Days';
      case AutomationTriggerType.addedWithinDays:
        return 'Days';
    }
  }

  static String _actionLabel(AutomationActionType a) {
    switch (a) {
      case AutomationActionType.addTag:
        return 'Add tag';
      case AutomationActionType.addToCollection:
        return 'Add to collection';
      case AutomationActionType.setFavorite:
        return 'Set favorite';
      case AutomationActionType.setArchived:
        return 'Set archived';
      case AutomationActionType.setPinned:
        return 'Set pinned';
      case AutomationActionType.addReminder:
        return 'Add reminder';
    }
  }

  static String _actionArgHint(AutomationActionType a) {
    switch (a) {
      case AutomationActionType.addTag:
        return 'Tag name (e.g. twitter)';
      case AutomationActionType.addToCollection:
        return 'Collection name or ID';
      case AutomationActionType.setFavorite:
      case AutomationActionType.setArchived:
      case AutomationActionType.setPinned:
        return 'true or false';
      case AutomationActionType.addReminder:
        return 'Days from now';
    }
  }

  static bool _actionRequiresArg(AutomationActionType action) {
    return true;
  }
}

class _ConditionDraft {
  _ConditionDraft({
    this.type = AutomationTriggerType.domainEquals,
    String value = '',
  }) : value = TextEditingController(text: value);

  factory _ConditionDraft.fromCondition(AutomationCondition condition) {
    return _ConditionDraft(type: condition.type, value: condition.value);
  }

  AutomationTriggerType type;
  final TextEditingController value;

  void dispose() {
    value.dispose();
  }
}

class _ActionDraft {
  _ActionDraft({
    this.type = AutomationActionType.addTag,
    String arg = '',
  }) : arg = TextEditingController(text: arg);

  factory _ActionDraft.fromAction(AutomationAction action) {
    return _ActionDraft(type: action.type, arg: action.arg);
  }

  AutomationActionType type;
  final TextEditingController arg;

  void dispose() {
    arg.dispose();
  }
}
