import 'package:marky/features/search/domain/search_query.dart';

abstract interface class SearchQueryRepository {
  static const int maxRecentSearches = 10;

  Future<SearchQuery> recordRecent(String query);
  Future<SearchQuery> saveSearch(String query, {String? label});
  Future<SearchQuery?> findByNormalizedQuery(String normalizedQuery);
  Future<List<SearchQuery>> getRecent({int limit = 10});
  Future<List<SearchQuery>> getSaved();
  Future<void> removeRecent(int id);
  Future<void> unsave(int id);
  Future<void> clearRecent();
  Stream<List<SearchQuery>> watchRecent({int limit = 10});
  Stream<List<SearchQuery>> watchSaved();
}
