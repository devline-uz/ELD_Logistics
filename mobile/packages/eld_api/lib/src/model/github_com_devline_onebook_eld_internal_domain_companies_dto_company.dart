//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_companies_dto_company.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany
///
/// Properties:
/// * [address] 
/// * [createdAt] 
/// * [email] 
/// * [homeTerminalAddress] 
/// * [id] 
/// * [logoKey] 
/// * [name] 
/// * [phone] 
/// * [plan] 
/// * [region] 
/// * [registrationNo] 
/// * [regulationProfile] 
/// * [settings] 
/// * [subscriptionEndAt] 
/// * [subscriptionStatus] 
/// * [timezone] 
/// * [unitSystem] 
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany implements Built<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany, GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder> {
  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'home_terminal_address')
  String? get homeTerminalAddress;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'logo_key')
  String? get logoKey;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'plan')
  String? get plan;

  @BuiltValueField(wireName: r'region')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum? get region;
  // enum regionEnum {  PK,  UZ,  US,  other,  };

  @BuiltValueField(wireName: r'registration_no')
  String? get registrationNo;

  @BuiltValueField(wireName: r'regulation_profile')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum? get regulationProfile;
  // enum regulationProfileEnum {  us_fmcsa,  generic,  canada,  texas,  california,  alaska,  hawaii,  };

  @BuiltValueField(wireName: r'settings')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings? get settings;

  @BuiltValueField(wireName: r'subscription_end_at')
  DateTime? get subscriptionEndAt;

  @BuiltValueField(wireName: r'subscription_status')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum? get subscriptionStatus;
  // enum subscriptionStatusEnum {  trial,  active,  grace,  readonly,  };

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'unit_system')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum? get unitSystem;
  // enum unitSystemEnum {  metric,  imperial,  };

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany._();

  factory GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany([void updates(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany, _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
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
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.logoKey != null) {
      yield r'logo_key';
      yield serializers.serialize(
        object.logoKey,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
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
    if (object.region != null) {
      yield r'region';
      yield serializers.serialize(
        object.region,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum),
      );
    }
    if (object.registrationNo != null) {
      yield r'registration_no';
      yield serializers.serialize(
        object.registrationNo,
        specifiedType: const FullType(String),
      );
    }
    if (object.regulationProfile != null) {
      yield r'regulation_profile';
      yield serializers.serialize(
        object.regulationProfile,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum),
      );
    }
    if (object.settings != null) {
      yield r'settings';
      yield serializers.serialize(
        object.settings,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
    if (object.unitSystem != null) {
      yield r'unit_system';
      yield serializers.serialize(
        object.unitSystem,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder result,
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
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'logo_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.logoKey = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum?;
          if (valueDes == null) continue;
          result.regulationProfile = valueDes;
          break;
        case r'settings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings?;
          if (valueDes == null) continue;
          result.settings.replace(valueDes);
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum?;
          if (valueDes == null) continue;
          result.subscriptionStatus = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.timezone = valueDes;
          break;
        case r'unit_system':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum?;
          if (valueDes == null) continue;
          result.unitSystem = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyBuilder();
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


class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PK')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum PK = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum_PK;
  @BuiltValueEnumConst(wireName: r'UZ')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum UZ = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum_UZ;
  @BuiltValueEnumConst(wireName: r'US')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum US = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum_US;
  @BuiltValueEnumConst(wireName: r'other')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum other = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegionEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'us_fmcsa')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum usFmcsa = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum_usFmcsa;
  @BuiltValueEnumConst(wireName: r'generic')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum generic = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum_generic;
  @BuiltValueEnumConst(wireName: r'canada')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum canada = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum_canada;
  @BuiltValueEnumConst(wireName: r'texas')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum texas = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum_texas;
  @BuiltValueEnumConst(wireName: r'california')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum california = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum_california;
  @BuiltValueEnumConst(wireName: r'alaska')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum alaska = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum_alaska;
  @BuiltValueEnumConst(wireName: r'hawaii')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum hawaii = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum_hawaii;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyRegulationProfileEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'trial')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum trial = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum_trial;
  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum active = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'grace')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum grace = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum_grace;
  @BuiltValueEnumConst(wireName: r'readonly')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum readonly = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum_readonly;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanySubscriptionStatusEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'metric')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum metric = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum_metric;
  @BuiltValueEnumConst(wireName: r'imperial')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum imperial = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum_imperial;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUnitSystemEnumValueOf(name);
}

