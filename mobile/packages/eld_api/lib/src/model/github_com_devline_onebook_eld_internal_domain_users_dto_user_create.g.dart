// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_user_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_email =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
        ._('email');
const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_sms =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
        ._('sms');
const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_telegram =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
        ._('telegram');
const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnumValueOf(
        String name) {
  switch (name) {
    case 'email':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_email;
    case 'sms':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_sms;
    case 'telegram':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_telegram;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum>(const <GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum>[
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_email,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_sms,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_telegram,
  _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum>
    _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'email': 'email',
    'sms': 'sms',
    'telegram': 'telegram',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'email': 'email',
    'sms': 'sms',
    'telegram': 'telegram',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
      deserialize(
              Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate {
  @override
  final String? branchId;
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum?
      channel;
  @override
  final String? email;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? phone;
  @override
  final String roleId;
  @override
  final String username;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate._(
      {this.branchId,
      this.channel,
      this.email,
      required this.firstName,
      required this.lastName,
      this.phone,
      required this.roleId,
      required this.username})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate &&
        branchId == other.branchId &&
        channel == other.channel &&
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
    _$hash = $jc(_$hash, channel.hashCode);
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
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate')
          ..add('branchId', branchId)
          ..add('channel', channel)
          ..add('email', email)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('phone', phone)
          ..add('roleId', roleId)
          ..add('username', username))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate,
            GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum?
      _channel;
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum?
      get channel => _$this._channel;
  set channel(
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum?
              channel) =>
      _$this._channel = channel;

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

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _channel = $v.channel;
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
      GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate._(
          branchId: branchId,
          channel: channel,
          email: email,
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName,
              r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate',
              'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName,
              r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate',
              'lastName'),
          phone: phone,
          roleId: BuiltValueNullFieldError.checkNotNull(
              roleId,
              r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate',
              'roleId'),
          username: BuiltValueNullFieldError.checkNotNull(
              username,
              r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate',
              'username'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
