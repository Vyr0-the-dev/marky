// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_meta_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBackupMetaEntityCollection on Isar {
  IsarCollection<BackupMetaEntity> get backupMeta => this.collection();
}

const BackupMetaEntitySchema = CollectionSchema(
  name: r'BackupMetaEntity',
  id: 2991706327158712657,
  properties: {
    r'autoBackupEnabled': PropertySchema(
      id: 0,
      name: r'autoBackupEnabled',
      type: IsarType.bool,
    ),
    r'backupIntervalHours': PropertySchema(
      id: 1,
      name: r'backupIntervalHours',
      type: IsarType.long,
    ),
    r'consecutiveFailureCount': PropertySchema(
      id: 2,
      name: r'consecutiveFailureCount',
      type: IsarType.long,
    ),
    r'googleDriveAccountEmail': PropertySchema(
      id: 3,
      name: r'googleDriveAccountEmail',
      type: IsarType.string,
    ),
    r'googleDriveFolderId': PropertySchema(
      id: 4,
      name: r'googleDriveFolderId',
      type: IsarType.string,
    ),
    r'lastBackupAt': PropertySchema(
      id: 5,
      name: r'lastBackupAt',
      type: IsarType.dateTime,
    ),
    r'lastBackupBytes': PropertySchema(
      id: 6,
      name: r'lastBackupBytes',
      type: IsarType.long,
    ),
    r'lastBackupError': PropertySchema(
      id: 7,
      name: r'lastBackupError',
      type: IsarType.string,
    ),
    r'lastBackupFileId': PropertySchema(
      id: 8,
      name: r'lastBackupFileId',
      type: IsarType.string,
    ),
    r'lastBackupSuccess': PropertySchema(
      id: 9,
      name: r'lastBackupSuccess',
      type: IsarType.bool,
    )
  },
  estimateSize: _backupMetaEntityEstimateSize,
  serialize: _backupMetaEntitySerialize,
  deserialize: _backupMetaEntityDeserialize,
  deserializeProp: _backupMetaEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _backupMetaEntityGetId,
  getLinks: _backupMetaEntityGetLinks,
  attach: _backupMetaEntityAttach,
  version: '3.1.0+1',
);

int _backupMetaEntityEstimateSize(
  BackupMetaEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.googleDriveAccountEmail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.googleDriveFolderId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastBackupError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastBackupFileId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _backupMetaEntitySerialize(
  BackupMetaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.autoBackupEnabled);
  writer.writeLong(offsets[1], object.backupIntervalHours);
  writer.writeLong(offsets[2], object.consecutiveFailureCount);
  writer.writeString(offsets[3], object.googleDriveAccountEmail);
  writer.writeString(offsets[4], object.googleDriveFolderId);
  writer.writeDateTime(offsets[5], object.lastBackupAt);
  writer.writeLong(offsets[6], object.lastBackupBytes);
  writer.writeString(offsets[7], object.lastBackupError);
  writer.writeString(offsets[8], object.lastBackupFileId);
  writer.writeBool(offsets[9], object.lastBackupSuccess);
}

BackupMetaEntity _backupMetaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BackupMetaEntity(
    autoBackupEnabled: reader.readBoolOrNull(offsets[0]) ?? false,
    backupIntervalHours: reader.readLongOrNull(offsets[1]) ?? 24,
    consecutiveFailureCount: reader.readLongOrNull(offsets[2]) ?? 0,
    googleDriveAccountEmail: reader.readStringOrNull(offsets[3]),
    googleDriveFolderId: reader.readStringOrNull(offsets[4]),
    id: id,
    lastBackupAt: reader.readDateTimeOrNull(offsets[5]),
    lastBackupBytes: reader.readLongOrNull(offsets[6]),
    lastBackupError: reader.readStringOrNull(offsets[7]),
    lastBackupFileId: reader.readStringOrNull(offsets[8]),
    lastBackupSuccess: reader.readBoolOrNull(offsets[9]),
  );
  return object;
}

