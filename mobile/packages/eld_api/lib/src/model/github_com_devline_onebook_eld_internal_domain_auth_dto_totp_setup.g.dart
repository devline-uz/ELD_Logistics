// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_totp_setup.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup {
  @override
  final int? digits;
  @override
  final String? issuer;
  @override
  final String? otpauthUrl;
  @override
  final int? period;
  @override
  final String? secret;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup._(
      {this.digits, this.issuer, this.otpauthUrl, this.period, this.secret})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup &&
        digits == other.digits &&
        issuer == other.issuer &&
        otpauthUrl == other.otpauthUrl &&
        period == other.period &&
        secret == other.secret;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, digits.hashCode);
    _$hash = $jc(_$hash, issuer.hashCode);
    _$hash = $jc(_$hash, otpauthUrl.hashCode);
    _$hash = $jc(_$hash, period.hashCode);
    _$hash = $jc(_$hash, secret.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup')
          ..add('digits', digits)
          ..add('issuer', issuer)
          ..add('otpauthUrl', otpauthUrl)
          ..add('period', period)
          ..add('secret', secret))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup,
            GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup? _$v;

  int? _digits;
  int? get digits => _$this._digits;
  set digits(int? digits) => _$this._digits = digits;

  String? _issuer;
  String? get issuer => _$this._issuer;
  set issuer(String? issuer) => _$this._issuer = issuer;

  String? _otpauthUrl;
  String? get otpauthUrl => _$this._otpauthUrl;
  set otpauthUrl(String? otpauthUrl) => _$this._otpauthUrl = otpauthUrl;

  int? _period;
  int? get period => _$this._period;
  set period(int? period) => _$this._period = period;

  String? _secret;
  String? get secret => _$this._secret;
  set secret(String? secret) => _$this._secret = secret;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _digits = $v.digits;
      _issuer = $v.issuer;
      _otpauthUrl = $v.otpauthUrl;
      _period = $v.period;
      _secret = $v.secret;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup._(
          digits: digits,
          issuer: issuer,
          otpauthUrl: otpauthUrl,
          period: period,
          secret: secret,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
