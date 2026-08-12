// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserSessionCollection on Isar {
  IsarCollection<UserSession> get userSessions => this.collection();
}

const UserSessionSchema = CollectionSchema(
  name: r'UserSession',
  id: -3071581603382586382,
  properties: {
    r'isLoggedIn': PropertySchema(
      id: 0,
      name: r'isLoggedIn',
      type: IsarType.bool,
    ),
    r'loginTime': PropertySchema(
      id: 1,
      name: r'loginTime',
      type: IsarType.dateTime,
    ),
    r'phoneNumber': PropertySchema(
      id: 2,
      name: r'phoneNumber',
      type: IsarType.string,
    ),
  },

  estimateSize: _userSessionEstimateSize,
  serialize: _userSessionSerialize,
  deserialize: _userSessionDeserialize,
  deserializeProp: _userSessionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _userSessionGetId,
  getLinks: _userSessionGetLinks,
  attach: _userSessionAttach,
  version: '3.3.2',
);

int _userSessionEstimateSize(
  UserSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.phoneNumber.length * 3;
  return bytesCount;
}

void _userSessionSerialize(
  UserSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isLoggedIn);
  writer.writeDateTime(offsets[1], object.loginTime);
  writer.writeString(offsets[2], object.phoneNumber);
}

UserSession _userSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserSession();
  object.id = id;
  object.isLoggedIn = reader.readBool(offsets[0]);
  object.loginTime = reader.readDateTime(offsets[1]);
  object.phoneNumber = reader.readString(offsets[2]);
  return object;
}

P _userSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userSessionGetId(UserSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userSessionGetLinks(UserSession object) {
  return [];
}

void _userSessionAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserSession object,
) {
  object.id = id;
}

extension UserSessionQueryWhereSort
    on QueryBuilder<UserSession, UserSession, QWhere> {
  QueryBuilder<UserSession, UserSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserSessionQueryWhere
    on QueryBuilder<UserSession, UserSession, QWhereClause> {
  QueryBuilder<UserSession, UserSession, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<UserSession, UserSession, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterWhereClause> idBetween(
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

extension UserSessionQueryFilter
    on QueryBuilder<UserSession, UserSession, QFilterCondition> {
  QueryBuilder<UserSession, UserSession, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  isLoggedInEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isLoggedIn', value: value),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  loginTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'loginTime', value: value),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  loginTimeGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'loginTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  loginTimeLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'loginTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  loginTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'loginTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  phoneNumberEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  phoneNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  phoneNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  phoneNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'phoneNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  phoneNumberStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  phoneNumberEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  phoneNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  phoneNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'phoneNumber',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  phoneNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'phoneNumber', value: ''),
      );
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterFilterCondition>
  phoneNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'phoneNumber', value: ''),
      );
    });
  }
}

extension UserSessionQueryObject
    on QueryBuilder<UserSession, UserSession, QFilterCondition> {}

extension UserSessionQueryLinks
    on QueryBuilder<UserSession, UserSession, QFilterCondition> {}

extension UserSessionQuerySortBy
    on QueryBuilder<UserSession, UserSession, QSortBy> {
  QueryBuilder<UserSession, UserSession, QAfterSortBy> sortByIsLoggedIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoggedIn', Sort.asc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> sortByIsLoggedInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoggedIn', Sort.desc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> sortByLoginTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginTime', Sort.asc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> sortByLoginTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginTime', Sort.desc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> sortByPhoneNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.asc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> sortByPhoneNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.desc);
    });
  }
}

extension UserSessionQuerySortThenBy
    on QueryBuilder<UserSession, UserSession, QSortThenBy> {
  QueryBuilder<UserSession, UserSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> thenByIsLoggedIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoggedIn', Sort.asc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> thenByIsLoggedInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoggedIn', Sort.desc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> thenByLoginTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginTime', Sort.asc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> thenByLoginTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginTime', Sort.desc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> thenByPhoneNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.asc);
    });
  }

  QueryBuilder<UserSession, UserSession, QAfterSortBy> thenByPhoneNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.desc);
    });
  }
}

extension UserSessionQueryWhereDistinct
    on QueryBuilder<UserSession, UserSession, QDistinct> {
  QueryBuilder<UserSession, UserSession, QDistinct> distinctByIsLoggedIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLoggedIn');
    });
  }

  QueryBuilder<UserSession, UserSession, QDistinct> distinctByLoginTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loginTime');
    });
  }

  QueryBuilder<UserSession, UserSession, QDistinct> distinctByPhoneNumber({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phoneNumber', caseSensitive: caseSensitive);
    });
  }
}

extension UserSessionQueryProperty
    on QueryBuilder<UserSession, UserSession, QQueryProperty> {
  QueryBuilder<UserSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserSession, bool, QQueryOperations> isLoggedInProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLoggedIn');
    });
  }

  QueryBuilder<UserSession, DateTime, QQueryOperations> loginTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loginTime');
    });
  }

  QueryBuilder<UserSession, String, QQueryOperations> phoneNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phoneNumber');
    });
  }
}
