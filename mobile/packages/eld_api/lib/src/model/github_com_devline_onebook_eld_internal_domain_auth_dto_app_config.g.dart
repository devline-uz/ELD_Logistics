// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_app_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig {
  @override
  final int? accessTokenTtlSeconds;
  @override
  final BuiltMap<String, bool>? featureFlags;
  @override
  final bool? forceUpdate;
  @override
  final String? latestVersion;
  @override
  final String? minSupportedVersion;
  @override
  final DateTime? serverTime;
  @override
  final String? supportEmail;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig._(
      {this.accessTokenTtlSeconds,
      this.featureFlags,
      this.forceUpdate,
      this.latestVersion,
      this.minSupportedVersion,
      this.serverTime,
      this.supportEmail})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig &&
        accessTokenTtlSeconds == other.accessTokenTtlSeconds &&
        featureFlags == other.featureFlags &&
        forceUpdate == other.forceUpdate &&
        latestVersion == other.latestVersion &&
        minSupportedVersion == other.minSupportedVersion &&
        serverTime == other.serverTime &&
        supportEmail == other.supportEmail;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessTokenTtlSeconds.hashCode);
    _$hash = $jc(_$hash, featureFlags.hashCode);
    _$hash = $jc(_$hash, forceUpdate.hashCode);
    _$hash = $jc(_$hash, latestVersion.hashCode);
    _$hash = $jc(_$hash, minSupportedVersion.hashCode);
    _$hash = $jc(_$hash, serverTime.hashCode);
    _$hash = $jc(_$hash, supportEmail.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig')
          ..add('accessTokenTtlSeconds', accessTokenTtlSeconds)
          ..add('featureFlags', featureFlags)
          ..add('forceUpdate', forceUpdate)
          ..add('latestVersion', latestVersion)
          ..add('minSupportedVersion', minSupportedVersion)
          ..add('serverTime', serverTime)
          ..add('supportEmail', supportEmail))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig,
            GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig? _$v;

  int? _accessTokenTtlSeconds;
  int? get accessTokenTtlSeconds => _$this._accessTokenTtlSeconds;
  set accessTokenTtlSeconds(int? accessTokenTtlSeconds) =>
      _$this._accessTokenTtlSeconds = accessTokenTtlSeconds;

  MapBuilder<String, bool>? _featureFlags;
  MapBuilder<String, bool> get featureFlags =>
      _$this._featureFlags ??= MapBuilder<String, bool>();
  set featureFlags(MapBuilder<String, bool>? featureFlags) =>
      _$this._featureFlags = featureFlags;

  bool? _forceUpdate;
  bool? get forceUpdate => _$this._forceUpdate;
  set forceUpdate(bool? forceUpdate) => _$this._forceUpdate = forceUpdate;

  String? _latestVersion;
  String? get latestVersion => _$this._latestVersion;
  set latestVersion(String? latestVersion) =>
      _$this._latestVersion = latestVersion;

  String? _minSupportedVersion;
  String? get minSupportedVersion => _$this._minSupportedVersion;
  set minSupportedVersion(String? minSupportedVersion) =>
      _$this._minSupportedVersion = minSupportedVersion;

  DateTime? _serverTime;
  DateTime? get serverTime => _$this._serverTime;
  set serverTime(DateTime? serverTime) => _$this._serverTime = serverTime;

  String? _supportEmail;
  String? get supportEmail => _$this._supportEmail;
  set supportEmail(String? supportEmail) => _$this._supportEmail = supportEmail;

  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessTokenTtlSeconds = $v.accessTokenTtlSeconds;
      _featureFlags = $v.featureFlags?.toBuilder();
      _forceUpdate = $v.forceUpdate;
      _latestVersion = $v.latestVersion;
      _minSupportedVersion = $v.minSupportedVersion;
      _serverTime = $v.serverTime;
      _supportEmail = $v.supportEmail;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig._(
            accessTokenTtlSeconds: accessTokenTtlSeconds,
            featureFlags: _featureFlags?.build(),
            forceUpdate: forceUpdate,
            latestVersion: latestVersion,
            minSupportedVersion: minSupportedVersion,
            serverTime: serverTime,
            supportEmail: supportEmail,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'featureFlags';
        _featureFlags?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig',
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
