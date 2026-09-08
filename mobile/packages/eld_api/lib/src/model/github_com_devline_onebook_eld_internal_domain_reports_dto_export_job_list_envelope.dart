//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_reports_dto_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_reports_dto_export_job.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_export_job_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope
///
/// Properties:
/// * [data] - Data is the page of jobs.
/// * [meta] - Meta carries the pagination counters.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope, GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder> {
  /// Data is the page of jobs.
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob>? get data;

  /// Meta carries the pagination counters.
  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainReportsDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope, _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob)]),
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
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob>?;
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
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobListEnvelopeBuilder();
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


