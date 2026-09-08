//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_password_forgot_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest
///
/// Properties:
/// * [login] - Login is the username or the email address of the account.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest, GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder> {
  /// Login is the username or the email address of the account.
  @BuiltValueField(wireName: r'login')
  String get login;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest, _$GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'login';
    yield serializers.serialize(
      object.login,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'login':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.login = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoPasswordForgotRequestBuilder();
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


