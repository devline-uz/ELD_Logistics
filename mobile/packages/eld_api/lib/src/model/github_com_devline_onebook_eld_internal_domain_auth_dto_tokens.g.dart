// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_tokens.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokens
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoTokens {
  @override
  final String? accessToken;
  @override
  final int? expiresIn;
  @override
  final DateTime? refreshExpiresAt;
  @override
  final String? refreshToken;
  @override
  final String? tokenType;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokens(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokens._(
      {this.accessToken,
      this.expiresIn,
      this.refreshExpiresAt,
      this.refreshToken,
      this.tokenType})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokens rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainAuthDtoTokens &&
        accessToken == other.accessToken &&
        expiresIn == other.expiresIn &&
        refreshExpiresAt == other.refreshExpiresAt &&
        refreshToken == other.refreshToken &&
        tokenType == other.tokenType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jc(_$hash, refreshExpiresAt.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, tokenType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTokens')
          ..add('accessToken', accessToken)
          ..add('expiresIn', expiresIn)
          ..add('refreshExpiresAt', refreshExpiresAt)
          ..add('refreshToken', refreshToken)
          ..add('tokenType', tokenType))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoTokens,
            GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokens? _$v;

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

  String? _tokenType;
  String? get tokenType => _$this._tokenType;
  set tokenType(String? tokenType) => _$this._tokenType = tokenType;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoTokens._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _expiresIn = $v.expiresIn;
      _refreshExpiresAt = $v.refreshExpiresAt;
      _refreshToken = $v.refreshToken;
      _tokenType = $v.tokenType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainAuthDtoTokens other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokens;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokens build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokens _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokens._(
          accessToken: accessToken,
          expiresIn: expiresIn,
          refreshExpiresAt: refreshExpiresAt,
          refreshToken: refreshToken,
          tokenType: tokenType,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
