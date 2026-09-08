//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_companies_dto_company_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate
///
/// Properties:
/// * [address] 
/// * [email] 
/// * [homeTerminalAddress] 
/// * [logoKey] 
/// * [name] 
/// * [phone] 
/// * [plan] 
/// * [region] 
/// * [registrationNo] 
/// * [regulationProfile] 
/// * [timezone] 
/// * [unitSystem] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate implements Built<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate, GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateBuilder> {
  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'home_terminal_address')
  String? get homeTerminalAddress;

  @BuiltValueField(wireName: r'logo_key')
  String? get logoKey;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'plan')
  String? get plan;

  @BuiltValueField(wireName: r'region')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum? get region;
  // enum regionEnum {  PK,  UZ,  US,  other,  };

  @BuiltValueField(wireName: r'registration_no')
  String? get registrationNo;

  @BuiltValueField(wireName: r'regulation_profile')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum? get regulationProfile;
  // enum regulationProfileEnum {  us_fmcsa,  generic,  canada,  texas,  california,  alaska,  hawaii,  };

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'unit_system')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum? get unitSystem;
  // enum unitSystemEnum {  metric,  imperial,  };

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate([void updates(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate, _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType(String),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateBuilder result,
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum?;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum?;
          if (valueDes == null) continue;
          result.regulationProfile = valueDes;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum?;
          if (valueDes == null) continue;
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
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PK')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum PK = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum_PK;
  @BuiltValueEnumConst(wireName: r'UZ')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum UZ = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum_UZ;
  @BuiltValueEnumConst(wireName: r'US')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum US = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum_US;
  @BuiltValueEnumConst(wireName: r'other')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum other = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegionEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'us_fmcsa')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum usFmcsa = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum_usFmcsa;
  @BuiltValueEnumConst(wireName: r'generic')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum generic = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum_generic;
  @BuiltValueEnumConst(wireName: r'canada')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum canada = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum_canada;
  @BuiltValueEnumConst(wireName: r'texas')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum texas = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum_texas;
  @BuiltValueEnumConst(wireName: r'california')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum california = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum_california;
  @BuiltValueEnumConst(wireName: r'alaska')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum alaska = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum_alaska;
  @BuiltValueEnumConst(wireName: r'hawaii')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum hawaii = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum_hawaii;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateRegulationProfileEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'metric')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum metric = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum_metric;
  @BuiltValueEnumConst(wireName: r'imperial')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum imperial = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum_imperial;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyUpdateUnitSystemEnumValueOf(name);
}

