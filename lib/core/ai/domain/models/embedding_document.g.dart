// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedding_document.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEmbeddingDocumentCollection on Isar {
  IsarCollection<EmbeddingDocument> get embeddingDocuments => this.collection();
}

const EmbeddingDocumentSchema = CollectionSchema(
  name: r'EmbeddingDocument',
  id: -184869493421462717,
  properties: {
    r'bookmarkId': PropertySchema(
      id: 0,
      name: r'bookmarkId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dimensions': PropertySchema(
      id: 2,
      name: r'dimensions',
      type: IsarType.long,
    ),
    r'modelName': PropertySchema(
      id: 3,
      name: r'modelName',
      type: IsarType.string,
    ),
    r'values': PropertySchema(
      id: 4,
      name: r'values',
      type: IsarType.doubleList,
    )
  },
  estimateSize: _embeddingDocumentEstimateSize,
  serialize: _embeddingDocumentSerialize,
  deserialize: _embeddingDocumentDeserialize,
  deserializeProp: _embeddingDocumentDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookmarkId': IndexSchema(
      id: 7502005763379596484,
      name: r'bookmarkId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookmarkId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _embeddingDocumentGetId,
  getLinks: _embeddingDocumentGetLinks,
  attach: _embeddingDocumentAttach,
  version: '3.1.0+1',
);

int _embeddingDocumentEstimateSize(
  EmbeddingDocument object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.modelName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.values.length * 8;
  return bytesCount;
}

void _embeddingDocumentSerialize(
  EmbeddingDocument object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bookmarkId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.dimensions);
  writer.writeString(offsets[3], object.modelName);
  writer.writeDoubleList(offsets[4], object.values);
}

EmbeddingDocument _embeddingDocumentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmbeddingDocument(
    bookmarkId: reader.readLong(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    dimensions: reader.readLong(offsets[2]),
    modelName: reader.readStringOrNull(offsets[3]),
    values: reader.readDoubleList(offsets[4]) ?? [],
  );
  object.id = id;
  return object;
}

P _embeddingDocumentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _embeddingDocumentGetId(EmbeddingDocument object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _embeddingDocumentGetLinks(
    EmbeddingDocument object) {
  return [];
}

void _embeddingDocumentAttach(
    IsarCollection<dynamic> col, Id id, EmbeddingDocument object) {
  object.id = id;
}

extension EmbeddingDocumentQueryWhereSort
    on QueryBuilder<EmbeddingDocument, EmbeddingDocument, QWhere> {
  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhere>
      anyBookmarkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookmarkId'),
      );
    });
  }
}

extension EmbeddingDocumentQueryWhere
    on QueryBuilder<EmbeddingDocument, EmbeddingDocument, QWhereClause> {
  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhereClause>
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

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhereClause>
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

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhereClause>
      bookmarkIdEqualTo(int bookmarkId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookmarkId',
        value: [bookmarkId],
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhereClause>
      bookmarkIdNotEqualTo(int bookmarkId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookmarkId',
              lower: [],
              upper: [bookmarkId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookmarkId',
              lower: [bookmarkId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookmarkId',
              lower: [bookmarkId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookmarkId',
              lower: [],
              upper: [bookmarkId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhereClause>
      bookmarkIdGreaterThan(
    int bookmarkId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookmarkId',
        lower: [bookmarkId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhereClause>
      bookmarkIdLessThan(
    int bookmarkId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookmarkId',
        lower: [],
        upper: [bookmarkId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterWhereClause>
      bookmarkIdBetween(
    int lowerBookmarkId,
    int upperBookmarkId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookmarkId',
        lower: [lowerBookmarkId],
        includeLower: includeLower,
        upper: [upperBookmarkId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EmbeddingDocumentQueryFilter
    on QueryBuilder<EmbeddingDocument, EmbeddingDocument, QFilterCondition> {
  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      bookmarkIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookmarkId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      bookmarkIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookmarkId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      bookmarkIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookmarkId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      bookmarkIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookmarkId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      dimensionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dimensions',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      dimensionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dimensions',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      dimensionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dimensions',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      dimensionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dimensions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'modelName',
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'modelName',
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modelName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'modelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'modelName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelName',
        value: '',
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      modelNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'modelName',
        value: '',
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      valuesElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'values',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      valuesElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'values',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      valuesElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'values',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      valuesElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'values',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      valuesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'values',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      valuesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'values',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      valuesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'values',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      valuesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'values',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      valuesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'values',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterFilterCondition>
      valuesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'values',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension EmbeddingDocumentQueryObject
    on QueryBuilder<EmbeddingDocument, EmbeddingDocument, QFilterCondition> {}

extension EmbeddingDocumentQueryLinks
    on QueryBuilder<EmbeddingDocument, EmbeddingDocument, QFilterCondition> {}

extension EmbeddingDocumentQuerySortBy
    on QueryBuilder<EmbeddingDocument, EmbeddingDocument, QSortBy> {
  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      sortByBookmarkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkId', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      sortByBookmarkIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkId', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      sortByDimensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensions', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      sortByDimensionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensions', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      sortByModelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelName', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      sortByModelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelName', Sort.desc);
    });
  }
}

extension EmbeddingDocumentQuerySortThenBy
    on QueryBuilder<EmbeddingDocument, EmbeddingDocument, QSortThenBy> {
  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      thenByBookmarkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkId', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      thenByBookmarkIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkId', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      thenByDimensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensions', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      thenByDimensionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensions', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      thenByModelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelName', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QAfterSortBy>
      thenByModelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelName', Sort.desc);
    });
  }
}

extension EmbeddingDocumentQueryWhereDistinct
    on QueryBuilder<EmbeddingDocument, EmbeddingDocument, QDistinct> {
  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QDistinct>
      distinctByBookmarkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookmarkId');
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QDistinct>
      distinctByDimensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dimensions');
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QDistinct>
      distinctByModelName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modelName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmbeddingDocument, EmbeddingDocument, QDistinct>
      distinctByValues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'values');
    });
  }
}

extension EmbeddingDocumentQueryProperty
    on QueryBuilder<EmbeddingDocument, EmbeddingDocument, QQueryProperty> {
  QueryBuilder<EmbeddingDocument, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EmbeddingDocument, int, QQueryOperations> bookmarkIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookmarkId');
    });
  }

  QueryBuilder<EmbeddingDocument, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<EmbeddingDocument, int, QQueryOperations> dimensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dimensions');
    });
  }

  QueryBuilder<EmbeddingDocument, String?, QQueryOperations>
      modelNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modelName');
    });
  }

  QueryBuilder<EmbeddingDocument, List<double>, QQueryOperations>
      valuesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'values');
    });
  }
}
