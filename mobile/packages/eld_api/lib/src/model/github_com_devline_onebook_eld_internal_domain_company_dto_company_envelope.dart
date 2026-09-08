//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_company.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_company_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope, GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany? get data;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany?;
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
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyEnvelopeBuilder();
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


