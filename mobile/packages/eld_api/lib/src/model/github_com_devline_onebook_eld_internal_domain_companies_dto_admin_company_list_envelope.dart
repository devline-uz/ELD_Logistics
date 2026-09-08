//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_companies_dto_company.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_companies_dto_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_companies_dto_admin_company_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope, GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope, _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdminCompanyListEnvelopeBuilder();
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


