// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotificationCollection on Isar {
  IsarCollection<Notification> get notifications => this.collection();
}

const NotificationSchema = CollectionSchema(
  name: r'Notification',
  id: -4128487677257470820,
  properties: {
    r'enabled': PropertySchema(id: 0, name: r'enabled', type: IsarType.bool),
    r'idHabit': PropertySchema(id: 1, name: r'idHabit', type: IsarType.long),
    r'idTask': PropertySchema(id: 2, name: r'idTask', type: IsarType.long),
    r'remindAt': PropertySchema(
      id: 3,
      name: r'remindAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _notificationEstimateSize,
  serialize: _notificationSerialize,
  deserialize: _notificationDeserialize,
  deserializeProp: _notificationDeserializeProp,
  idName: r'idNotif',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _notificationGetId,
  getLinks: _notificationGetLinks,
  attach: _notificationAttach,
  version: '3.3.2',
);

int _notificationEstimateSize(
  Notification object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _notificationSerialize(
  Notification object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.enabled);
  writer.writeLong(offsets[1], object.idHabit);
  writer.writeLong(offsets[2], object.idTask);
  writer.writeDateTime(offsets[3], object.remindAt);
}

Notification _notificationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Notification();
  object.enabled = reader.readBool(offsets[0]);
  object.idHabit = reader.readLongOrNull(offsets[1]);
  object.idNotif = id;
  object.idTask = reader.readLongOrNull(offsets[2]);
  object.remindAt = reader.readDateTime(offsets[3]);
  return object;
}

P _notificationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _notificationGetId(Notification object) {
  return object.idNotif;
}

List<IsarLinkBase<dynamic>> _notificationGetLinks(Notification object) {
  return [];
}

void _notificationAttach(
  IsarCollection<dynamic> col,
  Id id,
  Notification object,
) {
  object.idNotif = id;
}

extension NotificationQueryWhereSort
    on QueryBuilder<Notification, Notification, QWhere> {
  QueryBuilder<Notification, Notification, QAfterWhere> anyIdNotif() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NotificationQueryWhere
    on QueryBuilder<Notification, Notification, QWhereClause> {
  QueryBuilder<Notification, Notification, QAfterWhereClause> idNotifEqualTo(
    Id idNotif,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: idNotif, upper: idNotif),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterWhereClause> idNotifNotEqualTo(
    Id idNotif,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: idNotif, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: idNotif, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: idNotif, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: idNotif, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Notification, Notification, QAfterWhereClause>
  idNotifGreaterThan(Id idNotif, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: idNotif, includeLower: include),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterWhereClause> idNotifLessThan(
    Id idNotif, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: idNotif, includeUpper: include),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterWhereClause> idNotifBetween(
    Id lowerIdNotif,
    Id upperIdNotif, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIdNotif,
          includeLower: includeLower,
          upper: upperIdNotif,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension NotificationQueryFilter
    on QueryBuilder<Notification, Notification, QFilterCondition> {
  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enabled', value: value),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idHabitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'idHabit'),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idHabitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'idHabit'),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idHabitEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'idHabit', value: value),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idHabitGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'idHabit',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idHabitLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'idHabit',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idHabitBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'idHabit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idNotifEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'idNotif', value: value),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idNotifGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'idNotif',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idNotifLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'idNotif',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idNotifBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'idNotif',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idTaskIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'idTask'),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idTaskIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'idTask'),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition> idTaskEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'idTask', value: value),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idTaskGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'idTask',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  idTaskLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'idTask',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition> idTaskBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'idTask',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  remindAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remindAt', value: value),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  remindAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remindAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  remindAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remindAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
  remindAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remindAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension NotificationQueryObject
    on QueryBuilder<Notification, Notification, QFilterCondition> {}

extension NotificationQueryLinks
    on QueryBuilder<Notification, Notification, QFilterCondition> {}

extension NotificationQuerySortBy
    on QueryBuilder<Notification, Notification, QSortBy> {
  QueryBuilder<Notification, Notification, QAfterSortBy> sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> sortByIdHabit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idHabit', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> sortByIdHabitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idHabit', Sort.desc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> sortByIdTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTask', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> sortByIdTaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTask', Sort.desc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> sortByRemindAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remindAt', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> sortByRemindAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remindAt', Sort.desc);
    });
  }
}

extension NotificationQuerySortThenBy
    on QueryBuilder<Notification, Notification, QSortThenBy> {
  QueryBuilder<Notification, Notification, QAfterSortBy> thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByIdHabit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idHabit', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByIdHabitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idHabit', Sort.desc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByIdNotif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idNotif', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByIdNotifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idNotif', Sort.desc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByIdTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTask', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByIdTaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTask', Sort.desc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByRemindAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remindAt', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByRemindAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remindAt', Sort.desc);
    });
  }
}

extension NotificationQueryWhereDistinct
    on QueryBuilder<Notification, Notification, QDistinct> {
  QueryBuilder<Notification, Notification, QDistinct> distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<Notification, Notification, QDistinct> distinctByIdHabit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idHabit');
    });
  }

  QueryBuilder<Notification, Notification, QDistinct> distinctByIdTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idTask');
    });
  }

  QueryBuilder<Notification, Notification, QDistinct> distinctByRemindAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remindAt');
    });
  }
}

extension NotificationQueryProperty
    on QueryBuilder<Notification, Notification, QQueryProperty> {
  QueryBuilder<Notification, int, QQueryOperations> idNotifProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idNotif');
    });
  }

  QueryBuilder<Notification, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<Notification, int?, QQueryOperations> idHabitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idHabit');
    });
  }

  QueryBuilder<Notification, int?, QQueryOperations> idTaskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idTask');
    });
  }

  QueryBuilder<Notification, DateTime, QQueryOperations> remindAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remindAt');
    });
  }
}
