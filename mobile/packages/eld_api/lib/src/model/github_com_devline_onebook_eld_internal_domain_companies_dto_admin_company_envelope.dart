//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_companies_dto_company.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_companies_dto_admin_company_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope, GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany? get data;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope, _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany?;
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
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyEnvelopeBuilder();
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


