//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_companies_dto_subscription_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate
///
/// Properties:
/// * [clearEndAt] - ClearEndAt removes subscription_end_at (perpetual / internal tenants).
/// * [plan] 
/// * [subscriptionEndAt] - EndAt is the moment the paid period ends. Send null together with clear_end_at to drop the date entirely.
/// * [subscriptionStatus] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate implements Built<GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate, GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder> {
  /// ClearEndAt removes subscription_end_at (perpetual / internal tenants).
  @BuiltValueField(wireName: r'clear_end_at')
  bool? get clearEndAt;

  @BuiltValueField(wireName: r'plan')
  String? get plan;

  /// EndAt is the moment the paid period ends. Send null together with clear_end_at to drop the date entirely.
  @BuiltValueField(wireName: r'subscription_end_at')
  DateTime? get subscriptionEndAt;

  @BuiltValueField(wireName: r'subscription_status')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum? get subscriptionStatus;
  // enum subscriptionStatusEnum {  trial,  active,  grace,  readonly,  };

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate([void updates(GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate, _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.clearEndAt != null) {
      yield r'clear_end_at';
      yield serializers.serialize(
        object.clearEndAt,
        specifiedType: const FullType(bool),
      );
    }
    if (object.plan != null) {
      yield r'plan';
      yield serializers.serialize(
        object.plan,
        specifiedType: const FullType(String),
      );
    }
    if (object.subscriptionEndAt != null) {
      yield r'subscription_end_at';
      yield serializers.serialize(
        object.subscriptionEndAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.subscriptionStatus != null) {
      yield r'subscription_status';
      yield serializers.serialize(
        object.subscriptionStatus,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clear_end_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.clearEndAt = valueDes;
          break;
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.plan = valueDes;
          break;
        case r'subscription_end_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.subscriptionEndAt = valueDes;
          break;
        case r'subscription_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum?;
          if (valueDes == null) continue;
          result.subscriptionStatus = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'trial')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum trial = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_trial;
  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum active = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'grace')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum grace = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_grace;
  @BuiltValueEnumConst(wireName: r'readonly')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum readonly = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_readonly;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoSubscriptionUpdateSubscriptionStatusEnumValueOf(name);
}

