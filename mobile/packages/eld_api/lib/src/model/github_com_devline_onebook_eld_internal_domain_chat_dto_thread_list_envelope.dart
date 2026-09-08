//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_chat_dto_thread.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_chat_dto_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_chat_dto_thread_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope, GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainChatDtoThread>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainChatDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope, _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainChatDtoThread)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainChatDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainChatDtoThread)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainChatDtoThread>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainChatDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainChatDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainChatDtoThreadListEnvelopeBuilder();
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


