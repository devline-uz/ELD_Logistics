//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_refresh_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest
///
/// Properties:
/// * [appVersion] 
/// * [refreshToken] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest, GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder> {
  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  @BuiltValueField(wireName: r'refresh_token')
  String get refreshToken;

  GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest, _$GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    yield r'refresh_token';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder result,
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
        case r'refresh_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoRefreshRequestBuilder();
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


