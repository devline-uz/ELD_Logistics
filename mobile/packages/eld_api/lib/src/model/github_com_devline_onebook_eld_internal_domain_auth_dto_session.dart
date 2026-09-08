//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_session.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoSession
///
/// Properties:
/// * [appVersion] 
/// * [createdAt] 
/// * [current] 
/// * [deviceId] 
/// * [deviceType] 
/// * [expiresAt] 
/// * [id] 
/// * [ip] - IP is truncated; the full address stays in the audit trail only.
/// * [lastSeenAt] 
/// * [status] 
/// * [userAgent] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoSession implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoSession, GithubComDevlineOnebookEldInternalDomainAuthDtoSessionBuilder> {
  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'current')
  bool? get current;

  @BuiltValueField(wireName: r'device_id')
  String? get deviceId;

  @BuiltValueField(wireName: r'device_type')
  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum? get deviceType;
  // enum deviceTypeEnum {  web,  phone,  tablet,  };

  @BuiltValueField(wireName: r'expires_at')
  DateTime? get expiresAt;

  @BuiltValueField(wireName: r'id')
  String? get id;

  /// IP is truncated; the full address stays in the audit trail only.
  @BuiltValueField(wireName: r'ip')
  String? get ip;

  @BuiltValueField(wireName: r'last_seen_at')
  DateTime? get lastSeenAt;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum? get status;
  // enum statusEnum {  active,  paused,  revoked,  };

  @BuiltValueField(wireName: r'user_agent')
  String? get userAgent;

  GithubComDevlineOnebookEldInternalDomainAuthDtoSession._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoSession([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoSessionBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoSession;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoSessionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoSession> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoSession> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoSession, _$GithubComDevlineOnebookEldInternalDomainAuthDtoSession];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoSession';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoSession object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
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
    if (object.current != null) {
      yield r'current';
      yield serializers.serialize(
        object.current,
        specifiedType: const FullType(bool),
      );
    }
    if (object.deviceId != null) {
      yield r'device_id';
      yield serializers.serialize(
        object.deviceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceType != null) {
      yield r'device_type';
      yield serializers.serialize(
        object.deviceType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum),
      );
    }
    if (object.expiresAt != null) {
      yield r'expires_at';
      yield serializers.serialize(
        object.expiresAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.ip != null) {
      yield r'ip';
      yield serializers.serialize(
        object.ip,
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
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum),
      );
    }
    if (object.userAgent != null) {
      yield r'user_agent';
      yield serializers.serialize(
        object.userAgent,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoSession object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoSessionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'current':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.current = valueDes;
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceId = valueDes;
          break;
        case r'device_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum?;
          if (valueDes == null) continue;
          result.deviceType = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.expiresAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'ip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ip = valueDes;
          break;
        case r'last_seen_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastSeenAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'user_agent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userAgent = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoSession deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoSessionBuilder();
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


class GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'web')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum web = _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum_web;
  @BuiltValueEnumConst(wireName: r'phone')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum phone = _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum_phone;
  @BuiltValueEnumConst(wireName: r'tablet')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum tablet = _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum_tablet;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionDeviceTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum active = _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'paused')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum paused = _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum_paused;
  @BuiltValueEnumConst(wireName: r'revoked')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum revoked = _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum_revoked;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainAuthDtoSessionStatusEnumValueOf(name);
}

