// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_login_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult {
  @override
  final String? accessToken;
  @override
  final int? expiresIn;
  @override
  final DateTime? refreshExpiresAt;
  @override
  final String? refreshToken;
  @override
  final bool? replacedSession;
  @override
  final bool? requiresTotpSetup;
  @override
  final String? sessionId;
  @override
  final bool? subscriptionReadonly;
  @override
  final String? tokenType;
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoProfile? user;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult._(
      {this.accessToken,
      this.expiresIn,
      this.refreshExpiresAt,
      this.refreshToken,
      this.replacedSession,
      this.requiresTotpSetup,
      this.sessionId,
      this.subscriptionReadonly,
      this.tokenType,
      this.user})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult &&
        accessToken == other.accessToken &&
        expiresIn == other.expiresIn &&
        refreshExpiresAt == other.refreshExpiresAt &&
        refreshToken == other.refreshToken &&
        replacedSession == other.replacedSession &&
        requiresTotpSetup == other.requiresTotpSetup &&
        sessionId == other.sessionId &&
        subscriptionReadonly == other.subscriptionReadonly &&
        tokenType == other.tokenType &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jc(_$hash, refreshExpiresAt.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, replacedSession.hashCode);
    _$hash = $jc(_$hash, requiresTotpSetup.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, subscriptionReadonly.hashCode);
    _$hash = $jc(_$hash, tokenType.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult')
          ..add('accessToken', accessToken)
          ..add('expiresIn', expiresIn)
          ..add('refreshExpiresAt', refreshExpiresAt)
          ..add('refreshToken', refreshToken)
          ..add('replacedSession', replacedSession)
          ..add('requiresTotpSetup', requiresTotpSetup)
          ..add('sessionId', sessionId)
          ..add('subscriptionReadonly', subscriptionReadonly)
          ..add('tokenType', tokenType)
          ..add('user', user))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult,
            GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  DateTime? _refreshExpiresAt;
  DateTime? get refreshExpiresAt => _$this._refreshExpiresAt;
  set refreshExpiresAt(DateTime? refreshExpiresAt) =>
      _$this._refreshExpiresAt = refreshExpiresAt;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  bool? _replacedSession;
  bool? get replacedSession => _$this._replacedSession;
  set replacedSession(bool? replacedSession) =>
      _$this._replacedSession = replacedSession;

  bool? _requiresTotpSetup;
  bool? get requiresTotpSetup => _$this._requiresTotpSetup;
  set requiresTotpSetup(bool? requiresTotpSetup) =>
      _$this._requiresTotpSetup = requiresTotpSetup;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  bool? _subscriptionReadonly;
  bool? get subscriptionReadonly => _$this._subscriptionReadonly;
  set subscriptionReadonly(bool? subscriptionReadonly) =>
      _$this._subscriptionReadonly = subscriptionReadonly;

  String? _tokenType;
  String? get tokenType => _$this._tokenType;
  set tokenType(String? tokenType) => _$this._tokenType = tokenType;

  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder? _user;
  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder get user =>
      _$this._user ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder();
  set user(
          GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder?
              user) =>
      _$this._user = user;

  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _expiresIn = $v.expiresIn;
      _refreshExpiresAt = $v.refreshExpiresAt;
      _refreshToken = $v.refreshToken;
      _replacedSession = $v.replacedSession;
      _requiresTotpSetup = $v.requiresTotpSetup;
      _sessionId = $v.sessionId;
      _subscriptionReadonly = $v.subscriptionReadonly;
      _tokenType = $v.tokenType;
      _user = $v.user?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult._(
            accessToken: accessToken,
            expiresIn: expiresIn,
            refreshExpiresAt: refreshExpiresAt,
            refreshToken: refreshToken,
            replacedSession: replacedSession,
            requiresTotpSetup: requiresTotpSetup,
            sessionId: sessionId,
            subscriptionReadonly: subscriptionReadonly,
            tokenType: tokenType,
            user: _user?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        _user?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult',
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
