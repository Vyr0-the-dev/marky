// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsCollection on Isar {
  IsarCollection<AppSettings> get appSettings => this.collection();
}

const AppSettingsSchema = CollectionSchema(
  name: r'AppSettings',
  id: -5633561779022347008,
  properties: {
    r'accentColor': PropertySchema(
      id: 0,
      name: r'accentColor',
      type: IsarType.string,
    ),
    r'aiEnabled': PropertySchema(
      id: 1,
      name: r'aiEnabled',
      type: IsarType.bool,
    ),
    r'analyticsEnabled': PropertySchema(
      id: 2,
      name: r'analyticsEnabled',
      type: IsarType.bool,
    ),
    r'animationsEnabled': PropertySchema(
      id: 3,
      name: r'animationsEnabled',
      type: IsarType.bool,
    ),
    r'autoArchiveDays': PropertySchema(
      id: 4,
      name: r'autoArchiveDays',
      type: IsarType.long,
    ),
    r'autoDeleteDays': PropertySchema(
      id: 5,
      name: r'autoDeleteDays',
      type: IsarType.long,
    ),
    r'backupEnabled': PropertySchema(
      id: 6,
      name: r'backupEnabled',
      type: IsarType.bool,
    ),
    r'backupEncryptionEnabled': PropertySchema(
      id: 7,
      name: r'backupEncryptionEnabled',
      type: IsarType.bool,
    ),
    r'backupTarget': PropertySchema(
      id: 8,
      name: r'backupTarget',
      type: IsarType.string,
    ),
    r'clipboardDetectionEnabled': PropertySchema(
      id: 9,
      name: r'clipboardDetectionEnabled',
      type: IsarType.bool,
    ),
    r'crashLogsEnabled': PropertySchema(
      id: 10,
      name: r'crashLogsEnabled',
      type: IsarType.bool,
    ),
    r'defaultLayoutMode': PropertySchema(
      id: 11,
      name: r'defaultLayoutMode',
      type: IsarType.string,
    ),
    r'defaultOpenBehavior': PropertySchema(
      id: 12,
      name: r'defaultOpenBehavior',
      type: IsarType.string,
    ),
    r'dynamicColorEnabled': PropertySchema(
      id: 13,
      name: r'dynamicColorEnabled',
      type: IsarType.bool,
    ),
    r'gridDensity': PropertySchema(
      id: 14,
      name: r'gridDensity',
      type: IsarType.string,
    ),
    r'hapticsEnabled': PropertySchema(
      id: 15,
      name: r'hapticsEnabled',
      type: IsarType.bool,
    ),
    r'languagePreference': PropertySchema(
      id: 16,
      name: r'languagePreference',
      type: IsarType.string,
    ),
    r'localAiOnlyMode': PropertySchema(
      id: 17,
      name: r'localAiOnlyMode',
      type: IsarType.bool,
    ),
    r'oledPureBlackEnabled': PropertySchema(
      id: 18,
      name: r'oledPureBlackEnabled',
      type: IsarType.bool,
    ),
    r'recentSearches': PropertySchema(
      id: 19,
      name: r'recentSearches',
      type: IsarType.stringList,
    ),
    r'themeMode': PropertySchema(
      id: 20,
      name: r'themeMode',
      type: IsarType.string,
    )
  },
  estimateSize: _appSettingsEstimateSize,
  serialize: _appSettingsSerialize,
  deserialize: _appSettingsDeserialize,
  deserializeProp: _appSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsGetId,
  getLinks: _appSettingsGetLinks,
  attach: _appSettingsAttach,
  version: '3.1.0+1',
);

