// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'priority.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPriorityCollection on Isar {
  IsarCollection<Priority> get prioritys => this.collection();
}

const PrioritySchema = CollectionSchema(
  name: r'Priority',
  id: 6,
  properties: {
    r'color': PropertySchema(
      id: 0,
      name: r'color',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _priorityEstimateSize,
  serialize: _prioritySerialize,
  deserialize: _priorityDeserialize,
  deserializeProp: _priorityDeserializeProp,
  idName: r'idPriorities',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _priorityGetId,
  getLinks: _priorityGetLinks,
  attach: _priorityAttach,
  version: '3.1.0+1',
);

int _priorityEstimateSize(
  Priority object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _prioritySerialize(
  Priority object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.color);
  writer.writeString(offsets[1], object.name);
}

Priority _priorityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Priority();
  object.color = reader.readLong(offsets[0]);
  object.idPriorities = id;
  object.name = reader.readString(offsets[1]);
  return object;
}

P _priorityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _priorityGetId(Priority object) {
  return object.idPriorities;
}

List<IsarLinkBase<dynamic>> _priorityGetLinks(Priority object) {
  return [];
}

void _priorityAttach(IsarCollection<dynamic> col, Id id, Priority object) {
  object.idPriorities = id;
}

extension PriorityQueryWhereSort on QueryBuilder<Priority, Priority, QWhere> {
  QueryBuilder<Priority, Priority, QAfterWhere> anyIdPriorities() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PriorityQueryWhere on QueryBuilder<Priority, Priority, QWhereClause> {
  QueryBuilder<Priority, Priority, QAfterWhereClause> idPrioritiesEqualTo(
      Id idPriorities) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: idPriorities,
        upper: idPriorities,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterWhereClause> idPrioritiesNotEqualTo(
      Id idPriorities) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: idPriorities, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(
                  lower: idPriorities, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(
                  lower: idPriorities, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: idPriorities, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Priority, Priority, QAfterWhereClause> idPrioritiesGreaterThan(
      Id idPriorities,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: idPriorities, includeLower: include),
      );
    });
  }

  QueryBuilder<Priority, Priority, QAfterWhereClause> idPrioritiesLessThan(
      Id idPriorities,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: idPriorities, includeUpper: include),
      );
    });
  }

  QueryBuilder<Priority, Priority, QAfterWhereClause> idPrioritiesBetween(
    Id lowerIdPriorities,
    Id upperIdPriorities, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIdPriorities,
        includeLower: includeLower,
        upper: upperIdPriorities,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PriorityQueryFilter
    on QueryBuilder<Priority, Priority, QFilterCondition> {
  QueryBuilder<Priority, Priority, QAfterFilterCondition> colorEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: value,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition> colorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'color',
        value: value,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition> colorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'color',
        value: value,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition> colorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'color',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition> idPrioritiesEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idPriorities',
        value: value,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition>
      idPrioritiesGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idPriorities',
        value: value,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition> idPrioritiesLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idPriorities',
        value: value,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition> idPrioritiesBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idPriorities',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<Priority, Priority, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<Priority, Priority, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<Priority, Priority, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<Priority, Priority, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<Priority, Priority, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<Priority, Priority, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Priority, Priority, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension PriorityQueryObject
    on QueryBuilder<Priority, Priority, QFilterCondition> {}

extension PriorityQueryLinks
    on QueryBuilder<Priority, Priority, QFilterCondition> {}

extension PriorityQuerySortBy on QueryBuilder<Priority, Priority, QSortBy> {
  QueryBuilder<Priority, Priority, QAfterSortBy> sortByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.asc);
    });
  }

  QueryBuilder<Priority, Priority, QAfterSortBy> sortByColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.desc);
    });
  }

  QueryBuilder<Priority, Priority, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Priority, Priority, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension PriorityQuerySortThenBy
    on QueryBuilder<Priority, Priority, QSortThenBy> {
  QueryBuilder<Priority, Priority, QAfterSortBy> thenByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.asc);
    });
  }

  QueryBuilder<Priority, Priority, QAfterSortBy> thenByColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.desc);
    });
  }

  QueryBuilder<Priority, Priority, QAfterSortBy> thenByIdPriorities() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idPriorities', Sort.asc);
    });
  }

  QueryBuilder<Priority, Priority, QAfterSortBy> thenByIdPrioritiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idPriorities', Sort.desc);
    });
  }

  QueryBuilder<Priority, Priority, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Priority, Priority, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension PriorityQueryWhereDistinct
    on QueryBuilder<Priority, Priority, QDistinct> {
  QueryBuilder<Priority, Priority, QDistinct> distinctByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'color');
    });
  }

  QueryBuilder<Priority, Priority, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension PriorityQueryProperty
    on QueryBuilder<Priority, Priority, QQueryProperty> {
  QueryBuilder<Priority, int, QQueryOperations> idPrioritiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idPriorities');
    });
  }

  QueryBuilder<Priority, int, QQueryOperations> colorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'color');
    });
  }

  QueryBuilder<Priority, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
