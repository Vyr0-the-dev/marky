// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_config.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVaultConfigCollection on Isar {
  IsarCollection<VaultConfig> get vaultConfigs => this.collection();
}

const VaultConfigSchema = CollectionSchema(
  name: r'VaultConfig',
  id: 2728340259194939701,
  properties: {
    r'autoLockDurationSeconds': PropertySchema(
      id: 0,
      name: r'autoLockDurationSeconds',
      type: IsarType.long,
    ),
    r'biometricsEnabled': PropertySchema(
      id: 1,
      name: r'biometricsEnabled',
      type: IsarType.bool,
    ),
    r'decoyModeEnabled': PropertySchema(
      id: 2,
      name: r'decoyModeEnabled',
      type: IsarType.bool,
    ),
    r'failedAttemptCount': PropertySchema(
      id: 3,
      name: r'failedAttemptCount',
      type: IsarType.long,
    ),
    r'lastUnlockAt': PropertySchema(
      id: 4,
      name: r'lastUnlockAt',
      type: IsarType.dateTime,
    ),
    r'screenshotProtectionEnabled': PropertySchema(
      id: 5,
      name: r'screenshotProtectionEnabled',
      type: IsarType.bool,
    )
  },
  estimateSize: _vaultConfigEstimateSize,
  serialize: _vaultConfigSerialize,
  deserialize: _vaultConfigDeserialize,
  deserializeProp: _vaultConfigDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _vaultConfigGetId,
  getLinks: _vaultConfigGetLinks,
  attach: _vaultConfigAttach,
  version: '3.1.0+1',
);

int _vaultConfigEstimateSize(
  VaultConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _vaultConfigSerialize(
  VaultConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.autoLockDurationSeconds);
  writer.writeBool(offsets[1], object.biometricsEnabled);
  writer.writeBool(offsets[2], object.decoyModeEnabled);
  writer.writeLong(offsets[3], object.failedAttemptCount);
  writer.writeDateTime(offsets[4], object.lastUnlockAt);
  writer.writeBool(offsets[5], object.screenshotProtectionEnabled);
}

VaultConfig _vaultConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VaultConfig(
    autoLockDurationSeconds: reader.readLongOrNull(offsets[0]) ?? 300,
    biometricsEnabled: reader.readBoolOrNull(offsets[1]) ?? false,
    decoyModeEnabled: reader.readBoolOrNull(offsets[2]) ?? false,
    failedAttemptCount: reader.readLongOrNull(offsets[3]) ?? 0,
    lastUnlockAt: reader.readDateTimeOrNull(offsets[4]),
    screenshotProtectionEnabled: reader.readBoolOrNull(offsets[5]) ?? true,
  );
  object.id = id;
  return object;
}

P _vaultConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 300) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _vaultConfigGetId(VaultConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vaultConfigGetLinks(VaultConfig object) {
  return [];
}

void _vaultConfigAttach(
    IsarCollection<dynamic> col, Id id, VaultConfig object) {
  object.id = id;
}

extension VaultConfigQueryWhereSort
    on QueryBuilder<VaultConfig, VaultConfig, QWhere> {
  QueryBuilder<VaultConfig, VaultConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VaultConfigQueryWhere
    on QueryBuilder<VaultConfig, VaultConfig, QWhereClause> {
  QueryBuilder<VaultConfig, VaultConfig, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<VaultConfig, VaultConfig, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterWhereClause> idBetween(
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

extension VaultConfigQueryFilter
    on QueryBuilder<VaultConfig, VaultConfig, QFilterCondition> {
  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      autoLockDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoLockDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      autoLockDurationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autoLockDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      autoLockDurationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autoLockDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      autoLockDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autoLockDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      biometricsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'biometricsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      decoyModeEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'decoyModeEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      failedAttemptCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failedAttemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      failedAttemptCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'failedAttemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      failedAttemptCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'failedAttemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      failedAttemptCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'failedAttemptCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      lastUnlockAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUnlockAt',
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      lastUnlockAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUnlockAt',
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      lastUnlockAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUnlockAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      lastUnlockAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUnlockAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      lastUnlockAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUnlockAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      lastUnlockAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUnlockAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterFilterCondition>
      screenshotProtectionEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'screenshotProtectionEnabled',
        value: value,
      ));
    });
  }
}

extension VaultConfigQueryObject
    on QueryBuilder<VaultConfig, VaultConfig, QFilterCondition> {}

extension VaultConfigQueryLinks
    on QueryBuilder<VaultConfig, VaultConfig, QFilterCondition> {}

extension VaultConfigQuerySortBy
    on QueryBuilder<VaultConfig, VaultConfig, QSortBy> {
  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByAutoLockDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByAutoLockDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByBiometricsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricsEnabled', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByBiometricsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricsEnabled', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByDecoyModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decoyModeEnabled', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByDecoyModeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decoyModeEnabled', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByFailedAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttemptCount', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByFailedAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttemptCount', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy> sortByLastUnlockAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUnlockAt', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByLastUnlockAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUnlockAt', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByScreenshotProtectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenshotProtectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      sortByScreenshotProtectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenshotProtectionEnabled', Sort.desc);
    });
  }
}

extension VaultConfigQuerySortThenBy
    on QueryBuilder<VaultConfig, VaultConfig, QSortThenBy> {
  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByAutoLockDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByAutoLockDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByBiometricsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricsEnabled', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByBiometricsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricsEnabled', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByDecoyModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decoyModeEnabled', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByDecoyModeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decoyModeEnabled', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByFailedAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttemptCount', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByFailedAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttemptCount', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy> thenByLastUnlockAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUnlockAt', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByLastUnlockAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUnlockAt', Sort.desc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByScreenshotProtectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenshotProtectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QAfterSortBy>
      thenByScreenshotProtectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenshotProtectionEnabled', Sort.desc);
    });
  }
}

extension VaultConfigQueryWhereDistinct
    on QueryBuilder<VaultConfig, VaultConfig, QDistinct> {
  QueryBuilder<VaultConfig, VaultConfig, QDistinct>
      distinctByAutoLockDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoLockDurationSeconds');
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QDistinct>
      distinctByBiometricsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'biometricsEnabled');
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QDistinct>
      distinctByDecoyModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'decoyModeEnabled');
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QDistinct>
      distinctByFailedAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failedAttemptCount');
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QDistinct> distinctByLastUnlockAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUnlockAt');
    });
  }

  QueryBuilder<VaultConfig, VaultConfig, QDistinct>
      distinctByScreenshotProtectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'screenshotProtectionEnabled');
    });
  }
}

extension VaultConfigQueryProperty
    on QueryBuilder<VaultConfig, VaultConfig, QQueryProperty> {
  QueryBuilder<VaultConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VaultConfig, int, QQueryOperations>
      autoLockDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoLockDurationSeconds');
    });
  }

  QueryBuilder<VaultConfig, bool, QQueryOperations>
      biometricsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'biometricsEnabled');
    });
  }

  QueryBuilder<VaultConfig, bool, QQueryOperations> decoyModeEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'decoyModeEnabled');
    });
  }

  QueryBuilder<VaultConfig, int, QQueryOperations>
      failedAttemptCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failedAttemptCount');
    });
  }

  QueryBuilder<VaultConfig, DateTime?, QQueryOperations>
      lastUnlockAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUnlockAt');
    });
  }

  QueryBuilder<VaultConfig, bool, QQueryOperations>
      screenshotProtectionEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'screenshotProtectionEnabled');
    });
  }
}
