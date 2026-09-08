//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_branch.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_branch_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope, GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchListEnvelopeBuilder();
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


