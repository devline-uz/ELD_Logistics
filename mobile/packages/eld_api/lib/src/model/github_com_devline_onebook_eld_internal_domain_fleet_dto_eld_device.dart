//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_eld_device.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice
///
/// Properties:
/// * [connectionType] 
/// * [createdAt] 
/// * [firmware] 
/// * [id] 
/// * [lastSeenAt] 
/// * [malfunctionCodes] - MalfunctionCodes are the raised FMCSA Appendix A letters (P/E/T/L/R/S/O).
/// * [model] 
/// * [notes] 
/// * [serial] 
/// * [simPresent] 
/// * [status] 
/// * [unitId] 
/// * [unitNumber] 
/// * [updatedAt] 
/// * [vendor] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice, GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceBuilder> {
  @BuiltValueField(wireName: r'connection_type')
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum? get connectionType;
  // enum connectionTypeEnum {  bluetooth,  wifi,  cellular,  usb,  };

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'firmware')
  String? get firmware;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'last_seen_at')
  DateTime? get lastSeenAt;

  /// MalfunctionCodes are the raised FMCSA Appendix A letters (P/E/T/L/R/S/O).
  @BuiltValueField(wireName: r'malfunction_codes')
  BuiltList<String>? get malfunctionCodes;

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'serial')
  String? get serial;

  @BuiltValueField(wireName: r'sim_present')
  bool? get simPresent;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum? get status;
  // enum statusEnum {  active,  inactive,  malfunction,  };

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'vendor')
  String? get vendor;

  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice, _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.connectionType != null) {
      yield r'connection_type';
      yield serializers.serialize(
        object.connectionType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.firmware != null) {
      yield r'firmware';
      yield serializers.serialize(
        object.firmware,
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
        specifiedType: const FullType(BuiltList, [FullType(String)]),
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
    if (object.serial != null) {
      yield r'serial';
      yield serializers.serialize(
        object.serial,
        specifiedType: const FullType(String),
      );
    }
    if (object.simPresent != null) {
      yield r'sim_present';
      yield serializers.serialize(
        object.simPresent,
        specifiedType: const FullType(bool),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum),
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
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.vendor != null) {
      yield r'vendor';
      yield serializers.serialize(
        object.vendor,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'connection_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum?;
          if (valueDes == null) continue;
          result.connectionType = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'firmware':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.firmware = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
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
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.malfunctionCodes.replace(valueDes);
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
        case r'serial':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.serial = valueDes;
          break;
        case r'sim_present':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.simPresent = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
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
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        case r'vendor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vendor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceBuilder();
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


class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'bluetooth')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum bluetooth = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum_bluetooth;
  @BuiltValueEnumConst(wireName: r'wifi')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum wifi = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum_wifi;
  @BuiltValueEnumConst(wireName: r'cellular')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum cellular = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum_cellular;
  @BuiltValueEnumConst(wireName: r'usb')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum usb = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum_usb;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceConnectionTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum active = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'malfunction')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum malfunction = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum_malfunction;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceStatusEnumValueOf(name);
}

