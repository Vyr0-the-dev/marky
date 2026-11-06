import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/search_query_entity.dart';
import 'package:marky/features/search/data/search_query_mapper.dart';
import 'package:marky/features/search/domain/search_query.dart';
import 'package:marky/features/search/domain/search_query_repository.dart';

class IsarSearchQueryRepository implements SearchQueryRepository {
  IsarSearchQueryRepository(this._isar);

  final Isar _isar;

  @override
  Future<SearchQuery> recordRecent(String query) async {
    final String normalized = SearchQuery.normalize(query);
    if (normalized.isEmpty) {
      throw ArgumentError.value(query, 'query', 'Query must not be blank');
    }
    final DateTime now = DateTime.now();
    final SearchQuery recorded = await _upsertNormalized(
      normalized,
      (SearchQuery? existing) => (existing ??
              SearchQuery(
                query: query.trim(),
                normalizedQuery: normalized,
                createdAt: now,
                lastUsedAt: now,
              ))
          .copyWith(
        query: query.trim(),
        isRecent: true,
        useCount: (existing?.useCount ?? 0) + 1,
        lastUsedAt: now,
      ),
    );
    await _pruneRecent();
    return recorded;
  }

  @override
  Future<SearchQuery> saveSearch(String query, {String? label}) async {
    final String normalized = SearchQuery.normalize(query);
    if (normalized.isEmpty) {
      throw ArgumentError.value(query, 'query', 'Query must not be blank');
    }
    final DateTime now = DateTime.now();
    return _upsertNormalized(
      normalized,
      (SearchQuery? existing) => (existing ??
              SearchQuery(
                query: query.trim(),
                normalizedQuery: normalized,
                createdAt: now,
                lastUsedAt: now,
              ))
          .copyWith(
        query: query.trim(),
        label: label,
        isSaved: true,
        savedAt: now,
        lastUsedAt: now,
      ),
    );
  }

  @override
  Future<SearchQuery?> findByNormalizedQuery(String normalizedQuery) async {
    final SearchQueryEntity? entity = await _isar.searchQueries
        .where()
        .normalizedQueryEqualTo(normalizedQuery)
        .findFirst();
    return entity == null ? null : SearchQueryMapper.toDomain(entity);
  }

  @override
  Future<List<SearchQuery>> getRecent({
    int limit = SearchQueryRepository.maxRecentSearches,
  }) async {
    final List<SearchQueryEntity> rows = await _isar.searchQueries
        .filter()
        .isRecentEqualTo(true)
        .sortByLastUsedAtDesc()
        .limit(limit)
        .findAll();
    return rows.map(SearchQueryMapper.toDomain).toList(growable: false);
  }

  @override
  Future<List<SearchQuery>> getSaved() async {
    final List<SearchQueryEntity> rows = await _isar.searchQueries
        .filter()
        .isSavedEqualTo(true)
        .sortBySavedAtDesc()
        .findAll();
    return rows.map(SearchQueryMapper.toDomain).toList(growable: false);
  }

  @override
  Future<void> removeRecent(int id) async {
    await _transition(
        id, (SearchQuery query) => query.copyWith(isRecent: false));
  }

  @override
  Future<void> unsave(int id) async {
    await _transition(
        id, (SearchQuery query) => query.copyWith(isSaved: false));
  }

  @override
  Future<void> clearRecent() async {
    await _isar.writeTxn<void>(() async {
      final List<SearchQueryEntity> rows =
          await _isar.searchQueries.filter().isRecentEqualTo(true).findAll();
      for (final SearchQueryEntity row in rows) {
        if (row.isSaved) {
          row.isRecent = false;
          await _isar.searchQueries.put(row);
        } else {
          await _isar.searchQueries.delete(row.id);
        }
      }
    });
  }

  @override
  Stream<List<SearchQuery>> watchRecent({
    int limit = SearchQueryRepository.maxRecentSearches,
  }) {
    final Query<SearchQueryEntity> query = _isar.searchQueries
        .filter()
        .isRecentEqualTo(true)
        .sortByLastUsedAtDesc()
        .limit(limit)
        .build();
    return query.watch(fireImmediately: true).map(
          (List<SearchQueryEntity> rows) =>
              rows.map(SearchQueryMapper.toDomain).toList(growable: false),
        );
  }

  @override
  Stream<List<SearchQuery>> watchSaved() {
    final Query<SearchQueryEntity> query = _isar.searchQueries
        .filter()
        .isSavedEqualTo(true)
        .sortBySavedAtDesc()
        .build();
    return query.watch(fireImmediately: true).map(
          (List<SearchQueryEntity> rows) =>
              rows.map(SearchQueryMapper.toDomain).toList(growable: false),
        );
  }

  Future<SearchQuery> _upsertNormalized(
    String normalized,
    SearchQuery Function(SearchQuery? existing) build,
  ) async {
    return _isar.writeTxn<SearchQuery>(() async {
      final SearchQueryEntity? before = await _isar.searchQueries
          .where()
          .normalizedQueryEqualTo(normalized)
          .findFirst();
      final SearchQuery next = build(
        before == null ? null : SearchQueryMapper.toDomain(before),
      );
      final int id =
          await _isar.searchQueries.put(SearchQueryMapper.toEntity(next));
      return next.copyWith(id: id);
    });
  }

  Future<void> _pruneRecent() async {
    await _isar.writeTxn<void>(() async {
      final List<SearchQueryEntity> rows = await _isar.searchQueries
          .filter()
          .isRecentEqualTo(true)
          .sortByLastUsedAtDesc()
          .findAll();
      if (rows.length <= SearchQueryRepository.maxRecentSearches) return;
      final List<SearchQueryEntity> expired =
          rows.skip(SearchQueryRepository.maxRecentSearches).toList();
      for (final SearchQueryEntity row in expired) {
        if (row.isSaved) {
          row.isRecent = false;
          await _isar.searchQueries.put(row);
        } else {
          await _isar.searchQueries.delete(row.id);
        }
      }
    });
  }

  Future<void> _transition(
    int id,
    SearchQuery Function(SearchQuery query) edit,
  ) async {
    await _isar.writeTxn<void>(() async {
      final SearchQueryEntity? before = await _isar.searchQueries.get(id);
      if (before == null) return;
      await _isar.searchQueries.put(
        SearchQueryMapper.toEntity(edit(SearchQueryMapper.toDomain(before))),
      );
    });
  }
}
