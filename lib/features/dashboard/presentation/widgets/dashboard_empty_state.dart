import 'package:flutter/material.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_typography.dart';

/// Empty state shown when the user has no bookmarks yet.
class DashboardEmptyState extends StatelessWidget {
  /// Creates the [DashboardEmptyState].
  const DashboardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.insights_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16),
          Text(
            'No data yet',
            style: AppTypography.sectionTitle,
          ),
          SizedBox(height: 8),
          Text(
            'Save some bookmarks to see your analytics',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
