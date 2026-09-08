//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_settings.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings
///
/// Properties:
/// * [distanceRegionsSet] - DistanceRegionsSet selects the region catalogue used by the distance report (Q0.1).
/// * [fuelTypes] - FuelTypes limits the values a unit may declare.
/// * [quickNotes] - QuickNotes are the note presets offered on the duty status form (Q1.3).
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings, GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder> {
  /// DistanceRegionsSet selects the region catalogue used by the distance report (Q0.1).
  @BuiltValueField(wireName: r'distance_regions_set')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum? get distanceRegionsSet;
  // enum distanceRegionsSetEnum {  us_states,  pk_provinces,  uz_regions,  none,  };

  /// FuelTypes limits the values a unit may declare.
  @BuiltValueField(wireName: r'fuel_types')
  BuiltList<String>? get fuelTypes;

  /// QuickNotes are the note presets offered on the duty status form (Q1.3).
  @BuiltValueField(wireName: r'quick_notes')
  BuiltList<String>? get quickNotes;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.distanceRegionsSet != null) {
      yield r'distance_regions_set';
      yield serializers.serialize(
        object.distanceRegionsSet,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum),
      );
    }
    if (object.fuelTypes != null) {
      yield r'fuel_types';
      yield serializers.serialize(
        object.fuelTypes,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.quickNotes != null) {
      yield r'quick_notes';
      yield serializers.serialize(
        object.quickNotes,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'distance_regions_set':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum?;
          if (valueDes == null) continue;
          result.distanceRegionsSet = valueDes;
          break;
        case r'fuel_types':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.fuelTypes.replace(valueDes);
          break;
        case r'quick_notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.quickNotes.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsBuilder();
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


/// DistanceRegionsSet selects the region catalogue used by the distance report (Q0.1).
class GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'us_states')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum usStates = _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_usStates;
  @BuiltValueEnumConst(wireName: r'pk_provinces')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum pkProvinces = _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_pkProvinces;
  @BuiltValueEnumConst(wireName: r'uz_regions')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum uzRegions = _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_uzRegions;
  @BuiltValueEnumConst(wireName: r'none')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum none = _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_none;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoSettingsDistanceRegionsSetEnumValueOf(name);
}

