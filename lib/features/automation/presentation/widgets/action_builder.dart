import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/automation/domain/models/rule_action.dart';

/// Widget for building and editing a list of [RuleAction] configurations.
class ActionBuilder extends StatefulWidget {
  /// Creates an [ActionBuilder].
  const ActionBuilder({
    required this.actions,
    required this.onChanged,
    super.key,
  });

  final List<RuleAction> actions;
  final ValueChanged<List<RuleAction>> onChanged;

  @override
  State<ActionBuilder> createState() => _ActionBuilderState();
}

class _ActionBuilderState extends State<ActionBuilder> {
  late final List<RuleAction> _actions;

  @override
  void initState() {
    super.initState();
    _actions = List<RuleAction>.from(widget.actions);
  }

  void _notifyChange() {
    widget.onChanged(List<RuleAction>.from(_actions));
  }

  void _addAction(RuleActionType type) {
    setState(() {
      _actions.add(RuleAction(actionType: type, config: const <String, dynamic>{}));
    });
    _notifyChange();
  }

  void _removeAction(int index) {
    setState(() {
      _actions.removeAt(index);
    });
    _notifyChange();
  }

  void _updateAction(int index, RuleAction action) {
    setState(() {
      _actions[index] = action;
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ..._actions.asMap().entries.map((MapEntry<int, RuleAction> entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActionRow(
              action: entry.value,
              onChanged: (RuleAction action) => _updateAction(entry.key, action),
              onRemove: () => _removeAction(entry.key),
            ),
          );
        }),
        const SizedBox(height: 8),
        _buildAddActionButton(),
      ],
    );
  }

  Widget _buildAddActionButton() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: RuleActionType.values.map((RuleActionType type) {
        return ActionChip(
          label: Text(
            _actionTypeLabel(type),
            style: AppTypography.metadata.copyWith(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.surface3,
          side: BorderSide.none,
          avatar: const Icon(
            Icons.add,
            size: 16,
            color: AppColors.accentPrimary,
          ),
          onPressed: () => _addAction(type),
        );
      }).toList(),
    );
  }

  String _actionTypeLabel(RuleActionType type) {
    switch (type) {
      case RuleActionType.addTag:
        return 'Add tag';
      case RuleActionType.addToCollection:
        return 'Add to collection';
      case RuleActionType.archive:
        return 'Archive';
      case RuleActionType.addReminder:
        return 'Add reminder';
      case RuleActionType.moveToVault:
        return 'Move to vault';
      case RuleActionType.markAsFavorite:
        return 'Mark favorite';
    }
  }
}

// ─── Individual action row ─────────────────────────────────────────────

class _ActionRow extends StatefulWidget {
  const _ActionRow({
    required this.action,
    required this.onChanged,
    required this.onRemove,
  });

  final RuleAction action;
  final ValueChanged<RuleAction> onChanged;
  final VoidCallback onRemove;

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  late final Map<String, dynamic> _config;

  @override
  void initState() {
    super.initState();
    _config = Map<String, dynamic>.from(widget.action.config);
  }

  void _notifyChange() {
    widget.onChanged(
      RuleAction(actionType: widget.action.actionType, config: _config),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                _actionIcon(widget.action.actionType),
                size: 18,
                color: AppColors.accentPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _actionTypeLabel(widget.action.actionType),
                  style: AppTypography.cardTitle,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.danger,
                ),
                onPressed: widget.onRemove,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildConfigFields(),
        ],
      ),
    );
  }

  Widget _buildConfigFields() {
    switch (widget.action.actionType) {
      case RuleActionType.addTag:
        return _buildTextField(
          label: 'Tag ID or Slug',
          hint: 'tagId: 42 or tagSlug: flutter',
          keyName: 'tagId',
          fallbackKey: 'tagSlug',
        );
      case RuleActionType.addToCollection:
        return _buildTextField(
          label: 'Collection ID or Slug',
          hint: 'collectionId: 7 or collectionSlug: work',
          keyName: 'collectionId',
          fallbackKey: 'collectionSlug',
        );
      case RuleActionType.addReminder:
        return Column(
          children: <Widget>[
            _buildTextField(
              label: 'Title',
              hint: 'Read later',
              keyName: 'title',
            ),
            const SizedBox(height: 8),
            _buildTextField(
              label: 'Body (optional)',
              hint: 'Check this article',
              keyName: 'body',
            ),
          ],
        );
      case RuleActionType.archive:
      case RuleActionType.moveToVault:
      case RuleActionType.markAsFavorite:
        return const Text(
          'No configuration needed.',
          style: AppTypography.metadata,
        );
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String keyName,
    String? fallbackKey,
  }) {
    final String initialValue = _config[keyName]?.toString() ??
        (fallbackKey != null ? _config[fallbackKey]?.toString() ?? '' : '');

    return TextField(
      controller: TextEditingController(text: initialValue),
      style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.metadata.copyWith(color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusMini),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      onChanged: (String value) {
        if (value.isEmpty) {
          _config.remove(keyName);
          if (fallbackKey != null) _config.remove(fallbackKey);
        } else {
          final int? parsed = int.tryParse(value);
          if (parsed != null) {
            _config[keyName] = parsed;
            if (fallbackKey != null) _config.remove(fallbackKey);
          } else {
            if (fallbackKey != null) {
              _config[fallbackKey] = value;
            }
            _config.remove(keyName);
          }
        }
        _notifyChange();
      },
    );
  }

  String _actionTypeLabel(RuleActionType type) {
    switch (type) {
      case RuleActionType.addTag:
        return 'Add tag';
      case RuleActionType.addToCollection:
        return 'Add to collection';
      case RuleActionType.archive:
        return 'Archive';
      case RuleActionType.addReminder:
        return 'Add reminder';
      case RuleActionType.moveToVault:
        return 'Move to vault';
      case RuleActionType.markAsFavorite:
        return 'Mark favorite';
    }
  }

  IconData _actionIcon(RuleActionType type) {
    switch (type) {
      case RuleActionType.addTag:
        return Icons.label;
      case RuleActionType.addToCollection:
        return Icons.folder;
      case RuleActionType.archive:
        return Icons.archive;
      case RuleActionType.addReminder:
        return Icons.alarm;
      case RuleActionType.moveToVault:
        return Icons.lock;
      case RuleActionType.markAsFavorite:
        return Icons.star;
    }
  }
}
