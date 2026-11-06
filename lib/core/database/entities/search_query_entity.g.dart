// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_query_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSearchQueryEntityCollection on Isar {
  IsarCollection<SearchQueryEntity> get searchQueries => this.collection();
}

const SearchQueryEntitySchema = CollectionSchema(
  name: r'SearchQueryEntity',
  id: -314847972918659247,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isRecent': PropertySchema(
      id: 1,
      name: r'isRecent',
      type: IsarType.bool,
    ),
    r'isSaved': PropertySchema(
      id: 2,
      name: r'isSaved',
      type: IsarType.bool,
    ),
    r'label': PropertySchema(
      id: 3,
      name: r'label',
      type: IsarType.string,
    ),
    r'lastUsedAt': PropertySchema(
      id: 4,
      name: r'lastUsedAt',
      type: IsarType.dateTime,
    ),
    r'normalizedQuery': PropertySchema(
      id: 5,
      name: r'normalizedQuery',
      type: IsarType.string,
    ),
    r'query': PropertySchema(
      id: 6,
      name: r'query',
      type: IsarType.string,
    ),
    r'savedAt': PropertySchema(
      id: 7,
      name: r'savedAt',
      type: IsarType.dateTime,
    ),
    r'useCount': PropertySchema(
      id: 8,
      name: r'useCount',
      type: IsarType.long,
    )
  },
  estimateSize: _searchQueryEntityEstimateSize,
  serialize: _searchQueryEntitySerialize,
  deserialize: _searchQueryEntityDeserialize,
  deserializeProp: _searchQueryEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'normalizedQuery': IndexSchema(
      id: -8869323565622634762,
      name: r'normalizedQuery',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'normalizedQuery',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'isRecent': IndexSchema(
      id: 1814391413947816954,
      name: r'isRecent',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isRecent',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isSaved': IndexSchema(
      id: -1922149643158809683,
      name: r'isSaved',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSaved',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'lastUsedAt': IndexSchema(
      id: 458483797936957613,
      name: r'lastUsedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastUsedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _searchQueryEntityGetId,
  getLinks: _searchQueryEntityGetLinks,
  attach: _searchQueryEntityAttach,
  version: '3.1.0+1',
);

int _searchQueryEntityEstimateSize(
  SearchQueryEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.label;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.normalizedQuery.length * 3;
  bytesCount += 3 + object.query.length * 3;
  return bytesCount;
}

void _searchQueryEntitySerialize(
  SearchQueryEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isRecent);
  writer.writeBool(offsets[2], object.isSaved);
  writer.writeString(offsets[3], object.label);
  writer.writeDateTime(offsets[4], object.lastUsedAt);
  writer.writeString(offsets[5], object.normalizedQuery);
  writer.writeString(offsets[6], object.query);
  writer.writeDateTime(offsets[7], object.savedAt);
  writer.writeLong(offsets[8], object.useCount);
}

SearchQueryEntity _searchQueryEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SearchQueryEntity(
    createdAt: reader.readDateTime(offsets[0]),
    isRecent: reader.readBoolOrNull(offsets[1]) ?? true,
    isSaved: reader.readBoolOrNull(offsets[2]) ?? false,
    label: reader.readStringOrNull(offsets[3]),
    lastUsedAt: reader.readDateTime(offsets[4]),
    normalizedQuery: reader.readString(offsets[5]),
    query: reader.readString(offsets[6]),
    savedAt: reader.readDateTimeOrNull(offsets[7]),
    useCount: reader.readLongOrNull(offsets[8]) ?? 0,
  );
  object.id = id;
  return object;
}

