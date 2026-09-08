// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_password_forgot_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest {
  @override
  final String login;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest._(
      {required this.login})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest &&
        login == other.login;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, login.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest')
          ..add('login', login))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest,
            GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest? _$v;

  String? _login;
  String? get login => _$this._login;
  set login(String? login) => _$this._login = login;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _login = $v.login;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest
            ._(
          login: BuiltValueNullFieldError.checkNotNull(
              login,
              r'GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest',
              'login'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
