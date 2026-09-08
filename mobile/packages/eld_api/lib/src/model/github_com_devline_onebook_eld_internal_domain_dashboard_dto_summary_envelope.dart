//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dashboard_dto_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dashboard_dto_summary_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope, GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary? get data;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope, _$GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary),
          ) as GithubComDevlineOnebookEldInternalDomainDashboardDtoSummary?;
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
  GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelopeBuilder();
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


