//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_invitation_accept_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest
///
/// Properties:
/// * [password] 
/// * [pin] - PIN optionally sets the 6 digit driver PIN in the same call.
/// * [token] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest, GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder> {
  @BuiltValueField(wireName: r'password')
  String get password;

  /// PIN optionally sets the 6 digit driver PIN in the same call.
  @BuiltValueField(wireName: r'pin')
  String? get pin;

  @BuiltValueField(wireName: r'token')
  String get token;

  GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest, _$GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
    if (object.pin != null) {
      yield r'pin';
      yield serializers.serialize(
        object.pin,
        specifiedType: const FullType(String),
      );
    }
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder result,
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
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pin = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoInvitationAcceptRequestBuilder();
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


