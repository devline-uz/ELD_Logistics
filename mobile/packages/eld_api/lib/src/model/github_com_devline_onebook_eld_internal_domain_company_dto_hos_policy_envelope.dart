//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_hos_policy.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_hos_policy_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope, GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy? get data;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy?;
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
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyEnvelopeBuilder();
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


