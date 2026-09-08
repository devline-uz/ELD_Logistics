//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_notifications_dto_push_token.g.dart';

/// GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken
///
/// Properties:
/// * [appVersion] 
/// * [deviceId] 
/// * [lastSeenAt] 
/// * [platform] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken implements Built<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken, GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder> {
  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  @BuiltValueField(wireName: r'device_id')
  String? get deviceId;

  @BuiltValueField(wireName: r'last_seen_at')
  DateTime? get lastSeenAt;

  @BuiltValueField(wireName: r'platform')
  String? get platform;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken._();

  factory GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken([void updates(GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken> get serializer => _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken, _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
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
    if (object.lastSeenAt != null) {
      yield r'last_seen_at';
      yield serializers.serialize(
        object.lastSeenAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.platform != null) {
      yield r'platform';
      yield serializers.serialize(
        object.platform,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceId = valueDes;
          break;
        case r'last_seen_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastSeenAt = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.platform = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenBuilder();
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


