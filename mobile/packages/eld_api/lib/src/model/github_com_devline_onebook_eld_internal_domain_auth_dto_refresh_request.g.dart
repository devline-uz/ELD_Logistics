// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_refresh_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest {
  @override
  final String? appVersion;
  @override
  final String refreshToken;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest._(
      {this.appVersion, required this.refreshToken})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest &&
        appVersion == other.appVersion &&
        refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest')
          ..add('appVersion', appVersion)
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest,
            GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest? _$v;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _appVersion = $v.appVersion;
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest._(
          appVersion: appVersion,
          refreshToken: BuiltValueNullFieldError.checkNotNull(
              refreshToken,
              r'GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest',
              'refreshToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