int _appSettingsEstimateSize(
  AppSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accentColor.length * 3;
  {
    final value = object.backupTarget;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.defaultLayoutMode.length * 3;
  bytesCount += 3 + object.defaultOpenBehavior.length * 3;
  bytesCount += 3 + object.gridDensity.length * 3;
  bytesCount += 3 + object.languagePreference.length * 3;
  {
    final list = object.recentSearches;
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
  bytesCount += 3 + object.themeMode.length * 3;
  return bytesCount;
}

void _appSettingsSerialize(
  AppSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accentColor);
  writer.writeBool(offsets[1], object.aiEnabled);
  writer.writeBool(offsets[2], object.analyticsEnabled);
  writer.writeBool(offsets[3], object.animationsEnabled);
  writer.writeLong(offsets[4], object.autoArchiveDays);
  writer.writeLong(offsets[5], object.autoDeleteDays);
  writer.writeBool(offsets[6], object.backupEnabled);
  writer.writeBool(offsets[7], object.backupEncryptionEnabled);
  writer.writeString(offsets[8], object.backupTarget);
  writer.writeBool(offsets[9], object.clipboardDetectionEnabled);
  writer.writeBool(offsets[10], object.crashLogsEnabled);
  writer.writeString(offsets[11], object.defaultLayoutMode);
  writer.writeString(offsets[12], object.defaultOpenBehavior);
  writer.writeBool(offsets[13], object.dynamicColorEnabled);
  writer.writeString(offsets[14], object.gridDensity);
  writer.writeBool(offsets[15], object.hapticsEnabled);
  writer.writeString(offsets[16], object.languagePreference);
  writer.writeBool(offsets[17], object.localAiOnlyMode);
  writer.writeBool(offsets[18], object.oledPureBlackEnabled);
  writer.writeStringList(offsets[19], object.recentSearches);
  writer.writeString(offsets[20], object.themeMode);
}

AppSettings _appSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettings(
    accentColor: reader.readStringOrNull(offsets[0]) ?? 'default',
    aiEnabled: reader.readBoolOrNull(offsets[1]) ?? false,
    analyticsEnabled: reader.readBoolOrNull(offsets[2]) ?? false,
    animationsEnabled: reader.readBoolOrNull(offsets[3]) ?? true,
    autoArchiveDays: reader.readLongOrNull(offsets[4]),
    autoDeleteDays: reader.readLongOrNull(offsets[5]),
    backupEnabled: reader.readBoolOrNull(offsets[6]) ?? false,
    backupEncryptionEnabled: reader.readBoolOrNull(offsets[7]) ?? false,
    backupTarget: reader.readStringOrNull(offsets[8]),
    clipboardDetectionEnabled: reader.readBoolOrNull(offsets[9]) ?? true,
    crashLogsEnabled: reader.readBoolOrNull(offsets[10]) ?? true,
    defaultLayoutMode: reader.readStringOrNull(offsets[11]) ?? 'grid',
    defaultOpenBehavior: reader.readStringOrNull(offsets[12]) ?? 'inApp',
    dynamicColorEnabled: reader.readBoolOrNull(offsets[13]) ?? false,
    gridDensity: reader.readStringOrNull(offsets[14]) ?? 'comfortable',
    hapticsEnabled: reader.readBoolOrNull(offsets[15]) ?? true,
    languagePreference: reader.readStringOrNull(offsets[16]) ?? 'system',
    localAiOnlyMode: reader.readBoolOrNull(offsets[17]) ?? true,
    oledPureBlackEnabled: reader.readBoolOrNull(offsets[18]) ?? false,
    recentSearches: reader.readStringList(offsets[19]),
    themeMode: reader.readStringOrNull(offsets[20]) ?? 'system',
  );
  object.id = id;
  return object;
}

