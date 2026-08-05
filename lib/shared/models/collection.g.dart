// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookmarkCollectionCollection on Isar {
  IsarCollection<BookmarkCollection> get bookmarkCollections =>
      this.collection();
}

const BookmarkCollectionSchema = CollectionSchema(
  name: r'BookmarkCollection',
  id: -7433758756138560705,
  properties: {
    r'accentColor': PropertySchema(
      id: 0,
      name: r'accentColor',
      type: IsarType.string,
    ),
    r'coverImageUrl': PropertySchema(
      id: 1,
      name: r'coverImageUrl',
      type: IsarType.string,
    ),
    r'coverLocalPath': PropertySchema(
      id: 2,
      name: r'coverLocalPath',
      type: IsarType.string,
    ),
    r'coverMode': PropertySchema(
      id: 3,
      name: r'coverMode',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 5,
      name: r'description',
      type: IsarType.string,
    ),
    r'icon': PropertySchema(
      id: 6,
      name: r'icon',
      type: IsarType.string,
    ),
    r'isArchived': PropertySchema(
      id: 7,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'isPinned': PropertySchema(
      id: 8,
      name: r'isPinned',
      type: IsarType.bool,
    ),
    r'isSmartCollection': PropertySchema(
      id: 9,
      name: r'isSmartCollection',
      type: IsarType.bool,
    ),
    r'itemCount': PropertySchema(
      id: 10,
      name: r'itemCount',
      type: IsarType.long,
    ),
    r'slug': PropertySchema(
      id: 11,
      name: r'slug',
      type: IsarType.string,
    ),
    r'smartRuleJson': PropertySchema(
      id: 12,
      name: r'smartRuleJson',
      type: IsarType.string,
    ),
    r'sortMode': PropertySchema(
      id: 13,
      name: r'sortMode',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 14,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _bookmarkCollectionEstimateSize,
  serialize: _bookmarkCollectionSerialize,
  deserialize: _bookmarkCollectionDeserialize,
  deserializeProp: _bookmarkCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'slug': IndexSchema(
      id: 6169444064746062836,
      name: r'slug',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'slug',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bookmarkCollectionGetId,
  getLinks: _bookmarkCollectionGetLinks,
  attach: _bookmarkCollectionAttach,
  version: '3.1.0+1',
);

int _bookmarkCollectionEstimateSize(
  BookmarkCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.accentColor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.coverImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.coverLocalPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.coverMode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.icon;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.slug.length * 3;
  {
    final value = object.smartRuleJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sortMode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _bookmarkCollectionSerialize(
  BookmarkCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accentColor);
  writer.writeString(offsets[1], object.coverImageUrl);
  writer.writeString(offsets[2], object.coverLocalPath);
  writer.writeString(offsets[3], object.coverMode);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.description);
  writer.writeString(offsets[6], object.icon);
  writer.writeBool(offsets[7], object.isArchived);
  writer.writeBool(offsets[8], object.isPinned);
  writer.writeBool(offsets[9], object.isSmartCollection);
  writer.writeLong(offsets[10], object.itemCount);
  writer.writeString(offsets[11], object.slug);
  writer.writeString(offsets[12], object.smartRuleJson);
  writer.writeString(offsets[13], object.sortMode);
  writer.writeString(offsets[14], object.title);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

BookmarkCollection _bookmarkCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BookmarkCollection(
    accentColor: reader.readStringOrNull(offsets[0]),
    coverImageUrl: reader.readStringOrNull(offsets[1]),
    coverLocalPath: reader.readStringOrNull(offsets[2]),
    coverMode: reader.readStringOrNull(offsets[3]),
    createdAt: reader.readDateTime(offsets[4]),
    description: reader.readStringOrNull(offsets[5]),
    icon: reader.readStringOrNull(offsets[6]),
    isArchived: reader.readBoolOrNull(offsets[7]) ?? false,
    isPinned: reader.readBoolOrNull(offsets[8]) ?? false,
    isSmartCollection: reader.readBoolOrNull(offsets[9]) ?? false,
    itemCount: reader.readLongOrNull(offsets[10]) ?? 0,
    slug: reader.readString(offsets[11]),
    smartRuleJson: reader.readStringOrNull(offsets[12]),
    sortMode: reader.readStringOrNull(offsets[13]),
    title: reader.readString(offsets[14]),
    updatedAt: reader.readDateTime(offsets[15]),
  );
  object.id = id;
  return object;
}

P _bookmarkCollectionDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bookmarkCollectionGetId(BookmarkCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookmarkCollectionGetLinks(
    BookmarkCollection object) {
  return [];
}

void _bookmarkCollectionAttach(
    IsarCollection<dynamic> col, Id id, BookmarkCollection object) {
  object.id = id;
}

extension BookmarkCollectionByIndex on IsarCollection<BookmarkCollection> {
  Future<BookmarkCollection?> getBySlug(String slug) {
    return getByIndex(r'slug', [slug]);
  }

  BookmarkCollection? getBySlugSync(String slug) {
    return getByIndexSync(r'slug', [slug]);
  }

  Future<bool> deleteBySlug(String slug) {
    return deleteByIndex(r'slug', [slug]);
  }

  bool deleteBySlugSync(String slug) {
    return deleteByIndexSync(r'slug', [slug]);
  }

  Future<List<BookmarkCollection?>> getAllBySlug(List<String> slugValues) {
    final values = slugValues.map((e) => [e]).toList();
    return getAllByIndex(r'slug', values);
  }

  List<BookmarkCollection?> getAllBySlugSync(List<String> slugValues) {
    final values = slugValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'slug', values);
  }

  Future<int> deleteAllBySlug(List<String> slugValues) {
    final values = slugValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'slug', values);
  }

  int deleteAllBySlugSync(List<String> slugValues) {
    final values = slugValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'slug', values);
  }

  Future<Id> putBySlug(BookmarkCollection object) {
    return putByIndex(r'slug', object);
  }

  Id putBySlugSync(BookmarkCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'slug', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySlug(List<BookmarkCollection> objects) {
    return putAllByIndex(r'slug', objects);
  }

  List<Id> putAllBySlugSync(List<BookmarkCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'slug', objects, saveLinks: saveLinks);
  }
}

extension BookmarkCollectionQueryWhereSort
    on QueryBuilder<BookmarkCollection, BookmarkCollection, QWhere> {
  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BookmarkCollectionQueryWhere
    on QueryBuilder<BookmarkCollection, BookmarkCollection, QWhereClause> {
  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterWhereClause>
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

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterWhereClause>
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

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterWhereClause>
      slugEqualTo(String slug) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'slug',
        value: [slug],
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterWhereClause>
      slugNotEqualTo(String slug) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'slug',
              lower: [],
              upper: [slug],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'slug',
              lower: [slug],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'slug',
              lower: [slug],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'slug',
              lower: [],
              upper: [slug],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BookmarkCollectionQueryFilter
    on QueryBuilder<BookmarkCollection, BookmarkCollection, QFilterCondition> {
  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accentColor',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accentColor',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accentColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accentColor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accentColor',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      accentColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accentColor',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverImageUrl',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverImageUrl',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverImageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coverImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coverImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coverImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coverImageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coverImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverLocalPath',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverLocalPath',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverLocalPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coverLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coverLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coverLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coverLocalPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverLocalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coverLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverMode',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverMode',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coverMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coverMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coverMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coverMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverMode',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      coverModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coverMode',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
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

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
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

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
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

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'icon',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'icon',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'icon',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'icon',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      iconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
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

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
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

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
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

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      isArchivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isArchived',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      isPinnedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPinned',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      isSmartCollectionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSmartCollection',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      itemCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      itemCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      itemCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      itemCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      slugEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      slugGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      slugLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      slugBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'slug',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      slugStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      slugEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      slugContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'slug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      slugMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'slug',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      slugIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slug',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      slugIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'slug',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'smartRuleJson',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'smartRuleJson',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'smartRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'smartRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'smartRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'smartRuleJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'smartRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'smartRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'smartRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'smartRuleJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'smartRuleJson',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      smartRuleJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'smartRuleJson',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sortMode',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sortMode',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sortMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sortMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sortMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sortMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortMode',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      sortModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sortMode',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BookmarkCollectionQueryObject
    on QueryBuilder<BookmarkCollection, BookmarkCollection, QFilterCondition> {}

extension BookmarkCollectionQueryLinks
    on QueryBuilder<BookmarkCollection, BookmarkCollection, QFilterCondition> {}

extension BookmarkCollectionQuerySortBy
    on QueryBuilder<BookmarkCollection, BookmarkCollection, QSortBy> {
  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByCoverImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImageUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByCoverImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImageUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByCoverLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverLocalPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByCoverLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverLocalPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByCoverMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverMode', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByCoverModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverMode', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByIsSmartCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSmartCollection', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByIsSmartCollectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSmartCollection', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByItemCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemCount', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByItemCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemCount', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortBySlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortBySlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortBySmartRuleJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartRuleJson', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortBySmartRuleJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartRuleJson', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortBySortMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortMode', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortBySortModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortMode', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension BookmarkCollectionQuerySortThenBy
    on QueryBuilder<BookmarkCollection, BookmarkCollection, QSortThenBy> {
  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByCoverImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImageUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByCoverImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImageUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByCoverLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverLocalPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByCoverLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverLocalPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByCoverMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverMode', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByCoverModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverMode', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByIsSmartCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSmartCollection', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByIsSmartCollectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSmartCollection', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByItemCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemCount', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByItemCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemCount', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenBySlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenBySlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slug', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenBySmartRuleJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartRuleJson', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenBySmartRuleJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartRuleJson', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenBySortMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortMode', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenBySortModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortMode', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension BookmarkCollectionQueryWhereDistinct
    on QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct> {
  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByAccentColor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accentColor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByCoverImageUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverImageUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByCoverLocalPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverLocalPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByCoverMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByIcon({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'icon', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPinned');
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByIsSmartCollection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSmartCollection');
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByItemCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemCount');
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctBySlug({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'slug', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctBySmartRuleJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'smartRuleJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctBySortMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkCollection, BookmarkCollection, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension BookmarkCollectionQueryProperty
    on QueryBuilder<BookmarkCollection, BookmarkCollection, QQueryProperty> {
  QueryBuilder<BookmarkCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BookmarkCollection, String?, QQueryOperations>
      accentColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accentColor');
    });
  }

  QueryBuilder<BookmarkCollection, String?, QQueryOperations>
      coverImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverImageUrl');
    });
  }

  QueryBuilder<BookmarkCollection, String?, QQueryOperations>
      coverLocalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverLocalPath');
    });
  }

  QueryBuilder<BookmarkCollection, String?, QQueryOperations>
      coverModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverMode');
    });
  }

  QueryBuilder<BookmarkCollection, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BookmarkCollection, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<BookmarkCollection, String?, QQueryOperations> iconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'icon');
    });
  }

  QueryBuilder<BookmarkCollection, bool, QQueryOperations>
      isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<BookmarkCollection, bool, QQueryOperations> isPinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPinned');
    });
  }

  QueryBuilder<BookmarkCollection, bool, QQueryOperations>
      isSmartCollectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSmartCollection');
    });
  }

  QueryBuilder<BookmarkCollection, int, QQueryOperations> itemCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemCount');
    });
  }

  QueryBuilder<BookmarkCollection, String, QQueryOperations> slugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slug');
    });
  }

  QueryBuilder<BookmarkCollection, String?, QQueryOperations>
      smartRuleJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'smartRuleJson');
    });
  }

  QueryBuilder<BookmarkCollection, String?, QQueryOperations>
      sortModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortMode');
    });
  }

  QueryBuilder<BookmarkCollection, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<BookmarkCollection, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
