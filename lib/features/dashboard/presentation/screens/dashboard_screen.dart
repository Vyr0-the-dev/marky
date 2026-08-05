import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:marky/app/theme/app_colors.dart';
import 'package:marky/app/theme/app_typography.dart';
import 'package:marky/features/dashboard/domain/models/models.dart';
import 'package:marky/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:marky/features/dashboard/presentation/widgets/dashboard_empty_state.dart';
import 'package:marky/features/dashboard/presentation/widgets/hourly_activity_heatmap.dart';
import 'package:marky/features/dashboard/presentation/widgets/source_distribution_chart.dart';
import 'package:marky/features/dashboard/presentation/widgets/stat_summary_card.dart';
import 'package:marky/features/dashboard/presentation/widgets/tag_density_chart.dart';
import 'package:marky/features/dashboard/presentation/widgets/weekly_trend_chart.dart';

/// Full dashboard screen displaying bookmark analytics.
///
/// Watches [dashboardStatsProvider] and renders loading, error, and data
/// states. Accessible only from the Settings screen.
class DashboardScreen extends ConsumerWidget {
  /// Creates the [DashboardScreen].
  const DashboardScreen({super.key});

  static String _formatCount(int value) {
    if (value < 1000) {
      return value.toString();
    }
    return NumberFormat.compact().format(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardStats> statsAsync =
        ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.base,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('Dashboard'),
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (Object error, StackTrace? stackTrace) => _ErrorBody(
          error: error,
          onRetry: () => ref.invalidate(dashboardStatsProvider),
        ),
        data: (DashboardStats stats) {
          if (stats.totalBookmarks == 0) {
            return const DashboardEmptyState();
          }
          return _DashboardContent(
            stats: stats,
            formatCount: _formatCount,
          );
        },
      ),
    );
  }
}

// ─── Error body ────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load dashboard',
              style: AppTypography.sectionTitle.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentPrimary,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard content ─────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.stats,
    required this.formatCount,
  });

  final DashboardStats stats;
  final String Function(int) formatCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Row 1: Total, Unread, Favorites
          Row(
            children: <Widget>[
              Expanded(
                child: StatSummaryCard(
                  label: 'Bookmarks',
                  value: formatCount(stats.totalBookmarks),
                  icon: Icons.bookmark_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatSummaryCard(
                  label: 'Unread',
                  value: formatCount(stats.unreadCount),
                  icon: Icons.mark_email_unread_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatSummaryCard(
                  label: 'Favorites',
                  value: formatCount(stats.favoriteCount),
                  icon: Icons.favorite_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Collections, Tags, Recently Added
          Row(
            children: <Widget>[
              Expanded(
                child: StatSummaryCard(
                  label: 'Collections',
                  value: formatCount(stats.totalCollections),
                  icon: Icons.folder_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatSummaryCard(
                  label: 'Tags',
                  value: formatCount(stats.totalTags),
                  icon: Icons.label_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatSummaryCard(
                  label: 'Recent',
                  value: formatCount(stats.recentlyAdded.length),
                  icon: Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Weekly Trend
          _SectionCard(
            title: 'Weekly Trend',
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: WeeklyTrendChart(data: stats.weeklyTrend),
            ),
          ),
          const SizedBox(height: 16),
          // Sources
          _SectionCard(
            title: 'Sources',
            child: AspectRatio(
              aspectRatio: 16 / 12,
              child: SourceDistributionChart(
                distribution: stats.sourceDistribution,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Top Tags
          _SectionCard(
            title: 'Top Tags',
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: TagDensityChart(tags: stats.topTags),
            ),
          ),
          const SizedBox(height: 16),
          // Activity by Hour
          _SectionCard(
            title: 'Activity by Hour',
            child: HourlyActivityHeatmap(
              hourlyActivity: stats.hourlyActivity,
            ),
          ),
          const SizedBox(height: 16),
          // Read / Archived / Vault breakdown
          Row(
            children: <Widget>[
              Expanded(
                child: StatSummaryCard(
                  label: 'Read',
                  value: formatCount(stats.readCount),
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatSummaryCard(
                  label: 'Archived',
                  value: formatCount(stats.archivedCount),
                  icon: Icons.archive_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatSummaryCard(
                  label: 'Vault',
                  value: formatCount(stats.vaultCount),
                  icon: Icons.lock_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Section card wrapper ──────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTypography.cardTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
