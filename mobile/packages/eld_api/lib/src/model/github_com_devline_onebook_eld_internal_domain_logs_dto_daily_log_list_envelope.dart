//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_daily_log_summary.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_daily_log_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope, GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainLogsDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope, _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogListEnvelopeBuilder();
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


