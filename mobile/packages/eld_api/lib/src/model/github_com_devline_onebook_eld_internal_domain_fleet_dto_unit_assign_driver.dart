//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_assign_driver.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver
///
/// Properties:
/// * [driverId] 
/// * [role] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder> {
  @BuiltValueField(wireName: r'driver_id')
  String get driverId;

  @BuiltValueField(wireName: r'role')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum get role;
  // enum roleEnum {  primary,  co,  };

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'driver_id';
    yield serializers.serialize(
      object.driverId,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverId = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder();
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


class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'primary')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum primary = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_primary;
  @BuiltValueEnumConst(wireName: r'co')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum co = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_co;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnumValueOf(name);
}

