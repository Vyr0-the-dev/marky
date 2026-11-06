import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/core/database/database_providers.dart';
import 'package:marky/features/collections/data/isar_bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/bookmark_collection.dart';
import 'package:marky/features/collections/domain/bookmark_collection_repository.dart';
import 'package:marky/features/collections/domain/smart_collection_evaluator.dart';

final Provider<BookmarkCollectionRepository>
    bookmarkCollectionRepositoryProvider =
    Provider<BookmarkCollectionRepository>((Ref ref) {
  return IsarBookmarkCollectionRepository(ref.watch(markyIsarProvider));
});

final Provider<SmartCollectionEvaluator> smartCollectionEvaluatorProvider =
    Provider<SmartCollectionEvaluator>((Ref ref) {
  return const DefaultSmartCollectionEvaluator();
});

/// Reactive list of non-archived collections — used by the Library
/// collection panel and the bookmark detail's "add to collection"
/// picker.
final AutoDisposeStreamProvider<List<BookmarkCollection>>
    bookmarkCollectionsProvider =
    StreamProvider.autoDispose<List<BookmarkCollection>>((Ref ref) {
  return ref.watch(bookmarkCollectionRepositoryProvider).watchAll();
});

/// Variant including archived — for Settings → Collections "Trash"
/// view (Faz 8).
final AutoDisposeStreamProvider<List<BookmarkCollection>>
    bookmarkCollectionsWithArchivedProvider =
    StreamProvider.autoDispose<List<BookmarkCollection>>((Ref ref) {
  return ref
      .watch(bookmarkCollectionRepositoryProvider)
      .watchAll(includeArchived: true);
});

final AutoDisposeStreamProviderFamily<BookmarkCollection?, int>
    bookmarkCollectionByIdProvider =
    StreamProvider.autoDispose.family<BookmarkCollection?, int>(
  (Ref ref, int id) =>
      ref.watch(bookmarkCollectionRepositoryProvider).watchById(id),
);
