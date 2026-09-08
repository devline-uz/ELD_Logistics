//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_hos_policy_doc_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_hos_policy_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate
///
/// Properties:
/// * [effectiveFrom] - EffectiveFrom must not be in the past: retroactive violations are forbidden. Omitted means \"now\".
/// * [policy] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate, GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder> {
  /// EffectiveFrom must not be in the past: retroactive violations are forbidden. Omitted means \"now\".
  @BuiltValueField(wireName: r'effective_from')
  DateTime? get effectiveFrom;

  @BuiltValueField(wireName: r'policy')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocInput get policy;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.effectiveFrom != null) {
      yield r'effective_from';
      yield serializers.serialize(
        object.effectiveFrom,
        specifiedType: const FullType(DateTime),
      );
    }
    yield r'policy';
    yield serializers.serialize(
      object.policy,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocInput),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'effective_from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.effectiveFrom = valueDes;
          break;
        case r'policy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocInput),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocInput;
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
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyCreateBuilder();
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


