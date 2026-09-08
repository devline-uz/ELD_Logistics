// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_notifications_dto_push_token_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
    _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_android =
    const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
        ._('android');
const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
    _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_ios =
    const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
        ._('ios');
const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
    _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_web =
    const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
        ._('web');
const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
    _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
    _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnumValueOf(
        String name) {
  switch (name) {
    case 'android':
      return _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_android;
    case 'ios':
      return _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_ios;
    case 'web':
      return _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_web;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum>
    _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum>(const <GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum>[
  _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_android,
  _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_ios,
  _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_web,
  _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum>
    _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'android': 'android',
    'ios': 'ios',
    'web': 'web',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'android': 'android',
    'ios': 'ios',
    'web': 'web',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate
    extends GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate {
  @override
  final String? appVersion;
  @override
  final String deviceId;
  @override
  final GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum
      platform;
  @override
  final String token;

  factory _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate._(
      {this.appVersion,
      required this.deviceId,
      required this.platform,
      required this.token})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate &&
        appVersion == other.appVersion &&
        deviceId == other.deviceId &&
        platform == other.platform &&
        token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate')
          ..add('appVersion', appVersion)
          ..add('deviceId', deviceId)
          ..add('platform', platform)
          ..add('token', token))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate,
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate?
      _$v;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum?
      _platform;
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum?
      get platform => _$this._platform;
  set platform(
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum?
              platform) =>
      _$this._platform = platform;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _appVersion = $v.appVersion;
      _deviceId = $v.deviceId;
      _platform = $v.platform;
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate
            ._(
          appVersion: appVersion,
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId,
              r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate',
              'deviceId'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform,
              r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate',
              'platform'),
          token: BuiltValueNullFieldError.checkNotNull(
              token,
              r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate',
              'token'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
