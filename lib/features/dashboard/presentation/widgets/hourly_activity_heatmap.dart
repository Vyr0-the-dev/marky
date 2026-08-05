import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_typography.dart';

/// A 24-cell horizontal heatmap showing bookmark creation activity by hour.
class HourlyActivityHeatmap extends StatelessWidget {
  /// Creates the [HourlyActivityHeatmap].
  const HourlyActivityHeatmap({
    super.key,
    required this.hourlyActivity,
  });

  /// 24 buckets of activity counts (index 0 = midnight).
  final List<int> hourlyActivity;

  @override
  Widget build(BuildContext context) {
    if (hourlyActivity.isEmpty) {
      return const _NoDataPlaceholder();
    }

    final int maxValue = hourlyActivity.reduce(
      (int a, int b) => a > b ? a : b,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Hour cells in a 4-row × 6-column grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.4,
          ),
          itemCount: 24,
          itemBuilder: (BuildContext context, int index) {
            final int count = index < hourlyActivity.length
                ? hourlyActivity[index]
                : 0;

            final double intensity = maxValue > 0
                ? (count / maxValue).clamp(0.0, 1.0)
                : 0.0;

            return Container(
              decoration: BoxDecoration(
                color: count == 0
                    ? AppColors.surface2
                    : AppColors.accentPrimary.withValues(
                        alpha: 0.15 + (intensity * 0.85),
                      ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index.toString().padLeft(2, '0')}:00',
                style: AppTypography.metadata.copyWith(
                  color: intensity > 0.4
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          children: <Widget>[
            Text(
              'Less',
              style: AppTypography.metadata.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 80,
              height: 8,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[
                    AppColors.surface2,
                    AppColors.accentPrimary,
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'More',
              style: AppTypography.metadata.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NoDataPlaceholder extends StatelessWidget {
  const _NoDataPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '--',
        style: AppTypography.sectionTitle,
      ),
    );
  }
}
