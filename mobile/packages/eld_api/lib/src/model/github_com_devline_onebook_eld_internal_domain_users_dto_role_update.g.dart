// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_role_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_company =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum._(
        'company');
const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_branch =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum._(
        'branch');
const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum._(
        'unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnumValueOf(
        String name) {
  switch (name) {
    case 'company':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_company;
    case 'branch':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_branch;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum>(const <GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum>[
  _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_company,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_branch,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'company': 'company',
    'branch': 'branch',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'company': 'company',
    'branch': 'branch',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate {
  @override
  final String? description;
  @override
  final String? name;
  @override
  final BuiltList<String> permissions;
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum?
      scope;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate._(
      {this.description, this.name, required this.permissions, this.scope})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate &&
        description == other.description &&
        name == other.name &&
        permissions == other.permissions &&
        scope == other.scope;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, permissions.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate')
          ..add('description', description)
          ..add('name', name)
          ..add('permissions', permissions)
          ..add('scope', scope))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate,
            GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate? _$v;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ListBuilder<String>? _permissions;
  ListBuilder<String> get permissions =>
      _$this._permissions ??= ListBuilder<String>();
  set permissions(ListBuilder<String>? permissions) =>
      _$this._permissions = permissions;

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum? _scope;
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum?
      get scope => _$this._scope;
  set scope(
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum?
              scope) =>
      _$this._scope = scope;

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _description = $v.description;
      _name = $v.name;
      _permissions = $v.permissions.toBuilder();
      _scope = $v.scope;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate._(
            description: description,
            name: name,
            permissions: permissions.build(),
            scope: scope,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'permissions';
        permissions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate',
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
