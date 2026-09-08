//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_telemetry_point.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint
///
/// Properties:
/// * [batteryPct] 
/// * [batteryVoltageV] 
/// * [coolantLevelPct] 
/// * [coolantTempC] 
/// * [diagnostics] - Diagnostics are the FMCSA Appendix A letters active at TS (TZ §10.5). Send an empty array to clear the stored codes; omit the field to leave them untouched.
/// * [disconnected] - Disconnected marks the sample the ELD sends when it loses the link to the phone (TZ §10.1 \"Disconnected\").
/// * [driverId] - DriverID is null for unidentified driving (TZ A§10.4); the sample then opens or extends an unidentified_events buffer entry.
/// * [dutyStatus] - DutyStatus is the duty status in force at TS, when known.
/// * [engineHours] - EngineHours is the ECM total engine time in hours.
/// * [fuelPct] 
/// * [headingDeg] 
/// * [ignition] 
/// * [lat] 
/// * [lng] 
/// * [odometerM] - OdometerM is the ECM total distance in metres.
/// * [oilLevelPct] 
/// * [speedKmh] 
/// * [ts] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint, GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder> {
  @BuiltValueField(wireName: r'battery_pct')
  num? get batteryPct;

  @BuiltValueField(wireName: r'battery_voltage_v')
  num? get batteryVoltageV;

  @BuiltValueField(wireName: r'coolant_level_pct')
  num? get coolantLevelPct;

  @BuiltValueField(wireName: r'coolant_temp_c')
  num? get coolantTempC;

  /// Diagnostics are the FMCSA Appendix A letters active at TS (TZ §10.5). Send an empty array to clear the stored codes; omit the field to leave them untouched.
  @BuiltValueField(wireName: r'diagnostics')
  BuiltList<String>? get diagnostics;

  /// Disconnected marks the sample the ELD sends when it loses the link to the phone (TZ §10.1 \"Disconnected\").
  @BuiltValueField(wireName: r'disconnected')
  bool? get disconnected;

  /// DriverID is null for unidentified driving (TZ A§10.4); the sample then opens or extends an unidentified_events buffer entry.
  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  /// DutyStatus is the duty status in force at TS, when known.
  @BuiltValueField(wireName: r'duty_status')
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum? get dutyStatus;
  // enum dutyStatusEnum {  OFF,  SB,  DR,  ON,  };

  /// EngineHours is the ECM total engine time in hours.
  @BuiltValueField(wireName: r'engine_hours')
  num? get engineHours;

  @BuiltValueField(wireName: r'fuel_pct')
  num? get fuelPct;

  @BuiltValueField(wireName: r'heading_deg')
  num? get headingDeg;

  @BuiltValueField(wireName: r'ignition')
  bool? get ignition;

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  /// OdometerM is the ECM total distance in metres.
  @BuiltValueField(wireName: r'odometer_m')
  int? get odometerM;

  @BuiltValueField(wireName: r'oil_level_pct')
  num? get oilLevelPct;

  @BuiltValueField(wireName: r'speed_kmh')
  num? get speedKmh;

  @BuiltValueField(wireName: r'ts')
  DateTime get ts;

  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint, _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.batteryPct != null) {
      yield r'battery_pct';
      yield serializers.serialize(
        object.batteryPct,
        specifiedType: const FullType(num),
      );
    }
    if (object.batteryVoltageV != null) {
      yield r'battery_voltage_v';
      yield serializers.serialize(
        object.batteryVoltageV,
        specifiedType: const FullType(num),
      );
    }
    if (object.coolantLevelPct != null) {
      yield r'coolant_level_pct';
      yield serializers.serialize(
        object.coolantLevelPct,
        specifiedType: const FullType(num),
      );
    }
    if (object.coolantTempC != null) {
      yield r'coolant_temp_c';
      yield serializers.serialize(
        object.coolantTempC,
        specifiedType: const FullType(num),
      );
    }
    if (object.diagnostics != null) {
      yield r'diagnostics';
      yield serializers.serialize(
        object.diagnostics,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.disconnected != null) {
      yield r'disconnected';
      yield serializers.serialize(
        object.disconnected,
        specifiedType: const FullType(bool),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.dutyStatus != null) {
      yield r'duty_status';
      yield serializers.serialize(
        object.dutyStatus,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum),
      );
    }
    if (object.engineHours != null) {
      yield r'engine_hours';
      yield serializers.serialize(
        object.engineHours,
        specifiedType: const FullType(num),
      );
    }
    if (object.fuelPct != null) {
      yield r'fuel_pct';
      yield serializers.serialize(
        object.fuelPct,
        specifiedType: const FullType(num),
      );
    }
    if (object.headingDeg != null) {
      yield r'heading_deg';
      yield serializers.serialize(
        object.headingDeg,
        specifiedType: const FullType(num),
      );
    }
    if (object.ignition != null) {
      yield r'ignition';
      yield serializers.serialize(
        object.ignition,
        specifiedType: const FullType(bool),
      );
    }
    if (object.lat != null) {
      yield r'lat';
      yield serializers.serialize(
        object.lat,
        specifiedType: const FullType(num),
      );
    }
    if (object.lng != null) {
      yield r'lng';
      yield serializers.serialize(
        object.lng,
        specifiedType: const FullType(num),
      );
    }
    if (object.odometerM != null) {
      yield r'odometer_m';
      yield serializers.serialize(
        object.odometerM,
        specifiedType: const FullType(int),
      );
    }
    if (object.oilLevelPct != null) {
      yield r'oil_level_pct';
      yield serializers.serialize(
        object.oilLevelPct,
        specifiedType: const FullType(num),
      );
    }
    if (object.speedKmh != null) {
      yield r'speed_kmh';
      yield serializers.serialize(
        object.speedKmh,
        specifiedType: const FullType(num),
      );
    }
    yield r'ts';
    yield serializers.serialize(
      object.ts,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'battery_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.batteryPct = valueDes;
          break;
        case r'battery_voltage_v':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.batteryVoltageV = valueDes;
          break;
        case r'coolant_level_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.coolantLevelPct = valueDes;
          break;
        case r'coolant_temp_c':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.coolantTempC = valueDes;
          break;
        case r'diagnostics':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.diagnostics.replace(valueDes);
          break;
        case r'disconnected':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.disconnected = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'duty_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum?;
          if (valueDes == null) continue;
          result.dutyStatus = valueDes;
          break;
        case r'engine_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.engineHours = valueDes;
          break;
        case r'fuel_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.fuelPct = valueDes;
          break;
        case r'heading_deg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.headingDeg = valueDes;
          break;
        case r'ignition':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.ignition = valueDes;
          break;
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lng = valueDes;
          break;
        case r'odometer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.odometerM = valueDes;
          break;
        case r'oil_level_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.oilLevelPct = valueDes;
          break;
        case r'speed_kmh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.speedKmh = valueDes;
          break;
        case r'ts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.ts = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}


/// DutyStatus is the duty status in force at TS, when known.
class GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OFF')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum OFF = _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_OFF;
  @BuiltValueEnumConst(wireName: r'SB')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum SB = _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_SB;
  @BuiltValueEnumConst(wireName: r'DR')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum DR = _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_DR;
  @BuiltValueEnumConst(wireName: r'ON')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum ON = _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_ON;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPointDutyStatusEnumValueOf(name);
}

