import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom [CacheManager] for Marky image assets.
///
/// Enforces bounded disk usage:
/// • Max file age: 7 days (stale period)
/// • Max file count: 200 objects
///
/// The cache key isolates Marky's image cache from other
/// [flutter_cache_manager] consumers in the app.
final CacheManager markyImageCacheManager = CacheManager(
  Config(
    'marky_images',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 200,
  ),
);
