//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_password_reset_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest
///
/// Properties:
/// * [password] 
/// * [token] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest, GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder> {
  @BuiltValueField(wireName: r'password')
  String get password;

  @BuiltValueField(wireName: r'token')
  String get token;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest, _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
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
    GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordResetRequestBuilder();
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


