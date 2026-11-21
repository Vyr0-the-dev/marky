import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Computes disk usage and clears Marky's offline reader snapshots, cached
/// thumbnails, and cached network images.
class CacheManagementService {
  const CacheManagementService({
    Future<Directory> Function()? documentsDirProvider,
    Future<Directory> Function()? tempDirProvider,
  })  : _documentsDirProvider = documentsDirProvider,
        _tempDirProvider = tempDirProvider;

  final Future<Directory> Function()? _documentsDirProvider;
  final Future<Directory> Function()? _tempDirProvider;

  Future<List<Directory>> _cacheDirectories() async {
    final List<Directory> dirs = <Directory>[];
    try {
      final Directory docDir = _documentsDirProvider != null
          ? await _documentsDirProvider()
          : await getApplicationDocumentsDirectory();
      dirs
        ..add(Directory('${docDir.path}/reader_cache'))
        ..add(Directory('${docDir.path}/thumbnails'));
    } catch (_) {
      // Ignore unavailable platform directory.
    }
    try {
      final Directory tempDir = _tempDirProvider != null
          ? await _tempDirProvider()
          : await getTemporaryDirectory();
      dirs
        ..add(Directory('${tempDir.path}/reader_cache'))
        ..add(Directory('${tempDir.path}/libCachedImageData'));
    } catch (_) {
      // Ignore unavailable platform directory.
    }
    return dirs;
  }

  /// Total bytes currently used across Marky's offline article & image caches.
  Future<int> computeTotalBytes() async {
    int total = 0;
    final List<Directory> dirs = await _cacheDirectories();
    for (final Directory dir in dirs) {
      if (!dir.existsSync()) continue;
      try {
        await for (final FileSystemEntity entity
            in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              total += await entity.length();
            } catch (_) {
              // File may have been removed concurrently.
            }
          }
        }
      } catch (_) {
        // Directory may be unreadable.
      }
    }
    return total;
  }

  /// Deletes all cached reader articles, local thumbnails, and image cache
  /// files, then clears Flutter's in-memory image cache.
  Future<void> clearAll() async {
    final List<Directory> dirs = await _cacheDirectories();
    for (final Directory dir in dirs) {
      if (!dir.existsSync()) continue;
      try {
        await for (final FileSystemEntity entity in dir.list()) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {
            // Best-effort deletion per file.
          }
        }
      } catch (_) {
        // Best-effort directory cleanup.
      }
    }
    try {
      PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages();
    } catch (_) {
      // PaintingBinding may not be initialized in pure unit tests.
    }
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;
    if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(2)} GB';
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
    if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(0)} KB';
    return '$bytes B';
  }
}

final Provider<CacheManagementService> cacheManagementServiceProvider =
    Provider<CacheManagementService>((Ref ref) {
  return const CacheManagementService();
});

final AutoDisposeFutureProvider<int> cacheSizeBytesProvider =
    FutureProvider.autoDispose<int>((Ref ref) {
  return ref.watch(cacheManagementServiceProvider).computeTotalBytes();
});
