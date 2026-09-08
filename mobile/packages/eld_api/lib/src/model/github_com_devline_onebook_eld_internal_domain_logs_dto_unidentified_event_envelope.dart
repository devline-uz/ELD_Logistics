//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_unidentified_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_unidentified_event_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope, GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent? get data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope, _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent?;
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
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventEnvelopeBuilder();
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


