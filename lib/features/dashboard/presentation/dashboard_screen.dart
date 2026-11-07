import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/database/enums/bookmark_source_type.dart';
import 'package:marky/features/dashboard/data/dashboard_providers.dart';
import 'package:marky/features/dashboard/domain/dashboard_stats.dart';
import 'package:marky/l10n/app_localizations.dart';

/// Dashboard screen — library analytics and reading overview.
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
                'Error: $e',
          ),
        ),
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
    final ColorScheme colors = theme.colorScheme;
    final String topSource =
        stats.topHosts.isEmpty ? '—' : stats.topHosts.first.host;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ReadingRoomSpacing.lg,
        ReadingRoomSpacing.md,
        ReadingRoomSpacing.lg,
        ReadingRoomSpacing.huge,
      ),
      children: <Widget>[
        _ReadingProgressHeroCard(stats: stats),
        const SizedBox(height: ReadingRoomSpacing.lg),
        _SummaryCards(
          stats: stats,
          topSource: topSource,
        ),
        if (stats.timeline.isNotEmpty) ...<Widget>[
          const SizedBox(height: ReadingRoomSpacing.lg),
          _TimelinePanel(buckets: stats.timeline),
        ],
        if (stats.topHosts.isNotEmpty) ...<Widget>[
          const SizedBox(height: ReadingRoomSpacing.lg),
          _SectionCard(
            title: 'En Çok Okunan Kaynaklar',
            icon: Icons.public_rounded,
            accentColor: colors.primary,
            children: <Widget>[
              for (int i = 0; i < stats.topHosts.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: ReadingRoomSpacing.md),
                _RankedBarRow(
                  rank: i + 1,
                  label: stats.topHosts[i].host,
                  count: stats.topHosts[i].count,
                  maxCount: stats.topHosts.first.count,
                  color: colors.primary,
                ),
              ],
            ],
          ),
        ],
        if (stats.sourceBreakdown.isNotEmpty) ...<Widget>[
          const SizedBox(height: ReadingRoomSpacing.lg),
          _SectionCard(
            title: 'Kaynak Dağılımı',
            icon: Icons.layers_outlined,
            accentColor: colors.secondary,
            children: <Widget>[
              for (int i = 0;
                  i < stats.sourceBreakdown.length;
                  i++) ...<Widget>[
                if (i > 0) const SizedBox(height: ReadingRoomSpacing.md),
                _RankedBarRow(
                  leadingIcon:
                      _sourceIcon(stats.sourceBreakdown[i].sourceType),
                  label: stats.sourceBreakdown[i].label,
                  count: stats.sourceBreakdown[i].count,
                  maxCount: stats.sourceBreakdown.first.count,
                  color: colors.secondary,
                ),
              ],
            ],
          ),
        ],
        if (stats.topTags.isNotEmpty) ...<Widget>[
          const SizedBox(height: ReadingRoomSpacing.lg),
          _SectionCard(
            title: 'Popüler Etiketler',
            icon: Icons.sell_outlined,
            accentColor: colors.tertiary,
            children: <Widget>[
              for (int i = 0; i < stats.topTags.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: ReadingRoomSpacing.md),
                _RankedBarRow(
                  leadingIcon: Icons.tag_rounded,
                  label: stats.topTags[i].tagName,
                  count: stats.topTags[i].count,
                  maxCount: stats.topTags.first.count,
                  color: colors.tertiary,
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  static IconData _sourceIcon(BookmarkSourceType type) {
    switch (type) {
      case BookmarkSourceType.share:
        return Icons.share_rounded;
      case BookmarkSourceType.clipboard:
        return Icons.content_paste_rounded;
      case BookmarkSourceType.manual:
        return Icons.edit_note_rounded;
      case BookmarkSourceType.import:
        return Icons.file_download_outlined;
      case BookmarkSourceType.automation:
        return Icons.auto_fix_high_rounded;
    }
  }
}

// ─── Reading progress hero card ─────────────────────────────────

class _ReadingProgressHeroCard extends StatelessWidget {
  const _ReadingProgressHeroCard({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final int readCount =
        (stats.totalBookmarks - stats.unreadCount).clamp(0, stats.totalBookmarks);
    final double ratio = stats.readRatio.clamp(0.0, 1.0);
    final String percentageText = '${(ratio * 100).round()}%';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        border: Border.all(color: colors.outline),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colors.primary.withValues(alpha: 0.10),
            colors.surfaceContainerLow,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'KÜTÜPHANE GENEL BAKIŞI',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                        ),
                      ),
                      const SizedBox(height: ReadingRoomSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            stats.totalBookmarks.toString(),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(width: ReadingRoomSpacing.sm),
                          Text(
                            'kayıtlı bağlantı',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReadingRoomSpacing.md,
                    vertical: ReadingRoomSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 15,
                        color: colors.primary,
                      ),
                      const SizedBox(width: ReadingRoomSpacing.xs),
                      Text(
                        '%$percentageText Okundu',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: colors.outline.withValues(alpha: 0.45),
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: _HeroMiniStat(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Okundu',
                    value: readCount.toString(),
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Expanded(
                  child: _HeroMiniStat(
                    icon: Icons.schedule_rounded,
                    label: 'Okunmadı',
                    value: stats.unreadCount.toString(),
                    color: colors.error,
                  ),
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Expanded(
                  child: _HeroMiniStat(
                    icon: Icons.favorite_border_rounded,
                    label: 'Favoriler',
                    value: stats.favoritesCount.toString(),
                    color: colors.tertiary,
                  ),
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Expanded(
                  child: _HeroMiniStat(
                    icon: Icons.archive_outlined,
                    label: 'Arşivlenenler',
                    value: stats.archivedCount.toString(),
                    color: colors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMiniStat extends StatelessWidget {
  const _HeroMiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReadingRoomSpacing.sm,
        vertical: ReadingRoomSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard - 2),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 15, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Metric grid cards ──────────────────────────────────────────

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.stats,
    required this.topSource,
  });

  final DashboardStats stats;
  final String topSource;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<_StatCard> cards = <_StatCard>[
      _StatCard(
        label: 'Toplam',
        value: stats.totalBookmarks.toString(),
        icon: Icons.bookmark_outline_rounded,
        color: colors.primary,
      ),
      _StatCard(
        label: 'Okunmamış',
        value: stats.unreadCount.toString(),
        icon: Icons.visibility_off_outlined,
        color: colors.error,
      ),
      _StatCard(
        label: 'Bu Hafta',
        value: stats.addedThisWeek.toString(),
        icon: Icons.calendar_today_rounded,
        color: colors.tertiary,
      ),
      _StatCard(
        label: 'Okunma Oranı',
        value: '%${(stats.readRatio * 100).toStringAsFixed(0)}',
        icon: Icons.pie_chart_outline_rounded,
        color: colors.primary,
      ),
      _StatCard(
        label: 'Favoriler',
        value: stats.favoritesCount.toString(),
        icon: Icons.favorite_outline_rounded,
        color: colors.tertiary,
      ),
      _StatCard(
        label: 'En Çok Kaynak',
        value: topSource,
        icon: Icons.public_rounded,
        color: colors.secondary,
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
    final ColorScheme colors = theme.colorScheme;
    return SizedBox(
      height: 112,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
          border: Border.all(color: colors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ReadingRoomSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Spacer(),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
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

// ─── 7-day activity timeline ────────────────────────────────────

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.buckets});

  final List<TimelineBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final int maxCount = buckets.fold<int>(
      0,
      (int max, TimelineBucket bucket) =>
          bucket.count > max ? bucket.count : max,
    );
    final int totalWeek = buckets.fold<int>(
      0,
      (int sum, TimelineBucket bucket) => sum + bucket.count,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        border: Border.all(color: colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Expanded(
                  child: Text(
                    'Son 7 Günlük Hareket',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReadingRoomSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$totalWeek kayıt',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.lg),
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
    final ColorScheme colors = theme.colorScheme;
    final double fraction = maxCount == 0 ? 0 : bucket.count / maxCount;
    final double barHeight = 8 + (fraction * 60);
    final bool hasActivity = bucket.count > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            bucket.count.toString(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: hasActivity ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: hasActivity ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: colors.outline.withValues(alpha: 0.35),
            ),
            child: SizedBox(
              height: barHeight,
              width: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: hasActivity
                      ? colors.primary
                      : colors.outline.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bucket.shortLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ranked section card & row ──────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        border: Border.all(color: colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: accentColor),
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _RankedBarRow extends StatelessWidget {
  const _RankedBarRow({
    required this.label,
    required this.count,
    required this.maxCount,
    required this.color,
    this.rank,
    this.leadingIcon,
  });

  final int? rank;
  final IconData? leadingIcon;
  final String label;
  final int count;
  final int maxCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final double fraction =
        maxCount == 0 ? 0 : (count / maxCount).clamp(0.0, 1.0);

    return Row(
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: rank != null
              ? Text(
                  '$rank',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : Icon(
                  leadingIcon ?? Icons.circle,
                  size: 15,
                  color: color,
                ),
        ),
        const SizedBox(width: ReadingRoomSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: ReadingRoomSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ReadingRoomSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      count.toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6,
                  backgroundColor: colors.outline.withValues(alpha: 0.35),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
