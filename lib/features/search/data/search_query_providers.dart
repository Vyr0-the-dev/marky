import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marky/core/database/database_providers.dart';
import 'package:marky/features/search/data/isar_search_query_repository.dart';
import 'package:marky/features/search/domain/search_query.dart';
import 'package:marky/features/search/domain/search_query_repository.dart';

final Provider<SearchQueryRepository> searchQueryRepositoryProvider =
    Provider<SearchQueryRepository>((Ref ref) {
  return IsarSearchQueryRepository(ref.watch(markyIsarProvider));
});

final AutoDisposeStreamProvider<List<SearchQuery>> recentSearchQueriesProvider =
    StreamProvider.autoDispose<List<SearchQuery>>((Ref ref) {
  return ref.watch(searchQueryRepositoryProvider).watchRecent();
});

final AutoDisposeStreamProvider<List<SearchQuery>> savedSearchQueriesProvider =
    StreamProvider.autoDispose<List<SearchQuery>>((Ref ref) {
  return ref.watch(searchQueryRepositoryProvider).watchSaved();
});
