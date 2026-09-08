//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_reports_dto_meta.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_reports_dto_activity_row.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_activity_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope
///
/// Properties:
/// * [data] - Data is the page of rows.
/// * [meta] - Meta carries the pagination counters.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope, GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder> {
  /// Data is the page of rows.
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow>? get data;

  /// Meta carries the pagination counters.
  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainReportsDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope, _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoActivityListEnvelopeBuilder();
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


