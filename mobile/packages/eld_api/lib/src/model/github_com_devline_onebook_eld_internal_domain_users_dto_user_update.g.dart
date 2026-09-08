// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_user_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate {
  @override
  final String? branchId;
  @override
  final String? email;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? phone;
  @override
  final String? roleId;
  @override
  final String? username;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate._(
      {this.branchId,
      this.email,
      this.firstName,
      this.lastName,
      this.phone,
      this.roleId,
      this.username})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate &&
        branchId == other.branchId &&
        email == other.email &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        phone == other.phone &&
        roleId == other.roleId &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, roleId.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate')
          ..add('branchId', branchId)
          ..add('email', email)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('phone', phone)
          ..add('roleId', roleId)
          ..add('username', username))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate,
            GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _roleId;
  String? get roleId => _$this._roleId;
  set roleId(String? roleId) => _$this._roleId = roleId;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdateBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _email = $v.email;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _phone = $v.phone;
      _roleId = $v.roleId;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserUpdate._(
          branchId: branchId,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          roleId: roleId,
          username: username,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
