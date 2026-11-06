import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/bookmarks/domain/bookmark_repository.dart';
import 'package:marky/features/dashboard/domain/dashboard_analytics_service.dart';
import 'package:marky/features/dashboard/domain/dashboard_stats.dart';
import 'package:marky/features/tags/data/tag_providers.dart';
import 'package:marky/features/tags/domain/tag_repository.dart';

/// Computes dashboard stats on demand. Auto-disposes when the
/// screen is left so stale numbers don't linger.
final AutoDisposeFutureProvider<DashboardStats> dashboardStatsProvider =
    FutureProvider.autoDispose<DashboardStats>((Ref ref) async {
  final BookmarkRepository bookmarks = ref.watch(bookmarkRepositoryProvider);
  final TagRepository tags = ref.watch(tagRepositoryProvider);
  final DashboardAnalyticsService service = DashboardAnalyticsService(
    bookmarkRepository: bookmarks,
    tagRepository: tags,
  );
  return service.compute();
});
