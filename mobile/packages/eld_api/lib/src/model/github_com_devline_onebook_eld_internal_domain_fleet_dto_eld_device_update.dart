//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_eld_device_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate
///
/// Properties:
/// * [connectionType] 
/// * [firmware] 
/// * [model] 
/// * [notes] 
/// * [serial] 
/// * [simPresent] 
/// * [status] 
/// * [vendor] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate, GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateBuilder> {
  @BuiltValueField(wireName: r'connection_type')
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum? get connectionType;
  // enum connectionTypeEnum {  bluetooth,  wifi,  cellular,  usb,  };

  @BuiltValueField(wireName: r'firmware')
  String? get firmware;

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'serial')
  String? get serial;

  @BuiltValueField(wireName: r'sim_present')
  bool? get simPresent;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum? get status;
  // enum statusEnum {  active,  inactive,  malfunction,  };

  @BuiltValueField(wireName: r'vendor')
  String? get vendor;

  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate, _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.connectionType != null) {
      yield r'connection_type';
      yield serializers.serialize(
        object.connectionType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum),
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
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'connection_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum?;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'bluetooth')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum bluetooth = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum_bluetooth;
  @BuiltValueEnumConst(wireName: r'wifi')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum wifi = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum_wifi;
  @BuiltValueEnumConst(wireName: r'cellular')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum cellular = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum_cellular;
  @BuiltValueEnumConst(wireName: r'usb')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum usb = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum_usb;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateConnectionTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum active = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'malfunction')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum malfunction = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum_malfunction;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceUpdateStatusEnumValueOf(name);
}

