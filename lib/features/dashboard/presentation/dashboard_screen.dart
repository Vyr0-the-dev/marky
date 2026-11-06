import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/features/dashboard/data/dashboard_providers.dart';
import 'package:marky/features/dashboard/domain/dashboard_stats.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Dashboard screen — library analytics and stats.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardStats> statsAsync =
        ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.dashboardTitle ?? 'Dashboard',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: statsAsync.when(
        data: (DashboardStats stats) => _DashboardBody(stats: stats),
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (Object e, _) => Center(
            child: Text(
                AppLocalizations.of(context)?.detailInlineError(e.toString()) ??
                    'Error: $e')),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String topSource =
        stats.topHosts.isEmpty ? '—' : stats.topHosts.first.host;

    return ListView(
      padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
      children: <Widget>[
        _SummaryCards(
          stats: stats,
          topSource: topSource,
        ),

        const SizedBox(height: ReadingRoomSpacing.xl),

        if (stats.timeline.isNotEmpty) ...<Widget>[
          _TimelinePanel(buckets: stats.timeline),
          const SizedBox(height: ReadingRoomSpacing.xl),
        ],

        if (stats.sourceBreakdown.isNotEmpty) ...<Widget>[
          Text('Source Breakdown', style: theme.textTheme.titleSmall),
          const SizedBox(height: ReadingRoomSpacing.sm),
          ...stats.sourceBreakdown.map((SourceTypeCount source) => _BarRow(
                label: source.label,
                count: source.count,
                maxCount: stats.sourceBreakdown.first.count,
                color: Colors.lightBlueAccent,
              )),
          const SizedBox(height: ReadingRoomSpacing.xl),
        ],

        // ── Top sources ──────────────────────────────────────
        if (stats.topHosts.isNotEmpty) ...<Widget>[
          Text('Top Sources', style: theme.textTheme.titleSmall),
          const SizedBox(height: ReadingRoomSpacing.sm),
          ...stats.topHosts.map((HostCount h) => _BarRow(
                label: h.host,
                count: h.count,
                maxCount: stats.topHosts.first.count,
                color: theme.colorScheme.primary,
              )),
        ],

        const SizedBox(height: ReadingRoomSpacing.xl),

        // ── Top tags ─────────────────────────────────────────
        if (stats.topTags.isNotEmpty) ...<Widget>[
          Text('Top Tags', style: theme.textTheme.titleSmall),
          const SizedBox(height: ReadingRoomSpacing.sm),
          ...stats.topTags.map((TagCount t) => _BarRow(
                label: t.tagName,
                count: t.count,
                maxCount: stats.topTags.first.count,
                color: theme.colorScheme.tertiary,
              )),
        ],

        const SizedBox(height: ReadingRoomSpacing.huge),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.stats,
    required this.topSource,
  });

  final DashboardStats stats;
  final String topSource;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_StatCard> cards = <_StatCard>[
      _StatCard(
        label: 'Total',
        value: stats.totalBookmarks.toString(),
        icon: Icons.bookmark_outline,
        color: theme.colorScheme.primary,
      ),
      _StatCard(
        label: 'Unread',
        value: stats.unreadCount.toString(),
        icon: Icons.visibility_off_outlined,
        color: theme.colorScheme.error,
      ),
      _StatCard(
        label: 'This week',
        value: stats.addedThisWeek.toString(),
        icon: Icons.calendar_today,
        color: theme.colorScheme.tertiary,
      ),
      _StatCard(
        label: 'Read %',
        value: '${(stats.readRatio * 100).toStringAsFixed(0)}%',
        icon: Icons.pie_chart_outline,
        color: Colors.tealAccent,
      ),
      _StatCard(
        label: 'Favorites',
        value: stats.favoritesCount.toString(),
        icon: Icons.favorite_outline,
        color: Colors.pinkAccent,
      ),
      _StatCard(
        label: 'Top source',
        value: topSource,
        icon: Icons.public_rounded,
        color: Colors.lightBlueAccent,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 720 ? 3 : 2;
        const double gap = ReadingRoomSpacing.md;
        final double width =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map(
                (_StatCard card) => SizedBox(
                  width: width,
                  child: card,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.buckets});

  final List<TimelineBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int maxCount = buckets.fold<int>(
      0,
      (int max, TimelineBucket bucket) =>
          bucket.count > max ? bucket.count : max,
    );

    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('7-day Timeline', style: theme.textTheme.titleSmall),
            const SizedBox(height: ReadingRoomSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buckets
                  .map(
                    (TimelineBucket bucket) => Expanded(
                      child: _TimelineBar(
                        bucket: bucket,
                        maxCount: maxCount,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineBar extends StatelessWidget {
  const _TimelineBar({
    required this.bucket,
    required this.maxCount,
  });

  final TimelineBucket bucket;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double fraction = maxCount == 0 ? 0 : bucket.count / maxCount;
    final double barHeight = 6 + (fraction * 58);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            bucket.count.toString(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: SizedBox(
              height: barHeight,
              width: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: <Color>[
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bucket.shortLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat card ──────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: 104,
      child: Card(
        margin: EdgeInsets.zero,
        color: color.withValues(alpha: 0.09),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ReadingRoomSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 17),
                  ),
                  const Spacer(),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bar row ────────────────────────────────────────────────────

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.count,
    required this.maxCount,
    required this.color,
  });

  final String label;
  final int count;
  final int maxCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double fraction = maxCount == 0 ? 0 : count / maxCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: ReadingRoomSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 14,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  color.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: ReadingRoomSpacing.sm),
          SizedBox(
            width: 30,
            child: Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