P _backupMetaEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 24) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readBoolOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _backupMetaEntityGetId(BackupMetaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _backupMetaEntityGetLinks(BackupMetaEntity object) {
  return [];
}

void _backupMetaEntityAttach(
    IsarCollection<dynamic> col, Id id, BackupMetaEntity object) {
  object.id = id;
}

extension BackupMetaEntityQueryWhereSort
    on QueryBuilder<BackupMetaEntity, BackupMetaEntity, QWhere> {
  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BackupMetaEntityQueryWhere
    on QueryBuilder<BackupMetaEntity, BackupMetaEntity, QWhereClause> {
  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterWhereClause>
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

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterWhereClause> idBetween(
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

extension BackupMetaEntityQueryFilter
    on QueryBuilder<BackupMetaEntity, BackupMetaEntity, QFilterCondition> {
  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      autoBackupEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoBackupEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      backupIntervalHoursEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupIntervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      backupIntervalHoursGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backupIntervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      backupIntervalHoursLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backupIntervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      backupIntervalHoursBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backupIntervalHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      consecutiveFailureCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutiveFailureCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      consecutiveFailureCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consecutiveFailureCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      consecutiveFailureCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consecutiveFailureCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      consecutiveFailureCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consecutiveFailureCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'googleDriveAccountEmail',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'googleDriveAccountEmail',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'googleDriveAccountEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'googleDriveAccountEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'googleDriveAccountEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'googleDriveAccountEmail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'googleDriveAccountEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'googleDriveAccountEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'googleDriveAccountEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'googleDriveAccountEmail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'googleDriveAccountEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveAccountEmailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'googleDriveAccountEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'googleDriveFolderId',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'googleDriveFolderId',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'googleDriveFolderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'googleDriveFolderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'googleDriveFolderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'googleDriveFolderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'googleDriveFolderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'googleDriveFolderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'googleDriveFolderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'googleDriveFolderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'googleDriveFolderId',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      googleDriveFolderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'googleDriveFolderId',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
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

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
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

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
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

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastBackupAt',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastBackupAt',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastBackupAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastBackupAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastBackupAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastBackupAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastBackupBytes',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastBackupBytes',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupBytesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastBackupBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupBytesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastBackupBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupBytesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastBackupBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupBytesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastBackupBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastBackupError',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastBackupError',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastBackupError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastBackupError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastBackupError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastBackupError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastBackupError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastBackupError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastBackupError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastBackupError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastBackupError',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastBackupError',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastBackupFileId',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastBackupFileId',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastBackupFileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastBackupFileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastBackupFileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastBackupFileId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastBackupFileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastBackupFileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastBackupFileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastBackupFileId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastBackupFileId',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupFileIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastBackupFileId',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupSuccessIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastBackupSuccess',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupSuccessIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastBackupSuccess',
      ));
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterFilterCondition>
      lastBackupSuccessEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastBackupSuccess',
        value: value,
      ));
    });
  }
}

extension BackupMetaEntityQueryObject
    on QueryBuilder<BackupMetaEntity, BackupMetaEntity, QFilterCondition> {}

extension BackupMetaEntityQueryLinks
    on QueryBuilder<BackupMetaEntity, BackupMetaEntity, QFilterCondition> {}

extension BackupMetaEntityQuerySortBy
    on QueryBuilder<BackupMetaEntity, BackupMetaEntity, QSortBy> {
  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByAutoBackupEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupEnabled', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByAutoBackupEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupEnabled', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByBackupIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupIntervalHours', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByBackupIntervalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupIntervalHours', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByConsecutiveFailureCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveFailureCount', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByConsecutiveFailureCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveFailureCount', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByGoogleDriveAccountEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'googleDriveAccountEmail', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByGoogleDriveAccountEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'googleDriveAccountEmail', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByGoogleDriveFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'googleDriveFolderId', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByGoogleDriveFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'googleDriveFolderId', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByLastBackupAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByLastBackupBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupBytes', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByLastBackupBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupBytes', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByLastBackupError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupError', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByLastBackupErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupError', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByLastBackupFileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupFileId', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByLastBackupFileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupFileId', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByLastBackupSuccess() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupSuccess', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      sortByLastBackupSuccessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupSuccess', Sort.desc);
    });
  }
}

