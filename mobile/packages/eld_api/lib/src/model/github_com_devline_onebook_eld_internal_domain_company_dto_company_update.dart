//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_company_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate
///
/// Properties:
/// * [address] 
/// * [email] 
/// * [homeTerminalAddress] 
/// * [logoKey] 
/// * [name] 
/// * [phone] 
/// * [region] 
/// * [registrationNo] 
/// * [regulationProfile] 
/// * [settings] 
/// * [timezone] 
/// * [unitSystem] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate, GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateBuilder> {
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

  @BuiltValueField(wireName: r'region')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum? get region;
  // enum regionEnum {  PK,  UZ,  US,  other,  };

  @BuiltValueField(wireName: r'registration_no')
  String? get registrationNo;

  @BuiltValueField(wireName: r'regulation_profile')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum? get regulationProfile;
  // enum regulationProfileEnum {  us_fmcsa,  generic,  canada,  texas,  california,  alaska,  hawaii,  };

  @BuiltValueField(wireName: r'settings')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings? get settings;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'unit_system')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum? get unitSystem;
  // enum unitSystemEnum {  metric,  imperial,  };

  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate object, {
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
    if (object.region != null) {
      yield r'region';
      yield serializers.serialize(
        object.region,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum),
      );
    }
    if (object.settings != null) {
      yield r'settings';
      yield serializers.serialize(
        object.settings,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateBuilder result,
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
        case r'region':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum?;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum?;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum?;
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
  GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PK')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum PK = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum_PK;
  @BuiltValueEnumConst(wireName: r'UZ')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum UZ = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum_UZ;
  @BuiltValueEnumConst(wireName: r'US')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum US = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum_US;
  @BuiltValueEnumConst(wireName: r'other')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum other = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegionEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'us_fmcsa')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum usFmcsa = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum_usFmcsa;
  @BuiltValueEnumConst(wireName: r'generic')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum generic = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum_generic;
  @BuiltValueEnumConst(wireName: r'canada')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum canada = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum_canada;
  @BuiltValueEnumConst(wireName: r'texas')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum texas = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum_texas;
  @BuiltValueEnumConst(wireName: r'california')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum california = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum_california;
  @BuiltValueEnumConst(wireName: r'alaska')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum alaska = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum_alaska;
  @BuiltValueEnumConst(wireName: r'hawaii')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum hawaii = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum_hawaii;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateRegulationProfileEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'metric')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum metric = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum_metric;
  @BuiltValueEnumConst(wireName: r'imperial')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum imperial = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum_imperial;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoCompanyUpdateUnitSystemEnumValueOf(name);
}

