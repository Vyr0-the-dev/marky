import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_typography.dart';

/// A compact summary card showing a single metric with label and value.
class StatSummaryCard extends StatelessWidget {
  /// Creates a [StatSummaryCard].
  const StatSummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trend,
    this.trendUp,
  });

  /// Label text shown above the value.
  final String label;

  /// The metric value (e.g. "42").
  final String value;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional trend text (e.g. "+5%").
  final String? trend;

  /// Whether the trend is positive (green) or negative (red).
  final bool? trendUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(
                  icon,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.metadata.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.sectionTitle.copyWith(
              fontSize: 24,
              color: AppColors.textPrimary,
            ),
          ),
          if (trend != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              trend!,
              style: AppTypography.metadata.copyWith(
                color: (trendUp ?? true)
                    ? AppColors.success
                    : AppColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
