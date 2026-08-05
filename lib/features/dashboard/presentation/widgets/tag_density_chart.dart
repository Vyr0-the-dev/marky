import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/dashboard/domain/models/dashboard_stats.dart';

/// A bar chart showing top tags by usage count.
class TagDensityChart extends StatelessWidget {
  /// Creates the [TagDensityChart].
  const TagDensityChart({
    super.key,
    required this.tags,
  });

  /// Top tags to display.
  final List<TagStat> tags;

  @override
  Widget build(BuildContext context) {
    final List<TagStat> displayTags = tags.take(8).toList();

    if (displayTags.isEmpty) {
      return const _NoDataPlaceholder();
    }

    final double maxCount = displayTags
        .map((TagStat t) => t.count.toDouble())
        .fold<double>(1, (double a, double b) => a > b ? a : b);

    final double yInterval = maxCount <= 5 ? 1 : (maxCount / 4).ceilToDouble();

    return BarChart(
      BarChartData(
        maxY: maxCount * 1.2,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: yInterval,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.textTertiary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int index = value.toInt();
                if (index < 0 || index >= displayTags.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    displayTags[index].name,
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface3,
            getTooltipItem: (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              return BarTooltipItem(
                '${rod.toY.toInt()}',
                AppTypography.metadata.copyWith(
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
        ),
        barGroups: <BarChartGroupData>[
          for (int i = 0; i < displayTags.length; i++)
            BarChartGroupData(
              x: i,
              barRods: <BarChartRodData>[
                BarChartRodData(
                  toY: displayTags[i].count.toDouble(),
                  color: AppColors.accentSecondary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
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
