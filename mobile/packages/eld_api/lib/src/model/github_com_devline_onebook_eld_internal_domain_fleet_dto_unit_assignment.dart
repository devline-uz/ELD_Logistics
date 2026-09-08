//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_assignment.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment
///
/// Properties:
/// * [assignedAt] 
/// * [driverId] 
/// * [driverName] 
/// * [id] 
/// * [role] 
/// * [unassignedAt] 
/// * [unitId] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder> {
  @BuiltValueField(wireName: r'assigned_at')
  DateTime? get assignedAt;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'role')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum? get role;
  // enum roleEnum {  primary,  co,  };

  @BuiltValueField(wireName: r'unassigned_at')
  DateTime? get unassignedAt;

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.assignedAt != null) {
      yield r'assigned_at';
      yield serializers.serialize(
        object.assignedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum),
      );
    }
    if (object.unassignedAt != null) {
      yield r'unassigned_at';
      yield serializers.serialize(
        object.unassignedAt,
        specifiedType: const FullType(DateTime),
      );
    }
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
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'assigned_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.assignedAt = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverName = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum?;
          if (valueDes == null) continue;
          result.role = valueDes;
          break;
        case r'unassigned_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.unassignedAt = valueDes;
          break;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder();
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


class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'primary')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum primary = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_primary;
  @BuiltValueEnumConst(wireName: r'co')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum co = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_co;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnumValueOf(name);
}

