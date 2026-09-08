// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_logout_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest {
  @override
  final bool? pause;
  @override
  final String? refreshToken;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest._(
      {this.pause, this.refreshToken})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest &&
        pause == other.pause &&
        refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pause.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest')
          ..add('pause', pause)
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest,
            GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest? _$v;

  bool? _pause;
  bool? get pause => _$this._pause;
  set pause(bool? pause) => _$this._pause = pause;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _pause = $v.pause;
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest._(
          pause: pause,
          refreshToken: refreshToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
