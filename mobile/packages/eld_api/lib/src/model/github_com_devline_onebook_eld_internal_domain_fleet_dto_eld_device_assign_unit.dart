//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_eld_device_assign_unit.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit
///
/// Properties:
/// * [unitId] - UnitID is null to detach the device from its current unit.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit, GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnitBuilder> {
  /// UnitID is null to detach the device from its current unit.
  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnitBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnitSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnitSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit, _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.unitId != null) {
      yield r'unit_id';
      yield serializers.serialize(
        object.unitId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnitBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceAssignUnitBuilder();
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


