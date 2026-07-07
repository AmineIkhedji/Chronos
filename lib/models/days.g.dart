// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'days.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDaysCollection on Isar {
  IsarCollection<Days> get days => this.collection();
}

const DaysSchema = CollectionSchema(
  name: r'Days',
  id: 1846955126293866979,
  properties: {
    r'dayOfWeek': PropertySchema(
      id: 0,
      name: r'dayOfWeek',
      type: IsarType.long,
    ),
    r'idHabit': PropertySchema(
      id: 1,
      name: r'idHabit',
      type: IsarType.long,
    )
  },
  estimateSize: _daysEstimateSize,
  serialize: _daysSerialize,
  deserialize: _daysDeserialize,
  deserializeProp: _daysDeserializeProp,
  idName: r'idDay',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _daysGetId,
  getLinks: _daysGetLinks,
  attach: _daysAttach,
  version: '3.1.0+1',
);

int _daysEstimateSize(
  Days object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _daysSerialize(
  Days object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.dayOfWeek);
  writer.writeLong(offsets[1], object.idHabit);
}

Days _daysDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Days();
  object.dayOfWeek = reader.readLong(offsets[0]);
  object.idDay = id;
  object.idHabit = reader.readLong(offsets[1]);
  return object;
}

P _daysDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _daysGetId(Days object) {
  return object.idDay;
}

List<IsarLinkBase<dynamic>> _daysGetLinks(Days object) {
  return [];
}

void _daysAttach(IsarCollection<dynamic> col, Id id, Days object) {
  object.idDay = id;
}

extension DaysQueryWhereSort on QueryBuilder<Days, Days, QWhere> {
  QueryBuilder<Days, Days, QAfterWhere> anyIdDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DaysQueryWhere on QueryBuilder<Days, Days, QWhereClause> {
  QueryBuilder<Days, Days, QAfterWhereClause> idDayEqualTo(Id idDay) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: idDay,
        upper: idDay,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterWhereClause> idDayNotEqualTo(Id idDay) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: idDay, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: idDay, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: idDay, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: idDay, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Days, Days, QAfterWhereClause> idDayGreaterThan(Id idDay,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: idDay, includeLower: include),
      );
    });
  }

  QueryBuilder<Days, Days, QAfterWhereClause> idDayLessThan(Id idDay,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: idDay, includeUpper: include),
      );
    });
  }

  QueryBuilder<Days, Days, QAfterWhereClause> idDayBetween(
    Id lowerIdDay,
    Id upperIdDay, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIdDay,
        includeLower: includeLower,
        upper: upperIdDay,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DaysQueryFilter on QueryBuilder<Days, Days, QFilterCondition> {
  QueryBuilder<Days, Days, QAfterFilterCondition> dayOfWeekEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> dayOfWeekGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> dayOfWeekLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> dayOfWeekBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dayOfWeek',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> idDayEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idDay',
        value: value,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> idDayGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idDay',
        value: value,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> idDayLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idDay',
        value: value,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> idDayBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> idHabitEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idHabit',
        value: value,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> idHabitGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idHabit',
        value: value,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> idHabitLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idHabit',
        value: value,
      ));
    });
  }

  QueryBuilder<Days, Days, QAfterFilterCondition> idHabitBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idHabit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DaysQueryObject on QueryBuilder<Days, Days, QFilterCondition> {}

extension DaysQueryLinks on QueryBuilder<Days, Days, QFilterCondition> {}

extension DaysQuerySortBy on QueryBuilder<Days, Days, QSortBy> {
  QueryBuilder<Days, Days, QAfterSortBy> sortByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.asc);
    });
  }

  QueryBuilder<Days, Days, QAfterSortBy> sortByDayOfWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.desc);
    });
  }

  QueryBuilder<Days, Days, QAfterSortBy> sortByIdHabit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idHabit', Sort.asc);
    });
  }

  QueryBuilder<Days, Days, QAfterSortBy> sortByIdHabitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idHabit', Sort.desc);
    });
  }
}

extension DaysQuerySortThenBy on QueryBuilder<Days, Days, QSortThenBy> {
  QueryBuilder<Days, Days, QAfterSortBy> thenByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.asc);
    });
  }

  QueryBuilder<Days, Days, QAfterSortBy> thenByDayOfWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.desc);
    });
  }

  QueryBuilder<Days, Days, QAfterSortBy> thenByIdDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idDay', Sort.asc);
    });
  }

  QueryBuilder<Days, Days, QAfterSortBy> thenByIdDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idDay', Sort.desc);
    });
  }

  QueryBuilder<Days, Days, QAfterSortBy> thenByIdHabit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idHabit', Sort.asc);
    });
  }

  QueryBuilder<Days, Days, QAfterSortBy> thenByIdHabitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idHabit', Sort.desc);
    });
  }
}

extension DaysQueryWhereDistinct on QueryBuilder<Days, Days, QDistinct> {
  QueryBuilder<Days, Days, QDistinct> distinctByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dayOfWeek');
    });
  }

  QueryBuilder<Days, Days, QDistinct> distinctByIdHabit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idHabit');
    });
  }
}

extension DaysQueryProperty on QueryBuilder<Days, Days, QQueryProperty> {
  QueryBuilder<Days, int, QQueryOperations> idDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idDay');
    });
  }

  QueryBuilder<Days, int, QQueryOperations> dayOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dayOfWeek');
    });
  }

  QueryBuilder<Days, int, QQueryOperations> idHabitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idHabit');
    });
  }
}
