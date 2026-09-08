// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_totp_verified.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified {
  @override
  final bool? enabled;
  @override
  final BuiltList<String>? recoveryCodes;
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoTokens? tokens;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified._(
      {this.enabled, this.recoveryCodes, this.tokens})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified &&
        enabled == other.enabled &&
        recoveryCodes == other.recoveryCodes &&
        tokens == other.tokens;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, recoveryCodes.hashCode);
    _$hash = $jc(_$hash, tokens.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified')
          ..add('enabled', enabled)
          ..add('recoveryCodes', recoveryCodes)
          ..add('tokens', tokens))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified,
            GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  ListBuilder<String>? _recoveryCodes;
  ListBuilder<String> get recoveryCodes =>
      _$this._recoveryCodes ??= ListBuilder<String>();
  set recoveryCodes(ListBuilder<String>? recoveryCodes) =>
      _$this._recoveryCodes = recoveryCodes;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder? _tokens;
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder get tokens =>
      _$this._tokens ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder();
  set tokens(
          GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder?
              tokens) =>
      _$this._tokens = tokens;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _recoveryCodes = $v.recoveryCodes?.toBuilder();
      _tokens = $v.tokens?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified._(
            enabled: enabled,
            recoveryCodes: _recoveryCodes?.build(),
            tokens: _tokens?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'recoveryCodes';
        _recoveryCodes?.build();
        _$failedField = 'tokens';
        _tokens?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified',
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
