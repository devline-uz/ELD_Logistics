// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_login_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_web =
    const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
        ._('web');
const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_phone =
    const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
        ._('phone');
const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_tablet =
    const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
        ._('tablet');
const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
    _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'web':
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_web;
    case 'phone':
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_phone;
    case 'tablet':
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_tablet;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum>
    _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum>(const <GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum>[
  _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_web,
  _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_phone,
  _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_tablet,
  _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum>
    _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'web': 'web',
    'phone': 'phone',
    'tablet': 'tablet',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'web': 'web',
    'phone': 'phone',
    'tablet': 'tablet',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest {
  @override
  final String? appVersion;
  @override
  final String? companyId;
  @override
  final String? deviceId;
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum
      deviceType;
  @override
  final String password;
  @override
  final String? totpCode;
  @override
  final String username;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest._(
      {this.appVersion,
      this.companyId,
      this.deviceId,
      required this.deviceType,
      required this.password,
      this.totpCode,
      required this.username})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest &&
        appVersion == other.appVersion &&
        companyId == other.companyId &&
        deviceId == other.deviceId &&
        deviceType == other.deviceType &&
        password == other.password &&
        totpCode == other.totpCode &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, companyId.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceType.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, totpCode.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest')
          ..add('appVersion', appVersion)
          ..add('companyId', companyId)
          ..add('deviceId', deviceId)
          ..add('deviceType', deviceType)
          ..add('password', password)
          ..add('totpCode', totpCode)
          ..add('username', username))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest,
            GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest? _$v;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _companyId;
  String? get companyId => _$this._companyId;
  set companyId(String? companyId) => _$this._companyId = companyId;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum?
      _deviceType;
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum?
      get deviceType => _$this._deviceType;
  set deviceType(
          GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum?
              deviceType) =>
      _$this._deviceType = deviceType;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _totpCode;
  String? get totpCode => _$this._totpCode;
  set totpCode(String? totpCode) => _$this._totpCode = totpCode;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _appVersion = $v.appVersion;
      _companyId = $v.companyId;
      _deviceId = $v.deviceId;
      _deviceType = $v.deviceType;
      _password = $v.password;
      _totpCode = $v.totpCode;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest._(
          appVersion: appVersion,
          companyId: companyId,
          deviceId: deviceId,
          deviceType: BuiltValueNullFieldError.checkNotNull(
              deviceType,
              r'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest',
              'deviceType'),
          password: BuiltValueNullFieldError.checkNotNull(
              password,
              r'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest',
              'password'),
          totpCode: totpCode,
          username: BuiltValueNullFieldError.checkNotNull(
              username,
              r'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest',
              'username'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
