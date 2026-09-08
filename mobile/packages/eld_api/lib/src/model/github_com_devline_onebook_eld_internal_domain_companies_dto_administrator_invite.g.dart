// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_companies_dto_administrator_invite.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_email =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
        ._('email');
const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_sms =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
        ._('sms');
const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_telegram =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
        ._('telegram');
const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnumValueOf(
        String name) {
  switch (name) {
    case 'email':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_email;
    case 'sms':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_sms;
    case 'telegram':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_telegram;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum>
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum>(const <GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum>[
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_email,
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_sms,
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_telegram,
  _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum>
    _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum> {
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
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite
    extends GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite {
  @override
  final GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum?
      channel;
  @override
  final String email;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? phone;
  @override
  final String? username;

  factory _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite._(
      {this.channel,
      required this.email,
      required this.firstName,
      required this.lastName,
      this.phone,
      this.username})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite &&
        channel == other.channel &&
        email == other.email &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        phone == other.phone &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, channel.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite')
          ..add('channel', channel)
          ..add('email', email)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('phone', phone)
          ..add('username', username))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite,
            GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite?
      _$v;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum?
      _channel;
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum?
      get channel => _$this._channel;
  set channel(
          GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum?
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

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _channel = $v.channel;
      _email = $v.email;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _phone = $v.phone;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite
            ._(
          channel: channel,
          email: BuiltValueNullFieldError.checkNotNull(
              email,
              r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite',
              'email'),
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName,
              r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite',
              'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName,
              r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite',
              'lastName'),
          phone: phone,
          username: username,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
