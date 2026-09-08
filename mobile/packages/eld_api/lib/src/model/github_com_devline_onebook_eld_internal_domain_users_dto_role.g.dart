// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_role.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_company =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum._(
        'company');
const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_branch =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum._(
        'branch');
const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_self =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum._(
        'self');
const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum._(
        'unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnumValueOf(
        String name) {
  switch (name) {
    case 'company':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_company;
    case 'branch':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_branch;
    case 'self':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_self;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum>(const <GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum>[
  _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_company,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_branch,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_self,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'company': 'company',
    'branch': 'branch',
    'self': 'self',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'company': 'company',
    'branch': 'branch',
    'self': 'self',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum';

  @override
  Object serialize(Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRole
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoRole {
  @override
  final DateTime? createdAt;
  @override
  final String? description;
  @override
  final String? id;
  @override
  final bool? isSystem;
  @override
  final String? name;
  @override
  final BuiltList<String>? permissions;
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum? scope;
  @override
  final DateTime? updatedAt;
  @override
  final int? userCount;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoRole(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRole._(
      {this.createdAt,
      this.description,
      this.id,
      this.isSystem,
      this.name,
      this.permissions,
      this.scope,
      this.updatedAt,
      this.userCount})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRole rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainUsersDtoRole &&
        createdAt == other.createdAt &&
        description == other.description &&
        id == other.id &&
        isSystem == other.isSystem &&
        name == other.name &&
        permissions == other.permissions &&
        scope == other.scope &&
        updatedAt == other.updatedAt &&
        userCount == other.userCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, isSystem.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, permissions.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, userCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoRole')
          ..add('createdAt', createdAt)
          ..add('description', description)
          ..add('id', id)
          ..add('isSystem', isSystem)
          ..add('name', name)
          ..add('permissions', permissions)
          ..add('scope', scope)
          ..add('updatedAt', updatedAt)
          ..add('userCount', userCount))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainUsersDtoRole,
            GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRole? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _isSystem;
  bool? get isSystem => _$this._isSystem;
  set isSystem(bool? isSystem) => _$this._isSystem = isSystem;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ListBuilder<String>? _permissions;
  ListBuilder<String> get permissions =>
      _$this._permissions ??= ListBuilder<String>();
  set permissions(ListBuilder<String>? permissions) =>
      _$this._permissions = permissions;

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum? _scope;
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum? get scope =>
      _$this._scope;
  set scope(
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum?
              scope) =>
      _$this._scope = scope;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _userCount;
  int? get userCount => _$this._userCount;
  set userCount(int? userCount) => _$this._userCount = userCount;

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoRole._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _description = $v.description;
      _id = $v.id;
      _isSystem = $v.isSystem;
      _name = $v.name;
      _permissions = $v.permissions?.toBuilder();
      _scope = $v.scope;
      _updatedAt = $v.updatedAt;
      _userCount = $v.userCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainUsersDtoRole other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainUsersDtoRole;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRole build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRole _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoRole _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoRole._(
            createdAt: createdAt,
            description: description,
            id: id,
            isSystem: isSystem,
            name: name,
            permissions: _permissions?.build(),
            scope: scope,
            updatedAt: updatedAt,
            userCount: userCount,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'permissions';
        _permissions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoRole',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
