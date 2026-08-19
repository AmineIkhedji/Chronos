// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEventCollection on Isar {
  IsarCollection<Event> get events => this.collection();
}

const EventSchema = CollectionSchema(
  name: r'Event',
  id: 3,
  properties: {
    r'idTasks': PropertySchema(
      id: 0,
      name: r'idTasks',
      type: IsarType.long,
    )
  },
  estimateSize: _eventEstimateSize,
  serialize: _eventSerialize,
  deserialize: _eventDeserialize,
  deserializeProp: _eventDeserializeProp,
  idName: r'idEvent',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _eventGetId,
  getLinks: _eventGetLinks,
  attach: _eventAttach,
  version: '3.1.0+1',
);

int _eventEstimateSize(
  Event object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _eventSerialize(
  Event object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.idTasks);
}

Event _eventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Event();
  object.idEvent = id;
  object.idTasks = reader.readLong(offsets[0]);
  return object;
}

P _eventDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _eventGetId(Event object) {
  return object.idEvent;
}

List<IsarLinkBase<dynamic>> _eventGetLinks(Event object) {
  return [];
}

void _eventAttach(IsarCollection<dynamic> col, Id id, Event object) {
  object.idEvent = id;
}

extension EventQueryWhereSort on QueryBuilder<Event, Event, QWhere> {
  QueryBuilder<Event, Event, QAfterWhere> anyIdEvent() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EventQueryWhere on QueryBuilder<Event, Event, QWhereClause> {
  QueryBuilder<Event, Event, QAfterWhereClause> idEventEqualTo(Id idEvent) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: idEvent,
        upper: idEvent,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> idEventNotEqualTo(Id idEvent) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: idEvent, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: idEvent, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: idEvent, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: idEvent, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> idEventGreaterThan(Id idEvent,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: idEvent, includeLower: include),
      );
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> idEventLessThan(Id idEvent,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: idEvent, includeUpper: include),
      );
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> idEventBetween(
    Id lowerIdEvent,
    Id upperIdEvent, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIdEvent,
        includeLower: includeLower,
        upper: upperIdEvent,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EventQueryFilter on QueryBuilder<Event, Event, QFilterCondition> {
  QueryBuilder<Event, Event, QAfterFilterCondition> idEventEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idEvent',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> idEventGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idEvent',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> idEventLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idEvent',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> idEventBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idEvent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> idTasksEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idTasks',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> idTasksGreaterThan(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> idTasksLessThan(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> idTasksBetween(
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
}

extension EventQueryObject on QueryBuilder<Event, Event, QFilterCondition> {}

extension EventQueryLinks on QueryBuilder<Event, Event, QFilterCondition> {}

extension EventQuerySortBy on QueryBuilder<Event, Event, QSortBy> {
  QueryBuilder<Event, Event, QAfterSortBy> sortByIdTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTasks', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByIdTasksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTasks', Sort.desc);
    });
  }
}

extension EventQuerySortThenBy on QueryBuilder<Event, Event, QSortThenBy> {
  QueryBuilder<Event, Event, QAfterSortBy> thenByIdEvent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idEvent', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByIdEventDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idEvent', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByIdTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTasks', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByIdTasksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idTasks', Sort.desc);
    });
  }
}

extension EventQueryWhereDistinct on QueryBuilder<Event, Event, QDistinct> {
  QueryBuilder<Event, Event, QDistinct> distinctByIdTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idTasks');
    });
  }
}

extension EventQueryProperty on QueryBuilder<Event, Event, QQueryProperty> {
  QueryBuilder<Event, int, QQueryOperations> idEventProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idEvent');
    });
  }

  QueryBuilder<Event, int, QQueryOperations> idTasksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idTasks');
    });
  }
}
