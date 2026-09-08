// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_invitation_accept_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest {
  @override
  final String password;
  @override
  final String? pin;
  @override
  final String token;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest._(
      {required this.password, this.pin, required this.token})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest &&
        password == other.password &&
        pin == other.pin &&
        token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest')
          ..add('password', password)
          ..add('pin', pin)
          ..add('token', token))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest,
            GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest? _$v;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _password = $v.password;
      _pin = $v.pin;
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest
            ._(
          password: BuiltValueNullFieldError.checkNotNull(
              password,
              r'GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest',
              'password'),
          pin: pin,
          token: BuiltValueNullFieldError.checkNotNull(
              token,
              r'GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest',
              'token'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
