//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnit
///
/// Properties:
/// * [activatedOn] 
/// * [branchId] 
/// * [branchName] 
/// * [createdAt] 
/// * [eldDeviceId] - EldDeviceID is the ELD currently wired to this unit, null when none.
/// * [eldDeviceSerial] 
/// * [fuelType] 
/// * [gvwrClass] 
/// * [id] 
/// * [licensePlate] 
/// * [make] 
/// * [model] 
/// * [notes] 
/// * [odometerM] - OdometerM is the last telemetry odometer reading in metres, null when the unit has never reported. The backend never converts units.
/// * [outOfService] 
/// * [plateRegion] 
/// * [sleeperBerth] 
/// * [status] 
/// * [telemetryAt] 
/// * [unitNumber] 
/// * [updatedAt] 
/// * [vin] 
/// * [year] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnit implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnit, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitBuilder> {
  @BuiltValueField(wireName: r'activated_on')
  DateTime? get activatedOn;

  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'branch_name')
  String? get branchName;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  /// EldDeviceID is the ELD currently wired to this unit, null when none.
  @BuiltValueField(wireName: r'eld_device_id')
  String? get eldDeviceId;

  @BuiltValueField(wireName: r'eld_device_serial')
  String? get eldDeviceSerial;

  @BuiltValueField(wireName: r'fuel_type')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum? get fuelType;
  // enum fuelTypeEnum {  diesel,  petrol,  cng,  lpg,  electric,  hybrid,  };

  @BuiltValueField(wireName: r'gvwr_class')
  String? get gvwrClass;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'license_plate')
  String? get licensePlate;

  @BuiltValueField(wireName: r'make')
  String? get make;

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// OdometerM is the last telemetry odometer reading in metres, null when the unit has never reported. The backend never converts units.
  @BuiltValueField(wireName: r'odometer_m')
  int? get odometerM;

  @BuiltValueField(wireName: r'out_of_service')
  bool? get outOfService;

  @BuiltValueField(wireName: r'plate_region')
  String? get plateRegion;

  @BuiltValueField(wireName: r'sleeper_berth')
  bool? get sleeperBerth;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum? get status;
  // enum statusEnum {  active,  inactive,  };

  @BuiltValueField(wireName: r'telemetry_at')
  DateTime? get telemetryAt;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'vin')
  String? get vin;

  @BuiltValueField(wireName: r'year')
  int? get year;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnit._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnit([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnit> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnit> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnit, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnit];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.activatedOn != null) {
      yield r'activated_on';
      yield serializers.serialize(
        object.activatedOn,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.branchName != null) {
      yield r'branch_name';
      yield serializers.serialize(
        object.branchName,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.eldDeviceId != null) {
      yield r'eld_device_id';
      yield serializers.serialize(
        object.eldDeviceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.eldDeviceSerial != null) {
      yield r'eld_device_serial';
      yield serializers.serialize(
        object.eldDeviceSerial,
        specifiedType: const FullType(String),
      );
    }
    if (object.fuelType != null) {
      yield r'fuel_type';
      yield serializers.serialize(
        object.fuelType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum),
      );
    }
    if (object.gvwrClass != null) {
      yield r'gvwr_class';
      yield serializers.serialize(
        object.gvwrClass,
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
    if (object.licensePlate != null) {
      yield r'license_plate';
      yield serializers.serialize(
        object.licensePlate,
        specifiedType: const FullType(String),
      );
    }
    if (object.make != null) {
      yield r'make';
      yield serializers.serialize(
        object.make,
        specifiedType: const FullType(String),
      );
    }
    if (object.model != null) {
      yield r'model';
      yield serializers.serialize(
        object.model,
        specifiedType: const FullType(String),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.odometerM != null) {
      yield r'odometer_m';
      yield serializers.serialize(
        object.odometerM,
        specifiedType: const FullType(int),
      );
    }
    if (object.outOfService != null) {
      yield r'out_of_service';
      yield serializers.serialize(
        object.outOfService,
        specifiedType: const FullType(bool),
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
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum),
      );
    }
    if (object.telemetryAt != null) {
      yield r'telemetry_at';
      yield serializers.serialize(
        object.telemetryAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.unitNumber != null) {
      yield r'unit_number';
      yield serializers.serialize(
        object.unitNumber,
        specifiedType: const FullType(String),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
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
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'activated_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.activatedOn = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'branch_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchName = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'eld_device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.eldDeviceId = valueDes;
          break;
        case r'eld_device_serial':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.eldDeviceSerial = valueDes;
          break;
        case r'fuel_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum?;
          if (valueDes == null) continue;
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'license_plate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.licensePlate = valueDes;
          break;
        case r'make':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.make = valueDes;
          break;
        case r'model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
        case r'odometer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.odometerM = valueDes;
          break;
        case r'out_of_service':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.outOfService = valueDes;
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'telemetry_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.telemetryAt = valueDes;
          break;
        case r'unit_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitNumber = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitBuilder();
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


class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'diesel')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum diesel = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum_diesel;
  @BuiltValueEnumConst(wireName: r'petrol')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum petrol = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum_petrol;
  @BuiltValueEnumConst(wireName: r'cng')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum cng = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum_cng;
  @BuiltValueEnumConst(wireName: r'lpg')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum lpg = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum_lpg;
  @BuiltValueEnumConst(wireName: r'electric')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum electric = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum_electric;
  @BuiltValueEnumConst(wireName: r'hybrid')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum hybrid = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum_hybrid;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitFuelTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum active = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitStatusEnumValueOf(name);
}

