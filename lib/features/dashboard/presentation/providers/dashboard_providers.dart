import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:marky/core/database/isar_service.dart';
import 'package:marky/features/dashboard/domain/models/dashboard_stats.dart';
import 'package:marky/features/dashboard/domain/services/dashboard_statistics_service.dart';

/// Provider that exposes the live [DashboardStatisticsService].
///
/// Throws [StateError] if the database has not been opened yet.
final Provider<DashboardStatisticsService> dashboardStatisticsServiceProvider =
    Provider<DashboardStatisticsService>((Ref ref) {
  final Isar? isar = IsarService.instance.isar;
  if (isar == null) {
    throw StateError(
      'Isar database not initialized. '
      'Ensure IsarService.instance.open() is called during app bootstrap.',
    );
  }
  return DashboardStatisticsService(isar: isar);
});

/// FutureProvider that asynchronously computes [DashboardStats].
///
/// Exposes loading / error / data states visible in Riverpod DevTools.
final FutureProvider<DashboardStats> dashboardStatsProvider =
    FutureProvider<DashboardStats>((Ref ref) async {
  final DashboardStatisticsService service =
      ref.watch(dashboardStatisticsServiceProvider);
  return service.computeStats();
});
