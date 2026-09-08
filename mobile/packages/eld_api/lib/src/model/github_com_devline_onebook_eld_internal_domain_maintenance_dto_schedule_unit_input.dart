//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_unit_input.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput
///
/// Properties:
/// * [lastServiceValue] - LastServiceValue is the odometer / engine hour reading of the last service in `interval_unit`. Omitted means \"read it from telemetry now\".
/// * [unitId] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder> {
  /// LastServiceValue is the odometer / engine hour reading of the last service in `interval_unit`. Omitted means \"read it from telemetry now\".
  @BuiltValueField(wireName: r'last_service_value')
  num? get lastServiceValue;

  @BuiltValueField(wireName: r'unit_id')
  String get unitId;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.lastServiceValue != null) {
      yield r'last_service_value';
      yield serializers.serialize(
        object.lastServiceValue,
        specifiedType: const FullType(num),
      );
    }
    yield r'unit_id';
    yield serializers.serialize(
      object.unitId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'last_service_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lastServiceValue = valueDes;
          break;
        case r'unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unitId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder();
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


