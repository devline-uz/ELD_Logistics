// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_tracking_dto_trip.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip
    extends GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip {
  @override
  final int? distanceM;
  @override
  final GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief? driver;
  @override
  final int? durationSec;
  @override
  final DateTime? endAt;
  @override
  final num? endLat;
  @override
  final num? endLng;
  @override
  final String? id;
  @override
  final num? maxSpeedKmh;
  @override
  final bool? open;
  @override
  final DateTime? startAt;
  @override
  final num? startLat;
  @override
  final num? startLng;
  @override
  final String? unitId;
  @override
  final String? unitNumber;

  factory _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip._(
      {this.distanceM,
      this.driver,
      this.durationSec,
      this.endAt,
      this.endLat,
      this.endLng,
      this.id,
      this.maxSpeedKmh,
      this.open,
      this.startAt,
      this.startLat,
      this.startLng,
      this.unitId,
      this.unitNumber})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip &&
        distanceM == other.distanceM &&
        driver == other.driver &&
        durationSec == other.durationSec &&
        endAt == other.endAt &&
        endLat == other.endLat &&
        endLng == other.endLng &&
        id == other.id &&
        maxSpeedKmh == other.maxSpeedKmh &&
        open == other.open &&
        startAt == other.startAt &&
        startLat == other.startLat &&
        startLng == other.startLng &&
        unitId == other.unitId &&
        unitNumber == other.unitNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, driver.hashCode);
    _$hash = $jc(_$hash, durationSec.hashCode);
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jc(_$hash, endLat.hashCode);
    _$hash = $jc(_$hash, endLng.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, maxSpeedKmh.hashCode);
    _$hash = $jc(_$hash, open.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jc(_$hash, startLat.hashCode);
    _$hash = $jc(_$hash, startLng.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jc(_$hash, unitNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip')
          ..add('distanceM', distanceM)
          ..add('driver', driver)
          ..add('durationSec', durationSec)
          ..add('endAt', endAt)
          ..add('endLat', endLat)
          ..add('endLng', endLng)
          ..add('id', id)
          ..add('maxSpeedKmh', maxSpeedKmh)
          ..add('open', open)
          ..add('startAt', startAt)
          ..add('startLat', startLat)
          ..add('startLng', startLng)
          ..add('unitId', unitId)
          ..add('unitNumber', unitNumber))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip,
            GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip? _$v;

  int? _distanceM;
  int? get distanceM => _$this._distanceM;
  set distanceM(int? distanceM) => _$this._distanceM = distanceM;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder?
      _driver;
  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder
      get driver => _$this._driver ??=
          GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder();
  set driver(
          GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder?
              driver) =>
      _$this._driver = driver;

  int? _durationSec;
  int? get durationSec => _$this._durationSec;
  set durationSec(int? durationSec) => _$this._durationSec = durationSec;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  num? _endLat;
  num? get endLat => _$this._endLat;
  set endLat(num? endLat) => _$this._endLat = endLat;

  num? _endLng;
  num? get endLng => _$this._endLng;
  set endLng(num? endLng) => _$this._endLng = endLng;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  num? _maxSpeedKmh;
  num? get maxSpeedKmh => _$this._maxSpeedKmh;
  set maxSpeedKmh(num? maxSpeedKmh) => _$this._maxSpeedKmh = maxSpeedKmh;

  bool? _open;
  bool? get open => _$this._open;
  set open(bool? open) => _$this._open = open;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  num? _startLat;
  num? get startLat => _$this._startLat;
  set startLat(num? startLat) => _$this._startLat = startLat;

  num? _startLng;
  num? get startLng => _$this._startLng;
  set startLng(num? startLng) => _$this._startLng = startLng;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  String? _unitNumber;
  String? get unitNumber => _$this._unitNumber;
  set unitNumber(String? unitNumber) => _$this._unitNumber = unitNumber;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder() {
    GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _distanceM = $v.distanceM;
      _driver = $v.driver?.toBuilder();
      _durationSec = $v.durationSec;
      _endAt = $v.endAt;
      _endLat = $v.endLat;
      _endLng = $v.endLng;
      _id = $v.id;
      _maxSpeedKmh = $v.maxSpeedKmh;
      _open = $v.open;
      _startAt = $v.startAt;
      _startLat = $v.startLat;
      _startLng = $v.startLng;
      _unitId = $v.unitId;
      _unitNumber = $v.unitNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip _build() {
    _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip._(
            distanceM: distanceM,
            driver: _driver?.build(),
            durationSec: durationSec,
            endAt: endAt,
            endLat: endLat,
            endLng: endLng,
            id: id,
            maxSpeedKmh: maxSpeedKmh,
            open: open,
            startAt: startAt,
            startLat: startLat,
            startLng: startLng,
            unitId: unitId,
            unitNumber: unitNumber,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'driver';
        _driver?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip',
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
