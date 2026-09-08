//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_hos_policy_doc.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_hos_policy.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy
///
/// Properties:
/// * [createdAt] 
/// * [createdBy] 
/// * [effectiveFrom] 
/// * [id] 
/// * [policy] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy, GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder> {
  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'effective_from')
  DateTime? get effectiveFrom;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'policy')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc? get policy;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.createdBy != null) {
      yield r'created_by';
      yield serializers.serialize(
        object.createdBy,
        specifiedType: const FullType(String),
      );
    }
    if (object.effectiveFrom != null) {
      yield r'effective_from';
      yield serializers.serialize(
        object.effectiveFrom,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.policy != null) {
      yield r'policy';
      yield serializers.serialize(
        object.policy,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdBy = valueDes;
          break;
        case r'effective_from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.effectiveFrom = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'policy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc?;
          if (valueDes == null) continue;
          result.policy.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicy deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyBuilder();
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


