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
  id: 5,
  properties: {
    r'enabled': PropertySchema(
      id: 0,
      name: r'enabled',
      type: IsarType.bool,
    ),
    r'idTasks': PropertySchema(
      id: 1,
      name: r'idTasks',
      type: IsarType.long,
    ),
    r'remindAt': PropertySchema(
      id: 2,
      name: r'remindAt',
      type: IsarType.dateTime,
    )
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
  version: '3.1.0+1',
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
  writer.writeLong(offsets[1], object.idTasks);
  writer.writeDateTime(offsets[2], object.remindAt);
}

Notification _notificationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Notification();
  object.enabled = reader.readBool(offsets[0]);
  object.idNotif = id;
  object.idTasks = reader.readLong(offsets[1]);
  object.remindAt = reader.readDateTime(offsets[2]);
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
      return (reader.readLong(offset)) as P;
    case 2:
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
    IsarCollection<dynamic> col, Id id, Notification object) {
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
      Id idNotif) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: idNotif,
        upper: idNotif,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterWhereClause> idNotifNotEqualTo(
      Id idNotif) {
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
      Id idNotif,
      {bool include = false}) {
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
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIdNotif,
        includeLower: includeLower,
        upper: upperIdNotif,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NotificationQueryFilter
    on QueryBuilder<Notification, Notification, QFilterCondition> {
  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      idNotifEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idNotif',
        value: value,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      idNotifGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idNotif',
        value: value,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      idNotifLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idNotif',
        value: value,
      ));
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
      return query.addFilterCondition(FilterCondition.between(
        property: r'idNotif',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      idTasksEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idTasks',
        value: value,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      idTasksGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idTasks',
        value: value,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      idTasksLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idTasks',
        value: value,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      idTasksBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idTasks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      remindAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remindAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      remindAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remindAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Notification, Notification, QAfterFilterCondition>
      remindAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remindAt',
        value: value,
      ));
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
      return query.addFilterCondition(FilterCondition.between(
        property: r'remindAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
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

  QueryBuilder<Notification, Notification, QAfterSortBy> sortByIdTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTasks', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> sortByIdTasksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTasks', Sort.desc);
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

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByIdTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTasks', Sort.asc);
    });
  }

  QueryBuilder<Notification, Notification, QAfterSortBy> thenByIdTasksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTasks', Sort.desc);
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

  QueryBuilder<Notification, Notification, QDistinct> distinctByIdTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idTasks');
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

  QueryBuilder<Notification, int, QQueryOperations> idTasksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idTasks');
    });
  }

  QueryBuilder<Notification, DateTime, QQueryOperations> remindAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remindAt');
    });
  }
}
