// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_driver_license.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense {
  @override
  final String? driverId;
  @override
  final String? licenseNo;
  @override
  final String? licenseRegion;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense._(
      {this.driverId, this.licenseNo, this.licenseRegion})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense &&
        driverId == other.driverId &&
        licenseNo == other.licenseNo &&
        licenseRegion == other.licenseRegion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, licenseNo.hashCode);
    _$hash = $jc(_$hash, licenseRegion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense')
          ..add('driverId', driverId)
          ..add('licenseNo', licenseNo)
          ..add('licenseRegion', licenseRegion))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense,
            GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense? _$v;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _licenseNo;
  String? get licenseNo => _$this._licenseNo;
  set licenseNo(String? licenseNo) => _$this._licenseNo = licenseNo;

  String? _licenseRegion;
  String? get licenseRegion => _$this._licenseRegion;
  set licenseRegion(String? licenseRegion) =>
      _$this._licenseRegion = licenseRegion;

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverId = $v.driverId;
      _licenseNo = $v.licenseNo;
      _licenseRegion = $v.licenseRegion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense._(
          driverId: driverId,
          licenseNo: licenseNo,
          licenseRegion: licenseRegion,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
