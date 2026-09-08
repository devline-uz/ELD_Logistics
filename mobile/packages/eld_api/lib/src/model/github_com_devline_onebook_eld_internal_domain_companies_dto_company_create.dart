//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_companies_dto_administrator_invite.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_companies_dto_company_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate
///
/// Properties:
/// * [address] 
/// * [administrator] 
/// * [email] 
/// * [homeTerminalAddress] 
/// * [name] 
/// * [phone] 
/// * [plan] 
/// * [region] 
/// * [registrationNo] 
/// * [regulationProfile] 
/// * [subscriptionEndAt] 
/// * [subscriptionStatus] 
/// * [timezone] 
/// * [unitSystem] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate implements Built<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate, GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateBuilder> {
  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'administrator')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite get administrator;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'home_terminal_address')
  String? get homeTerminalAddress;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'plan')
  String? get plan;

  @BuiltValueField(wireName: r'region')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum get region;
  // enum regionEnum {  PK,  UZ,  US,  other,  };

  @BuiltValueField(wireName: r'registration_no')
  String? get registrationNo;

  @BuiltValueField(wireName: r'regulation_profile')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum get regulationProfile;
  // enum regulationProfileEnum {  us_fmcsa,  generic,  canada,  texas,  california,  alaska,  hawaii,  };

  @BuiltValueField(wireName: r'subscription_end_at')
  DateTime? get subscriptionEndAt;

  @BuiltValueField(wireName: r'subscription_status')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum? get subscriptionStatus;
  // enum subscriptionStatusEnum {  trial,  active,  grace,  readonly,  };

  @BuiltValueField(wireName: r'timezone')
  String get timezone;

  @BuiltValueField(wireName: r'unit_system')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum get unitSystem;
  // enum unitSystemEnum {  metric,  imperial,  };

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate._();

  factory GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate([void updates(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate, _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType(String),
      );
    }
    yield r'administrator';
    yield serializers.serialize(
      object.administrator,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite),
    );
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    if (object.homeTerminalAddress != null) {
      yield r'home_terminal_address';
      yield serializers.serialize(
        object.homeTerminalAddress,
        specifiedType: const FullType(String),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType(String),
      );
    }
    if (object.plan != null) {
      yield r'plan';
      yield serializers.serialize(
        object.plan,
        specifiedType: const FullType(String),
      );
    }
    yield r'region';
    yield serializers.serialize(
      object.region,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum),
    );
    if (object.registrationNo != null) {
      yield r'registration_no';
      yield serializers.serialize(
        object.registrationNo,
        specifiedType: const FullType(String),
      );
    }
    yield r'regulation_profile';
    yield serializers.serialize(
      object.regulationProfile,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum),
    );
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum),
      );
    }
    yield r'timezone';
    yield serializers.serialize(
      object.timezone,
      specifiedType: const FullType(String),
    );
    yield r'unit_system';
    yield serializers.serialize(
      object.unitSystem,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.address = valueDes;
          break;
        case r'administrator':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite;
          result.administrator.replace(valueDes);
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'home_terminal_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.homeTerminalAddress = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.plan = valueDes;
          break;
        case r'region':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum;
          result.region = valueDes;
          break;
        case r'registration_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.registrationNo = valueDes;
          break;
        case r'regulation_profile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum;
          result.regulationProfile = valueDes;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum?;
          if (valueDes == null) continue;
          result.subscriptionStatus = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timezone = valueDes;
          break;
        case r'unit_system':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum;
          result.unitSystem = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PK')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum PK = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum_PK;
  @BuiltValueEnumConst(wireName: r'UZ')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum UZ = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum_UZ;
  @BuiltValueEnumConst(wireName: r'US')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum US = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum_US;
  @BuiltValueEnumConst(wireName: r'other')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum other = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegionEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'us_fmcsa')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum usFmcsa = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum_usFmcsa;
  @BuiltValueEnumConst(wireName: r'generic')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum generic = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum_generic;
  @BuiltValueEnumConst(wireName: r'canada')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum canada = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum_canada;
  @BuiltValueEnumConst(wireName: r'texas')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum texas = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum_texas;
  @BuiltValueEnumConst(wireName: r'california')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum california = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum_california;
  @BuiltValueEnumConst(wireName: r'alaska')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum alaska = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum_alaska;
  @BuiltValueEnumConst(wireName: r'hawaii')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum hawaii = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum_hawaii;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateRegulationProfileEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'trial')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum trial = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum_trial;
  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum active = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'grace')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum grace = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum_grace;
  @BuiltValueEnumConst(wireName: r'readonly')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum readonly = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum_readonly;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateSubscriptionStatusEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'metric')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum metric = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum_metric;
  @BuiltValueEnumConst(wireName: r'imperial')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum imperial = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum_imperial;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreateUnitSystemEnumValueOf(name);
}

