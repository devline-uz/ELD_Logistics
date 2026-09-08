//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_telemetry.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry
///
/// Properties:
/// * [batteryPct] 
/// * [batteryVoltageV] 
/// * [coolantLevelPct] 
/// * [coolantTempC] 
/// * [engineHours] 
/// * [fuelPct] 
/// * [odometerM] 
/// * [oilLevelPct] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetryBuilder> {
  @BuiltValueField(wireName: r'battery_pct')
  num? get batteryPct;

  @BuiltValueField(wireName: r'battery_voltage_v')
  num? get batteryVoltageV;

  @BuiltValueField(wireName: r'coolant_level_pct')
  num? get coolantLevelPct;

  @BuiltValueField(wireName: r'coolant_temp_c')
  num? get coolantTempC;

  @BuiltValueField(wireName: r'engine_hours')
  num? get engineHours;

  @BuiltValueField(wireName: r'fuel_pct')
  num? get fuelPct;

  @BuiltValueField(wireName: r'odometer_m')
  int? get odometerM;

  @BuiltValueField(wireName: r'oil_level_pct')
  num? get oilLevelPct;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetryBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetrySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetrySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetryBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetryBuilder();
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


