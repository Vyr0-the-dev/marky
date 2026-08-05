// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookmarkItemCollection on Isar {
  IsarCollection<BookmarkItem> get bookmarkItems => this.collection();
}

const BookmarkItemSchema = CollectionSchema(
  name: r'BookmarkItem',
  id: -319914362943490429,
  properties: {
    r'aiCategory': PropertySchema(
      id: 0,
      name: r'aiCategory',
      type: IsarType.string,
    ),
    r'aiClusterId': PropertySchema(
      id: 1,
      name: r'aiClusterId',
      type: IsarType.string,
    ),
    r'aiEmbeddingRef': PropertySchema(
      id: 2,
      name: r'aiEmbeddingRef',
      type: IsarType.string,
    ),
    r'aiKeywords': PropertySchema(
      id: 3,
      name: r'aiKeywords',
      type: IsarType.stringList,
    ),
    r'aiSentiment': PropertySchema(
      id: 4,
      name: r'aiSentiment',
      type: IsarType.string,
    ),
    r'aiSummary': PropertySchema(
      id: 5,
      name: r'aiSummary',
      type: IsarType.string,
    ),
    r'author': PropertySchema(
      id: 6,
      name: r'author',
      type: IsarType.string,
    ),
    r'canonicalUrl': PropertySchema(
      id: 7,
      name: r'canonicalUrl',
      type: IsarType.string,
    ),
    r'cleanedUrl': PropertySchema(
      id: 8,
      name: r'cleanedUrl',
      type: IsarType.string,
    ),
    r'collectionIds': PropertySchema(
      id: 9,
      name: r'collectionIds',
      type: IsarType.longList,
    ),
    r'contentType': PropertySchema(
      id: 10,
      name: r'contentType',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 11,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'customMetadataJson': PropertySchema(
      id: 12,
      name: r'customMetadataJson',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 13,
      name: r'description',
      type: IsarType.string,
    ),
    r'dominantColorHex': PropertySchema(
      id: 14,
      name: r'dominantColorHex',
      type: IsarType.string,
    ),
    r'duplicateGroupId': PropertySchema(
      id: 15,
      name: r'duplicateGroupId',
      type: IsarType.string,
    ),
    r'externalContentId': PropertySchema(
      id: 16,
      name: r'externalContentId',
      type: IsarType.string,
    ),
    r'extractedText': PropertySchema(
      id: 17,
      name: r'extractedText',
      type: IsarType.string,
    ),
    r'extractionStatus': PropertySchema(
      id: 18,
      name: r'extractionStatus',
      type: IsarType.string,
    ),
    r'faviconStatus': PropertySchema(
      id: 19,
      name: r'faviconStatus',
      type: IsarType.byte,
      enumMap: _BookmarkItemfaviconStatusEnumValueMap,
    ),
    r'faviconUrl': PropertySchema(
      id: 20,
      name: r'faviconUrl',
      type: IsarType.string,
    ),
    r'heroImageLocalPath': PropertySchema(
      id: 21,
      name: r'heroImageLocalPath',
      type: IsarType.string,
    ),
    r'heroImageUrl': PropertySchema(
      id: 22,
      name: r'heroImageUrl',
      type: IsarType.string,
    ),
    r'importSource': PropertySchema(
      id: 23,
      name: r'importSource',
      type: IsarType.string,
    ),
    r'isArchived': PropertySchema(
      id: 24,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'isDeleted': PropertySchema(
      id: 25,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isFavorite': PropertySchema(
      id: 26,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'isInVault': PropertySchema(
      id: 27,
      name: r'isInVault',
      type: IsarType.bool,
    ),
    r'isPinned': PropertySchema(
      id: 28,
      name: r'isPinned',
      type: IsarType.bool,
    ),
    r'isRead': PropertySchema(
      id: 29,
      name: r'isRead',
      type: IsarType.bool,
    ),
    r'languageCode': PropertySchema(
      id: 30,
      name: r'languageCode',
      type: IsarType.string,
    ),
    r'lastInteractionAt': PropertySchema(
      id: 31,
      name: r'lastInteractionAt',
      type: IsarType.dateTime,
    ),
    r'lastOpenedAt': PropertySchema(
      id: 32,
      name: r'lastOpenedAt',
      type: IsarType.dateTime,
    ),
    r'lastSharedAt': PropertySchema(
      id: 33,
      name: r'lastSharedAt',
      type: IsarType.dateTime,
    ),
    r'localCacheStatus': PropertySchema(
      id: 34,
      name: r'localCacheStatus',
      type: IsarType.string,
    ),
    r'localFaviconPath': PropertySchema(
      id: 35,
      name: r'localFaviconPath',
      type: IsarType.string,
    ),
    r'localThumbnailPath': PropertySchema(
      id: 36,
      name: r'localThumbnailPath',
      type: IsarType.string,
    ),
    r'normalizedHost': PropertySchema(
      id: 37,
      name: r'normalizedHost',
      type: IsarType.string,
    ),
    r'noteIds': PropertySchema(
      id: 38,
      name: r'noteIds',
      type: IsarType.longList,
    ),
    r'openCount': PropertySchema(
      id: 39,
      name: r'openCount',
      type: IsarType.long,
    ),
    r'originalUrl': PropertySchema(
      id: 40,
      name: r'originalUrl',
      type: IsarType.string,
    ),
    r'publishDate': PropertySchema(
      id: 41,
      name: r'publishDate',
      type: IsarType.dateTime,
    ),
    r'publisher': PropertySchema(
      id: 42,
      name: r'publisher',
      type: IsarType.string,
    ),
    r'readProgress': PropertySchema(
      id: 43,
      name: r'readProgress',
      type: IsarType.double,
    ),
    r'readingTimeMinutes': PropertySchema(
      id: 44,
      name: r'readingTimeMinutes',
      type: IsarType.long,
    ),
    r'reminderIds': PropertySchema(
      id: 45,
      name: r'reminderIds',
      type: IsarType.longList,
    ),
    r'resolvedUrl': PropertySchema(
      id: 46,
      name: r'resolvedUrl',
      type: IsarType.string,
    ),
    r'scrapingStatus': PropertySchema(
      id: 47,
      name: r'scrapingStatus',
      type: IsarType.byte,
      enumMap: _BookmarkItemscrapingStatusEnumValueMap,
    ),
    r'sharedText': PropertySchema(
      id: 48,
      name: r'sharedText',
      type: IsarType.string,
    ),
    r'siteName': PropertySchema(
      id: 49,
      name: r'siteName',
      type: IsarType.string,
    ),
    r'snippet': PropertySchema(
      id: 50,
      name: r'snippet',
      type: IsarType.string,
    ),
    r'sourceApp': PropertySchema(
      id: 51,
      name: r'sourceApp',
      type: IsarType.string,
    ),
    r'sourceDeviceInfo': PropertySchema(
      id: 52,
      name: r'sourceDeviceInfo',
      type: IsarType.string,
    ),
    r'sourceDomain': PropertySchema(
      id: 53,
      name: r'sourceDomain',
      type: IsarType.string,
    ),
    r'sourceType': PropertySchema(
      id: 54,
      name: r'sourceType',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 55,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'tagIds': PropertySchema(
      id: 56,
      name: r'tagIds',
      type: IsarType.longList,
    ),
    r'thumbnailStatus': PropertySchema(
      id: 57,
      name: r'thumbnailStatus',
      type: IsarType.byte,
      enumMap: _BookmarkItemthumbnailStatusEnumValueMap,
    ),
    r'thumbnailUrl': PropertySchema(
      id: 58,
      name: r'thumbnailUrl',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 59,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 60,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'urlHash': PropertySchema(
      id: 61,
      name: r'urlHash',
      type: IsarType.string,
    ),
    r'videoThumbnailUrl': PropertySchema(
      id: 62,
      name: r'videoThumbnailUrl',
      type: IsarType.string,
    )
  },
  estimateSize: _bookmarkItemEstimateSize,
  serialize: _bookmarkItemSerialize,
  deserialize: _bookmarkItemDeserialize,
  deserializeProp: _bookmarkItemDeserializeProp,
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
    r'isArchived_isInVault_createdAt': IndexSchema(
      id: 6721048137366186188,
      name: r'isArchived_isInVault_createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isArchived',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'isInVault',
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
    r'isInVault': IndexSchema(
      id: -6391375227670669354,
      name: r'isInVault',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isInVault',
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
  getId: _bookmarkItemGetId,
  getLinks: _bookmarkItemGetLinks,
  attach: _bookmarkItemAttach,
  version: '3.1.0+1',
);

int _bookmarkItemEstimateSize(
  BookmarkItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiCategory;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.aiClusterId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.aiEmbeddingRef;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.aiKeywords;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.aiSentiment;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.aiSummary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
  {
    final value = object.cleanedUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.collectionIds;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.contentType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.customMetadataJson;
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
    final value = object.extractedText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.extractionStatus;
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
    final value = object.importSource;
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
    final value = object.localCacheStatus;
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
    final value = object.localThumbnailPath;
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
  {
    final value = object.noteIds;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  bytesCount += 3 + object.originalUrl.length * 3;
  {
    final value = object.publisher;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reminderIds;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.resolvedUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sharedText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
  {
    final value = object.sourceApp;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceDeviceInfo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceDomain;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.syncStatus;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tagIds;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.thumbnailUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
  {
    final value = object.videoThumbnailUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _bookmarkItemSerialize(
  BookmarkItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiCategory);
  writer.writeString(offsets[1], object.aiClusterId);
  writer.writeString(offsets[2], object.aiEmbeddingRef);
  writer.writeStringList(offsets[3], object.aiKeywords);
  writer.writeString(offsets[4], object.aiSentiment);
  writer.writeString(offsets[5], object.aiSummary);
  writer.writeString(offsets[6], object.author);
  writer.writeString(offsets[7], object.canonicalUrl);
  writer.writeString(offsets[8], object.cleanedUrl);
  writer.writeLongList(offsets[9], object.collectionIds);
  writer.writeString(offsets[10], object.contentType);
  writer.writeDateTime(offsets[11], object.createdAt);
  writer.writeString(offsets[12], object.customMetadataJson);
  writer.writeString(offsets[13], object.description);
  writer.writeString(offsets[14], object.dominantColorHex);
  writer.writeString(offsets[15], object.duplicateGroupId);
  writer.writeString(offsets[16], object.externalContentId);
  writer.writeString(offsets[17], object.extractedText);
  writer.writeString(offsets[18], object.extractionStatus);
  writer.writeByte(offsets[19], object.faviconStatus.index);
  writer.writeString(offsets[20], object.faviconUrl);
  writer.writeString(offsets[21], object.heroImageLocalPath);
  writer.writeString(offsets[22], object.heroImageUrl);
  writer.writeString(offsets[23], object.importSource);
  writer.writeBool(offsets[24], object.isArchived);
  writer.writeBool(offsets[25], object.isDeleted);
  writer.writeBool(offsets[26], object.isFavorite);
  writer.writeBool(offsets[27], object.isInVault);
  writer.writeBool(offsets[28], object.isPinned);
  writer.writeBool(offsets[29], object.isRead);
  writer.writeString(offsets[30], object.languageCode);
  writer.writeDateTime(offsets[31], object.lastInteractionAt);
  writer.writeDateTime(offsets[32], object.lastOpenedAt);
  writer.writeDateTime(offsets[33], object.lastSharedAt);
  writer.writeString(offsets[34], object.localCacheStatus);
  writer.writeString(offsets[35], object.localFaviconPath);
  writer.writeString(offsets[36], object.localThumbnailPath);
  writer.writeString(offsets[37], object.normalizedHost);
  writer.writeLongList(offsets[38], object.noteIds);
  writer.writeLong(offsets[39], object.openCount);
  writer.writeString(offsets[40], object.originalUrl);
  writer.writeDateTime(offsets[41], object.publishDate);
  writer.writeString(offsets[42], object.publisher);
  writer.writeDouble(offsets[43], object.readProgress);
  writer.writeLong(offsets[44], object.readingTimeMinutes);
  writer.writeLongList(offsets[45], object.reminderIds);
  writer.writeString(offsets[46], object.resolvedUrl);
  writer.writeByte(offsets[47], object.scrapingStatus.index);
  writer.writeString(offsets[48], object.sharedText);
  writer.writeString(offsets[49], object.siteName);
  writer.writeString(offsets[50], object.snippet);
  writer.writeString(offsets[51], object.sourceApp);
  writer.writeString(offsets[52], object.sourceDeviceInfo);
  writer.writeString(offsets[53], object.sourceDomain);
  writer.writeString(offsets[54], object.sourceType);
  writer.writeString(offsets[55], object.syncStatus);
  writer.writeLongList(offsets[56], object.tagIds);
  writer.writeByte(offsets[57], object.thumbnailStatus.index);
  writer.writeString(offsets[58], object.thumbnailUrl);
  writer.writeString(offsets[59], object.title);
  writer.writeDateTime(offsets[60], object.updatedAt);
  writer.writeString(offsets[61], object.urlHash);
  writer.writeString(offsets[62], object.videoThumbnailUrl);
}

BookmarkItem _bookmarkItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BookmarkItem(
    aiCategory: reader.readStringOrNull(offsets[0]),
    aiClusterId: reader.readStringOrNull(offsets[1]),
    aiEmbeddingRef: reader.readStringOrNull(offsets[2]),
    aiKeywords: reader.readStringList(offsets[3]),
    aiSentiment: reader.readStringOrNull(offsets[4]),
    aiSummary: reader.readStringOrNull(offsets[5]),
    author: reader.readStringOrNull(offsets[6]),
    canonicalUrl: reader.readStringOrNull(offsets[7]),
    cleanedUrl: reader.readStringOrNull(offsets[8]),
    collectionIds: reader.readLongList(offsets[9]),
    contentType: reader.readStringOrNull(offsets[10]),
    createdAt: reader.readDateTime(offsets[11]),
    customMetadataJson: reader.readStringOrNull(offsets[12]),
    description: reader.readStringOrNull(offsets[13]),
    duplicateGroupId: reader.readStringOrNull(offsets[15]),
    externalContentId: reader.readStringOrNull(offsets[16]),
    extractedText: reader.readStringOrNull(offsets[17]),
    extractionStatus: reader.readStringOrNull(offsets[18]),
    faviconStatus: _BookmarkItemfaviconStatusValueEnumMap[
            reader.readByteOrNull(offsets[19])] ??
        FaviconStatus.pending,
    faviconUrl: reader.readStringOrNull(offsets[20]),
    heroImageLocalPath: reader.readStringOrNull(offsets[21]),
    heroImageUrl: reader.readStringOrNull(offsets[22]),
    importSource: reader.readStringOrNull(offsets[23]),
    isArchived: reader.readBoolOrNull(offsets[24]) ?? false,
    isDeleted: reader.readBoolOrNull(offsets[25]) ?? false,
    isFavorite: reader.readBoolOrNull(offsets[26]) ?? false,
    isInVault: reader.readBoolOrNull(offsets[27]) ?? false,
    isPinned: reader.readBoolOrNull(offsets[28]) ?? false,
    isRead: reader.readBoolOrNull(offsets[29]) ?? false,
    languageCode: reader.readStringOrNull(offsets[30]),
    lastInteractionAt: reader.readDateTimeOrNull(offsets[31]),
    lastOpenedAt: reader.readDateTimeOrNull(offsets[32]),
    lastSharedAt: reader.readDateTimeOrNull(offsets[33]),
    localCacheStatus: reader.readStringOrNull(offsets[34]),
    localFaviconPath: reader.readStringOrNull(offsets[35]),
    localThumbnailPath: reader.readStringOrNull(offsets[36]),
    normalizedHost: reader.readStringOrNull(offsets[37]),
    noteIds: reader.readLongList(offsets[38]),
    openCount: reader.readLongOrNull(offsets[39]) ?? 0,
    originalUrl: reader.readString(offsets[40]),
    publishDate: reader.readDateTimeOrNull(offsets[41]),
    publisher: reader.readStringOrNull(offsets[42]),
    readProgress: reader.readDoubleOrNull(offsets[43]),
    readingTimeMinutes: reader.readLongOrNull(offsets[44]),
    reminderIds: reader.readLongList(offsets[45]),
    resolvedUrl: reader.readStringOrNull(offsets[46]),
    scrapingStatus: _BookmarkItemscrapingStatusValueEnumMap[
            reader.readByteOrNull(offsets[47])] ??
        ScrapingStatus.pending,
    sharedText: reader.readStringOrNull(offsets[48]),
    siteName: reader.readStringOrNull(offsets[49]),
    snippet: reader.readStringOrNull(offsets[50]),
    sourceApp: reader.readStringOrNull(offsets[51]),
    sourceDeviceInfo: reader.readStringOrNull(offsets[52]),
    sourceDomain: reader.readStringOrNull(offsets[53]),
    sourceType: reader.readStringOrNull(offsets[54]),
    syncStatus: reader.readStringOrNull(offsets[55]),
    tagIds: reader.readLongList(offsets[56]),
    thumbnailStatus: _BookmarkItemthumbnailStatusValueEnumMap[
            reader.readByteOrNull(offsets[57])] ??
        ThumbnailStatus.pending,
    thumbnailUrl: reader.readStringOrNull(offsets[58]),
    title: reader.readStringOrNull(offsets[59]),
    updatedAt: reader.readDateTime(offsets[60]),
    urlHash: reader.readStringOrNull(offsets[61]),
    videoThumbnailUrl: reader.readStringOrNull(offsets[62]),
  );
  object.dominantColorHex = reader.readStringOrNull(offsets[14]);
  object.id = id;
  return object;
}

P _bookmarkItemDeserializeProp<P>(
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
      return (reader.readStringList(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLongList(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (_BookmarkItemfaviconStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          FaviconStatus.pending) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 25:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 26:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 27:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 28:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 29:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 32:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 33:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 34:
      return (reader.readStringOrNull(offset)) as P;
    case 35:
      return (reader.readStringOrNull(offset)) as P;
    case 36:
      return (reader.readStringOrNull(offset)) as P;
    case 37:
      return (reader.readStringOrNull(offset)) as P;
    case 38:
      return (reader.readLongList(offset)) as P;
    case 39:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 40:
      return (reader.readString(offset)) as P;
    case 41:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 42:
      return (reader.readStringOrNull(offset)) as P;
    case 43:
      return (reader.readDoubleOrNull(offset)) as P;
    case 44:
      return (reader.readLongOrNull(offset)) as P;
    case 45:
      return (reader.readLongList(offset)) as P;
    case 46:
      return (reader.readStringOrNull(offset)) as P;
    case 47:
      return (_BookmarkItemscrapingStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ScrapingStatus.pending) as P;
    case 48:
      return (reader.readStringOrNull(offset)) as P;
    case 49:
      return (reader.readStringOrNull(offset)) as P;
    case 50:
      return (reader.readStringOrNull(offset)) as P;
    case 51:
      return (reader.readStringOrNull(offset)) as P;
    case 52:
      return (reader.readStringOrNull(offset)) as P;
    case 53:
      return (reader.readStringOrNull(offset)) as P;
    case 54:
      return (reader.readStringOrNull(offset)) as P;
    case 55:
      return (reader.readStringOrNull(offset)) as P;
    case 56:
      return (reader.readLongList(offset)) as P;
    case 57:
      return (_BookmarkItemthumbnailStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ThumbnailStatus.pending) as P;
    case 58:
      return (reader.readStringOrNull(offset)) as P;
    case 59:
      return (reader.readStringOrNull(offset)) as P;
    case 60:
      return (reader.readDateTime(offset)) as P;
    case 61:
      return (reader.readStringOrNull(offset)) as P;
    case 62:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BookmarkItemfaviconStatusEnumValueMap = {
  'pending': 0,
  'processing': 1,
  'done': 2,
  'failed': 3,
};
const _BookmarkItemfaviconStatusValueEnumMap = {
  0: FaviconStatus.pending,
  1: FaviconStatus.processing,
  2: FaviconStatus.done,
  3: FaviconStatus.failed,
};
const _BookmarkItemscrapingStatusEnumValueMap = {
  'pending': 0,
  'processing': 1,
  'done': 2,
  'failed': 3,
};
const _BookmarkItemscrapingStatusValueEnumMap = {
  0: ScrapingStatus.pending,
  1: ScrapingStatus.processing,
  2: ScrapingStatus.done,
  3: ScrapingStatus.failed,
};
const _BookmarkItemthumbnailStatusEnumValueMap = {
  'pending': 0,
  'processing': 1,
  'done': 2,
  'failed': 3,
};
const _BookmarkItemthumbnailStatusValueEnumMap = {
  0: ThumbnailStatus.pending,
  1: ThumbnailStatus.processing,
  2: ThumbnailStatus.done,
  3: ThumbnailStatus.failed,
};

Id _bookmarkItemGetId(BookmarkItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookmarkItemGetLinks(BookmarkItem object) {
  return [];
}

void _bookmarkItemAttach(
    IsarCollection<dynamic> col, Id id, BookmarkItem object) {
  object.id = id;
}

extension BookmarkItemQueryWhereSort
    on QueryBuilder<BookmarkItem, BookmarkItem, QWhere> {
  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhere> anyIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isFavorite'),
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhere>
      anyIsArchivedIsInVaultCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(
            indexName: r'isArchived_isInVault_createdAt'),
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhere> anyIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isRead'),
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhere> anyIsInVault() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isInVault'),
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension BookmarkItemQueryWhere
    on QueryBuilder<BookmarkItem, BookmarkItem, QWhereClause> {
  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      canonicalUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'canonicalUrl',
        value: [null],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      canonicalUrlEqualTo(String? canonicalUrl) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'canonicalUrl',
        value: [canonicalUrl],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      normalizedHostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'normalizedHost',
        value: [null],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      normalizedHostEqualTo(String? normalizedHost) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'normalizedHost',
        value: [normalizedHost],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> urlHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'urlHash',
        value: [null],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> urlHashEqualTo(
      String? urlHash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'urlHash',
        value: [urlHash],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> urlHashNotEqualTo(
      String? urlHash) {
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> isFavoriteEqualTo(
      bool isFavorite) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isFavorite',
        value: [isFavorite],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      isArchivedEqualToAnyIsInVaultCreatedAt(bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isArchived_isInVault_createdAt',
        value: [isArchived],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      isArchivedNotEqualToAnyIsInVaultCreatedAt(bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      isArchivedIsInVaultEqualToAnyCreatedAt(bool isArchived, bool isInVault) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isArchived_isInVault_createdAt',
        value: [isArchived, isInVault],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      isArchivedEqualToIsInVaultNotEqualToAnyCreatedAt(
          bool isArchived, bool isInVault) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [isArchived],
              upper: [isArchived, isInVault],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [isArchived, isInVault],
              includeLower: false,
              upper: [isArchived],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [isArchived, isInVault],
              includeLower: false,
              upper: [isArchived],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [isArchived],
              upper: [isArchived, isInVault],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      isArchivedIsInVaultCreatedAtEqualTo(
          bool isArchived, bool isInVault, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isArchived_isInVault_createdAt',
        value: [isArchived, isInVault, createdAt],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      isArchivedIsInVaultEqualToCreatedAtNotEqualTo(
          bool isArchived, bool isInVault, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [isArchived, isInVault],
              upper: [isArchived, isInVault, createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [isArchived, isInVault, createdAt],
              includeLower: false,
              upper: [isArchived, isInVault],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [isArchived, isInVault, createdAt],
              includeLower: false,
              upper: [isArchived, isInVault],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived_isInVault_createdAt',
              lower: [isArchived, isInVault],
              upper: [isArchived, isInVault, createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      isArchivedIsInVaultEqualToCreatedAtGreaterThan(
    bool isArchived,
    bool isInVault,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'isArchived_isInVault_createdAt',
        lower: [isArchived, isInVault, createdAt],
        includeLower: include,
        upper: [isArchived, isInVault],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      isArchivedIsInVaultEqualToCreatedAtLessThan(
    bool isArchived,
    bool isInVault,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'isArchived_isInVault_createdAt',
        lower: [isArchived, isInVault],
        upper: [isArchived, isInVault, createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      isArchivedIsInVaultEqualToCreatedAtBetween(
    bool isArchived,
    bool isInVault,
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'isArchived_isInVault_createdAt',
        lower: [isArchived, isInVault, lowerCreatedAt],
        includeLower: includeLower,
        upper: [isArchived, isInVault, upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> isReadEqualTo(
      bool isRead) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isRead',
        value: [isRead],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> isReadNotEqualTo(
      bool isRead) {
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> isInVaultEqualTo(
      bool isInVault) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isInVault',
        value: [isInVault],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
      isInVaultNotEqualTo(bool isInVault) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isInVault',
              lower: [],
              upper: [isInVault],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isInVault',
              lower: [isInVault],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isInVault',
              lower: [isInVault],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isInVault',
              lower: [],
              upper: [isInVault],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> createdAtEqualTo(
      DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> createdAtLessThan(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterWhereClause> createdAtBetween(
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

extension BookmarkItemQueryFilter
    on QueryBuilder<BookmarkItem, BookmarkItem, QFilterCondition> {
  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiCategory',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiCategory',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiCategory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiCategory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiCategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiClusterId',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiClusterId',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiClusterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiClusterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiClusterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiClusterId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiClusterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiClusterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiClusterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiClusterId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiClusterId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiClusterIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiClusterId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiEmbeddingRef',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiEmbeddingRef',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiEmbeddingRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiEmbeddingRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiEmbeddingRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiEmbeddingRef',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiEmbeddingRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiEmbeddingRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiEmbeddingRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiEmbeddingRef',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiEmbeddingRef',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiEmbeddingRefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiEmbeddingRef',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiKeywords',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiKeywords',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiKeywords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiKeywords',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiKeywords',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiKeywords',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiKeywords',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiKeywords',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiKeywords',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiKeywords',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiKeywords',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiKeywordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiKeywords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiSentiment',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiSentiment',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiSentiment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiSentiment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiSentiment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiSentiment',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiSentiment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiSentiment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiSentiment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiSentiment',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiSentiment',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSentimentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiSentiment',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiSummary',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiSummary',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiSummary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiSummary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      aiSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> authorEqualTo(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> authorBetween(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      authorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> authorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      canonicalUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'canonicalUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      canonicalUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'canonicalUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      canonicalUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'canonicalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      canonicalUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'canonicalUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      canonicalUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canonicalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      canonicalUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'canonicalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cleanedUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cleanedUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cleanedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cleanedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cleanedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cleanedUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cleanedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cleanedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cleanedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cleanedUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cleanedUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      cleanedUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cleanedUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      collectionIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'collectionIds',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      collectionIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'collectionIds',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      collectionIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      contentTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contentType',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      contentTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contentType',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      contentTypeEqualTo(
    String? value, {
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      contentTypeGreaterThan(
    String? value, {
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      contentTypeLessThan(
    String? value, {
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      contentTypeBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      contentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      contentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      contentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      contentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customMetadataJson',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customMetadataJson',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customMetadataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customMetadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      customMetadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      dominantColorHexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dominantColorHex',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      dominantColorHexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dominantColorHex',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      dominantColorHexContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dominantColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      dominantColorHexMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dominantColorHex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      dominantColorHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dominantColorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      dominantColorHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dominantColorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      duplicateGroupIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duplicateGroupId',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      duplicateGroupIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duplicateGroupId',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      duplicateGroupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'duplicateGroupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      duplicateGroupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'duplicateGroupId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      duplicateGroupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duplicateGroupId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      duplicateGroupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'duplicateGroupId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      externalContentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'externalContentId',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      externalContentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'externalContentId',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      externalContentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'externalContentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      externalContentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'externalContentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      externalContentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalContentId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      externalContentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'externalContentId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'extractedText',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'extractedText',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extractedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'extractedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'extractedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'extractedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'extractedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'extractedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'extractedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'extractedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extractedText',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'extractedText',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'extractionStatus',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'extractionStatus',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extractionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'extractionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'extractionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'extractionStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'extractionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'extractionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'extractionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'extractionStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extractionStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      extractionStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'extractionStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      faviconStatusEqualTo(FaviconStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'faviconStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      faviconStatusGreaterThan(
    FaviconStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'faviconStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      faviconStatusLessThan(
    FaviconStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'faviconStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      faviconStatusBetween(
    FaviconStatus lower,
    FaviconStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'faviconStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      faviconUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'faviconUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      faviconUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'faviconUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      faviconUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'faviconUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      faviconUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'faviconUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      faviconUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'faviconUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      faviconUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'faviconUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageLocalPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'heroImageLocalPath',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageLocalPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'heroImageLocalPath',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageLocalPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'heroImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageLocalPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'heroImageLocalPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageLocalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heroImageLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageLocalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'heroImageLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'heroImageUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'heroImageUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'heroImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'heroImageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heroImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      heroImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'heroImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'importSource',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'importSource',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'importSource',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'importSource',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'importSource',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      importSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'importSource',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      isArchivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isArchived',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      isFavoriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavorite',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      isInVaultEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isInVault',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      isPinnedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPinned',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> isReadEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRead',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      languageCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'languageCode',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      languageCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'languageCode',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      languageCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      languageCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'languageCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      languageCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      languageCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastInteractionAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastInteractionAt',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastInteractionAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastInteractionAt',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastInteractionAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastInteractionAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastOpenedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastOpenedAt',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastOpenedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastOpenedAt',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastOpenedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastOpenedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastSharedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSharedAt',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastSharedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSharedAt',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastSharedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSharedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastSharedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSharedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastSharedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSharedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      lastSharedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSharedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localCacheStatus',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localCacheStatus',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localCacheStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localCacheStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localCacheStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localCacheStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localCacheStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localCacheStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localCacheStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localCacheStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localCacheStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localCacheStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localCacheStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localFaviconPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localFaviconPath',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localFaviconPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localFaviconPath',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localFaviconPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localFaviconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localFaviconPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localFaviconPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localFaviconPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localFaviconPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localFaviconPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localFaviconPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localThumbnailPath',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localThumbnailPath',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localThumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localThumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localThumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localThumbnailPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localThumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localThumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localThumbnailPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localThumbnailPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localThumbnailPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      localThumbnailPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localThumbnailPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      normalizedHostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'normalizedHost',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      normalizedHostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'normalizedHost',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      normalizedHostContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'normalizedHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      normalizedHostMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'normalizedHost',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      normalizedHostIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedHost',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      normalizedHostIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'normalizedHost',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'noteIds',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'noteIds',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'noteIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'noteIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'noteIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'noteIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'noteIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'noteIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'noteIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'noteIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'noteIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      noteIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'noteIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      openCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'openCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      originalUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      originalUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      originalUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      originalUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      publishDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publishDate',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      publishDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publishDate',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      publishDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publishDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      publisherIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publisher',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      publisherIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publisher',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      publisherContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      publisherMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'publisher',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      publisherIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publisher',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      publisherIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'publisher',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      readProgressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'readProgress',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      readProgressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'readProgress',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      readingTimeMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'readingTimeMinutes',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      readingTimeMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'readingTimeMinutes',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      readingTimeMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readingTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      reminderIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reminderIds',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      reminderIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reminderIds',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      reminderIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'resolvedUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'resolvedUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resolvedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resolvedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resolvedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resolvedUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'resolvedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'resolvedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'resolvedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'resolvedUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resolvedUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      resolvedUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'resolvedUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      scrapingStatusEqualTo(ScrapingStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scrapingStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      scrapingStatusGreaterThan(
    ScrapingStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scrapingStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      scrapingStatusLessThan(
    ScrapingStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scrapingStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      scrapingStatusBetween(
    ScrapingStatus lower,
    ScrapingStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scrapingStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedText',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedText',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sharedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sharedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sharedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sharedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sharedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sharedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sharedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedText',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sharedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sharedText',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      siteNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'siteName',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      siteNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'siteName',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      siteNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'siteName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      siteNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'siteName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      siteNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'siteName',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      siteNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'siteName',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      snippetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'snippet',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      snippetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'snippet',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      snippetContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'snippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      snippetMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'snippet',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      snippetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snippet',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      snippetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'snippet',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceApp',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceApp',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceApp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceApp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceApp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceApp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceApp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceApp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceApp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceApp',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceApp',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceAppIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceApp',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceDeviceInfo',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceDeviceInfo',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceDeviceInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceDeviceInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceDeviceInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceDeviceInfo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceDeviceInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceDeviceInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceDeviceInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceDeviceInfo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceDeviceInfo',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDeviceInfoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceDeviceInfo',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceDomain',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceDomain',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceDomain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceDomain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceDomain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceDomain',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceDomain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceDomain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceDomain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceDomain',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceDomain',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceDomainIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceDomain',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceType',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceType',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceTypeEqualTo(
    String? value, {
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceTypeGreaterThan(
    String? value, {
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceTypeLessThan(
    String? value, {
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceTypeBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      sourceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncStatus',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncStatus',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      tagIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tagIds',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      tagIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tagIds',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      tagIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagIds',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailStatusEqualTo(ThumbnailStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailStatusGreaterThan(
    ThumbnailStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnailStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailStatusLessThan(
    ThumbnailStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnailStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailStatusBetween(
    ThumbnailStatus lower,
    ThumbnailStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnailStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'thumbnailUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'thumbnailUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnailUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'thumbnailUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      thumbnailUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'thumbnailUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      urlHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'urlHash',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      urlHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'urlHash',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
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

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      urlHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'urlHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      urlHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'urlHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      urlHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urlHash',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      urlHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'urlHash',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'videoThumbnailUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'videoThumbnailUrl',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoThumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoThumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoThumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoThumbnailUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'videoThumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'videoThumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'videoThumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'videoThumbnailUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoThumbnailUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterFilterCondition>
      videoThumbnailUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'videoThumbnailUrl',
        value: '',
      ));
    });
  }
}

extension BookmarkItemQueryObject
    on QueryBuilder<BookmarkItem, BookmarkItem, QFilterCondition> {}

extension BookmarkItemQueryLinks
    on QueryBuilder<BookmarkItem, BookmarkItem, QFilterCondition> {}

extension BookmarkItemQuerySortBy
    on QueryBuilder<BookmarkItem, BookmarkItem, QSortBy> {
  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByAiCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCategory', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByAiCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCategory', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByAiClusterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiClusterId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByAiClusterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiClusterId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByAiEmbeddingRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEmbeddingRef', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByAiEmbeddingRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEmbeddingRef', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByAiSentiment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSentiment', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByAiSentimentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSentiment', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByAiSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByAiSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByCanonicalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByCanonicalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByCleanedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanedUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByCleanedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanedUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByCustomMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByCustomMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByDominantColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dominantColorHex', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByDominantColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dominantColorHex', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByDuplicateGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateGroupId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByDuplicateGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateGroupId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByExternalContentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalContentId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByExternalContentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalContentId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByExtractedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedText', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByExtractedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedText', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByExtractionStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractionStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByExtractionStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractionStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByFaviconStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByFaviconStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByFaviconUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByFaviconUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByHeroImageLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageLocalPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByHeroImageLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageLocalPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByHeroImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByHeroImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByImportSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importSource', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByImportSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importSource', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByIsInVault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInVault', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByIsInVaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInVault', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLastInteractionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractionAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLastInteractionAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractionAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByLastOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLastOpenedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByLastSharedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSharedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLastSharedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSharedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLocalCacheStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localCacheStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLocalCacheStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localCacheStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLocalFaviconPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFaviconPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLocalFaviconPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFaviconPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLocalThumbnailPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localThumbnailPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByLocalThumbnailPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localThumbnailPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByNormalizedHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedHost', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByNormalizedHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedHost', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByOpenCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openCount', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByOpenCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openCount', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByOriginalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByOriginalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByPublishDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishDate', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByPublishDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishDate', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByPublisher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByPublisherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByReadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByReadProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByReadingTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingTimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByReadingTimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingTimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByResolvedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolvedUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByResolvedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolvedUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByScrapingStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrapingStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByScrapingStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrapingStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortBySharedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedText', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortBySharedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedText', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortBySiteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortBySiteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortBySnippet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snippet', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortBySnippetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snippet', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortBySourceApp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceApp', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortBySourceAppDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceApp', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortBySourceDeviceInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDeviceInfo', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortBySourceDeviceInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDeviceInfo', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortBySourceDomain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDomain', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortBySourceDomainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDomain', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByThumbnailStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByThumbnailStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByUrlHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlHash', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> sortByUrlHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlHash', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByVideoThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoThumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      sortByVideoThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoThumbnailUrl', Sort.desc);
    });
  }
}

extension BookmarkItemQuerySortThenBy
    on QueryBuilder<BookmarkItem, BookmarkItem, QSortThenBy> {
  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByAiCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCategory', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByAiCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCategory', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByAiClusterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiClusterId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByAiClusterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiClusterId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByAiEmbeddingRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEmbeddingRef', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByAiEmbeddingRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEmbeddingRef', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByAiSentiment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSentiment', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByAiSentimentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSentiment', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByAiSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByAiSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByCanonicalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByCanonicalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByCleanedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanedUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByCleanedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanedUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByCustomMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByCustomMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByDominantColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dominantColorHex', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByDominantColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dominantColorHex', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByDuplicateGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateGroupId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByDuplicateGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateGroupId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByExternalContentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalContentId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByExternalContentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalContentId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByExtractedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedText', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByExtractedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedText', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByExtractionStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractionStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByExtractionStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractionStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByFaviconStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByFaviconStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByFaviconUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByFaviconUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'faviconUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByHeroImageLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageLocalPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByHeroImageLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageLocalPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByHeroImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByHeroImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heroImageUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByImportSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importSource', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByImportSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importSource', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIsInVault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInVault', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIsInVaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInVault', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLastInteractionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractionAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLastInteractionAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractionAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByLastOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLastOpenedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByLastSharedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSharedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLastSharedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSharedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLocalCacheStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localCacheStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLocalCacheStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localCacheStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLocalFaviconPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFaviconPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLocalFaviconPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFaviconPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLocalThumbnailPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localThumbnailPath', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByLocalThumbnailPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localThumbnailPath', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByNormalizedHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedHost', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByNormalizedHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedHost', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByOpenCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openCount', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByOpenCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openCount', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByOriginalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByOriginalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByPublishDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishDate', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByPublishDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishDate', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByPublisher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByPublisherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByReadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByReadProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByReadingTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingTimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByReadingTimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingTimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByResolvedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolvedUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByResolvedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolvedUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByScrapingStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrapingStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByScrapingStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrapingStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenBySharedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedText', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenBySharedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedText', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenBySiteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenBySiteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siteName', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenBySnippet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snippet', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenBySnippetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snippet', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenBySourceApp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceApp', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenBySourceAppDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceApp', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenBySourceDeviceInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDeviceInfo', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenBySourceDeviceInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDeviceInfo', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenBySourceDomain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDomain', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenBySourceDomainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDomain', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByThumbnailStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailStatus', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByThumbnailStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailStatus', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByUrlHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlHash', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy> thenByUrlHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urlHash', Sort.desc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByVideoThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoThumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QAfterSortBy>
      thenByVideoThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoThumbnailUrl', Sort.desc);
    });
  }
}

extension BookmarkItemQueryWhereDistinct
    on QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> {
  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByAiCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiCategory', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByAiClusterId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiClusterId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByAiEmbeddingRef(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiEmbeddingRef',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByAiKeywords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiKeywords');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByAiSentiment(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiSentiment', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByAiSummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiSummary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByCanonicalUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canonicalUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByCleanedUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cleanedUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByCollectionIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionIds');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByContentType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByCustomMetadataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customMetadataJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByDominantColorHex({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dominantColorHex',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByDuplicateGroupId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duplicateGroupId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByExternalContentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'externalContentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByExtractedText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extractedText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByExtractionStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extractionStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByFaviconStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'faviconStatus');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByFaviconUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'faviconUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByHeroImageLocalPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heroImageLocalPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByHeroImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heroImageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByImportSource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importSource', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByIsInVault() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isInVault');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPinned');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRead');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByLanguageCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'languageCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByLastInteractionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastInteractionAt');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByLastOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastOpenedAt');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByLastSharedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSharedAt');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByLocalCacheStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localCacheStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByLocalFaviconPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localFaviconPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByLocalThumbnailPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localThumbnailPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByNormalizedHost(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'normalizedHost',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByNoteIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'noteIds');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByOpenCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openCount');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByOriginalUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByPublishDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publishDate');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByPublisher(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publisher', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByReadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readProgress');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByReadingTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readingTimeMinutes');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByReminderIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderIds');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByResolvedUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resolvedUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByScrapingStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scrapingStatus');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctBySharedText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctBySiteName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'siteName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctBySnippet(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snippet', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctBySourceApp(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceApp', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctBySourceDeviceInfo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceDeviceInfo',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctBySourceDomain(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceDomain', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctBySourceType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctBySyncStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByTagIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagIds');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByThumbnailStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailStatus');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByThumbnailUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct> distinctByUrlHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urlHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkItem, BookmarkItem, QDistinct>
      distinctByVideoThumbnailUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoThumbnailUrl',
          caseSensitive: caseSensitive);
    });
  }
}

extension BookmarkItemQueryProperty
    on QueryBuilder<BookmarkItem, BookmarkItem, QQueryProperty> {
  QueryBuilder<BookmarkItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> aiCategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiCategory');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> aiClusterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiClusterId');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      aiEmbeddingRefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiEmbeddingRef');
    });
  }

  QueryBuilder<BookmarkItem, List<String>?, QQueryOperations>
      aiKeywordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiKeywords');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> aiSentimentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiSentiment');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> aiSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiSummary');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> canonicalUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canonicalUrl');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> cleanedUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cleanedUrl');
    });
  }

  QueryBuilder<BookmarkItem, List<int>?, QQueryOperations>
      collectionIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionIds');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> contentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentType');
    });
  }

  QueryBuilder<BookmarkItem, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      customMetadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customMetadataJson');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      dominantColorHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dominantColorHex');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      duplicateGroupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duplicateGroupId');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      externalContentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'externalContentId');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      extractedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extractedText');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      extractionStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extractionStatus');
    });
  }

  QueryBuilder<BookmarkItem, FaviconStatus, QQueryOperations>
      faviconStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'faviconStatus');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> faviconUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'faviconUrl');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      heroImageLocalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heroImageLocalPath');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> heroImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heroImageUrl');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> importSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importSource');
    });
  }

  QueryBuilder<BookmarkItem, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<BookmarkItem, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<BookmarkItem, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<BookmarkItem, bool, QQueryOperations> isInVaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isInVault');
    });
  }

  QueryBuilder<BookmarkItem, bool, QQueryOperations> isPinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPinned');
    });
  }

  QueryBuilder<BookmarkItem, bool, QQueryOperations> isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRead');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> languageCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'languageCode');
    });
  }

  QueryBuilder<BookmarkItem, DateTime?, QQueryOperations>
      lastInteractionAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastInteractionAt');
    });
  }

  QueryBuilder<BookmarkItem, DateTime?, QQueryOperations>
      lastOpenedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastOpenedAt');
    });
  }

  QueryBuilder<BookmarkItem, DateTime?, QQueryOperations>
      lastSharedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSharedAt');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      localCacheStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localCacheStatus');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      localFaviconPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localFaviconPath');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      localThumbnailPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localThumbnailPath');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      normalizedHostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedHost');
    });
  }

  QueryBuilder<BookmarkItem, List<int>?, QQueryOperations> noteIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'noteIds');
    });
  }

  QueryBuilder<BookmarkItem, int, QQueryOperations> openCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openCount');
    });
  }

  QueryBuilder<BookmarkItem, String, QQueryOperations> originalUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalUrl');
    });
  }

  QueryBuilder<BookmarkItem, DateTime?, QQueryOperations>
      publishDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publishDate');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> publisherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publisher');
    });
  }

  QueryBuilder<BookmarkItem, double?, QQueryOperations> readProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readProgress');
    });
  }

  QueryBuilder<BookmarkItem, int?, QQueryOperations>
      readingTimeMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readingTimeMinutes');
    });
  }

  QueryBuilder<BookmarkItem, List<int>?, QQueryOperations>
      reminderIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderIds');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> resolvedUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resolvedUrl');
    });
  }

  QueryBuilder<BookmarkItem, ScrapingStatus, QQueryOperations>
      scrapingStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scrapingStatus');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> sharedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedText');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> siteNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'siteName');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> snippetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snippet');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> sourceAppProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceApp');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      sourceDeviceInfoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceDeviceInfo');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> sourceDomainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceDomain');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceType');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<BookmarkItem, List<int>?, QQueryOperations> tagIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagIds');
    });
  }

  QueryBuilder<BookmarkItem, ThumbnailStatus, QQueryOperations>
      thumbnailStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailStatus');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> thumbnailUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailUrl');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<BookmarkItem, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations> urlHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urlHash');
    });
  }

  QueryBuilder<BookmarkItem, String?, QQueryOperations>
      videoThumbnailUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoThumbnailUrl');
    });
  }
}
