//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_duty_dto_hos_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_duty_dto_hos_summary_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope, GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary? get data;

  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope, _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary?;
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
  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryEnvelopeBuilder();
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


