// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReminderCollection on Isar {
  IsarCollection<Reminder> get reminders => this.collection();
}

const ReminderSchema = CollectionSchema(
  name: r'Reminder',
  id: -8566764253612256045,
  properties: {
    r'body': PropertySchema(
      id: 0,
      name: r'body',
      type: IsarType.string,
    ),
    r'bookmarkId': PropertySchema(
      id: 1,
      name: r'bookmarkId',
      type: IsarType.long,
    ),
    r'completedAt': PropertySchema(
      id: 2,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'notificationId': PropertySchema(
      id: 4,
      name: r'notificationId',
      type: IsarType.string,
    ),
    r'repeatMode': PropertySchema(
      id: 5,
      name: r'repeatMode',
      type: IsarType.string,
    ),
    r'repeatRule': PropertySchema(
      id: 6,
      name: r'repeatRule',
      type: IsarType.string,
    ),
    r'scheduledAt': PropertySchema(
      id: 7,
      name: r'scheduledAt',
      type: IsarType.dateTime,
    ),
    r'snoozedUntil': PropertySchema(
      id: 8,
      name: r'snoozedUntil',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.string,
    ),
    r'timezone': PropertySchema(
      id: 10,
      name: r'timezone',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 11,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _reminderEstimateSize,
  serialize: _reminderSerialize,
  deserialize: _reminderDeserialize,
  deserializeProp: _reminderDeserializeProp,
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
    ),
    r'scheduledAt': IndexSchema(
      id: -1483275037155116518,
      name: r'scheduledAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'scheduledAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _reminderGetId,
  getLinks: _reminderGetLinks,
  attach: _reminderAttach,
  version: '3.1.0+1',
);

int _reminderEstimateSize(
  Reminder object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.body;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notificationId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.repeatMode.length * 3;
  {
    final value = object.repeatRule;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.timezone.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _reminderSerialize(
  Reminder object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.body);
  writer.writeLong(offsets[1], object.bookmarkId);
  writer.writeDateTime(offsets[2], object.completedAt);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.notificationId);
  writer.writeString(offsets[5], object.repeatMode);
  writer.writeString(offsets[6], object.repeatRule);
  writer.writeDateTime(offsets[7], object.scheduledAt);
  writer.writeDateTime(offsets[8], object.snoozedUntil);
  writer.writeString(offsets[9], object.status);
  writer.writeString(offsets[10], object.timezone);
  writer.writeString(offsets[11], object.title);
}

Reminder _reminderDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Reminder(
    body: reader.readStringOrNull(offsets[0]),
    bookmarkId: reader.readLong(offsets[1]),
    completedAt: reader.readDateTimeOrNull(offsets[2]),
    createdAt: reader.readDateTime(offsets[3]),
    notificationId: reader.readStringOrNull(offsets[4]),
    repeatMode: reader.readStringOrNull(offsets[5]) ?? 'none',
    repeatRule: reader.readStringOrNull(offsets[6]),
    scheduledAt: reader.readDateTime(offsets[7]),
    snoozedUntil: reader.readDateTimeOrNull(offsets[8]),
    status: reader.readStringOrNull(offsets[9]) ?? 'pending',
    timezone: reader.readString(offsets[10]),
    title: reader.readString(offsets[11]),
  );
  object.id = id;
  return object;
}

P _reminderDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? 'none') as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset) ?? 'pending') as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reminderGetId(Reminder object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reminderGetLinks(Reminder object) {
  return [];
}

void _reminderAttach(IsarCollection<dynamic> col, Id id, Reminder object) {
  object.id = id;
}

extension ReminderQueryWhereSort on QueryBuilder<Reminder, Reminder, QWhere> {
  QueryBuilder<Reminder, Reminder, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhere> anyBookmarkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookmarkId'),
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhere> anyScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'scheduledAt'),
      );
    });
  }
}

