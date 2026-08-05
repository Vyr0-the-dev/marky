import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_typography.dart';

/// A pie chart showing bookmark source distribution.
class SourceDistributionChart extends StatelessWidget {
  /// Creates the [SourceDistributionChart].
  const SourceDistributionChart({
    super.key,
    required this.distribution,
  });

  /// Map of source type → count.
  final Map<String, int> distribution;

  static const List<Color> _palette = <Color>[
    AppColors.accentPrimary,
    AppColors.accentSecondary,
    AppColors.accentTertiary,
    AppColors.accentLuxe,
    AppColors.success,
    AppColors.warning,
    AppColors.danger,
    AppColors.textSecondary,
  ];

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> entries = distribution.entries
        .where((MapEntry<String, int> e) => e.value > 0)
        .toList();

    if (entries.isEmpty) {
      return const _NoDataPlaceholder();
    }

    final int total = entries.fold<int>(
      0,
      (int sum, MapEntry<String, int> e) => sum + e.value,
    );

    final List<PieChartSectionData> sections = <PieChartSectionData>[
      for (int i = 0; i < entries.length; i++)
        PieChartSectionData(
          color: _palette[i % _palette.length],
          value: entries[i].value.toDouble(),
          title: '',
          radius: 60,
        ),
    ];

    return Column(
      children: <Widget>[
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: sections,
              pieTouchData: PieTouchData(
                touchCallback: (
                  FlTouchEvent event,
                  PieTouchResponse? response,
                ) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: <Widget>[
            for (int i = 0; i < entries.length; i++)
              _LegendItem(
                color: _palette[i % _palette.length],
                label: _formatLabel(entries[i].key),
                count: entries[i].value,
                total: total,
              ),
          ],
        ),
      ],
    );
  }

  String _formatLabel(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((String w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : '')
        .join(' ');
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  final Color color;
  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final double pct = total > 0 ? (count / total * 100) : 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label (${pct.toStringAsFixed(0)}%)',
          style: AppTypography.metadata.copyWith(
            color: AppColors.textSecondary,
          ),
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
