//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_warning_thresholds.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_hos_policy_doc.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc
///
/// Properties:
/// * [adverseConditionsExtensionMin] 
/// * [allowPc] 
/// * [allowYm] 
/// * [breakDurationMin] 
/// * [breakQualifyingStatuses] 
/// * [breakRequiredAfterDriveMin] 
/// * [cycleDays] 
/// * [cycleLimitMin] 
/// * [cycleRestartMin] 
/// * [dailyRestMin] 
/// * [driveLimitMin] 
/// * [motionThresholdKmh] 
/// * [shiftWindowMin] 
/// * [shortHaulException] 
/// * [sleeperBerthAvailable] 
/// * [sleeperSplitEnabled] 
/// * [warningThresholds] 
/// * [ymMaxSpeedKmh] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc, GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBuilder> {
  @BuiltValueField(wireName: r'adverse_conditions_extension_min')
  int? get adverseConditionsExtensionMin;

  @BuiltValueField(wireName: r'allow_pc')
  bool? get allowPc;

  @BuiltValueField(wireName: r'allow_ym')
  bool? get allowYm;

  @BuiltValueField(wireName: r'break_duration_min')
  int? get breakDurationMin;

  @BuiltValueField(wireName: r'break_qualifying_statuses')
  BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum>? get breakQualifyingStatuses;
  // enum breakQualifyingStatusesEnum {  OFF,  SB,  ON,  DR,  };

  @BuiltValueField(wireName: r'break_required_after_drive_min')
  int? get breakRequiredAfterDriveMin;

  @BuiltValueField(wireName: r'cycle_days')
  int? get cycleDays;

  @BuiltValueField(wireName: r'cycle_limit_min')
  int? get cycleLimitMin;

  @BuiltValueField(wireName: r'cycle_restart_min')
  int? get cycleRestartMin;

  @BuiltValueField(wireName: r'daily_rest_min')
  int? get dailyRestMin;

  @BuiltValueField(wireName: r'drive_limit_min')
  int? get driveLimitMin;

  @BuiltValueField(wireName: r'motion_threshold_kmh')
  num? get motionThresholdKmh;

  @BuiltValueField(wireName: r'shift_window_min')
  int? get shiftWindowMin;

  @BuiltValueField(wireName: r'short_haul_exception')
  bool? get shortHaulException;

  @BuiltValueField(wireName: r'sleeper_berth_available')
  bool? get sleeperBerthAvailable;

  @BuiltValueField(wireName: r'sleeper_split_enabled')
  bool? get sleeperSplitEnabled;

  @BuiltValueField(wireName: r'warning_thresholds')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds? get warningThresholds;

  @BuiltValueField(wireName: r'ym_max_speed_kmh')
  num? get ymMaxSpeedKmh;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.adverseConditionsExtensionMin != null) {
      yield r'adverse_conditions_extension_min';
      yield serializers.serialize(
        object.adverseConditionsExtensionMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.allowPc != null) {
      yield r'allow_pc';
      yield serializers.serialize(
        object.allowPc,
        specifiedType: const FullType(bool),
      );
    }
    if (object.allowYm != null) {
      yield r'allow_ym';
      yield serializers.serialize(
        object.allowYm,
        specifiedType: const FullType(bool),
      );
    }
    if (object.breakDurationMin != null) {
      yield r'break_duration_min';
      yield serializers.serialize(
        object.breakDurationMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.breakQualifyingStatuses != null) {
      yield r'break_qualifying_statuses';
      yield serializers.serialize(
        object.breakQualifyingStatuses,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum)]),
      );
    }
    if (object.breakRequiredAfterDriveMin != null) {
      yield r'break_required_after_drive_min';
      yield serializers.serialize(
        object.breakRequiredAfterDriveMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.cycleDays != null) {
      yield r'cycle_days';
      yield serializers.serialize(
        object.cycleDays,
        specifiedType: const FullType(int),
      );
    }
    if (object.cycleLimitMin != null) {
      yield r'cycle_limit_min';
      yield serializers.serialize(
        object.cycleLimitMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.cycleRestartMin != null) {
      yield r'cycle_restart_min';
      yield serializers.serialize(
        object.cycleRestartMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.dailyRestMin != null) {
      yield r'daily_rest_min';
      yield serializers.serialize(
        object.dailyRestMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.driveLimitMin != null) {
      yield r'drive_limit_min';
      yield serializers.serialize(
        object.driveLimitMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.motionThresholdKmh != null) {
      yield r'motion_threshold_kmh';
      yield serializers.serialize(
        object.motionThresholdKmh,
        specifiedType: const FullType(num),
      );
    }
    if (object.shiftWindowMin != null) {
      yield r'shift_window_min';
      yield serializers.serialize(
        object.shiftWindowMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.shortHaulException != null) {
      yield r'short_haul_exception';
      yield serializers.serialize(
        object.shortHaulException,
        specifiedType: const FullType(bool),
      );
    }
    if (object.sleeperBerthAvailable != null) {
      yield r'sleeper_berth_available';
      yield serializers.serialize(
        object.sleeperBerthAvailable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.sleeperSplitEnabled != null) {
      yield r'sleeper_split_enabled';
      yield serializers.serialize(
        object.sleeperSplitEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.warningThresholds != null) {
      yield r'warning_thresholds';
      yield serializers.serialize(
        object.warningThresholds,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds),
      );
    }
    if (object.ymMaxSpeedKmh != null) {
      yield r'ym_max_speed_kmh';
      yield serializers.serialize(
        object.ymMaxSpeedKmh,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'adverse_conditions_extension_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.adverseConditionsExtensionMin = valueDes;
          break;
        case r'allow_pc':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.allowPc = valueDes;
          break;
        case r'allow_ym':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.allowYm = valueDes;
          break;
        case r'break_duration_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.breakDurationMin = valueDes;
          break;
        case r'break_qualifying_statuses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum>?;
          if (valueDes == null) continue;
          result.breakQualifyingStatuses.replace(valueDes);
          break;
        case r'break_required_after_drive_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.breakRequiredAfterDriveMin = valueDes;
          break;
        case r'cycle_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.cycleDays = valueDes;
          break;
        case r'cycle_limit_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.cycleLimitMin = valueDes;
          break;
        case r'cycle_restart_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.cycleRestartMin = valueDes;
          break;
        case r'daily_rest_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.dailyRestMin = valueDes;
          break;
        case r'drive_limit_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.driveLimitMin = valueDes;
          break;
        case r'motion_threshold_kmh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.motionThresholdKmh = valueDes;
          break;
        case r'shift_window_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.shiftWindowMin = valueDes;
          break;
        case r'short_haul_exception':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.shortHaulException = valueDes;
          break;
        case r'sleeper_berth_available':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.sleeperBerthAvailable = valueDes;
          break;
        case r'sleeper_split_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.sleeperSplitEnabled = valueDes;
          break;
        case r'warning_thresholds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds?;
          if (valueDes == null) continue;
          result.warningThresholds.replace(valueDes);
          break;
        case r'ym_max_speed_kmh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.ymMaxSpeedKmh = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDoc deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBuilder();
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


class GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OFF')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum OFF = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum_OFF;
  @BuiltValueEnumConst(wireName: r'SB')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum SB = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum_SB;
  @BuiltValueEnumConst(wireName: r'ON')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum ON = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum_ON;
  @BuiltValueEnumConst(wireName: r'DR')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum DR = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum_DR;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoHosPolicyDocBreakQualifyingStatusesEnumValueOf(name);
}

