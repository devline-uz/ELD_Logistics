// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_invited =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum._(
        'invited');
const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_active =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum._(
        'active');
const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_inactive =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum._(
        'inactive');
const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum._(
        'unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'invited':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_invited;
    case 'active':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_active;
    case 'inactive':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_inactive;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_invited,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_active,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_inactive,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'invited': 'invited',
    'active': 'active',
    'inactive': 'inactive',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'invited': 'invited',
    'active': 'active',
    'inactive': 'inactive',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum';

  @override
  Object serialize(Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUser
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoUser {
  @override
  final DateTime? activatedAt;
  @override
  final String? branchId;
  @override
  final String? branchName;
  @override
  final DateTime? createdAt;
  @override
  final String? email;
  @override
  final String? firstName;
  @override
  final String? fullName;
  @override
  final String? id;
  @override
  final DateTime? invitedAt;
  @override
  final DateTime? lastLoginAt;
  @override
  final String? lastName;
  @override
  final String? phone;
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole? role;
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum? status;
  @override
  final bool? totpEnabled;
  @override
  final DateTime? updatedAt;
  @override
  final String? username;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoUser(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUser._(
      {this.activatedAt,
      this.branchId,
      this.branchName,
      this.createdAt,
      this.email,
      this.firstName,
      this.fullName,
      this.id,
      this.invitedAt,
      this.lastLoginAt,
      this.lastName,
      this.phone,
      this.role,
      this.status,
      this.totpEnabled,
      this.updatedAt,
      this.username})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUser rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainUsersDtoUser &&
        activatedAt == other.activatedAt &&
        branchId == other.branchId &&
        branchName == other.branchName &&
        createdAt == other.createdAt &&
        email == other.email &&
        firstName == other.firstName &&
        fullName == other.fullName &&
        id == other.id &&
        invitedAt == other.invitedAt &&
        lastLoginAt == other.lastLoginAt &&
        lastName == other.lastName &&
        phone == other.phone &&
        role == other.role &&
        status == other.status &&
        totpEnabled == other.totpEnabled &&
        updatedAt == other.updatedAt &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activatedAt.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, branchName.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, invitedAt.hashCode);
    _$hash = $jc(_$hash, lastLoginAt.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, totpEnabled.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoUser')
          ..add('activatedAt', activatedAt)
          ..add('branchId', branchId)
          ..add('branchName', branchName)
          ..add('createdAt', createdAt)
          ..add('email', email)
          ..add('firstName', firstName)
          ..add('fullName', fullName)
          ..add('id', id)
          ..add('invitedAt', invitedAt)
          ..add('lastLoginAt', lastLoginAt)
          ..add('lastName', lastName)
          ..add('phone', phone)
          ..add('role', role)
          ..add('status', status)
          ..add('totpEnabled', totpEnabled)
          ..add('updatedAt', updatedAt)
          ..add('username', username))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainUsersDtoUser,
            GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUser? _$v;

  DateTime? _activatedAt;
  DateTime? get activatedAt => _$this._activatedAt;
  set activatedAt(DateTime? activatedAt) => _$this._activatedAt = activatedAt;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _branchName;
  String? get branchName => _$this._branchName;
  set branchName(String? branchName) => _$this._branchName = branchName;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _invitedAt;
  DateTime? get invitedAt => _$this._invitedAt;
  set invitedAt(DateTime? invitedAt) => _$this._invitedAt = invitedAt;

  DateTime? _lastLoginAt;
  DateTime? get lastLoginAt => _$this._lastLoginAt;
  set lastLoginAt(DateTime? lastLoginAt) => _$this._lastLoginAt = lastLoginAt;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder? _role;
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder get role =>
      _$this._role ??=
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder();
  set role(
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder?
              role) =>
      _$this._role = role;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum? _status;
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum? get status =>
      _$this._status;
  set status(
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum?
              status) =>
      _$this._status = status;

  bool? _totpEnabled;
  bool? get totpEnabled => _$this._totpEnabled;
  set totpEnabled(bool? totpEnabled) => _$this._totpEnabled = totpEnabled;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoUser._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activatedAt = $v.activatedAt;
      _branchId = $v.branchId;
      _branchName = $v.branchName;
      _createdAt = $v.createdAt;
      _email = $v.email;
      _firstName = $v.firstName;
      _fullName = $v.fullName;
      _id = $v.id;
      _invitedAt = $v.invitedAt;
      _lastLoginAt = $v.lastLoginAt;
      _lastName = $v.lastName;
      _phone = $v.phone;
      _role = $v.role?.toBuilder();
      _status = $v.status;
      _totpEnabled = $v.totpEnabled;
      _updatedAt = $v.updatedAt;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainUsersDtoUser other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainUsersDtoUser;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUser build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUser _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoUser _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoUser._(
            activatedAt: activatedAt,
            branchId: branchId,
            branchName: branchName,
            createdAt: createdAt,
            email: email,
            firstName: firstName,
            fullName: fullName,
            id: id,
            invitedAt: invitedAt,
            lastLoginAt: lastLoginAt,
            lastName: lastName,
            phone: phone,
            role: _role?.build(),
            status: status,
            totpEnabled: totpEnabled,
            updatedAt: updatedAt,
            username: username,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'role';
        _role?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoUser',
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
