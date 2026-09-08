//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_support_dto_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_support_dto_ticket_message.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_message_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope, GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainSupportDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope, _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSupportDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessage>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSupportDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainSupportDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageListEnvelopeBuilder();
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


