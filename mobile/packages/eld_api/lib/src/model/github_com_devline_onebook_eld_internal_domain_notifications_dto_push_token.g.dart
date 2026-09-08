// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_notifications_dto_push_token.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken
    extends GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken {
  @override
  final String? appVersion;
  @override
  final String? deviceId;
  @override
  final DateTime? lastSeenAt;
  @override
  final String? platform;

  factory _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken._(
      {this.appVersion, this.deviceId, this.lastSeenAt, this.platform})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken &&
        appVersion == other.appVersion &&
        deviceId == other.deviceId &&
        lastSeenAt == other.lastSeenAt &&
        platform == other.platform;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken')
          ..add('appVersion', appVersion)
          ..add('deviceId', deviceId)
          ..add('lastSeenAt', lastSeenAt)
          ..add('platform', platform))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken,
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken? _$v;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(DateTime? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  String? _platform;
  String? get platform => _$this._platform;
  set platform(String? platform) => _$this._platform = platform;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder() {
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _appVersion = $v.appVersion;
      _deviceId = $v.deviceId;
      _lastSeenAt = $v.lastSeenAt;
      _platform = $v.platform;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken._(
          appVersion: appVersion,
          deviceId: deviceId,
          lastSeenAt: lastSeenAt,
          platform: platform,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
