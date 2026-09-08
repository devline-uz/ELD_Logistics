//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_chat_dto_message.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_chat_dto_message_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope, GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainChatDtoMessage? get data;

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope, _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainChatDtoMessage),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainChatDtoMessage),
          ) as GithubComDevlineOnebookEldInternalDomainChatDtoMessage?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainChatDtoMessageEnvelopeBuilder();
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