P _searchQueryEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _searchQueryEntityGetId(SearchQueryEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _searchQueryEntityGetLinks(
    SearchQueryEntity object) {
  return [];
}

void _searchQueryEntityAttach(
    IsarCollection<dynamic> col, Id id, SearchQueryEntity object) {
  object.id = id;
}

extension SearchQueryEntityByIndex on IsarCollection<SearchQueryEntity> {
  Future<SearchQueryEntity?> getByNormalizedQuery(String normalizedQuery) {
    return getByIndex(r'normalizedQuery', [normalizedQuery]);
  }

  SearchQueryEntity? getByNormalizedQuerySync(String normalizedQuery) {
    return getByIndexSync(r'normalizedQuery', [normalizedQuery]);
  }

  Future<bool> deleteByNormalizedQuery(String normalizedQuery) {
    return deleteByIndex(r'normalizedQuery', [normalizedQuery]);
  }

  bool deleteByNormalizedQuerySync(String normalizedQuery) {
    return deleteByIndexSync(r'normalizedQuery', [normalizedQuery]);
  }

  Future<List<SearchQueryEntity?>> getAllByNormalizedQuery(
      List<String> normalizedQueryValues) {
    final values = normalizedQueryValues.map((e) => [e]).toList();
    return getAllByIndex(r'normalizedQuery', values);
  }

  List<SearchQueryEntity?> getAllByNormalizedQuerySync(
      List<String> normalizedQueryValues) {
    final values = normalizedQueryValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'normalizedQuery', values);
  }

  Future<int> deleteAllByNormalizedQuery(List<String> normalizedQueryValues) {
    final values = normalizedQueryValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'normalizedQuery', values);
  }

  int deleteAllByNormalizedQuerySync(List<String> normalizedQueryValues) {
    final values = normalizedQueryValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'normalizedQuery', values);
  }

  Future<Id> putByNormalizedQuery(SearchQueryEntity object) {
    return putByIndex(r'normalizedQuery', object);
  }

  Id putByNormalizedQuerySync(SearchQueryEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'normalizedQuery', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNormalizedQuery(List<SearchQueryEntity> objects) {
    return putAllByIndex(r'normalizedQuery', objects);
  }

  List<Id> putAllByNormalizedQuerySync(List<SearchQueryEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'normalizedQuery', objects, saveLinks: saveLinks);
  }
}

extension SearchQueryEntityQueryWhereSort
    on QueryBuilder<SearchQueryEntity, SearchQueryEntity, QWhere> {
  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhere>
      anyIsRecent() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isRecent'),
      );
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhere> anyIsSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSaved'),
      );
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhere>
      anyLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastUsedAt'),
      );
    });
  }
}

