//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_eld_device_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate
///
/// Properties:
/// * [connectionType] 
/// * [firmware] 
/// * [model] 
/// * [notes] 
/// * [serial] 
/// * [simPresent] 
/// * [status] 
/// * [unitId] 
/// * [vendor] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate, GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateBuilder> {
  @BuiltValueField(wireName: r'connection_type')
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum? get connectionType;
  // enum connectionTypeEnum {  bluetooth,  wifi,  cellular,  usb,  };

  @BuiltValueField(wireName: r'firmware')
  String? get firmware;

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'serial')
  String get serial;

  @BuiltValueField(wireName: r'sim_present')
  bool? get simPresent;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum? get status;
  // enum statusEnum {  active,  inactive,  malfunction,  };

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'vendor')
  String get vendor;

  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate, _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.connectionType != null) {
      yield r'connection_type';
      yield serializers.serialize(
        object.connectionType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum),
      );
    }
    if (object.firmware != null) {
      yield r'firmware';
      yield serializers.serialize(
        object.firmware,
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
    yield r'serial';
    yield serializers.serialize(
      object.serial,
      specifiedType: const FullType(String),
    );
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum),
      );
    }
    if (object.unitId != null) {
      yield r'unit_id';
      yield serializers.serialize(
        object.unitId,
        specifiedType: const FullType(String),
      );
    }
    yield r'vendor';
    yield serializers.serialize(
      object.vendor,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'connection_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum?;
          if (valueDes == null) continue;
          result.connectionType = valueDes;
          break;
        case r'firmware':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.firmware = valueDes;
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
            specifiedType: const FullType(String),
          ) as String;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum?;
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
        case r'vendor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'bluetooth')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum bluetooth = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum_bluetooth;
  @BuiltValueEnumConst(wireName: r'wifi')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum wifi = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum_wifi;
  @BuiltValueEnumConst(wireName: r'cellular')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum cellular = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum_cellular;
  @BuiltValueEnumConst(wireName: r'usb')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum usb = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum_usb;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateConnectionTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum active = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'malfunction')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum malfunction = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum_malfunction;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceCreateStatusEnumValueOf(name);
}

