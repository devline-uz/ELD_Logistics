//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_tracking_dto_driver_brief.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_tracking_dto_live_unit.g.dart';

/// GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit
///
/// Properties:
/// * [branchId] 
/// * [branchName] 
/// * [driver] 
/// * [dutyStatus] - DutyStatus is the HOS status of the driver at the wheel.
/// * [eldDeviceId] 
/// * [eldDeviceSerial] 
/// * [engineHours] 
/// * [headingDeg] 
/// * [lastSeenAt] - LastSeenAt is the timestamp of the last telemetry sample, null when the unit has never reported.
/// * [lat] 
/// * [lng] 
/// * [malfunctionCodes] 
/// * [odometerM] 
/// * [onlineStatus] - OnlineStatus is Online / Offline / Disconnected / Malfunction (TZ §10.1).
/// * [outOfService] - OutOfService mirrors units.out_of_service.
/// * [speedKmh] 
/// * [unitId] 
/// * [unitNumber] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit implements Built<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit, GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'branch_name')
  String? get branchName;

  @BuiltValueField(wireName: r'driver')
  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief? get driver;

  /// DutyStatus is the HOS status of the driver at the wheel.
  @BuiltValueField(wireName: r'duty_status')
  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum? get dutyStatus;
  // enum dutyStatusEnum {  OFF,  SB,  DR,  ON,  };

  @BuiltValueField(wireName: r'eld_device_id')
  String? get eldDeviceId;

  @BuiltValueField(wireName: r'eld_device_serial')
  String? get eldDeviceSerial;

  @BuiltValueField(wireName: r'engine_hours')
  num? get engineHours;

  @BuiltValueField(wireName: r'heading_deg')
  num? get headingDeg;

  /// LastSeenAt is the timestamp of the last telemetry sample, null when the unit has never reported.
  @BuiltValueField(wireName: r'last_seen_at')
  DateTime? get lastSeenAt;

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'malfunction_codes')
  BuiltList<String>? get malfunctionCodes;

  @BuiltValueField(wireName: r'odometer_m')
  int? get odometerM;

  /// OnlineStatus is Online / Offline / Disconnected / Malfunction (TZ §10.1).
  @BuiltValueField(wireName: r'online_status')
  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum? get onlineStatus;
  // enum onlineStatusEnum {  online,  offline,  disconnected,  malfunction,  };

  /// OutOfService mirrors units.out_of_service.
  @BuiltValueField(wireName: r'out_of_service')
  bool? get outOfService;

  @BuiltValueField(wireName: r'speed_kmh')
  num? get speedKmh;

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit._();

  factory GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit([void updates(GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit> get serializer => _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit, _$GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.driver != null) {
      yield r'driver';
      yield serializers.serialize(
        object.driver,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief),
      );
    }
    if (object.dutyStatus != null) {
      yield r'duty_status';
      yield serializers.serialize(
        object.dutyStatus,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum),
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
    if (object.engineHours != null) {
      yield r'engine_hours';
      yield serializers.serialize(
        object.engineHours,
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
    if (object.lastSeenAt != null) {
      yield r'last_seen_at';
      yield serializers.serialize(
        object.lastSeenAt,
        specifiedType: const FullType(DateTime),
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
    if (object.malfunctionCodes != null) {
      yield r'malfunction_codes';
      yield serializers.serialize(
        object.malfunctionCodes,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.odometerM != null) {
      yield r'odometer_m';
      yield serializers.serialize(
        object.odometerM,
        specifiedType: const FullType(int),
      );
    }
    if (object.onlineStatus != null) {
      yield r'online_status';
      yield serializers.serialize(
        object.onlineStatus,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum),
      );
    }
    if (object.outOfService != null) {
      yield r'out_of_service';
      yield serializers.serialize(
        object.outOfService,
        specifiedType: const FullType(bool),
      );
    }
    if (object.speedKmh != null) {
      yield r'speed_kmh';
      yield serializers.serialize(
        object.speedKmh,
        specifiedType: const FullType(num),
      );
    }
    if (object.unitId != null) {
      yield r'unit_id';
      yield serializers.serialize(
        object.unitId,
        specifiedType: const FullType(String),
      );
    }
    if (object.unitNumber != null) {
      yield r'unit_number';
      yield serializers.serialize(
        object.unitNumber,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitBuilder result,
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
        case r'branch_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchName = valueDes;
          break;
        case r'driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief),
          ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief?;
          if (valueDes == null) continue;
          result.driver.replace(valueDes);
          break;
        case r'duty_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum?;
          if (valueDes == null) continue;
          result.dutyStatus = valueDes;
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
        case r'engine_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.engineHours = valueDes;
          break;
        case r'heading_deg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.headingDeg = valueDes;
          break;
        case r'last_seen_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastSeenAt = valueDes;
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
        case r'malfunction_codes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.malfunctionCodes.replace(valueDes);
          break;
        case r'odometer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.odometerM = valueDes;
          break;
        case r'online_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum?;
          if (valueDes == null) continue;
          result.onlineStatus = valueDes;
          break;
        case r'out_of_service':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.outOfService = valueDes;
          break;
        case r'speed_kmh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.speedKmh = valueDes;
          break;
        case r'unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitId = valueDes;
          break;
        case r'unit_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitNumber = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitBuilder();
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


/// DutyStatus is the HOS status of the driver at the wheel.
class GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OFF')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum OFF = _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum_OFF;
  @BuiltValueEnumConst(wireName: r'SB')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum SB = _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum_SB;
  @BuiltValueEnumConst(wireName: r'DR')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum DR = _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum_DR;
  @BuiltValueEnumConst(wireName: r'ON')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum ON = _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum_ON;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitDutyStatusEnumValueOf(name);
}

/// OnlineStatus is Online / Offline / Disconnected / Malfunction (TZ §10.1).
class GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'online')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum online = _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum_online;
  @BuiltValueEnumConst(wireName: r'offline')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum offline = _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum_offline;
  @BuiltValueEnumConst(wireName: r'disconnected')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum disconnected = _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum_disconnected;
  @BuiltValueEnumConst(wireName: r'malfunction')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum malfunction = _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum_malfunction;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitOnlineStatusEnumValueOf(name);
}

