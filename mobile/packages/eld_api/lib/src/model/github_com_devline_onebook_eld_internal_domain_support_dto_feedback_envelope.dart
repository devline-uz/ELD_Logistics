//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_support_dto_feedback.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_support_dto_feedback_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope, GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback? get data;

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope, _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback),
          ) as GithubComDevlineOnebookEldInternalDomainSupportDtoFeedback?;
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
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackEnvelopeBuilder();
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


