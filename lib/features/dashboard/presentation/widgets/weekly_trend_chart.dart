import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/dashboard/domain/models/dashboard_stats.dart';

/// A line chart showing bookmark creation counts over the last 7 days.
class WeeklyTrendChart extends StatelessWidget {
  /// Creates the [WeeklyTrendChart].
  const WeeklyTrendChart({
    super.key,
    required this.data,
  });

  /// Daily counts for the past week.
  final List<DailyCount> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _NoDataPlaceholder();
    }

    final List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < data.length; i++)
        FlSpot(i.toDouble(), data[i].count.toDouble()),
    ];

    final double maxY = data
        .map((DailyCount d) => d.count.toDouble())
        .fold<double>(1, (double a, double b) => a > b ? a : b);

    final double yInterval = maxY <= 5 ? 1 : (maxY / 4).ceilToDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
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
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat.E().format(data[index].date),
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface3,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot spot) {
                final int index = spot.x.toInt();
                final String day = DateFormat.MMMd().format(data[index].date);
                return LineTooltipItem(
                  '${spot.y.toInt()}\n$day',
                  AppTypography.metadata.copyWith(
                    color: AppColors.textPrimary,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.accentPrimary,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.accentPrimary.withValues(alpha: 0.3),
                  AppColors.accentPrimary.withValues(alpha: 0),
                ],
              ),
            ),
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
