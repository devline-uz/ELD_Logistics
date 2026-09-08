// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_user_role.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_company =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum._(
        'company');
const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_branch =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum._(
        'branch');
const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_self =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum._(
        'self');
const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum._(
        'unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnumValueOf(
        String name) {
  switch (name) {
    case 'company':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_company;
    case 'branch':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_branch;
    case 'self':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_self;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum>(const <GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum>[
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_company,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_branch,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_self,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum> {
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
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole {
  @override
  final String? id;
  @override
  final bool? isSystem;
  @override
  final String? name;
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum?
      scope;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole._(
      {this.id, this.isSystem, this.name, this.scope})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole &&
        id == other.id &&
        isSystem == other.isSystem &&
        name == other.name &&
        scope == other.scope;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, isSystem.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole')
          ..add('id', id)
          ..add('isSystem', isSystem)
          ..add('name', name)
          ..add('scope', scope))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole,
            GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _isSystem;
  bool? get isSystem => _$this._isSystem;
  set isSystem(bool? isSystem) => _$this._isSystem = isSystem;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum? _scope;
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum?
      get scope => _$this._scope;
  set scope(
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum?
              scope) =>
      _$this._scope = scope;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _isSystem = $v.isSystem;
      _name = $v.name;
      _scope = $v.scope;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole._(
          id: id,
          isSystem: isSystem,
          name: name,
          scope: scope,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
