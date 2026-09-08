//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_malfunction_code.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_telemetry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_diagnostics.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics
///
/// Properties:
/// * [connectionState] - ConnectionState is the administrator facing device state.
/// * [connectionType] 
/// * [deviceFirmware] 
/// * [deviceId] 
/// * [deviceModel] 
/// * [deviceSerial] 
/// * [deviceStatus] 
/// * [deviceVendor] 
/// * [lastSeenAt] 
/// * [malfunctionCodes] - MalfunctionCodes are FMCSA Appendix A letters: P power, E engine sync, T timing, L positioning, R data recording, S data transfer, O other.
/// * [simPresent] 
/// * [telemetry] 
/// * [telemetryAt] 
/// * [unitId] 
/// * [unitNumber] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsBuilder> {
  /// ConnectionState is the administrator facing device state.
  @BuiltValueField(wireName: r'connection_state')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum? get connectionState;
  // enum connectionStateEnum {  online,  offline,  disconnected,  malfunction,  no_device,  };

  @BuiltValueField(wireName: r'connection_type')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum? get connectionType;
  // enum connectionTypeEnum {  bluetooth,  wifi,  cellular,  usb,  };

  @BuiltValueField(wireName: r'device_firmware')
  String? get deviceFirmware;

  @BuiltValueField(wireName: r'device_id')
  String? get deviceId;

  @BuiltValueField(wireName: r'device_model')
  String? get deviceModel;

  @BuiltValueField(wireName: r'device_serial')
  String? get deviceSerial;

  @BuiltValueField(wireName: r'device_status')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum? get deviceStatus;
  // enum deviceStatusEnum {  active,  inactive,  malfunction,  };

  @BuiltValueField(wireName: r'device_vendor')
  String? get deviceVendor;

  @BuiltValueField(wireName: r'last_seen_at')
  DateTime? get lastSeenAt;

  /// MalfunctionCodes are FMCSA Appendix A letters: P power, E engine sync, T timing, L positioning, R data recording, S data transfer, O other.
  @BuiltValueField(wireName: r'malfunction_codes')
  BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode>? get malfunctionCodes;

  @BuiltValueField(wireName: r'sim_present')
  bool? get simPresent;

  @BuiltValueField(wireName: r'telemetry')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry? get telemetry;

  @BuiltValueField(wireName: r'telemetry_at')
  DateTime? get telemetryAt;

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.connectionState != null) {
      yield r'connection_state';
      yield serializers.serialize(
        object.connectionState,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum),
      );
    }
    if (object.connectionType != null) {
      yield r'connection_type';
      yield serializers.serialize(
        object.connectionType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum),
      );
    }
    if (object.deviceFirmware != null) {
      yield r'device_firmware';
      yield serializers.serialize(
        object.deviceFirmware,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceId != null) {
      yield r'device_id';
      yield serializers.serialize(
        object.deviceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceModel != null) {
      yield r'device_model';
      yield serializers.serialize(
        object.deviceModel,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceSerial != null) {
      yield r'device_serial';
      yield serializers.serialize(
        object.deviceSerial,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceStatus != null) {
      yield r'device_status';
      yield serializers.serialize(
        object.deviceStatus,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum),
      );
    }
    if (object.deviceVendor != null) {
      yield r'device_vendor';
      yield serializers.serialize(
        object.deviceVendor,
        specifiedType: const FullType(String),
      );
    }
    if (object.lastSeenAt != null) {
      yield r'last_seen_at';
      yield serializers.serialize(
        object.lastSeenAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.malfunctionCodes != null) {
      yield r'malfunction_codes';
      yield serializers.serialize(
        object.malfunctionCodes,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode)]),
      );
    }
    if (object.simPresent != null) {
      yield r'sim_present';
      yield serializers.serialize(
        object.simPresent,
        specifiedType: const FullType(bool),
      );
    }
    if (object.telemetry != null) {
      yield r'telemetry';
      yield serializers.serialize(
        object.telemetry,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry),
      );
    }
    if (object.telemetryAt != null) {
      yield r'telemetry_at';
      yield serializers.serialize(
        object.telemetryAt,
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
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'connection_state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum?;
          if (valueDes == null) continue;
          result.connectionState = valueDes;
          break;
        case r'connection_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum?;
          if (valueDes == null) continue;
          result.connectionType = valueDes;
          break;
        case r'device_firmware':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceFirmware = valueDes;
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceId = valueDes;
          break;
        case r'device_model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceModel = valueDes;
          break;
        case r'device_serial':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceSerial = valueDes;
          break;
        case r'device_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum?;
          if (valueDes == null) continue;
          result.deviceStatus = valueDes;
          break;
        case r'device_vendor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceVendor = valueDes;
          break;
        case r'last_seen_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastSeenAt = valueDes;
          break;
        case r'malfunction_codes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode>?;
          if (valueDes == null) continue;
          result.malfunctionCodes.replace(valueDes);
          break;
        case r'sim_present':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.simPresent = valueDes;
          break;
        case r'telemetry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitTelemetry?;
          if (valueDes == null) continue;
          result.telemetry.replace(valueDes);
          break;
        case r'telemetry_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.telemetryAt = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsBuilder();
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


/// ConnectionState is the administrator facing device state.
class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'online')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum online = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum_online;
  @BuiltValueEnumConst(wireName: r'offline')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum offline = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum_offline;
  @BuiltValueEnumConst(wireName: r'disconnected')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum disconnected = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum_disconnected;
  @BuiltValueEnumConst(wireName: r'malfunction')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum malfunction = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum_malfunction;
  @BuiltValueEnumConst(wireName: r'no_device')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum noDevice = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum_noDevice;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionStateEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'bluetooth')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum bluetooth = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum_bluetooth;
  @BuiltValueEnumConst(wireName: r'wifi')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum wifi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum_wifi;
  @BuiltValueEnumConst(wireName: r'cellular')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum cellular = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum_cellular;
  @BuiltValueEnumConst(wireName: r'usb')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum usb = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum_usb;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsConnectionTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum active = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'malfunction')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum malfunction = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum_malfunction;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsDeviceStatusEnumValueOf(name);
}

