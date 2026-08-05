// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automation_rule.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAutomationRuleCollection on Isar {
  IsarCollection<AutomationRule> get automationRules => this.collection();
}

const AutomationRuleSchema = CollectionSchema(
  name: r'AutomationRule',
  id: -2923571291435955635,
  properties: {
    r'actions': PropertySchema(
      id: 0,
      name: r'actions',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'enabled': PropertySchema(
      id: 3,
      name: r'enabled',
      type: IsarType.bool,
    ),
    r'executionCount': PropertySchema(
      id: 4,
      name: r'executionCount',
      type: IsarType.long,
    ),
    r'lastExecutedAt': PropertySchema(
      id: 5,
      name: r'lastExecutedAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 6,
      name: r'name',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 7,
      name: r'priority',
      type: IsarType.long,
    ),
    r'triggerConfig': PropertySchema(
      id: 8,
      name: r'triggerConfig',
      type: IsarType.string,
    ),
    r'triggerType': PropertySchema(
      id: 9,
      name: r'triggerType',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _automationRuleEstimateSize,
  serialize: _automationRuleSerialize,
  deserialize: _automationRuleDeserialize,
  deserializeProp: _automationRuleDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _automationRuleGetId,
  getLinks: _automationRuleGetLinks,
  attach: _automationRuleAttach,
  version: '3.1.0+1',
);

int _automationRuleEstimateSize(
  AutomationRule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actions.length * 3;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.triggerConfig.length * 3;
  bytesCount += 3 + object.triggerType.length * 3;
  return bytesCount;
}

void _automationRuleSerialize(
  AutomationRule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actions);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.description);
  writer.writeBool(offsets[3], object.enabled);
  writer.writeLong(offsets[4], object.executionCount);
  writer.writeDateTime(offsets[5], object.lastExecutedAt);
  writer.writeString(offsets[6], object.name);
  writer.writeLong(offsets[7], object.priority);
  writer.writeString(offsets[8], object.triggerConfig);
  writer.writeString(offsets[9], object.triggerType);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

AutomationRule _automationRuleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AutomationRule(
    actions: reader.readString(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    description: reader.readStringOrNull(offsets[2]),
    enabled: reader.readBoolOrNull(offsets[3]) ?? true,
    executionCount: reader.readLongOrNull(offsets[4]) ?? 0,
    lastExecutedAt: reader.readDateTimeOrNull(offsets[5]),
    name: reader.readString(offsets[6]),
    priority: reader.readLongOrNull(offsets[7]) ?? 0,
    triggerConfig: reader.readString(offsets[8]),
    triggerType: reader.readString(offsets[9]),
    updatedAt: reader.readDateTime(offsets[10]),
  );
  object.id = id;
  return object;
}

P _automationRuleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _automationRuleGetId(AutomationRule object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _automationRuleGetLinks(AutomationRule object) {
  return [];
}

void _automationRuleAttach(
    IsarCollection<dynamic> col, Id id, AutomationRule object) {
  object.id = id;
}

extension AutomationRuleQueryWhereSort
    on QueryBuilder<AutomationRule, AutomationRule, QWhere> {
  QueryBuilder<AutomationRule, AutomationRule, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AutomationRuleQueryWhere
    on QueryBuilder<AutomationRule, AutomationRule, QWhereClause> {
  QueryBuilder<AutomationRule, AutomationRule, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterWhereClause> idBetween(
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

extension AutomationRuleQueryFilter
    on QueryBuilder<AutomationRule, AutomationRule, QFilterCondition> {
  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      actionsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      actionsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      actionsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      actionsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      actionsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      actionsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      actionsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      actionsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      actionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actions',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      actionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actions',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      executionCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'executionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      executionCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'executionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      executionCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'executionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      executionCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'executionCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      lastExecutedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastExecutedAt',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      lastExecutedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastExecutedAt',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      lastExecutedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastExecutedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      lastExecutedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastExecutedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      lastExecutedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastExecutedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      lastExecutedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastExecutedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      priorityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      priorityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerConfigEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerConfig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerConfigGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggerConfig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerConfigLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggerConfig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerConfigBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggerConfig',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerConfigStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'triggerConfig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerConfigEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'triggerConfig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerConfigContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'triggerConfig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerConfigMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'triggerConfig',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerConfigIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerConfig',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerConfigIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'triggerConfig',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggerType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'triggerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'triggerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'triggerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'triggerType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerType',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      triggerTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'triggerType',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

  QueryBuilder<AutomationRule, AutomationRule, QAfterFilterCondition>
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

extension AutomationRuleQueryObject
    on QueryBuilder<AutomationRule, AutomationRule, QFilterCondition> {}

extension AutomationRuleQueryLinks
    on QueryBuilder<AutomationRule, AutomationRule, QFilterCondition> {}

extension AutomationRuleQuerySortBy
    on QueryBuilder<AutomationRule, AutomationRule, QSortBy> {
  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> sortByActions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actions', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByActionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actions', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByExecutionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionCount', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByExecutionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionCount', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByLastExecutedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastExecutedAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByLastExecutedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastExecutedAt', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByTriggerConfig() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerConfig', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByTriggerConfigDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerConfig', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByTriggerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerType', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByTriggerTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerType', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AutomationRuleQuerySortThenBy
    on QueryBuilder<AutomationRule, AutomationRule, QSortThenBy> {
  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> thenByActions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actions', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByActionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actions', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByExecutionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionCount', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByExecutionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionCount', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByLastExecutedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastExecutedAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByLastExecutedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastExecutedAt', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByTriggerConfig() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerConfig', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByTriggerConfigDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerConfig', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByTriggerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerType', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByTriggerTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerType', Sort.desc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AutomationRuleQueryWhereDistinct
    on QueryBuilder<AutomationRule, AutomationRule, QDistinct> {
  QueryBuilder<AutomationRule, AutomationRule, QDistinct> distinctByActions(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actions', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QDistinct> distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QDistinct>
      distinctByExecutionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'executionCount');
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QDistinct>
      distinctByLastExecutedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastExecutedAt');
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QDistinct> distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QDistinct>
      distinctByTriggerConfig({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggerConfig',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QDistinct> distinctByTriggerType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggerType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutomationRule, AutomationRule, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AutomationRuleQueryProperty
    on QueryBuilder<AutomationRule, AutomationRule, QQueryProperty> {
  QueryBuilder<AutomationRule, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AutomationRule, String, QQueryOperations> actionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actions');
    });
  }

  QueryBuilder<AutomationRule, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AutomationRule, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<AutomationRule, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<AutomationRule, int, QQueryOperations> executionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'executionCount');
    });
  }

  QueryBuilder<AutomationRule, DateTime?, QQueryOperations>
      lastExecutedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastExecutedAt');
    });
  }

  QueryBuilder<AutomationRule, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AutomationRule, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<AutomationRule, String, QQueryOperations>
      triggerConfigProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggerConfig');
    });
  }

  QueryBuilder<AutomationRule, String, QQueryOperations> triggerTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggerType');
    });
  }

  QueryBuilder<AutomationRule, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
