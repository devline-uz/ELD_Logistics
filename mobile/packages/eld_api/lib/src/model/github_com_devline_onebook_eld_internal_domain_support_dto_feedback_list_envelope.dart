//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_support_dto_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_support_dto_feedback.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_support_dto_feedback_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope, GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainSupportDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope, _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback)]),
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
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback>?;
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
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackListEnvelopeBuilder();
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


