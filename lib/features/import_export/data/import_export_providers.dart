import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/features/bookmarks/data/bookmark_providers.dart';
import 'package:marky/features/capture/data/capture_providers.dart';
import 'package:marky/features/collections/data/bookmark_collection_providers.dart';
import 'package:marky/features/import_export/domain/export_service.dart';
import 'package:marky/features/import_export/domain/import_service.dart';
import 'package:marky/features/tags/data/tag_providers.dart';

final Provider<ExportService> exportServiceProvider =
    Provider<ExportService>((Ref ref) {
  return ExportService(
    bookmarkRepository: ref.watch(bookmarkRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    collectionRepository: ref.watch(bookmarkCollectionRepositoryProvider),
  );
});

final Provider<ImportService> importServiceProvider =
    Provider<ImportService>((Ref ref) {
  return ImportService(
    bookmarkRepository: ref.watch(bookmarkRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    collectionRepository: ref.watch(bookmarkCollectionRepositoryProvider),
    duplicateDetector: ref.watch(duplicateDetectorProvider),
    mergeService: ref.watch(upsertMergeServiceProvider),
  );
});
