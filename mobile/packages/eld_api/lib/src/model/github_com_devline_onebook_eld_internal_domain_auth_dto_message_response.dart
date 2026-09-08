//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_message_response.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse
///
/// Properties:
/// * [message] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse, GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  String? get message;

  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse, _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder();
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


