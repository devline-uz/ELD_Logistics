//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_chat_dto_message.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_chat_dto_cursor_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_chat_dto_message_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope, GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainChatDtoMessage>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope, _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainChatDtoMessage)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainChatDtoMessage)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainChatDtoMessage>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta),
          ) as GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta?;
          if (valueDes == null) continue;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainChatDtoMessageListEnvelopeBuilder();
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


