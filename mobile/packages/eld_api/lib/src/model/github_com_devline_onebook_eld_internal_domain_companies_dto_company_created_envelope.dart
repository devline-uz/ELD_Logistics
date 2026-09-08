//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_companies_dto_company_created.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_companies_dto_company_created_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope, GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated? get data;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope, _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated?;
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
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedEnvelopeBuilder();
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