extension BackupMetaEntityQuerySortThenBy
    on QueryBuilder<BackupMetaEntity, BackupMetaEntity, QSortThenBy> {
  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByAutoBackupEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupEnabled', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByAutoBackupEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupEnabled', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByBackupIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupIntervalHours', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByBackupIntervalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupIntervalHours', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByConsecutiveFailureCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveFailureCount', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByConsecutiveFailureCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveFailureCount', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByGoogleDriveAccountEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'googleDriveAccountEmail', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByGoogleDriveAccountEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'googleDriveAccountEmail', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByGoogleDriveFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'googleDriveFolderId', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByGoogleDriveFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'googleDriveFolderId', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByLastBackupAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByLastBackupBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupBytes', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByLastBackupBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupBytes', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByLastBackupError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupError', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByLastBackupErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupError', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByLastBackupFileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupFileId', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByLastBackupFileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupFileId', Sort.desc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByLastBackupSuccess() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupSuccess', Sort.asc);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QAfterSortBy>
      thenByLastBackupSuccessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupSuccess', Sort.desc);
    });
  }
}

extension BackupMetaEntityQueryWhereDistinct
    on QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct> {
  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct>
      distinctByAutoBackupEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoBackupEnabled');
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct>
      distinctByBackupIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backupIntervalHours');
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct>
      distinctByConsecutiveFailureCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutiveFailureCount');
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct>
      distinctByGoogleDriveAccountEmail({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'googleDriveAccountEmail',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct>
      distinctByGoogleDriveFolderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'googleDriveFolderId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct>
      distinctByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBackupAt');
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct>
      distinctByLastBackupBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBackupBytes');
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct>
      distinctByLastBackupError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBackupError',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct>
      distinctByLastBackupFileId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBackupFileId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupMetaEntity, BackupMetaEntity, QDistinct>
      distinctByLastBackupSuccess() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBackupSuccess');
    });
  }
}

extension BackupMetaEntityQueryProperty
    on QueryBuilder<BackupMetaEntity, BackupMetaEntity, QQueryProperty> {
  QueryBuilder<BackupMetaEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BackupMetaEntity, bool, QQueryOperations>
      autoBackupEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoBackupEnabled');
    });
  }

  QueryBuilder<BackupMetaEntity, int, QQueryOperations>
      backupIntervalHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backupIntervalHours');
    });
  }

  QueryBuilder<BackupMetaEntity, int, QQueryOperations>
      consecutiveFailureCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutiveFailureCount');
    });
  }

  QueryBuilder<BackupMetaEntity, String?, QQueryOperations>
      googleDriveAccountEmailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'googleDriveAccountEmail');
    });
  }

  QueryBuilder<BackupMetaEntity, String?, QQueryOperations>
      googleDriveFolderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'googleDriveFolderId');
    });
  }

  QueryBuilder<BackupMetaEntity, DateTime?, QQueryOperations>
      lastBackupAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBackupAt');
    });
  }

  QueryBuilder<BackupMetaEntity, int?, QQueryOperations>
      lastBackupBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBackupBytes');
    });
  }

  QueryBuilder<BackupMetaEntity, String?, QQueryOperations>
      lastBackupErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBackupError');
    });
  }

  QueryBuilder<BackupMetaEntity, String?, QQueryOperations>
      lastBackupFileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBackupFileId');
    });
  }

  QueryBuilder<BackupMetaEntity, bool?, QQueryOperations>
      lastBackupSuccessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBackupSuccess');
    });
  }
}
