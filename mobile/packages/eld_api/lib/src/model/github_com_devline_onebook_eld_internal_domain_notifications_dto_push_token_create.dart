//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_notifications_dto_push_token_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate
///
/// Properties:
/// * [appVersion] 
/// * [deviceId] 
/// * [platform] 
/// * [token] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate implements Built<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate, GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder> {
  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  @BuiltValueField(wireName: r'platform')
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum get platform;
  // enum platformEnum {  android,  ios,  web,  };

  @BuiltValueField(wireName: r'token')
  String get token;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate._();

  factory GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate([void updates(GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate, _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum),
    );
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder result,
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
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum),
          ) as GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum;
          result.platform = valueDes;
          break;
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'android')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum android = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'ios')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum ios = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'web')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum web = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_web;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum> get values => _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnumValues;
  static GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenCreatePlatformEnumValueOf(name);
}