extension ReminderQueryWhere on QueryBuilder<Reminder, Reminder, QWhereClause> {
  QueryBuilder<Reminder, Reminder, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> idBetween(
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

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> bookmarkIdEqualTo(
      int bookmarkId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookmarkId',
        value: [bookmarkId],
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> bookmarkIdNotEqualTo(
      int bookmarkId) {
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

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> bookmarkIdGreaterThan(
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

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> bookmarkIdLessThan(
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

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> bookmarkIdBetween(
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

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> scheduledAtEqualTo(
      DateTime scheduledAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'scheduledAt',
        value: [scheduledAt],
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> scheduledAtNotEqualTo(
      DateTime scheduledAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledAt',
              lower: [],
              upper: [scheduledAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledAt',
              lower: [scheduledAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledAt',
              lower: [scheduledAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledAt',
              lower: [],
              upper: [scheduledAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> scheduledAtGreaterThan(
    DateTime scheduledAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledAt',
        lower: [scheduledAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> scheduledAtLessThan(
    DateTime scheduledAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledAt',
        lower: [],
        upper: [scheduledAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> scheduledAtBetween(
    DateTime lowerScheduledAt,
    DateTime upperScheduledAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledAt',
        lower: [lowerScheduledAt],
        includeLower: includeLower,
        upper: [upperScheduledAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReminderQueryFilter
    on QueryBuilder<Reminder, Reminder, QFilterCondition> {
  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'body',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'body',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'body',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'body',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bookmarkIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookmarkId',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bookmarkIdGreaterThan(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bookmarkIdLessThan(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> bookmarkIdBetween(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> completedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      notificationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notificationId',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      notificationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notificationId',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> notificationIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      notificationIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      notificationIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> notificationIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      notificationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      notificationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      notificationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> notificationIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notificationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      notificationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationId',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      notificationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notificationId',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatModeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatModeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'repeatMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatMode',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      repeatModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'repeatMode',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatRuleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'repeatRule',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      repeatRuleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'repeatRule',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatRuleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatRuleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatRuleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatRuleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatRule',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatRuleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'repeatRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatRuleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'repeatRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatRuleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'repeatRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatRuleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'repeatRule',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> repeatRuleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatRule',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      repeatRuleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'repeatRule',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> scheduledAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      scheduledAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> scheduledAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> scheduledAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> snoozedUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'snoozedUntil',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      snoozedUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'snoozedUntil',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> snoozedUntilEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snoozedUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      snoozedUntilGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'snoozedUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> snoozedUntilLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'snoozedUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> snoozedUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'snoozedUntil',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> timezoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> timezoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> timezoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> timezoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timezone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> timezoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> timezoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> timezoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> timezoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'timezone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> timezoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timezone',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> timezoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'timezone',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> titleContains(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension ReminderQueryObject
    on QueryBuilder<Reminder, Reminder, QFilterCondition> {}

extension ReminderQueryLinks
    on QueryBuilder<Reminder, Reminder, QFilterCondition> {}

extension ReminderQuerySortBy on QueryBuilder<Reminder, Reminder, QSortBy> {
  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByBookmarkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkId', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByBookmarkIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkId', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByNotificationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByRepeatModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByRepeatRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatRule', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByRepeatRuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatRule', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByScheduledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortBySnoozedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozedUntil', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortBySnoozedUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozedUntil', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByTimezone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByTimezoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension ReminderQuerySortThenBy
    on QueryBuilder<Reminder, Reminder, QSortThenBy> {
  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByBookmarkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkId', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByBookmarkIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkId', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByNotificationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByRepeatModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByRepeatRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatRule', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByRepeatRuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatRule', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByScheduledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenBySnoozedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozedUntil', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenBySnoozedUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozedUntil', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByTimezone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByTimezoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension ReminderQueryWhereDistinct
    on QueryBuilder<Reminder, Reminder, QDistinct> {
  QueryBuilder<Reminder, Reminder, QDistinct> distinctByBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'body', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByBookmarkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookmarkId');
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByNotificationId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByRepeatMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByRepeatRule(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatRule', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledAt');
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctBySnoozedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snoozedUntil');
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByTimezone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timezone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension ReminderQueryProperty
    on QueryBuilder<Reminder, Reminder, QQueryProperty> {
  QueryBuilder<Reminder, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Reminder, String?, QQueryOperations> bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'body');
    });
  }

  QueryBuilder<Reminder, int, QQueryOperations> bookmarkIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookmarkId');
    });
  }

  QueryBuilder<Reminder, DateTime?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<Reminder, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Reminder, String?, QQueryOperations> notificationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationId');
    });
  }

  QueryBuilder<Reminder, String, QQueryOperations> repeatModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatMode');
    });
  }

  QueryBuilder<Reminder, String?, QQueryOperations> repeatRuleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatRule');
    });
  }

  QueryBuilder<Reminder, DateTime, QQueryOperations> scheduledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledAt');
    });
  }

  QueryBuilder<Reminder, DateTime?, QQueryOperations> snoozedUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snoozedUntil');
    });
  }

  QueryBuilder<Reminder, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Reminder, String, QQueryOperations> timezoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timezone');
    });
  }

  QueryBuilder<Reminder, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
