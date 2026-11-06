// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookmarkEntityCollection on Isar {
  IsarCollection<BookmarkEntity> get bookmarks => this.collection();
}

const BookmarkEntitySchema = CollectionSchema(
  name: r'BookmarkEntity',
  id: -7369956597930324689,
  properties: {
    r'author': PropertySchema(
      id: 0,
      name: r'author',
      type: IsarType.string,
    ),
    r'canonicalUrl': PropertySchema(
      id: 1,
      name: r'canonicalUrl',
      type: IsarType.string,
    ),
    r'collectionIds': PropertySchema(
      id: 2,
      name: r'collectionIds',
      type: IsarType.longList,
    ),
    r'contentType': PropertySchema(
      id: 3,
      name: r'contentType',
      type: IsarType.string,
      enumMap: _BookmarkEntitycontentTypeEnumValueMap,
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
    r'dominantColorHex': PropertySchema(
      id: 6,
      name: r'dominantColorHex',
      type: IsarType.string,
    ),
    r'duplicateGroupId': PropertySchema(
      id: 7,
      name: r'duplicateGroupId',
      type: IsarType.string,
    ),
    r'externalContentId': PropertySchema(
      id: 8,
      name: r'externalContentId',
      type: IsarType.string,
    ),
    r'faviconUrl': PropertySchema(
      id: 9,
      name: r'faviconUrl',
      type: IsarType.string,
    ),
    r'heroImageLocalPath': PropertySchema(
      id: 10,
      name: r'heroImageLocalPath',
      type: IsarType.string,
    ),
    r'heroImageUrl': PropertySchema(
      id: 11,
      name: r'heroImageUrl',
      type: IsarType.string,
    ),
    r'inlineNotes': PropertySchema(
      id: 12,
      name: r'inlineNotes',
      type: IsarType.string,
    ),
    r'isArchived': PropertySchema(
      id: 13,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'isFavorite': PropertySchema(
      id: 14,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'isPinned': PropertySchema(
      id: 15,
      name: r'isPinned',
      type: IsarType.bool,
    ),
    r'isRead': PropertySchema(
      id: 16,
      name: r'isRead',
      type: IsarType.bool,
    ),
    r'languageCode': PropertySchema(
      id: 17,
      name: r'languageCode',
      type: IsarType.string,
    ),
    r'lastInteractionAt': PropertySchema(
      id: 18,
      name: r'lastInteractionAt',
      type: IsarType.dateTime,
    ),
    r'lastOpenedAt': PropertySchema(
      id: 19,
      name: r'lastOpenedAt',
      type: IsarType.dateTime,
    ),
    r'localFaviconPath': PropertySchema(
      id: 20,
      name: r'localFaviconPath',
      type: IsarType.string,
    ),
    r'normalizedHost': PropertySchema(
      id: 21,
      name: r'normalizedHost',
      type: IsarType.string,
    ),
    r'openCount': PropertySchema(
      id: 22,
      name: r'openCount',
      type: IsarType.long,
    ),
    r'originalUrl': PropertySchema(
      id: 23,
      name: r'originalUrl',
      type: IsarType.string,
    ),
    r'publishDate': PropertySchema(
      id: 24,
      name: r'publishDate',
      type: IsarType.dateTime,
    ),
    r'publisher': PropertySchema(
      id: 25,
      name: r'publisher',
      type: IsarType.string,
    ),
    r'readProgress': PropertySchema(
      id: 26,
      name: r'readProgress',
      type: IsarType.double,
    ),
    r'readingTimeMinutes': PropertySchema(
      id: 27,
      name: r'readingTimeMinutes',
      type: IsarType.long,
    ),
    r'reminderIds': PropertySchema(
      id: 28,
      name: r'reminderIds',
      type: IsarType.longList,
    ),
    r'scrapingStatus': PropertySchema(
      id: 29,
      name: r'scrapingStatus',
      type: IsarType.string,
      enumMap: _BookmarkEntityscrapingStatusEnumValueMap,
    ),
    r'siteName': PropertySchema(
      id: 30,
      name: r'siteName',
      type: IsarType.string,
    ),
    r'snippet': PropertySchema(
      id: 31,
      name: r'snippet',
      type: IsarType.string,
    ),
    r'sourceType': PropertySchema(
      id: 32,
      name: r'sourceType',
      type: IsarType.string,
      enumMap: _BookmarkEntitysourceTypeEnumValueMap,
    ),
    r'tagIds': PropertySchema(
      id: 33,
      name: r'tagIds',
      type: IsarType.longList,
    ),
    r'title': PropertySchema(
      id: 34,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 35,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'urlHash': PropertySchema(
      id: 36,
      name: r'urlHash',
      type: IsarType.string,
    )
  },
  estimateSize: _bookmarkEntityEstimateSize,
  serialize: _bookmarkEntitySerialize,
  deserialize: _bookmarkEntityDeserialize,
  deserializeProp: _bookmarkEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'canonicalUrl': IndexSchema(
      id: 1898383433214980253,
      name: r'canonicalUrl',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'canonicalUrl',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'normalizedHost': IndexSchema(
      id: -1133545256588746263,
      name: r'normalizedHost',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'normalizedHost',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'urlHash': IndexSchema(
      id: 3626799727396018272,
      name: r'urlHash',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'urlHash',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'externalContentId': IndexSchema(
      id: 8590563696134471644,
      name: r'externalContentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'externalContentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isFavorite': IndexSchema(
      id: 5742774614603939776,
      name: r'isFavorite',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isFavorite',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isArchived_createdAt': IndexSchema(
      id: 2616731637558516989,
      name: r'isArchived_createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isArchived',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isRead': IndexSchema(
      id: -944277114070112791,
      name: r'isRead',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isRead',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bookmarkEntityGetId,
  getLinks: _bookmarkEntityGetLinks,
  attach: _bookmarkEntityAttach,
  version: '3.1.0+1',
);

int _bookmarkEntityEstimateSize(
  BookmarkEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.author;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.canonicalUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.collectionIds.length * 8;
  bytesCount += 3 + object.contentType.name.length * 3;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dominantColorHex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.duplicateGroupId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.externalContentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.faviconUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.heroImageLocalPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.heroImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.inlineNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.languageCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.localFaviconPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.normalizedHost;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.originalUrl.length * 3;
  {
    final value = object.publisher;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.reminderIds.length * 8;
  bytesCount += 3 + object.scrapingStatus.name.length * 3;
  {
    final value = object.siteName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.snippet;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sourceType.name.length * 3;
  bytesCount += 3 + object.tagIds.length * 8;
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.urlHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _bookmarkEntitySerialize(
  BookmarkEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeString(offsets[1], object.canonicalUrl);
  writer.writeLongList(offsets[2], object.collectionIds);
  writer.writeString(offsets[3], object.contentType.name);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.description);
  writer.writeString(offsets[6], object.dominantColorHex);
  writer.writeString(offsets[7], object.duplicateGroupId);
  writer.writeString(offsets[8], object.externalContentId);
  writer.writeString(offsets[9], object.faviconUrl);
  writer.writeString(offsets[10], object.heroImageLocalPath);
  writer.writeString(offsets[11], object.heroImageUrl);
  writer.writeString(offsets[12], object.inlineNotes);
  writer.writeBool(offsets[13], object.isArchived);
  writer.writeBool(offsets[14], object.isFavorite);
  writer.writeBool(offsets[15], object.isPinned);
  writer.writeBool(offsets[16], object.isRead);
  writer.writeString(offsets[17], object.languageCode);
  writer.writeDateTime(offsets[18], object.lastInteractionAt);
  writer.writeDateTime(offsets[19], object.lastOpenedAt);
  writer.writeString(offsets[20], object.localFaviconPath);
  writer.writeString(offsets[21], object.normalizedHost);
  writer.writeLong(offsets[22], object.openCount);
  writer.writeString(offsets[23], object.originalUrl);
  writer.writeDateTime(offsets[24], object.publishDate);
  writer.writeString(offsets[25], object.publisher);
  writer.writeDouble(offsets[26], object.readProgress);
  writer.writeLong(offsets[27], object.readingTimeMinutes);
  writer.writeLongList(offsets[28], object.reminderIds);
  writer.writeString(offsets[29], object.scrapingStatus.name);
  writer.writeString(offsets[30], object.siteName);
  writer.writeString(offsets[31], object.snippet);
  writer.writeString(offsets[32], object.sourceType.name);
  writer.writeLongList(offsets[33], object.tagIds);
  writer.writeString(offsets[34], object.title);
  writer.writeDateTime(offsets[35], object.updatedAt);
  writer.writeString(offsets[36], object.urlHash);
}

BookmarkEntity _bookmarkEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BookmarkEntity(
    author: reader.readStringOrNull(offsets[0]),
    canonicalUrl: reader.readStringOrNull(offsets[1]),
    collectionIds: reader.readLongList(offsets[2]) ?? const <int>[],
    contentType: _BookmarkEntitycontentTypeValueEnumMap[
            reader.readStringOrNull(offsets[3])] ??
        BookmarkContentType.unknown,
    createdAt: reader.readDateTime(offsets[4]),
    description: reader.readStringOrNull(offsets[5]),
    dominantColorHex: reader.readStringOrNull(offsets[6]),
    duplicateGroupId: reader.readStringOrNull(offsets[7]),
    externalContentId: reader.readStringOrNull(offsets[8]),
    faviconUrl: reader.readStringOrNull(offsets[9]),
    heroImageLocalPath: reader.readStringOrNull(offsets[10]),
    heroImageUrl: reader.readStringOrNull(offsets[11]),
    inlineNotes: reader.readStringOrNull(offsets[12]),
    isArchived: reader.readBoolOrNull(offsets[13]) ?? false,
    isFavorite: reader.readBoolOrNull(offsets[14]) ?? false,
    isPinned: reader.readBoolOrNull(offsets[15]) ?? false,
    isRead: reader.readBoolOrNull(offsets[16]) ?? false,
    languageCode: reader.readStringOrNull(offsets[17]),
    lastInteractionAt: reader.readDateTimeOrNull(offsets[18]),
    lastOpenedAt: reader.readDateTimeOrNull(offsets[19]),
    localFaviconPath: reader.readStringOrNull(offsets[20]),
    normalizedHost: reader.readStringOrNull(offsets[21]),
    openCount: reader.readLongOrNull(offsets[22]) ?? 0,
    originalUrl: reader.readString(offsets[23]),
    publishDate: reader.readDateTimeOrNull(offsets[24]),
    publisher: reader.readStringOrNull(offsets[25]),
    readProgress: reader.readDoubleOrNull(offsets[26]),
    readingTimeMinutes: reader.readLongOrNull(offsets[27]),
    reminderIds: reader.readLongList(offsets[28]) ?? const <int>[],
    scrapingStatus: _BookmarkEntityscrapingStatusValueEnumMap[
            reader.readStringOrNull(offsets[29])] ??
        BookmarkScrapingStatus.pending,
    siteName: reader.readStringOrNull(offsets[30]),
    snippet: reader.readStringOrNull(offsets[31]),
    sourceType: _BookmarkEntitysourceTypeValueEnumMap[
            reader.readStringOrNull(offsets[32])] ??
        BookmarkSourceType.manual,
    tagIds: reader.readLongList(offsets[33]) ?? const <int>[],
    title: reader.readStringOrNull(offsets[34]),
    updatedAt: reader.readDateTime(offsets[35]),
    urlHash: reader.readStringOrNull(offsets[36]),
  );
  object.id = id;
  return object;
}

P _bookmarkEntityDeserializeProp<P>(
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
      return (reader.readLongList(offset) ?? const <int>[]) as P;
    case 3:
      return (_BookmarkEntitycontentTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          BookmarkContentType.unknown) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 14:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 15:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 16:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 19:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readDoubleOrNull(offset)) as P;
    case 27:
      return (reader.readLongOrNull(offset)) as P;
    case 28:
      return (reader.readLongList(offset) ?? const <int>[]) as P;
    case 29:
      return (_BookmarkEntityscrapingStatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          BookmarkScrapingStatus.pending) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (_BookmarkEntitysourceTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          BookmarkSourceType.manual) as P;
    case 33:
      return (reader.readLongList(offset) ?? const <int>[]) as P;
    case 34:
      return (reader.readStringOrNull(offset)) as P;
    case 35:
      return (reader.readDateTime(offset)) as P;
    case 36:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BookmarkEntitycontentTypeEnumValueMap = {
  r'article': r'article',
  r'video': r'video',
  r'image': r'image',
  r'discussion': r'discussion',
  r'audio': r'audio',
  r'code': r'code',
  r'product': r'product',
  r'document': r'document',
  r'unknown': r'unknown',
};
const _BookmarkEntitycontentTypeValueEnumMap = {
  r'article': BookmarkContentType.article,
  r'video': BookmarkContentType.video,
  r'image': BookmarkContentType.image,
  r'discussion': BookmarkContentType.discussion,
  r'audio': BookmarkContentType.audio,
  r'code': BookmarkContentType.code,
  r'product': BookmarkContentType.product,
  r'document': BookmarkContentType.document,
  r'unknown': BookmarkContentType.unknown,
};
const _BookmarkEntityscrapingStatusEnumValueMap = {
  r'pending': r'pending',
  r'processing': r'processing',
  r'done': r'done',
  r'failed': r'failed',
};
const _BookmarkEntityscrapingStatusValueEnumMap = {
  r'pending': BookmarkScrapingStatus.pending,
  r'processing': BookmarkScrapingStatus.processing,
  r'done': BookmarkScrapingStatus.done,
  r'failed': BookmarkScrapingStatus.failed,
};
const _BookmarkEntitysourceTypeEnumValueMap = {
  r'manual': r'manual',
  r'share': r'share',
  r'clipboard': r'clipboard',
  r'import': r'import',
  r'automation': r'automation',
};
const _BookmarkEntitysourceTypeValueEnumMap = {
  r'manual': BookmarkSourceType.manual,
  r'share': BookmarkSourceType.share,
  r'clipboard': BookmarkSourceType.clipboard,
  r'import': BookmarkSourceType.import,
  r'automation': BookmarkSourceType.automation,
};

Id _bookmarkEntityGetId(BookmarkEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookmarkEntityGetLinks(BookmarkEntity object) {
  return [];
}

void _bookmarkEntityAttach(
    IsarCollection<dynamic> col, Id id, BookmarkEntity object) {
  object.id = id;
}

extension BookmarkEntityQueryWhereSort
    on QueryBuilder<BookmarkEntity, BookmarkEntity, QWhere> {
  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhere> anyIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isFavorite'),
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhere>
      anyIsArchivedCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isArchived_createdAt'),
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhere> anyIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isRead'),
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension BookmarkEntityQueryWhere
    on QueryBuilder<BookmarkEntity, BookmarkEntity, QWhereClause> {
  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      canonicalUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'canonicalUrl',
        value: [null],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      canonicalUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'canonicalUrl',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      canonicalUrlEqualTo(String? canonicalUrl) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'canonicalUrl',
        value: [canonicalUrl],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      canonicalUrlNotEqualTo(String? canonicalUrl) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'canonicalUrl',
              lower: [],
              upper: [canonicalUrl],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'canonicalUrl',
              lower: [canonicalUrl],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'canonicalUrl',
              lower: [canonicalUrl],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'canonicalUrl',
              lower: [],
              upper: [canonicalUrl],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      normalizedHostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'normalizedHost',
        value: [null],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      normalizedHostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'normalizedHost',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      normalizedHostEqualTo(String? normalizedHost) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'normalizedHost',
        value: [normalizedHost],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      normalizedHostNotEqualTo(String? normalizedHost) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedHost',
              lower: [],
              upper: [normalizedHost],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedHost',
              lower: [normalizedHost],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedHost',
              lower: [normalizedHost],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedHost',
              lower: [],
              upper: [normalizedHost],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      urlHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'urlHash',
        value: [null],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      urlHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'urlHash',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      urlHashEqualTo(String? urlHash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'urlHash',
        value: [urlHash],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      urlHashNotEqualTo(String? urlHash) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'urlHash',
              lower: [],
              upper: [urlHash],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'urlHash',
              lower: [urlHash],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'urlHash',
              lower: [urlHash],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'urlHash',
              lower: [],
              upper: [urlHash],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      externalContentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'externalContentId',
        value: [null],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      externalContentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'externalContentId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      externalContentIdEqualTo(String? externalContentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'externalContentId',
        value: [externalContentId],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      externalContentIdNotEqualTo(String? externalContentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'externalContentId',
              lower: [],
              upper: [externalContentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'externalContentId',
              lower: [externalContentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'externalContentId',
              lower: [externalContentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'externalContentId',
              lower: [],
              upper: [externalContentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      isFavoriteEqualTo(bool isFavorite) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isFavorite',
        value: [isFavorite],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      isFavoriteNotEqualTo(bool isFavorite) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavorite',
              lower: [],
              upper: [isFavorite],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavorite',
              lower: [isFavorite],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavorite',
              lower: [isFavorite],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavorite',
              lower: [],
              upper: [isFavorite],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      isArchivedEqualToAnyCreatedAt(bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isArchived_createdAt',
        value: [isArchived],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      isArchivedNotEqualToAnyCreatedAt(bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_createdAt',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_createdAt',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_createdAt',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_createdAt',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      isArchivedCreatedAtEqualTo(bool isArchived, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isArchived_createdAt',
        value: [isArchived, createdAt],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      isArchivedEqualToCreatedAtNotEqualTo(
          bool isArchived, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_createdAt',
              lower: [isArchived],
              upper: [isArchived, createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_createdAt',
              lower: [isArchived, createdAt],
              includeLower: false,
              upper: [isArchived],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_createdAt',
              lower: [isArchived, createdAt],
              includeLower: false,
              upper: [isArchived],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_createdAt',
              lower: [isArchived],
              upper: [isArchived, createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      isArchivedEqualToCreatedAtGreaterThan(
    bool isArchived,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'isArchived_createdAt',
        lower: [isArchived, createdAt],
        includeLower: include,
        upper: [isArchived],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      isArchivedEqualToCreatedAtLessThan(
    bool isArchived,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'isArchived_createdAt',
        lower: [isArchived],
        upper: [isArchived, createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      isArchivedEqualToCreatedAtBetween(
    bool isArchived,
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'isArchived_createdAt',
        lower: [isArchived, lowerCreatedAt],
        includeLower: includeLower,
        upper: [isArchived, upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause> isReadEqualTo(
      bool isRead) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isRead',
        value: [isRead],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      isReadNotEqualTo(bool isRead) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isRead',
              lower: [],
              upper: [isRead],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isRead',
              lower: [isRead],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isRead',
              lower: [isRead],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isRead',
              lower: [],
              upper: [isRead],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterWhereClause>
      createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BookmarkEntityQueryFilter
    on QueryBuilder<BookmarkEntity, BookmarkEntity, QFilterCondition> {
  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'author',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'canonicalUrl',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'canonicalUrl',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canonicalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'canonicalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'canonicalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'canonicalUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'canonicalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'canonicalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'canonicalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'canonicalUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canonicalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      canonicalUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'canonicalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      collectionIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      collectionIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectionIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      collectionIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectionIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      collectionIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectionIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      collectionIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collectionIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      collectionIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collectionIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      collectionIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collectionIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      collectionIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collectionIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      collectionIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collectionIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      collectionIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'collectionIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      contentTypeEqualTo(
    BookmarkContentType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      contentTypeGreaterThan(
    BookmarkContentType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      contentTypeLessThan(
    BookmarkContentType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      contentTypeBetween(
    BookmarkContentType lower,
    BookmarkContentType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      contentTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      contentTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      contentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      contentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      contentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      contentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dominantColorHex',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dominantColorHex',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dominantColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dominantColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dominantColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dominantColorHex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dominantColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dominantColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dominantColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dominantColorHex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dominantColorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      dominantColorHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dominantColorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duplicateGroupId',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duplicateGroupId',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duplicateGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duplicateGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duplicateGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duplicateGroupId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'duplicateGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'duplicateGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'duplicateGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'duplicateGroupId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duplicateGroupId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      duplicateGroupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'duplicateGroupId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'externalContentId',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'externalContentId',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalContentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'externalContentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'externalContentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'externalContentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'externalContentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'externalContentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'externalContentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'externalContentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalContentId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      externalContentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'externalContentId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'faviconUrl',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'faviconUrl',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'faviconUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'faviconUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'faviconUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      faviconUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'faviconUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'heroImageLocalPath',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'heroImageLocalPath',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heroImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heroImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heroImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heroImageLocalPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'heroImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'heroImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'heroImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'heroImageLocalPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heroImageLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageLocalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'heroImageLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'heroImageUrl',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'heroImageUrl',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heroImageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'heroImageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heroImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      heroImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'heroImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'inlineNotes',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'inlineNotes',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inlineNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inlineNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inlineNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inlineNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'inlineNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'inlineNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inlineNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inlineNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inlineNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      inlineNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inlineNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      isArchivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isArchived',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      isFavoriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavorite',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      isPinnedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPinned',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      isReadEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRead',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'languageCode',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'languageCode',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'languageCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'languageCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      languageCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastInteractionAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastInteractionAt',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastInteractionAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastInteractionAt',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastInteractionAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastInteractionAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastInteractionAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastInteractionAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastInteractionAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastInteractionAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastInteractionAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastInteractionAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastOpenedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastOpenedAt',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastOpenedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastOpenedAt',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastOpenedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastOpenedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastOpenedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastOpenedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastOpenedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastOpenedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      lastOpenedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastOpenedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localFaviconPath',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localFaviconPath',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localFaviconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localFaviconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localFaviconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localFaviconPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localFaviconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localFaviconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localFaviconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localFaviconPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localFaviconPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      localFaviconPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localFaviconPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'normalizedHost',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'normalizedHost',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'normalizedHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'normalizedHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'normalizedHost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'normalizedHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'normalizedHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'normalizedHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'normalizedHost',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedHost',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      normalizedHostIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'normalizedHost',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      openCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'openCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      openCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'openCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      openCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'openCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      openCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'openCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      originalUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      originalUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      originalUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      originalUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      originalUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      originalUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      originalUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      originalUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      originalUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      originalUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publishDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publishDate',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publishDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publishDate',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publishDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publishDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publishDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publishDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publishDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publishDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publishDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publishDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publisher',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publisher',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publisher',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'publisher',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publisher',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      publisherIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'publisher',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readProgressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'readProgress',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readProgressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'readProgress',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readProgressEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readProgressGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readProgressLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readProgressBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readingTimeMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'readingTimeMinutes',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readingTimeMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'readingTimeMinutes',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readingTimeMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readingTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readingTimeMinutesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readingTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readingTimeMinutesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readingTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      readingTimeMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readingTimeMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      reminderIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      reminderIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      reminderIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      reminderIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      reminderIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      reminderIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      reminderIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      reminderIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      reminderIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      reminderIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      scrapingStatusEqualTo(
    BookmarkScrapingStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scrapingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      scrapingStatusGreaterThan(
    BookmarkScrapingStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scrapingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      scrapingStatusLessThan(
    BookmarkScrapingStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scrapingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      scrapingStatusBetween(
    BookmarkScrapingStatus lower,
    BookmarkScrapingStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scrapingStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      scrapingStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scrapingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      scrapingStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scrapingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      scrapingStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scrapingStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      scrapingStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scrapingStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      scrapingStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scrapingStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      scrapingStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scrapingStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'siteName',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'siteName',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'siteName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'siteName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'siteName',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      siteNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'siteName',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'snippet',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'snippet',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'snippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'snippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'snippet',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'snippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'snippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'snippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'snippet',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snippet',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      snippetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'snippet',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      sourceTypeEqualTo(
    BookmarkSourceType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      sourceTypeGreaterThan(
    BookmarkSourceType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      sourceTypeLessThan(
    BookmarkSourceType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      sourceTypeBetween(
    BookmarkSourceType lower,
    BookmarkSourceType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      sourceTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      sourceTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      sourceTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      sourceTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      sourceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      sourceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      tagIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      tagIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tagIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      tagIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tagIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      tagIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tagIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      tagIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      tagIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      tagIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      tagIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      tagIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      tagIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      titleEqualTo(
    String? value, {
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      titleGreaterThan(
    String? value, {
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      titleLessThan(
    String? value, {
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      titleBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
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

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'urlHash',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'urlHash',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urlHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'urlHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'urlHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'urlHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'urlHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'urlHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'urlHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'urlHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urlHash',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterFilterCondition>
      urlHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'urlHash',
        value: '',
      ));
    });
  }
}

extension BookmarkEntityQueryObject
    on QueryBuilder<BookmarkEntity, BookmarkEntity, QFilterCondition> {}

extension BookmarkEntityQueryLinks
    on QueryBuilder<BookmarkEntity, BookmarkEntity, QFilterCondition> {}

extension BookmarkEntityQuerySortBy
    on QueryBuilder<BookmarkEntity, BookmarkEntity, QSortBy> {
  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByCanonicalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByCanonicalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByDominantColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dominantColorHex', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByDominantColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dominantColorHex', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByDuplicateGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateGroupId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByDuplicateGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateGroupId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByExternalContentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalContentId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByExternalContentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalContentId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByFaviconUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByFaviconUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByHeroImageLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageLocalPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByHeroImageLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageLocalPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByHeroImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByHeroImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByInlineNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inlineNotes', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByInlineNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inlineNotes', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByLastInteractionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractionAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByLastInteractionAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractionAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByLastOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByLastOpenedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByLocalFaviconPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFaviconPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByLocalFaviconPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFaviconPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByNormalizedHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedHost', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByNormalizedHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedHost', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortByOpenCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openCount', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByOpenCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openCount', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByOriginalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByOriginalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByPublishDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishDate', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByPublishDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishDate', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortByPublisher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByPublisherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByReadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByReadProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByReadingTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingTimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByReadingTimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingTimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByScrapingStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrapingStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByScrapingStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrapingStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortBySiteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortBySiteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortBySnippet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snippet', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortBySnippetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snippet', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> sortByUrlHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlHash', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      sortByUrlHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlHash', Sort.desc);
    });
  }
}

extension BookmarkEntityQuerySortThenBy
    on QueryBuilder<BookmarkEntity, BookmarkEntity, QSortThenBy> {
  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByCanonicalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByCanonicalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByDominantColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dominantColorHex', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByDominantColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dominantColorHex', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByDuplicateGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateGroupId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByDuplicateGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateGroupId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByExternalContentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalContentId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByExternalContentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalContentId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByFaviconUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByFaviconUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByHeroImageLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageLocalPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByHeroImageLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageLocalPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByHeroImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByHeroImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByInlineNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inlineNotes', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByInlineNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inlineNotes', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByLastInteractionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractionAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByLastInteractionAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractionAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByLastOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByLastOpenedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByLocalFaviconPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFaviconPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByLocalFaviconPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFaviconPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByNormalizedHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedHost', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByNormalizedHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedHost', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByOpenCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openCount', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByOpenCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openCount', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByOriginalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByOriginalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByPublishDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishDate', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByPublishDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishDate', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByPublisher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByPublisherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByReadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByReadProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByReadingTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingTimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByReadingTimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingTimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByScrapingStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrapingStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByScrapingStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrapingStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenBySiteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenBySiteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenBySnippet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snippet', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenBySnippetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snippet', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy> thenByUrlHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlHash', Sort.asc);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QAfterSortBy>
      thenByUrlHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlHash', Sort.desc);
    });
  }
}

extension BookmarkEntityQueryWhereDistinct
    on QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> {
  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByCanonicalUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canonicalUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByCollectionIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionIds');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByContentType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByDominantColorHex({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dominantColorHex',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByDuplicateGroupId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duplicateGroupId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByExternalContentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'externalContentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByFaviconUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'faviconUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByHeroImageLocalPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heroImageLocalPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByHeroImageUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heroImageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByInlineNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inlineNotes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPinned');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRead');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByLanguageCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'languageCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByLastInteractionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastInteractionAt');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByLastOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastOpenedAt');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByLocalFaviconPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localFaviconPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByNormalizedHost({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'normalizedHost',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByOpenCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openCount');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByOriginalUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByPublishDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publishDate');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByPublisher(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publisher', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByReadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readProgress');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByReadingTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readingTimeMinutes');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByReminderIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderIds');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByScrapingStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scrapingStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctBySiteName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'siteName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctBySnippet(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snippet', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctBySourceType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByTagIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagIds');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkEntity, QDistinct> distinctByUrlHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urlHash', caseSensitive: caseSensitive);
    });
  }
}

extension BookmarkEntityQueryProperty
    on QueryBuilder<BookmarkEntity, BookmarkEntity, QQueryProperty> {
  QueryBuilder<BookmarkEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      canonicalUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canonicalUrl');
    });
  }

  QueryBuilder<BookmarkEntity, List<int>, QQueryOperations>
      collectionIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionIds');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkContentType, QQueryOperations>
      contentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentType');
    });
  }

  QueryBuilder<BookmarkEntity, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      dominantColorHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dominantColorHex');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      duplicateGroupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duplicateGroupId');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      externalContentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'externalContentId');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations> faviconUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'faviconUrl');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      heroImageLocalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heroImageLocalPath');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      heroImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heroImageUrl');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      inlineNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inlineNotes');
    });
  }

  QueryBuilder<BookmarkEntity, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<BookmarkEntity, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<BookmarkEntity, bool, QQueryOperations> isPinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPinned');
    });
  }

  QueryBuilder<BookmarkEntity, bool, QQueryOperations> isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRead');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      languageCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'languageCode');
    });
  }

  QueryBuilder<BookmarkEntity, DateTime?, QQueryOperations>
      lastInteractionAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastInteractionAt');
    });
  }

  QueryBuilder<BookmarkEntity, DateTime?, QQueryOperations>
      lastOpenedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastOpenedAt');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      localFaviconPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localFaviconPath');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations>
      normalizedHostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedHost');
    });
  }

  QueryBuilder<BookmarkEntity, int, QQueryOperations> openCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openCount');
    });
  }

  QueryBuilder<BookmarkEntity, String, QQueryOperations> originalUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalUrl');
    });
  }

  QueryBuilder<BookmarkEntity, DateTime?, QQueryOperations>
      publishDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publishDate');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations> publisherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publisher');
    });
  }

  QueryBuilder<BookmarkEntity, double?, QQueryOperations>
      readProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readProgress');
    });
  }

  QueryBuilder<BookmarkEntity, int?, QQueryOperations>
      readingTimeMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readingTimeMinutes');
    });
  }

  QueryBuilder<BookmarkEntity, List<int>, QQueryOperations>
      reminderIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderIds');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkScrapingStatus, QQueryOperations>
      scrapingStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scrapingStatus');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations> siteNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'siteName');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations> snippetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snippet');
    });
  }

  QueryBuilder<BookmarkEntity, BookmarkSourceType, QQueryOperations>
      sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceType');
    });
  }

  QueryBuilder<BookmarkEntity, List<int>, QQueryOperations> tagIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagIds');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<BookmarkEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<BookmarkEntity, String?, QQueryOperations> urlHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urlHash');
    });
  }
}
