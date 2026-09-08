//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_app_config.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig
///
/// Properties:
/// * [accessTokenTtlSeconds] - AccessTokenTTLSeconds lets a client schedule its refresh.
/// * [featureFlags] - FeatureFlags toggles optional modules per deployment.
/// * [forceUpdate] 
/// * [latestVersion] 
/// * [minSupportedVersion] 
/// * [serverTime] - ServerTime lets the client detect clock drift before signing events.
/// * [supportEmail] - SupportEmail is shown on the mobile about screen.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig, GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder> {
  /// AccessTokenTTLSeconds lets a client schedule its refresh.
  @BuiltValueField(wireName: r'access_token_ttl_seconds')
  int? get accessTokenTtlSeconds;

  /// FeatureFlags toggles optional modules per deployment.
  @BuiltValueField(wireName: r'feature_flags')
  BuiltMap<String, bool>? get featureFlags;

  @BuiltValueField(wireName: r'force_update')
  bool? get forceUpdate;

  @BuiltValueField(wireName: r'latest_version')
  String? get latestVersion;

  @BuiltValueField(wireName: r'min_supported_version')
  String? get minSupportedVersion;

  /// ServerTime lets the client detect clock drift before signing events.
  @BuiltValueField(wireName: r'server_time')
  DateTime? get serverTime;

  /// SupportEmail is shown on the mobile about screen.
  @BuiltValueField(wireName: r'support_email')
  String? get supportEmail;

  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig, _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.accessTokenTtlSeconds != null) {
      yield r'access_token_ttl_seconds';
      yield serializers.serialize(
        object.accessTokenTtlSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.featureFlags != null) {
      yield r'feature_flags';
      yield serializers.serialize(
        object.featureFlags,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType(bool)]),
      );
    }
    if (object.forceUpdate != null) {
      yield r'force_update';
      yield serializers.serialize(
        object.forceUpdate,
        specifiedType: const FullType(bool),
      );
    }
    if (object.latestVersion != null) {
      yield r'latest_version';
      yield serializers.serialize(
        object.latestVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.minSupportedVersion != null) {
      yield r'min_supported_version';
      yield serializers.serialize(
        object.minSupportedVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.serverTime != null) {
      yield r'server_time';
      yield serializers.serialize(
        object.serverTime,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.supportEmail != null) {
      yield r'support_email';
      yield serializers.serialize(
        object.supportEmail,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'access_token_ttl_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.accessTokenTtlSeconds = valueDes;
          break;
        case r'feature_flags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(bool)]),
          ) as BuiltMap<String, bool>?;
          if (valueDes == null) continue;
          result.featureFlags.replace(valueDes);
          break;
        case r'force_update':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.forceUpdate = valueDes;
          break;
        case r'latest_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.latestVersion = valueDes;
          break;
        case r'min_supported_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.minSupportedVersion = valueDes;
          break;
        case r'server_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.serverTime = valueDes;
          break;
        case r'support_email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.supportEmail = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder();
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


