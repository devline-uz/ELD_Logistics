// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_co_driver.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_invited =
    const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
        ._('invited');
const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_active =
    const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
        ._('active');
const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_inactive =
    const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
        ._('inactive');
const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'invited':
      return _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_invited;
    case 'active':
      return _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_active;
    case 'inactive':
      return _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_inactive;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_invited,
  _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_active,
  _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_inactive,
  _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum> {
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
    GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver {
  @override
  final String? driverId;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? pairId;
  @override
  final DateTime? pairedAt;
  @override
  final GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum?
      status;
  @override
  final String? username;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver._(
      {this.driverId,
      this.firstName,
      this.lastName,
      this.pairId,
      this.pairedAt,
      this.status,
      this.username})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver &&
        driverId == other.driverId &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        pairId == other.pairId &&
        pairedAt == other.pairedAt &&
        status == other.status &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, pairId.hashCode);
    _$hash = $jc(_$hash, pairedAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver')
          ..add('driverId', driverId)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('pairId', pairId)
          ..add('pairedAt', pairedAt)
          ..add('status', status)
          ..add('username', username))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver,
            GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver? _$v;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _pairId;
  String? get pairId => _$this._pairId;
  set pairId(String? pairId) => _$this._pairId = pairId;

  DateTime? _pairedAt;
  DateTime? get pairedAt => _$this._pairedAt;
  set pairedAt(DateTime? pairedAt) => _$this._pairedAt = pairedAt;

  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum? _status;
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum?
      get status => _$this._status;
  set status(
          GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum?
              status) =>
      _$this._status = status;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverId = $v.driverId;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _pairId = $v.pairId;
      _pairedAt = $v.pairedAt;
      _status = $v.status;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver._(
          driverId: driverId,
          firstName: firstName,
          lastName: lastName,
          pairId: pairId,
          pairedAt: pairedAt,
          status: status,
          username: username,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
