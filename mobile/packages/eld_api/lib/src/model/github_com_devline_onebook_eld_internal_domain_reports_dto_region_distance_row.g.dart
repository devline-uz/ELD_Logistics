// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_reports_dto_region_distance_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow
    extends GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow {
  @override
  final String? country;
  @override
  final int? distanceM;
  @override
  final String? regionCode;
  @override
  final String? regionName;
  @override
  final String? unitId;
  @override
  final String? unitNumber;

  factory _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow._(
      {this.country,
      this.distanceM,
      this.regionCode,
      this.regionName,
      this.unitId,
      this.unitNumber})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow &&
        country == other.country &&
        distanceM == other.distanceM &&
        regionCode == other.regionCode &&
        regionName == other.regionName &&
        unitId == other.unitId &&
        unitNumber == other.unitNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, country.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, regionCode.hashCode);
    _$hash = $jc(_$hash, regionName.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jc(_$hash, unitNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow')
          ..add('country', country)
          ..add('distanceM', distanceM)
          ..add('regionCode', regionCode)
          ..add('regionName', regionName)
          ..add('unitId', unitId)
          ..add('unitNumber', unitNumber))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow,
            GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow? _$v;

  String? _country;
  String? get country => _$this._country;
  set country(String? country) => _$this._country = country;

  int? _distanceM;
  int? get distanceM => _$this._distanceM;
  set distanceM(int? distanceM) => _$this._distanceM = distanceM;

  String? _regionCode;
  String? get regionCode => _$this._regionCode;
  set regionCode(String? regionCode) => _$this._regionCode = regionCode;

  String? _regionName;
  String? get regionName => _$this._regionName;
  set regionName(String? regionName) => _$this._regionName = regionName;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  String? _unitNumber;
  String? get unitNumber => _$this._unitNumber;
  set unitNumber(String? unitNumber) => _$this._unitNumber = unitNumber;

  GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder() {
    GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _country = $v.country;
      _distanceM = $v.distanceM;
      _regionCode = $v.regionCode;
      _regionName = $v.regionName;
      _unitId = $v.unitId;
      _unitNumber = $v.unitNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow._(
          country: country,
          distanceM: distanceM,
          regionCode: regionCode,
          regionName: regionName,
          unitId: unitId,
          unitNumber: unitNumber,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
