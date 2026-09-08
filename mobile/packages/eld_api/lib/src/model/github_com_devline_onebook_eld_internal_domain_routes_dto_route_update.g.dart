// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_routes_dto_route_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate
    extends GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate {
  @override
  final GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput?
      destination;
  @override
  final String? driverId;
  @override
  final int? geofenceM;
  @override
  final String? note;
  @override
  final GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput? origin;
  @override
  final int? sequence;
  @override
  final String? unitId;

  factory _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate._(
      {this.destination,
      this.driverId,
      this.geofenceM,
      this.note,
      this.origin,
      this.sequence,
      this.unitId})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate &&
        destination == other.destination &&
        driverId == other.driverId &&
        geofenceM == other.geofenceM &&
        note == other.note &&
        origin == other.origin &&
        sequence == other.sequence &&
        unitId == other.unitId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, geofenceM.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, sequence.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate')
          ..add('destination', destination)
          ..add('driverId', driverId)
          ..add('geofenceM', geofenceM)
          ..add('note', note)
          ..add('origin', origin)
          ..add('sequence', sequence)
          ..add('unitId', unitId))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate,
            GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate? _$v;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder?
      _destination;
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder
      get destination => _$this._destination ??=
          GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder();
  set destination(
          GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder?
              destination) =>
      _$this._destination = destination;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  int? _geofenceM;
  int? get geofenceM => _$this._geofenceM;
  set geofenceM(int? geofenceM) => _$this._geofenceM = geofenceM;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder?
      _origin;
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder
      get origin => _$this._origin ??=
          GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder();
  set origin(
          GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder?
              origin) =>
      _$this._origin = origin;

  int? _sequence;
  int? get sequence => _$this._sequence;
  set sequence(int? sequence) => _$this._sequence = sequence;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder() {
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _destination = $v.destination?.toBuilder();
      _driverId = $v.driverId;
      _geofenceM = $v.geofenceM;
      _note = $v.note;
      _origin = $v.origin?.toBuilder();
      _sequence = $v.sequence;
      _unitId = $v.unitId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate _build() {
    _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate._(
            destination: _destination?.build(),
            driverId: driverId,
            geofenceM: geofenceM,
            note: note,
            origin: _origin?.build(),
            sequence: sequence,
            unitId: unitId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'destination';
        _destination?.build();

        _$failedField = 'origin';
        _origin?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate',
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
