// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_totp_verify_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest {
  @override
  final String? code;
  @override
  final String? recoveryCode;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest._(
      {this.code, this.recoveryCode})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest &&
        code == other.code &&
        recoveryCode == other.recoveryCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, recoveryCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest')
          ..add('code', code)
          ..add('recoveryCode', recoveryCode))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest,
            GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _recoveryCode;
  String? get recoveryCode => _$this._recoveryCode;
  set recoveryCode(String? recoveryCode) => _$this._recoveryCode = recoveryCode;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _recoveryCode = $v.recoveryCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest._(
          code: code,
          recoveryCode: recoveryCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
