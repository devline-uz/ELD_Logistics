//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_reports_dto_export_job.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_export_job_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope
///
/// Properties:
/// * [data] - Data is the job.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope, GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder> {
  /// Data is the job.
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob? get data;

  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope, _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob?;
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
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobEnvelopeBuilder();
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


