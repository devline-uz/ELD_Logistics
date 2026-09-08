// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_role_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_company =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum._(
        'company');
const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_branch =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum._(
        'branch');
const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum._(
        'unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnumValueOf(
        String name) {
  switch (name) {
    case 'company':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_company;
    case 'branch':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_branch;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum>(const <GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum>[
  _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_company,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_branch,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum> {
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
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate {
  @override
  final String? description;
  @override
  final String name;
  @override
  final BuiltList<String> permissions;
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum
      scope;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate._(
      {this.description,
      required this.name,
      required this.permissions,
      required this.scope})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate &&
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
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate')
          ..add('description', description)
          ..add('name', name)
          ..add('permissions', permissions)
          ..add('scope', scope))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate,
            GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate? _$v;

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

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum? _scope;
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum?
      get scope => _$this._scope;
  set scope(
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum?
              scope) =>
      _$this._scope = scope;

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder get _$this {
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
      GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate._(
            description: description,
            name: BuiltValueNullFieldError.checkNotNull(
                name,
                r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate',
                'name'),
            permissions: permissions.build(),
            scope: BuiltValueNullFieldError.checkNotNull(
                scope,
                r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate',
                'scope'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'permissions';
        permissions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate',
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