extension SearchQueryEntityQueryWhere
    on QueryBuilder<SearchQueryEntity, SearchQueryEntity, QWhereClause> {
  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      normalizedQueryEqualTo(String normalizedQuery) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'normalizedQuery',
        value: [normalizedQuery],
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      normalizedQueryNotEqualTo(String normalizedQuery) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedQuery',
              lower: [],
              upper: [normalizedQuery],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedQuery',
              lower: [normalizedQuery],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedQuery',
              lower: [normalizedQuery],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedQuery',
              lower: [],
              upper: [normalizedQuery],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      isRecentEqualTo(bool isRecent) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isRecent',
        value: [isRecent],
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      isRecentNotEqualTo(bool isRecent) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isRecent',
              lower: [],
              upper: [isRecent],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isRecent',
              lower: [isRecent],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isRecent',
              lower: [isRecent],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isRecent',
              lower: [],
              upper: [isRecent],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      isSavedEqualTo(bool isSaved) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSaved',
        value: [isSaved],
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      isSavedNotEqualTo(bool isSaved) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSaved',
              lower: [],
              upper: [isSaved],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSaved',
              lower: [isSaved],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSaved',
              lower: [isSaved],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSaved',
              lower: [],
              upper: [isSaved],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      lastUsedAtEqualTo(DateTime lastUsedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastUsedAt',
        value: [lastUsedAt],
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      lastUsedAtNotEqualTo(DateTime lastUsedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastUsedAt',
              lower: [],
              upper: [lastUsedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastUsedAt',
              lower: [lastUsedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastUsedAt',
              lower: [lastUsedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastUsedAt',
              lower: [],
              upper: [lastUsedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      lastUsedAtGreaterThan(
    DateTime lastUsedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastUsedAt',
        lower: [lastUsedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      lastUsedAtLessThan(
    DateTime lastUsedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastUsedAt',
        lower: [],
        upper: [lastUsedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterWhereClause>
      lastUsedAtBetween(
    DateTime lowerLastUsedAt,
    DateTime upperLastUsedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastUsedAt',
        lower: [lowerLastUsedAt],
        includeLower: includeLower,
        upper: [upperLastUsedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SearchQueryEntityQueryFilter
    on QueryBuilder<SearchQueryEntity, SearchQueryEntity, QFilterCondition> {
  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      isRecentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRecent',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      isSavedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSaved',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'label',
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'label',
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      lastUsedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      lastUsedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUsedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      lastUsedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUsedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      lastUsedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUsedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      normalizedQueryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedQuery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      normalizedQueryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'normalizedQuery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      normalizedQueryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'normalizedQuery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      normalizedQueryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'normalizedQuery',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      normalizedQueryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'normalizedQuery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      normalizedQueryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'normalizedQuery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      normalizedQueryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'normalizedQuery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      normalizedQueryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'normalizedQuery',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      normalizedQueryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedQuery',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      normalizedQueryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'normalizedQuery',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      queryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      queryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      queryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      queryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'query',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      queryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      queryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      queryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'query',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      queryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'query',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      queryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'query',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      queryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'query',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      savedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'savedAt',
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      savedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'savedAt',
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      savedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      savedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      savedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      savedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      useCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'useCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      useCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'useCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      useCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'useCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterFilterCondition>
      useCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'useCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SearchQueryEntityQueryObject
    on QueryBuilder<SearchQueryEntity, SearchQueryEntity, QFilterCondition> {}

extension SearchQueryEntityQueryLinks
    on QueryBuilder<SearchQueryEntity, SearchQueryEntity, QFilterCondition> {}

extension SearchQueryEntityQuerySortBy
    on QueryBuilder<SearchQueryEntity, SearchQueryEntity, QSortBy> {
  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByIsRecent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecent', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByIsRecentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecent', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByIsSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByIsSavedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByLastUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByNormalizedQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedQuery', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByNormalizedQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedQuery', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByUseCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      sortByUseCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.desc);
    });
  }
}

extension SearchQueryEntityQuerySortThenBy
    on QueryBuilder<SearchQueryEntity, SearchQueryEntity, QSortThenBy> {
  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByIsRecent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecent', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByIsRecentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecent', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByIsSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByIsSavedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSaved', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByLastUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByNormalizedQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedQuery', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByNormalizedQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedQuery', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByUseCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.asc);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QAfterSortBy>
      thenByUseCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.desc);
    });
  }
}

extension SearchQueryEntityQueryWhereDistinct
    on QueryBuilder<SearchQueryEntity, SearchQueryEntity, QDistinct> {
  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QDistinct>
      distinctByIsRecent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRecent');
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QDistinct>
      distinctByIsSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSaved');
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QDistinct> distinctByLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QDistinct>
      distinctByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsedAt');
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QDistinct>
      distinctByNormalizedQuery({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'normalizedQuery',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QDistinct> distinctByQuery(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'query', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QDistinct>
      distinctBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAt');
    });
  }

  QueryBuilder<SearchQueryEntity, SearchQueryEntity, QDistinct>
      distinctByUseCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useCount');
    });
  }
}

extension SearchQueryEntityQueryProperty
    on QueryBuilder<SearchQueryEntity, SearchQueryEntity, QQueryProperty> {
  QueryBuilder<SearchQueryEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SearchQueryEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SearchQueryEntity, bool, QQueryOperations> isRecentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRecent');
    });
  }

  QueryBuilder<SearchQueryEntity, bool, QQueryOperations> isSavedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSaved');
    });
  }

  QueryBuilder<SearchQueryEntity, String?, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<SearchQueryEntity, DateTime, QQueryOperations>
      lastUsedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsedAt');
    });
  }

  QueryBuilder<SearchQueryEntity, String, QQueryOperations>
      normalizedQueryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedQuery');
    });
  }

  QueryBuilder<SearchQueryEntity, String, QQueryOperations> queryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'query');
    });
  }

  QueryBuilder<SearchQueryEntity, DateTime?, QQueryOperations>
      savedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAt');
    });
  }

  QueryBuilder<SearchQueryEntity, int, QQueryOperations> useCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useCount');
    });
  }
}
