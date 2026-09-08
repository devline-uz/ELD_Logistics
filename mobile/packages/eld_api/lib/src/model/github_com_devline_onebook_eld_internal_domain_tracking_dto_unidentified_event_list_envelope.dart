//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_tracking_dto_unidentified_event.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_tracking_dto_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_tracking_dto_unidentified_event_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope, GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainTrackingDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope, _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainTrackingDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelopeBuilder();
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


