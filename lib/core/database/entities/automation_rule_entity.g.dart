// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automation_rule_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAutomationRuleEntityCollection on Isar {
  IsarCollection<AutomationRuleEntity> get automationRules => this.collection();
}

const AutomationRuleEntitySchema = CollectionSchema(
  name: r'AutomationRuleEntity',
  id: -3392093147397608164,
  properties: {
    r'actionArgs': PropertySchema(
      id: 0,
      name: r'actionArgs',
      type: IsarType.stringList,
    ),
    r'actionTypes': PropertySchema(
      id: 1,
      name: r'actionTypes',
      type: IsarType.stringList,
      enumMap: _AutomationRuleEntityactionTypesEnumValueMap,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'enabled': PropertySchema(
      id: 4,
      name: r'enabled',
      type: IsarType.bool,
    ),
    r'executionCount': PropertySchema(
      id: 5,
      name: r'executionCount',
      type: IsarType.long,
    ),
    r'lastExecutedAt': PropertySchema(
      id: 6,
      name: r'lastExecutedAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 7,
      name: r'name',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 8,
      name: r'priority',
      type: IsarType.long,
    ),
    r'triggerType': PropertySchema(
      id: 9,
      name: r'triggerType',
      type: IsarType.string,
      enumMap: _AutomationRuleEntitytriggerTypeEnumValueMap,
    ),
    r'triggerValue': PropertySchema(
      id: 10,
      name: r'triggerValue',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 11,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _automationRuleEntityEstimateSize,
  serialize: _automationRuleEntitySerialize,
  deserialize: _automationRuleEntityDeserialize,
  deserializeProp: _automationRuleEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _automationRuleEntityGetId,
  getLinks: _automationRuleEntityGetLinks,
  attach: _automationRuleEntityAttach,
  version: '3.1.0+1',
);

int _automationRuleEntityEstimateSize(
  AutomationRuleEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actionArgs.length * 3;
  {
    for (var i = 0; i < object.actionArgs.length; i++) {
      final value = object.actionArgs[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.actionTypes.length * 3;
  {
    for (var i = 0; i < object.actionTypes.length; i++) {
      final value = object.actionTypes[i];
      bytesCount += value.name.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.triggerType.name.length * 3;
  bytesCount += 3 + object.triggerValue.length * 3;
  return bytesCount;
}

void _automationRuleEntitySerialize(
  AutomationRuleEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.actionArgs);
  writer.writeStringList(
      offsets[1], object.actionTypes.map((e) => e.name).toList());
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.description);
  writer.writeBool(offsets[4], object.enabled);
  writer.writeLong(offsets[5], object.executionCount);
  writer.writeDateTime(offsets[6], object.lastExecutedAt);
  writer.writeString(offsets[7], object.name);
  writer.writeLong(offsets[8], object.priority);
  writer.writeString(offsets[9], object.triggerType.name);
  writer.writeString(offsets[10], object.triggerValue);
  writer.writeDateTime(offsets[11], object.updatedAt);
}

AutomationRuleEntity _automationRuleEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AutomationRuleEntity(
    actionArgs: reader.readStringList(offsets[0]) ?? const <String>[],
    actionTypes: reader
            .readStringList(offsets[1])
            ?.map((e) =>
                _AutomationRuleEntityactionTypesValueEnumMap[e] ??
                AutomationActionType.addTag)
            .toList() ??
        const <AutomationActionType>[],
    createdAt: reader.readDateTime(offsets[2]),
    description: reader.readStringOrNull(offsets[3]),
    enabled: reader.readBoolOrNull(offsets[4]) ?? true,
    executionCount: reader.readLongOrNull(offsets[5]) ?? 0,
    lastExecutedAt: reader.readDateTimeOrNull(offsets[6]),
    name: reader.readString(offsets[7]),
    priority: reader.readLongOrNull(offsets[8]) ?? 100,
    triggerType: _AutomationRuleEntitytriggerTypeValueEnumMap[
            reader.readStringOrNull(offsets[9])] ??
        AutomationTriggerType.domainEquals,
    triggerValue: reader.readString(offsets[10]),
    updatedAt: reader.readDateTime(offsets[11]),
  );
  object.id = id;
  return object;
}

P _automationRuleEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? const <String>[]) as P;
    case 1:
      return (reader
              .readStringList(offset)
              ?.map((e) =>
                  _AutomationRuleEntityactionTypesValueEnumMap[e] ??
                  AutomationActionType.addTag)
              .toList() ??
          const <AutomationActionType>[]) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset) ?? 100) as P;
    case 9:
      return (_AutomationRuleEntitytriggerTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AutomationTriggerType.domainEquals) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AutomationRuleEntityactionTypesEnumValueMap = {
  r'addTag': r'addTag',
  r'addToCollection': r'addToCollection',
  r'setFavorite': r'setFavorite',
  r'setArchived': r'setArchived',
  r'setPinned': r'setPinned',
  r'addReminder': r'addReminder',
};
const _AutomationRuleEntityactionTypesValueEnumMap = {
  r'addTag': AutomationActionType.addTag,
  r'addToCollection': AutomationActionType.addToCollection,
  r'setFavorite': AutomationActionType.setFavorite,
  r'setArchived': AutomationActionType.setArchived,
  r'setPinned': AutomationActionType.setPinned,
  r'addReminder': AutomationActionType.addReminder,
};
const _AutomationRuleEntitytriggerTypeEnumValueMap = {
  r'domainEquals': r'domainEquals',
  r'domainContains': r'domainContains',
  r'urlContains': r'urlContains',
  r'sourceTypeEquals': r'sourceTypeEquals',
  r'tagContains': r'tagContains',
  r'unreadForDays': r'unreadForDays',
  r'addedWithinDays': r'addedWithinDays',
  r'contentTypeEquals': r'contentTypeEquals',
  r'readingTimeGreaterThan': r'readingTimeGreaterThan',
  r'titleContains': r'titleContains',
  r'titleMatchesRegex': r'titleMatchesRegex',
};
const _AutomationRuleEntitytriggerTypeValueEnumMap = {
  r'domainEquals': AutomationTriggerType.domainEquals,
  r'domainContains': AutomationTriggerType.domainContains,
  r'urlContains': AutomationTriggerType.urlContains,
  r'sourceTypeEquals': AutomationTriggerType.sourceTypeEquals,
  r'tagContains': AutomationTriggerType.tagContains,
  r'unreadForDays': AutomationTriggerType.unreadForDays,
  r'addedWithinDays': AutomationTriggerType.addedWithinDays,
  r'contentTypeEquals': AutomationTriggerType.contentTypeEquals,
  r'readingTimeGreaterThan': AutomationTriggerType.readingTimeGreaterThan,
  r'titleContains': AutomationTriggerType.titleContains,
  r'titleMatchesRegex': AutomationTriggerType.titleMatchesRegex,
};

Id _automationRuleEntityGetId(AutomationRuleEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _automationRuleEntityGetLinks(
    AutomationRuleEntity object) {
  return [];
}

void _automationRuleEntityAttach(
    IsarCollection<dynamic> col, Id id, AutomationRuleEntity object) {
  object.id = id;
}

extension AutomationRuleEntityQueryWhereSort
    on QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QWhere> {
  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AutomationRuleEntityQueryWhere
    on QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QWhereClause> {
  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterWhereClause>
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterWhereClause>
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
}

extension AutomationRuleEntityQueryFilter on QueryBuilder<AutomationRuleEntity,
    AutomationRuleEntity, QFilterCondition> {
  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionArgs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionArgs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionArgs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionArgs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionArgs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionArgs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      actionArgsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionArgs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      actionArgsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionArgs',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionArgs',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionArgs',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionArgs',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionArgs',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionArgs',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionArgs',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionArgs',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionArgsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionArgs',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesElementEqualTo(
    AutomationActionType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesElementGreaterThan(
    AutomationActionType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesElementLessThan(
    AutomationActionType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesElementBetween(
    AutomationActionType lower,
    AutomationActionType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionTypes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      actionTypesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      actionTypesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionTypes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionTypes',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionTypes',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionTypes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionTypes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionTypes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionTypes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionTypes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> actionTypesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actionTypes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> descriptionEqualTo(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> descriptionGreaterThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> descriptionLessThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> descriptionBetween(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> descriptionStartsWith(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> descriptionEndsWith(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> executionCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'executionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> executionCountGreaterThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> executionCountLessThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> executionCountBetween(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> lastExecutedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastExecutedAt',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> lastExecutedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastExecutedAt',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> lastExecutedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastExecutedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> lastExecutedAtGreaterThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> lastExecutedAtLessThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> lastExecutedAtBetween(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> nameBetween(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> priorityGreaterThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> priorityLessThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> priorityBetween(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerTypeEqualTo(
    AutomationTriggerType value, {
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerTypeGreaterThan(
    AutomationTriggerType value, {
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerTypeLessThan(
    AutomationTriggerType value, {
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerTypeBetween(
    AutomationTriggerType lower,
    AutomationTriggerType upper, {
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerTypeStartsWith(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerTypeEndsWith(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      triggerTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'triggerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      triggerTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'triggerType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerType',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'triggerType',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerValueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerValueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggerValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerValueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggerValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerValueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggerValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'triggerValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'triggerValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      triggerValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'triggerValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
          QAfterFilterCondition>
      triggerValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'triggerValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> triggerValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'triggerValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity,
      QAfterFilterCondition> updatedAtBetween(
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

extension AutomationRuleEntityQueryObject on QueryBuilder<AutomationRuleEntity,
    AutomationRuleEntity, QFilterCondition> {}

extension AutomationRuleEntityQueryLinks on QueryBuilder<AutomationRuleEntity,
    AutomationRuleEntity, QFilterCondition> {}

extension AutomationRuleEntityQuerySortBy
    on QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QSortBy> {
  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByExecutionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionCount', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByExecutionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionCount', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByLastExecutedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastExecutedAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByLastExecutedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastExecutedAt', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByTriggerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerType', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByTriggerTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerType', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByTriggerValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerValue', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByTriggerValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerValue', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AutomationRuleEntityQuerySortThenBy
    on QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QSortThenBy> {
  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByExecutionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionCount', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByExecutionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionCount', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByLastExecutedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastExecutedAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByLastExecutedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastExecutedAt', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByTriggerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerType', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByTriggerTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerType', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByTriggerValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerValue', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByTriggerValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerValue', Sort.desc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AutomationRuleEntityQueryWhereDistinct
    on QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct> {
  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByActionArgs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionArgs');
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByActionTypes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionTypes');
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByExecutionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'executionCount');
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByLastExecutedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastExecutedAt');
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByTriggerType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggerType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByTriggerValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggerValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationRuleEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AutomationRuleEntityQueryProperty on QueryBuilder<
    AutomationRuleEntity, AutomationRuleEntity, QQueryProperty> {
  QueryBuilder<AutomationRuleEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AutomationRuleEntity, List<String>, QQueryOperations>
      actionArgsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionArgs');
    });
  }

  QueryBuilder<AutomationRuleEntity, List<AutomationActionType>,
      QQueryOperations> actionTypesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionTypes');
    });
  }

  QueryBuilder<AutomationRuleEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AutomationRuleEntity, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<AutomationRuleEntity, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<AutomationRuleEntity, int, QQueryOperations>
      executionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'executionCount');
    });
  }

  QueryBuilder<AutomationRuleEntity, DateTime?, QQueryOperations>
      lastExecutedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastExecutedAt');
    });
  }

  QueryBuilder<AutomationRuleEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AutomationRuleEntity, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<AutomationRuleEntity, AutomationTriggerType, QQueryOperations>
      triggerTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggerType');
    });
  }

  QueryBuilder<AutomationRuleEntity, String, QQueryOperations>
      triggerValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggerValue');
    });
  }

  QueryBuilder<AutomationRuleEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
