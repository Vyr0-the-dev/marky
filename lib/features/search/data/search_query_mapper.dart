import 'package:isar/isar.dart';

import 'package:marky/core/database/entities/search_query_entity.dart';
import 'package:marky/features/search/domain/search_query.dart';

abstract final class SearchQueryMapper {
  static SearchQuery toDomain(SearchQueryEntity entity) => SearchQuery(
        id: entity.id == Isar.autoIncrement ? null : entity.id,
        query: entity.query,
        normalizedQuery: entity.normalizedQuery,
        label: entity.label,
        isRecent: entity.isRecent,
        isSaved: entity.isSaved,
        useCount: entity.useCount,
        createdAt: entity.createdAt,
        lastUsedAt: entity.lastUsedAt,
        savedAt: entity.savedAt,
      );

  static SearchQueryEntity toEntity(SearchQuery query) {
    final SearchQueryEntity entity = SearchQueryEntity(
      query: query.query,
      normalizedQuery: query.normalizedQuery,
      label: query.label,
      isRecent: query.isRecent,
      isSaved: query.isSaved,
      useCount: query.useCount,
      createdAt: query.createdAt,
      lastUsedAt: query.lastUsedAt,
      savedAt: query.savedAt,
    );
    if (query.id != null) entity.id = query.id!;
    return entity;
  }
}
