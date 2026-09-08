//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_report.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_report_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope, GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport? get data;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport?;
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
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelopeBuilder();
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


