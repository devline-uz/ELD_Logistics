//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_duty_dto_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_duty_dto_duty_status_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_duty_dto_duty_status_event_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope, GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainDutyDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope, _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventListEnvelopeBuilder();
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


