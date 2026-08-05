import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_shapes.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/automation/domain/models/rule_action.dart';
import 'package:marky/features/automation/domain/models/rule_trigger.dart';
import 'package:marky/shared/models/automation_rule.dart';

/// Card widget displaying an automation rule with toggle and summary info.
class RuleCard extends StatelessWidget {
  /// Creates a [RuleCard].
  const RuleCard({
    required this.rule,
    required this.onTap,
    required this.onToggle,
    super.key,
  });

  final AutomationRule rule;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final String triggerSummary = _buildTriggerSummary();
    final String actionSummary = _buildActionSummary();

    return Material(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.radiusStandard),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      rule.name,
                      style: AppTypography.cardTitle,
                    ),
                    if (rule.description != null &&
                        rule.description!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        rule.description!,
                        style: AppTypography.metadata,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        _buildChip(
                          icon: Icons.bolt,
                          label: triggerSummary,
                          color: AppColors.accentSecondary,
                        ),
                        const SizedBox(width: 8),
                        _buildChip(
                          icon: Icons.play_arrow,
                          label: actionSummary,
                          color: AppColors.accentPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: rule.enabled,
                onChanged: (_) => onToggle(),
                activeThumbColor: AppColors.accentPrimary,
                activeTrackColor: AppColors.accentPrimary.withValues(alpha: 0.5),
                inactiveThumbColor: AppColors.textSecondary,
                inactiveTrackColor: AppColors.surface3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildTriggerSummary() {
    try {
      final Map<String, dynamic> json =
          jsonDecode(rule.triggerConfig) as Map<String, dynamic>;
      final RuleTrigger trigger = RuleTrigger.fromJson(json);
      switch (trigger.triggerType) {
        case RuleTriggerType.domainEquals:
          return 'domain = ${trigger.config['domain'] ?? '?'}';
        case RuleTriggerType.domainContains:
          return 'domain ~ ${trigger.config['domain'] ?? '?'}';
        case RuleTriggerType.sourceTypeEquals:
          return 'source = ${trigger.config['sourceType'] ?? '?'}';
        case RuleTriggerType.urlContains:
          return 'url ~ ${trigger.config['pattern'] ?? '?'}';
        case RuleTriggerType.hasTag:
          return 'has tag #${trigger.config['tagId'] ?? '?'}';
        case RuleTriggerType.isUnread:
          return 'unread';
      }
    } catch (_) {
      return rule.triggerType;
    }
  }

  String _buildActionSummary() {
    try {
      final List<dynamic> jsonList = jsonDecode(rule.actions) as List<dynamic>;
      final int count = jsonList.length;
      if (count == 0) return 'no actions';
      if (count == 1) {
        final Map<String, dynamic> json =
            jsonList.first as Map<String, dynamic>;
        final RuleAction action = RuleAction.fromJson(json);
        return _actionTypeLabel(action.actionType);
      }
      return '$count actions';
    } catch (_) {
      return 'actions';
    }
  }

  String _actionTypeLabel(RuleActionType type) {
    switch (type) {
      case RuleActionType.addTag:
        return 'add tag';
      case RuleActionType.addToCollection:
        return 'add to collection';
      case RuleActionType.archive:
        return 'archive';
      case RuleActionType.addReminder:
        return 'reminder';
      case RuleActionType.moveToVault:
        return 'vault';
      case RuleActionType.markAsFavorite:
        return 'favorite';
    }
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppShapes.radiusMini),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.metadata.copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
