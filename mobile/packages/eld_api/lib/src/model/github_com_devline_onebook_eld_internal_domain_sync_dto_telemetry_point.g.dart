// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_telemetry_point.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_OFF =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
        ._('OFF');
const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_SB =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
        ._('SB');
const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_DR =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
        ._('DR');
const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_ON =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
        ._('ON');
const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'OFF':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_OFF;
    case 'SB':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_SB;
    case 'DR':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_DR;
    case 'ON':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_ON;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_OFF,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_SB,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_DR,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_ON,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'OFF': 'OFF',
    'SB': 'SB',
    'DR': 'DR',
    'ON': 'ON',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'OFF': 'OFF',
    'SB': 'SB',
    'DR': 'DR',
    'ON': 'ON',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint {
  @override
  final num? batteryPct;
  @override
  final num? batteryVoltageV;
  @override
  final num? coolantLevelPct;
  @override
  final num? coolantTempC;
  @override
  final BuiltList<String>? diagnostics;
  @override
  final bool? disconnected;
  @override
  final String? driverId;
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum?
      dutyStatus;
  @override
  final num? engineHours;
  @override
  final num? fuelPct;
  @override
  final num? headingDeg;
  @override
  final bool? ignition;
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final int? odometerM;
  @override
  final num? oilLevelPct;
  @override
  final num? speedKmh;
  @override
  final DateTime ts;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint._(
      {this.batteryPct,
      this.batteryVoltageV,
      this.coolantLevelPct,
      this.coolantTempC,
      this.diagnostics,
      this.disconnected,
      this.driverId,
      this.dutyStatus,
      this.engineHours,
      this.fuelPct,
      this.headingDeg,
      this.ignition,
      this.lat,
      this.lng,
      this.odometerM,
      this.oilLevelPct,
      this.speedKmh,
      required this.ts})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint &&
        batteryPct == other.batteryPct &&
        batteryVoltageV == other.batteryVoltageV &&
        coolantLevelPct == other.coolantLevelPct &&
        coolantTempC == other.coolantTempC &&
        diagnostics == other.diagnostics &&
        disconnected == other.disconnected &&
        driverId == other.driverId &&
        dutyStatus == other.dutyStatus &&
        engineHours == other.engineHours &&
        fuelPct == other.fuelPct &&
        headingDeg == other.headingDeg &&
        ignition == other.ignition &&
        lat == other.lat &&
        lng == other.lng &&
        odometerM == other.odometerM &&
        oilLevelPct == other.oilLevelPct &&
        speedKmh == other.speedKmh &&
        ts == other.ts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, batteryPct.hashCode);
    _$hash = $jc(_$hash, batteryVoltageV.hashCode);
    _$hash = $jc(_$hash, coolantLevelPct.hashCode);
    _$hash = $jc(_$hash, coolantTempC.hashCode);
    _$hash = $jc(_$hash, diagnostics.hashCode);
    _$hash = $jc(_$hash, disconnected.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, dutyStatus.hashCode);
    _$hash = $jc(_$hash, engineHours.hashCode);
    _$hash = $jc(_$hash, fuelPct.hashCode);
    _$hash = $jc(_$hash, headingDeg.hashCode);
    _$hash = $jc(_$hash, ignition.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, odometerM.hashCode);
    _$hash = $jc(_$hash, oilLevelPct.hashCode);
    _$hash = $jc(_$hash, speedKmh.hashCode);
    _$hash = $jc(_$hash, ts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint')
          ..add('batteryPct', batteryPct)
          ..add('batteryVoltageV', batteryVoltageV)
          ..add('coolantLevelPct', coolantLevelPct)
          ..add('coolantTempC', coolantTempC)
          ..add('diagnostics', diagnostics)
          ..add('disconnected', disconnected)
          ..add('driverId', driverId)
          ..add('dutyStatus', dutyStatus)
          ..add('engineHours', engineHours)
          ..add('fuelPct', fuelPct)
          ..add('headingDeg', headingDeg)
          ..add('ignition', ignition)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('odometerM', odometerM)
          ..add('oilLevelPct', oilLevelPct)
          ..add('speedKmh', speedKmh)
          ..add('ts', ts))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint,
            GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint? _$v;

  num? _batteryPct;
  num? get batteryPct => _$this._batteryPct;
  set batteryPct(num? batteryPct) => _$this._batteryPct = batteryPct;

  num? _batteryVoltageV;
  num? get batteryVoltageV => _$this._batteryVoltageV;
  set batteryVoltageV(num? batteryVoltageV) =>
      _$this._batteryVoltageV = batteryVoltageV;

  num? _coolantLevelPct;
  num? get coolantLevelPct => _$this._coolantLevelPct;
  set coolantLevelPct(num? coolantLevelPct) =>
      _$this._coolantLevelPct = coolantLevelPct;

  num? _coolantTempC;
  num? get coolantTempC => _$this._coolantTempC;
  set coolantTempC(num? coolantTempC) => _$this._coolantTempC = coolantTempC;

  ListBuilder<String>? _diagnostics;
  ListBuilder<String> get diagnostics =>
      _$this._diagnostics ??= ListBuilder<String>();
  set diagnostics(ListBuilder<String>? diagnostics) =>
      _$this._diagnostics = diagnostics;

  bool? _disconnected;
  bool? get disconnected => _$this._disconnected;
  set disconnected(bool? disconnected) => _$this._disconnected = disconnected;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum?
      _dutyStatus;
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum?
      get dutyStatus => _$this._dutyStatus;
  set dutyStatus(
          GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum?
              dutyStatus) =>
      _$this._dutyStatus = dutyStatus;

  num? _engineHours;
  num? get engineHours => _$this._engineHours;
  set engineHours(num? engineHours) => _$this._engineHours = engineHours;

  num? _fuelPct;
  num? get fuelPct => _$this._fuelPct;
  set fuelPct(num? fuelPct) => _$this._fuelPct = fuelPct;

  num? _headingDeg;
  num? get headingDeg => _$this._headingDeg;
  set headingDeg(num? headingDeg) => _$this._headingDeg = headingDeg;

  bool? _ignition;
  bool? get ignition => _$this._ignition;
  set ignition(bool? ignition) => _$this._ignition = ignition;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  int? _odometerM;
  int? get odometerM => _$this._odometerM;
  set odometerM(int? odometerM) => _$this._odometerM = odometerM;

  num? _oilLevelPct;
  num? get oilLevelPct => _$this._oilLevelPct;
  set oilLevelPct(num? oilLevelPct) => _$this._oilLevelPct = oilLevelPct;

  num? _speedKmh;
  num? get speedKmh => _$this._speedKmh;
  set speedKmh(num? speedKmh) => _$this._speedKmh = speedKmh;

  DateTime? _ts;
  DateTime? get ts => _$this._ts;
  set ts(DateTime? ts) => _$this._ts = ts;

  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _batteryPct = $v.batteryPct;
      _batteryVoltageV = $v.batteryVoltageV;
      _coolantLevelPct = $v.coolantLevelPct;
      _coolantTempC = $v.coolantTempC;
      _diagnostics = $v.diagnostics?.toBuilder();
      _disconnected = $v.disconnected;
      _driverId = $v.driverId;
      _dutyStatus = $v.dutyStatus;
      _engineHours = $v.engineHours;
      _fuelPct = $v.fuelPct;
      _headingDeg = $v.headingDeg;
      _ignition = $v.ignition;
      _lat = $v.lat;
      _lng = $v.lng;
      _odometerM = $v.odometerM;
      _oilLevelPct = $v.oilLevelPct;
      _speedKmh = $v.speedKmh;
      _ts = $v.ts;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint _build() {
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint._(
            batteryPct: batteryPct,
            batteryVoltageV: batteryVoltageV,
            coolantLevelPct: coolantLevelPct,
            coolantTempC: coolantTempC,
            diagnostics: _diagnostics?.build(),
            disconnected: disconnected,
            driverId: driverId,
            dutyStatus: dutyStatus,
            engineHours: engineHours,
            fuelPct: fuelPct,
            headingDeg: headingDeg,
            ignition: ignition,
            lat: lat,
            lng: lng,
            odometerM: odometerM,
            oilLevelPct: oilLevelPct,
            speedKmh: speedKmh,
            ts: BuiltValueNullFieldError.checkNotNull(
                ts,
                r'GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint',
                'ts'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'diagnostics';
        _diagnostics?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint',
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
