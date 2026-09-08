//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_company.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany
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
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany, GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyBuilder> {
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
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum? get region;
  // enum regionEnum {  PK,  UZ,  US,  other,  };

  @BuiltValueField(wireName: r'registration_no')
  String? get registrationNo;

  @BuiltValueField(wireName: r'regulation_profile')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum? get regulationProfile;
  // enum regulationProfileEnum {  us_fmcsa,  generic,  canada,  texas,  california,  alaska,  hawaii,  };

  @BuiltValueField(wireName: r'settings')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings? get settings;

  @BuiltValueField(wireName: r'subscription_end_at')
  DateTime? get subscriptionEndAt;

  @BuiltValueField(wireName: r'subscription_status')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum? get subscriptionStatus;
  // enum subscriptionStatusEnum {  trial,  active,  grace,  readonly,  };

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'unit_system')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum? get unitSystem;
  // enum unitSystemEnum {  metric,  imperial,  };

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany object, {
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum),
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
    GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyBuilder result,
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum?;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum?;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum?;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum?;
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
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompany deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyBuilder();
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


class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PK')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum PK = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum_PK;
  @BuiltValueEnumConst(wireName: r'UZ')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum UZ = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum_UZ;
  @BuiltValueEnumConst(wireName: r'US')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum US = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum_US;
  @BuiltValueEnumConst(wireName: r'other')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum other = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegionEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'us_fmcsa')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum usFmcsa = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum_usFmcsa;
  @BuiltValueEnumConst(wireName: r'generic')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum generic = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum_generic;
  @BuiltValueEnumConst(wireName: r'canada')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum canada = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum_canada;
  @BuiltValueEnumConst(wireName: r'texas')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum texas = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum_texas;
  @BuiltValueEnumConst(wireName: r'california')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum california = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum_california;
  @BuiltValueEnumConst(wireName: r'alaska')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum alaska = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum_alaska;
  @BuiltValueEnumConst(wireName: r'hawaii')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum hawaii = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum_hawaii;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyRegulationProfileEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'trial')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum trial = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum_trial;
  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum active = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'grace')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum grace = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum_grace;
  @BuiltValueEnumConst(wireName: r'readonly')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum readonly = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum_readonly;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanySubscriptionStatusEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'metric')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum metric = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum_metric;
  @BuiltValueEnumConst(wireName: r'imperial')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum imperial = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum_imperial;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUnitSystemEnumValueOf(name);
}

