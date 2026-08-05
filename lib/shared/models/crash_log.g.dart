// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crash_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCrashLogCollection on Isar {
  IsarCollection<CrashLog> get crashLogs => this.collection();
}

const CrashLogSchema = CollectionSchema(
  name: r'CrashLog',
  id: -3005803319669503613,
  properties: {
    r'lastCrashError': PropertySchema(
      id: 0,
      name: r'lastCrashError',
      type: IsarType.string,
    ),
    r'lastCrashStackTrace': PropertySchema(
      id: 1,
      name: r'lastCrashStackTrace',
      type: IsarType.string,
    ),
    r'lastCrashTimestamp': PropertySchema(
      id: 2,
      name: r'lastCrashTimestamp',
      type: IsarType.long,
    ),
    r'totalCrashCount': PropertySchema(
      id: 3,
      name: r'totalCrashCount',
      type: IsarType.long,
    )
  },
  estimateSize: _crashLogEstimateSize,
  serialize: _crashLogSerialize,
  deserialize: _crashLogDeserialize,
  deserializeProp: _crashLogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _crashLogGetId,
  getLinks: _crashLogGetLinks,
  attach: _crashLogAttach,
  version: '3.1.0+1',
);

int _crashLogEstimateSize(
  CrashLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.lastCrashError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastCrashStackTrace;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _crashLogSerialize(
  CrashLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.lastCrashError);
  writer.writeString(offsets[1], object.lastCrashStackTrace);
  writer.writeLong(offsets[2], object.lastCrashTimestamp);
  writer.writeLong(offsets[3], object.totalCrashCount);
}

CrashLog _crashLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CrashLog(
    lastCrashError: reader.readStringOrNull(offsets[0]),
    lastCrashStackTrace: reader.readStringOrNull(offsets[1]),
    lastCrashTimestamp: reader.readLongOrNull(offsets[2]),
    totalCrashCount: reader.readLongOrNull(offsets[3]) ?? 0,
  );
  object.id = id;
  return object;
}

P _crashLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _crashLogGetId(CrashLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _crashLogGetLinks(CrashLog object) {
  return [];
}

void _crashLogAttach(IsarCollection<dynamic> col, Id id, CrashLog object) {
  object.id = id;
}

extension CrashLogQueryWhereSort on QueryBuilder<CrashLog, CrashLog, QWhere> {
  QueryBuilder<CrashLog, CrashLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CrashLogQueryWhere on QueryBuilder<CrashLog, CrashLog, QWhereClause> {
  QueryBuilder<CrashLog, CrashLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<CrashLog, CrashLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterWhereClause> idBetween(
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
}

extension CrashLogQueryFilter
    on QueryBuilder<CrashLog, CrashLog, QFilterCondition> {
  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCrashError',
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCrashError',
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition> lastCrashErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCrashError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCrashError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCrashError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition> lastCrashErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCrashError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastCrashError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastCrashError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastCrashError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition> lastCrashErrorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastCrashError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCrashError',
        value: '',
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastCrashError',
        value: '',
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCrashStackTrace',
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCrashStackTrace',
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCrashStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCrashStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCrashStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCrashStackTrace',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastCrashStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastCrashStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastCrashStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastCrashStackTrace',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCrashStackTrace',
        value: '',
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashStackTraceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastCrashStackTrace',
        value: '',
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCrashTimestamp',
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCrashTimestamp',
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashTimestampEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCrashTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashTimestampGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCrashTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashTimestampLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCrashTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      lastCrashTimestampBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCrashTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      totalCrashCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCrashCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      totalCrashCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCrashCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      totalCrashCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCrashCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterFilterCondition>
      totalCrashCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCrashCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CrashLogQueryObject
    on QueryBuilder<CrashLog, CrashLog, QFilterCondition> {}

extension CrashLogQueryLinks
    on QueryBuilder<CrashLog, CrashLog, QFilterCondition> {}

extension CrashLogQuerySortBy on QueryBuilder<CrashLog, CrashLog, QSortBy> {
  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> sortByLastCrashError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashError', Sort.asc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> sortByLastCrashErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashError', Sort.desc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> sortByLastCrashStackTrace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashStackTrace', Sort.asc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy>
      sortByLastCrashStackTraceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashStackTrace', Sort.desc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> sortByLastCrashTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashTimestamp', Sort.asc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy>
      sortByLastCrashTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashTimestamp', Sort.desc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> sortByTotalCrashCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCrashCount', Sort.asc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> sortByTotalCrashCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCrashCount', Sort.desc);
    });
  }
}

extension CrashLogQuerySortThenBy
    on QueryBuilder<CrashLog, CrashLog, QSortThenBy> {
  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> thenByLastCrashError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashError', Sort.asc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> thenByLastCrashErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashError', Sort.desc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> thenByLastCrashStackTrace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashStackTrace', Sort.asc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy>
      thenByLastCrashStackTraceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashStackTrace', Sort.desc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> thenByLastCrashTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashTimestamp', Sort.asc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy>
      thenByLastCrashTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrashTimestamp', Sort.desc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> thenByTotalCrashCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCrashCount', Sort.asc);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QAfterSortBy> thenByTotalCrashCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCrashCount', Sort.desc);
    });
  }
}

extension CrashLogQueryWhereDistinct
    on QueryBuilder<CrashLog, CrashLog, QDistinct> {
  QueryBuilder<CrashLog, CrashLog, QDistinct> distinctByLastCrashError(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCrashError',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QDistinct> distinctByLastCrashStackTrace(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCrashStackTrace',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CrashLog, CrashLog, QDistinct> distinctByLastCrashTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCrashTimestamp');
    });
  }

  QueryBuilder<CrashLog, CrashLog, QDistinct> distinctByTotalCrashCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCrashCount');
    });
  }
}

extension CrashLogQueryProperty
    on QueryBuilder<CrashLog, CrashLog, QQueryProperty> {
  QueryBuilder<CrashLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CrashLog, String?, QQueryOperations> lastCrashErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCrashError');
    });
  }

  QueryBuilder<CrashLog, String?, QQueryOperations>
      lastCrashStackTraceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCrashStackTrace');
    });
  }

  QueryBuilder<CrashLog, int?, QQueryOperations> lastCrashTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCrashTimestamp');
    });
  }

  QueryBuilder<CrashLog, int, QQueryOperations> totalCrashCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCrashCount');
    });
  }
}
