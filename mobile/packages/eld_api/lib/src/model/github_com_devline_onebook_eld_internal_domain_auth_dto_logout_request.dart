//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_logout_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest
///
/// Properties:
/// * [pause] - Pause keeps the session recoverable with a PIN (Leave Truck).
/// * [refreshToken] - RefreshToken optionally targets one session explicitly.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest, GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder> {
  /// Pause keeps the session recoverable with a PIN (Leave Truck).
  @BuiltValueField(wireName: r'pause')
  bool? get pause;

  /// RefreshToken optionally targets one session explicitly.
  @BuiltValueField(wireName: r'refresh_token')
  String? get refreshToken;

  GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest, _$GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.pause != null) {
      yield r'pause';
      yield serializers.serialize(
        object.pause,
        specifiedType: const FullType(bool),
      );
    }
    if (object.refreshToken != null) {
      yield r'refresh_token';
      yield serializers.serialize(
        object.refreshToken,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pause':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.pause = valueDes;
          break;
        case r'refresh_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoLogoutRequestBuilder();
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


