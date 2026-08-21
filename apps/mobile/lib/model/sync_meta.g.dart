// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_meta.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncMetaCollection on Isar {
  IsarCollection<SyncMeta> get syncMetas => this.collection();
}

const SyncMetaSchema = CollectionSchema(
  name: r'SyncMeta',
  id: 7779218425528899915,
  properties: {
    r'cursor': PropertySchema(id: 0, name: r'cursor', type: IsarType.long),
    r'lastPulledAt': PropertySchema(
      id: 1,
      name: r'lastPulledAt',
      type: IsarType.dateTime,
    ),
    r'lastPushedAt': PropertySchema(
      id: 2,
      name: r'lastPushedAt',
      type: IsarType.dateTime,
    ),
    r'recoveryMode': PropertySchema(
      id: 3,
      name: r'recoveryMode',
      type: IsarType.bool,
    ),
    r'schemaVersion': PropertySchema(
      id: 4,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
  },

  estimateSize: _syncMetaEstimateSize,
  serialize: _syncMetaSerialize,
  deserialize: _syncMetaDeserialize,
  deserializeProp: _syncMetaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _syncMetaGetId,
  getLinks: _syncMetaGetLinks,
  attach: _syncMetaAttach,
  version: '3.3.2',
);

int _syncMetaEstimateSize(
  SyncMeta object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _syncMetaSerialize(
  SyncMeta object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cursor);
  writer.writeDateTime(offsets[1], object.lastPulledAt);
  writer.writeDateTime(offsets[2], object.lastPushedAt);
  writer.writeBool(offsets[3], object.recoveryMode);
  writer.writeLong(offsets[4], object.schemaVersion);
}

SyncMeta _syncMetaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncMeta();
  object.cursor = reader.readLong(offsets[0]);
  object.id = id;
  object.lastPulledAt = reader.readDateTimeOrNull(offsets[1]);
  object.lastPushedAt = reader.readDateTimeOrNull(offsets[2]);
  object.recoveryMode = reader.readBool(offsets[3]);
  object.schemaVersion = reader.readLong(offsets[4]);
  return object;
}

P _syncMetaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncMetaGetId(SyncMeta object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncMetaGetLinks(SyncMeta object) {
  return [];
}

void _syncMetaAttach(IsarCollection<dynamic> col, Id id, SyncMeta object) {
  object.id = id;
}

extension SyncMetaQueryWhereSort on QueryBuilder<SyncMeta, SyncMeta, QWhere> {
  QueryBuilder<SyncMeta, SyncMeta, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncMetaQueryWhere on QueryBuilder<SyncMeta, SyncMeta, QWhereClause> {
  QueryBuilder<SyncMeta, SyncMeta, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SyncMeta, SyncMeta, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SyncMetaQueryFilter
    on QueryBuilder<SyncMeta, SyncMeta, QFilterCondition> {
  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> cursorEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cursor', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> cursorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cursor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> cursorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cursor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> cursorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cursor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> lastPulledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastPulledAt'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  lastPulledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastPulledAt'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> lastPulledAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPulledAt', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  lastPulledAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPulledAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> lastPulledAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPulledAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> lastPulledAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPulledAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> lastPushedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastPushedAt'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  lastPushedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastPushedAt'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> lastPushedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPushedAt', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  lastPushedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPushedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> lastPushedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPushedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> lastPushedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPushedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> recoveryModeEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recoveryMode', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> schemaVersionEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schemaVersion', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  schemaVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> schemaVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'schemaVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SyncMetaQueryObject
    on QueryBuilder<SyncMeta, SyncMeta, QFilterCondition> {}

extension SyncMetaQueryLinks
    on QueryBuilder<SyncMeta, SyncMeta, QFilterCondition> {}

extension SyncMetaQuerySortBy on QueryBuilder<SyncMeta, SyncMeta, QSortBy> {
  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByLastPulledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByLastPulledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledAt', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByLastPushedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByLastPushedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByRecoveryMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryMode', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByRecoveryModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryMode', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }
}

extension SyncMetaQuerySortThenBy
    on QueryBuilder<SyncMeta, SyncMeta, QSortThenBy> {
  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByLastPulledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByLastPulledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledAt', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByLastPushedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByLastPushedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByRecoveryMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryMode', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByRecoveryModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryMode', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }
}

extension SyncMetaQueryWhereDistinct
    on QueryBuilder<SyncMeta, SyncMeta, QDistinct> {
  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctByCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cursor');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctByLastPulledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPulledAt');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctByLastPushedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPushedAt');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctByRecoveryMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recoveryMode');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }
}

extension SyncMetaQueryProperty
    on QueryBuilder<SyncMeta, SyncMeta, QQueryProperty> {
  QueryBuilder<SyncMeta, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncMeta, int, QQueryOperations> cursorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cursor');
    });
  }

  QueryBuilder<SyncMeta, DateTime?, QQueryOperations> lastPulledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPulledAt');
    });
  }

  QueryBuilder<SyncMeta, DateTime?, QQueryOperations> lastPushedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPushedAt');
    });
  }

  QueryBuilder<SyncMeta, bool, QQueryOperations> recoveryModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recoveryMode');
    });
  }

  QueryBuilder<SyncMeta, int, QQueryOperations> schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }
}
