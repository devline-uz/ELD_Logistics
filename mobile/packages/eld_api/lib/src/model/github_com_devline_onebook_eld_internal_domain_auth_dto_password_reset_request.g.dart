// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_password_reset_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest {
  @override
  final String password;
  @override
  final String token;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest._(
      {required this.password, required this.token})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest &&
        password == other.password &&
        token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest')
          ..add('password', password)
          ..add('token', token))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest,
            GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest? _$v;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _password = $v.password;
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest._(
          password: BuiltValueNullFieldError.checkNotNull(
              password,
              r'GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest',
              'password'),
          token: BuiltValueNullFieldError.checkNotNull(
              token,
              r'GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest',
              'token'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
