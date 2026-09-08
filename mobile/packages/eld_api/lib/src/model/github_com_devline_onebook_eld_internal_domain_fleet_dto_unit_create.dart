//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate
///
/// Properties:
/// * [branchId] 
/// * [eldDeviceId] 
/// * [fuelType] 
/// * [gvwrClass] 
/// * [licensePlate] 
/// * [make] 
/// * [model] 
/// * [notes] 
/// * [plateRegion] 
/// * [sleeperBerth] 
/// * [unitNumber] 
/// * [vin] 
/// * [year] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'eld_device_id')
  String? get eldDeviceId;

  @BuiltValueField(wireName: r'fuel_type')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum get fuelType;
  // enum fuelTypeEnum {  diesel,  petrol,  cng,  lpg,  electric,  hybrid,  };

  @BuiltValueField(wireName: r'gvwr_class')
  String? get gvwrClass;

  @BuiltValueField(wireName: r'license_plate')
  String get licensePlate;

  @BuiltValueField(wireName: r'make')
  String get make;

  @BuiltValueField(wireName: r'model')
  String get model;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'plate_region')
  String? get plateRegion;

  @BuiltValueField(wireName: r'sleeper_berth')
  bool? get sleeperBerth;

  @BuiltValueField(wireName: r'unit_number')
  String get unitNumber;

  @BuiltValueField(wireName: r'vin')
  String? get vin;

  @BuiltValueField(wireName: r'year')
  int? get year;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.eldDeviceId != null) {
      yield r'eld_device_id';
      yield serializers.serialize(
        object.eldDeviceId,
        specifiedType: const FullType(String),
      );
    }
    yield r'fuel_type';
    yield serializers.serialize(
      object.fuelType,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum),
    );
    if (object.gvwrClass != null) {
      yield r'gvwr_class';
      yield serializers.serialize(
        object.gvwrClass,
        specifiedType: const FullType(String),
      );
    }
    yield r'license_plate';
    yield serializers.serialize(
      object.licensePlate,
      specifiedType: const FullType(String),
    );
    yield r'make';
    yield serializers.serialize(
      object.make,
      specifiedType: const FullType(String),
    );
    yield r'model';
    yield serializers.serialize(
      object.model,
      specifiedType: const FullType(String),
    );
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.plateRegion != null) {
      yield r'plate_region';
      yield serializers.serialize(
        object.plateRegion,
        specifiedType: const FullType(String),
      );
    }
    if (object.sleeperBerth != null) {
      yield r'sleeper_berth';
      yield serializers.serialize(
        object.sleeperBerth,
        specifiedType: const FullType(bool),
      );
    }
    yield r'unit_number';
    yield serializers.serialize(
      object.unitNumber,
      specifiedType: const FullType(String),
    );
    if (object.vin != null) {
      yield r'vin';
      yield serializers.serialize(
        object.vin,
        specifiedType: const FullType(String),
      );
    }
    if (object.year != null) {
      yield r'year';
      yield serializers.serialize(
        object.year,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'eld_device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.eldDeviceId = valueDes;
          break;
        case r'fuel_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum;
          result.fuelType = valueDes;
          break;
        case r'gvwr_class':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.gvwrClass = valueDes;
          break;
        case r'license_plate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.licensePlate = valueDes;
          break;
        case r'make':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.make = valueDes;
          break;
        case r'model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.model = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'plate_region':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.plateRegion = valueDes;
          break;
        case r'sleeper_berth':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.sleeperBerth = valueDes;
          break;
        case r'unit_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unitNumber = valueDes;
          break;
        case r'vin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vin = valueDes;
          break;
        case r'year':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.year = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'diesel')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum diesel = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum_diesel;
  @BuiltValueEnumConst(wireName: r'petrol')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum petrol = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum_petrol;
  @BuiltValueEnumConst(wireName: r'cng')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum cng = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum_cng;
  @BuiltValueEnumConst(wireName: r'lpg')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum lpg = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum_lpg;
  @BuiltValueEnumConst(wireName: r'electric')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum electric = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum_electric;
  @BuiltValueEnumConst(wireName: r'hybrid')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum hybrid = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum_hybrid;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitCreateFuelTypeEnumValueOf(name);
}

