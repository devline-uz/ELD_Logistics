//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope, GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest? get data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope, _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest?;
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
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelopeBuilder();
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


