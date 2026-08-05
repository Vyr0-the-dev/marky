import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/automation/domain/models/rule_trigger.dart';

/// Widget for building and editing a [RuleTrigger] configuration.
class TriggerBuilder extends StatefulWidget {
  /// Creates a [TriggerBuilder].
  const TriggerBuilder({
    required this.triggerType,
    required this.config,
    required this.onChanged,
    super.key,
  });

  final RuleTriggerType triggerType;
  final Map<String, dynamic> config;
  final ValueChanged<RuleTrigger> onChanged;

  @override
  State<TriggerBuilder> createState() => _TriggerBuilderState();
}

class _TriggerBuilderState extends State<TriggerBuilder> {
  late RuleTriggerType _selectedType;
  late final Map<String, dynamic> _config;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.triggerType;
    _config = Map<String, dynamic>.from(widget.config);
  }

  void _notifyChange() {
    widget.onChanged(
      RuleTrigger(triggerType: _selectedType, config: _config),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTriggerDropdown(),
        const SizedBox(height: 12),
        _buildConfigFields(),
      ],
    );
  }

  Widget _buildTriggerDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RuleTriggerType>(
          value: _selectedType,
          isExpanded: true,
          dropdownColor: AppColors.surface3,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          onChanged: (RuleTriggerType? value) {
            if (value == null) return;
            setState(() {
              _selectedType = value;
              _config.clear();
            });
            _notifyChange();
          },
          items: RuleTriggerType.values.map((RuleTriggerType type) {
            return DropdownMenuItem<RuleTriggerType>(
              value: type,
              child: Text(
                _triggerTypeLabel(type),
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildConfigFields() {
    switch (_selectedType) {
      case RuleTriggerType.domainEquals:
      case RuleTriggerType.domainContains:
        return _buildTextField(
          label: 'Domain',
          hint: 'e.g. youtube.com',
          keyName: 'domain',
        );
      case RuleTriggerType.sourceTypeEquals:
        return _buildTextField(
          label: 'Source Type',
          hint: 'e.g. share_sheet, manual',
          keyName: 'sourceType',
        );
      case RuleTriggerType.urlContains:
        return _buildTextField(
          label: 'URL Pattern',
          hint: 'e.g. github.com/flutter',
          keyName: 'pattern',
        );
      case RuleTriggerType.hasTag:
        return _buildNumberField(
          label: 'Tag ID',
          hint: 'e.g. 42',
          keyName: 'tagId',
        );
      case RuleTriggerType.isUnread:
        return const Text(
          'No configuration needed — triggers on unread bookmarks.',
          style: AppTypography.metadata,
        );
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String keyName,
  }) {
    return TextField(
      controller: TextEditingController(text: _config[keyName]?.toString() ?? ''),
      style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.metadata.copyWith(color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.surface3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: (String value) {
        _config[keyName] = value;
        _notifyChange();
      },
    );
  }

  Widget _buildNumberField({
    required String label,
    required String hint,
    required String keyName,
  }) {
    return TextField(
      controller: TextEditingController(
        text: _config[keyName]?.toString() ?? '',
      ),
      keyboardType: TextInputType.number,
      style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.metadata.copyWith(color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.surface3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: (String value) {
        final int? parsed = int.tryParse(value);
        if (parsed != null) {
          _config[keyName] = parsed;
        } else {
          _config.remove(keyName);
        }
        _notifyChange();
      },
    );
  }

  String _triggerTypeLabel(RuleTriggerType type) {
    switch (type) {
      case RuleTriggerType.domainEquals:
        return 'Domain equals';
      case RuleTriggerType.domainContains:
        return 'Domain contains';
      case RuleTriggerType.sourceTypeEquals:
        return 'Source type equals';
      case RuleTriggerType.urlContains:
        return 'URL contains';
      case RuleTriggerType.hasTag:
        return 'Has tag';
      case RuleTriggerType.isUnread:
        return 'Is unread';
    }
  }
}