P _appSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? 'default') as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 10:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 11:
      return (reader.readStringOrNull(offset) ?? 'grid') as P;
    case 12:
      return (reader.readStringOrNull(offset) ?? 'inApp') as P;
    case 13:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 14:
      return (reader.readStringOrNull(offset) ?? 'comfortable') as P;
    case 15:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 16:
      return (reader.readStringOrNull(offset) ?? 'system') as P;
    case 17:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 18:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 19:
      return (reader.readStringList(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset) ?? 'system') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsGetId(AppSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsGetLinks(AppSettings object) {
  return [];
}

void _appSettingsAttach(
    IsarCollection<dynamic> col, Id id, AppSettings object) {
  object.id = id;
}

extension AppSettingsQueryWhereSort
    on QueryBuilder<AppSettings, AppSettings, QWhere> {
  QueryBuilder<AppSettings, AppSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsQueryWhere
    on QueryBuilder<AppSettings, AppSettings, QWhereClause> {
  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idBetween(
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

extension AppSettingsQueryFilter
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {
  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorEqualTo(
    String value, {
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorGreaterThan(
    String value, {
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorLessThan(
    String value, {
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorBetween(
    String lower,
    String upper, {
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accentColor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accentColor',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accentColor',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      aiEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      analyticsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'analyticsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      animationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animationsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoArchiveDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'autoArchiveDays',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoArchiveDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'autoArchiveDays',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoArchiveDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoArchiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoArchiveDaysGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autoArchiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoArchiveDaysLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autoArchiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoArchiveDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autoArchiveDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoDeleteDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'autoDeleteDays',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoDeleteDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'autoDeleteDays',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoDeleteDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoDeleteDays',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoDeleteDaysGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autoDeleteDays',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoDeleteDaysLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autoDeleteDays',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoDeleteDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autoDeleteDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupEncryptionEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupEncryptionEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'backupTarget',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'backupTarget',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backupTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backupTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backupTarget',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'backupTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'backupTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'backupTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'backupTarget',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupTarget',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      backupTargetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'backupTarget',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      clipboardDetectionEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clipboardDetectionEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crashLogsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crashLogsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultLayoutModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultLayoutMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultLayoutModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultLayoutMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultLayoutModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultLayoutMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultLayoutModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultLayoutMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultLayoutModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'defaultLayoutMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultLayoutModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'defaultLayoutMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultLayoutModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'defaultLayoutMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultLayoutModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'defaultLayoutMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultLayoutModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultLayoutMode',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultLayoutModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'defaultLayoutMode',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultOpenBehaviorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultOpenBehavior',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultOpenBehaviorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultOpenBehavior',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultOpenBehaviorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultOpenBehavior',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultOpenBehaviorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultOpenBehavior',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultOpenBehaviorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'defaultOpenBehavior',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultOpenBehaviorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'defaultOpenBehavior',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultOpenBehaviorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'defaultOpenBehavior',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultOpenBehaviorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'defaultOpenBehavior',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultOpenBehaviorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultOpenBehavior',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultOpenBehaviorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'defaultOpenBehavior',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      dynamicColorEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dynamicColorEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gridDensityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gridDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gridDensityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gridDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gridDensityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gridDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gridDensityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gridDensity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gridDensityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gridDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gridDensityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gridDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gridDensityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gridDensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gridDensityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gridDensity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gridDensityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gridDensity',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gridDensityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gridDensity',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      hapticsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hapticsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languagePreferenceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languagePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languagePreferenceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'languagePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languagePreferenceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'languagePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languagePreferenceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'languagePreference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languagePreferenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'languagePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languagePreferenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'languagePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languagePreferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'languagePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languagePreferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'languagePreference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languagePreferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languagePreference',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languagePreferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'languagePreference',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      localAiOnlyModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localAiOnlyMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      oledPureBlackEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oledPureBlackEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recentSearches',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recentSearches',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recentSearches',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recentSearches',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recentSearches',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recentSearches',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recentSearches',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recentSearches',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recentSearches',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recentSearches',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recentSearches',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recentSearches',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recentSearches',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recentSearches',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recentSearches',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recentSearches',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recentSearches',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      recentSearchesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recentSearches',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'themeMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'themeMode',
        value: '',
      ));
    });
  }
}

extension AppSettingsQueryObject
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {}

extension AppSettingsQueryLinks
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {}

extension AppSettingsQuerySortBy
    on QueryBuilder<AppSettings, AppSettings, QSortBy> {
  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAiEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAiEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAnalyticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAnalyticsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAnimationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAnimationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAutoArchiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoArchiveDays', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAutoArchiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoArchiveDays', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAutoDeleteDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteDays', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAutoDeleteDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteDays', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByBackupEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByBackupEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByBackupEncryptionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupEncryptionEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByBackupEncryptionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupEncryptionEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByBackupTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupTarget', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByBackupTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupTarget', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByClipboardDetectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clipboardDetectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByClipboardDetectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clipboardDetectionEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCrashLogsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crashLogsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCrashLogsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crashLogsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDefaultLayoutMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultLayoutMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDefaultLayoutModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultLayoutMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDefaultOpenBehavior() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultOpenBehavior', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDefaultOpenBehaviorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultOpenBehavior', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicColorEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicColorEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByGridDensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridDensity', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByGridDensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridDensity', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByHapticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByHapticsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLanguagePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languagePreference', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLanguagePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languagePreference', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLocalAiOnlyMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localAiOnlyMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLocalAiOnlyModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localAiOnlyMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByOledPureBlackEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oledPureBlackEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByOledPureBlackEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oledPureBlackEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension AppSettingsQuerySortThenBy
    on QueryBuilder<AppSettings, AppSettings, QSortThenBy> {
  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAiEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAiEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAnalyticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAnalyticsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAnimationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAnimationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAutoArchiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoArchiveDays', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAutoArchiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoArchiveDays', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAutoDeleteDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteDays', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAutoDeleteDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteDays', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByBackupEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByBackupEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByBackupEncryptionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupEncryptionEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByBackupEncryptionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupEncryptionEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByBackupTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupTarget', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByBackupTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupTarget', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByClipboardDetectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clipboardDetectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByClipboardDetectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clipboardDetectionEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCrashLogsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crashLogsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCrashLogsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crashLogsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDefaultLayoutMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultLayoutMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDefaultLayoutModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultLayoutMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDefaultOpenBehavior() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultOpenBehavior', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDefaultOpenBehaviorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultOpenBehavior', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicColorEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicColorEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByGridDensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridDensity', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByGridDensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridDensity', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByHapticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByHapticsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLanguagePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languagePreference', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLanguagePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languagePreference', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLocalAiOnlyMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localAiOnlyMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLocalAiOnlyModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localAiOnlyMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByOledPureBlackEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oledPureBlackEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByOledPureBlackEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oledPureBlackEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension AppSettingsQueryWhereDistinct
    on QueryBuilder<AppSettings, AppSettings, QDistinct> {
  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByAccentColor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accentColor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByAiEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAnalyticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'analyticsEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAnimationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animationsEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAutoArchiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoArchiveDays');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByAutoDeleteDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoDeleteDays');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByBackupEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backupEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByBackupEncryptionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backupEncryptionEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByBackupTarget(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backupTarget', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByClipboardDetectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clipboardDetectionEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCrashLogsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'crashLogsEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByDefaultLayoutMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultLayoutMode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDefaultOpenBehavior({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultOpenBehavior',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDynamicColorEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dynamicColorEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByGridDensity(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gridDensity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByHapticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hapticsEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByLanguagePreference({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'languagePreference',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByLocalAiOnlyMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localAiOnlyMode');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByOledPureBlackEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oledPureBlackEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByRecentSearches() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recentSearches');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByThemeMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode', caseSensitive: caseSensitive);
    });
  }
}

extension AppSettingsQueryProperty
    on QueryBuilder<AppSettings, AppSettings, QQueryProperty> {
  QueryBuilder<AppSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations> accentColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accentColor');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> aiEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiEnabled');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> analyticsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'analyticsEnabled');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      animationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animationsEnabled');
    });
  }

  QueryBuilder<AppSettings, int?, QQueryOperations> autoArchiveDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoArchiveDays');
    });
  }

  QueryBuilder<AppSettings, int?, QQueryOperations> autoDeleteDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoDeleteDays');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> backupEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backupEnabled');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      backupEncryptionEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backupEncryptionEnabled');
    });
  }

  QueryBuilder<AppSettings, String?, QQueryOperations> backupTargetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backupTarget');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      clipboardDetectionEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clipboardDetectionEnabled');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> crashLogsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'crashLogsEnabled');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      defaultLayoutModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultLayoutMode');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      defaultOpenBehaviorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultOpenBehavior');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      dynamicColorEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dynamicColorEnabled');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations> gridDensityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gridDensity');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> hapticsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hapticsEnabled');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      languagePreferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'languagePreference');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> localAiOnlyModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localAiOnlyMode');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      oledPureBlackEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oledPureBlackEnabled');
    });
  }

  QueryBuilder<AppSettings, List<String>?, QQueryOperations>
      recentSearchesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recentSearches');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations> themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }
}
