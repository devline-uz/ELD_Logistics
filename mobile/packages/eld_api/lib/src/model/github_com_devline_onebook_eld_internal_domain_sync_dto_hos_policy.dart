//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_hos_policy.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy
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
/// * [cycleRestartMin] - CycleRestartMin is null when the policy has no restart provision.
/// * [dailyRestMin] 
/// * [driveLimitMin] 
/// * [effectiveFrom] 
/// * [motionThresholdKmh] 
/// * [shiftWindowMin] 
/// * [shortHaulException] 
/// * [sleeperSplitEnabled] 
/// * [versionId] - VersionID is the hos_policy_versions row; null means the built-in FMCSA 70/8 defaults.
/// * [warnBreakMin] 
/// * [warnCycleMin] 
/// * [warnDriveMin] 
/// * [warnShiftMin] 
/// * [ymMaxSpeedKmh] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy, GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBuilder> {
  @BuiltValueField(wireName: r'adverse_conditions_extension_min')
  int? get adverseConditionsExtensionMin;

  @BuiltValueField(wireName: r'allow_pc')
  bool? get allowPc;

  @BuiltValueField(wireName: r'allow_ym')
  bool? get allowYm;

  @BuiltValueField(wireName: r'break_duration_min')
  int? get breakDurationMin;

  @BuiltValueField(wireName: r'break_qualifying_statuses')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum>? get breakQualifyingStatuses;
  // enum breakQualifyingStatusesEnum {  OFF,  SB,  DR,  ON,  };

  @BuiltValueField(wireName: r'break_required_after_drive_min')
  int? get breakRequiredAfterDriveMin;

  @BuiltValueField(wireName: r'cycle_days')
  int? get cycleDays;

  @BuiltValueField(wireName: r'cycle_limit_min')
  int? get cycleLimitMin;

  /// CycleRestartMin is null when the policy has no restart provision.
  @BuiltValueField(wireName: r'cycle_restart_min')
  int? get cycleRestartMin;

  @BuiltValueField(wireName: r'daily_rest_min')
  int? get dailyRestMin;

  @BuiltValueField(wireName: r'drive_limit_min')
  int? get driveLimitMin;

  @BuiltValueField(wireName: r'effective_from')
  DateTime? get effectiveFrom;

  @BuiltValueField(wireName: r'motion_threshold_kmh')
  num? get motionThresholdKmh;

  @BuiltValueField(wireName: r'shift_window_min')
  int? get shiftWindowMin;

  @BuiltValueField(wireName: r'short_haul_exception')
  bool? get shortHaulException;

  @BuiltValueField(wireName: r'sleeper_split_enabled')
  bool? get sleeperSplitEnabled;

  /// VersionID is the hos_policy_versions row; null means the built-in FMCSA 70/8 defaults.
  @BuiltValueField(wireName: r'version_id')
  String? get versionId;

  @BuiltValueField(wireName: r'warn_break_min')
  int? get warnBreakMin;

  @BuiltValueField(wireName: r'warn_cycle_min')
  int? get warnCycleMin;

  @BuiltValueField(wireName: r'warn_drive_min')
  int? get warnDriveMin;

  @BuiltValueField(wireName: r'warn_shift_min')
  int? get warnShiftMin;

  @BuiltValueField(wireName: r'ym_max_speed_kmh')
  num? get ymMaxSpeedKmh;

  GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy, _$GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy object, {
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
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum)]),
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
    if (object.effectiveFrom != null) {
      yield r'effective_from';
      yield serializers.serialize(
        object.effectiveFrom,
        specifiedType: const FullType(DateTime),
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
    if (object.sleeperSplitEnabled != null) {
      yield r'sleeper_split_enabled';
      yield serializers.serialize(
        object.sleeperSplitEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.versionId != null) {
      yield r'version_id';
      yield serializers.serialize(
        object.versionId,
        specifiedType: const FullType(String),
      );
    }
    if (object.warnBreakMin != null) {
      yield r'warn_break_min';
      yield serializers.serialize(
        object.warnBreakMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.warnCycleMin != null) {
      yield r'warn_cycle_min';
      yield serializers.serialize(
        object.warnCycleMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.warnDriveMin != null) {
      yield r'warn_drive_min';
      yield serializers.serialize(
        object.warnDriveMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.warnShiftMin != null) {
      yield r'warn_shift_min';
      yield serializers.serialize(
        object.warnShiftMin,
        specifiedType: const FullType(int),
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
    GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBuilder result,
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
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum>?;
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
        case r'effective_from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.effectiveFrom = valueDes;
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
        case r'sleeper_split_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.sleeperSplitEnabled = valueDes;
          break;
        case r'version_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.versionId = valueDes;
          break;
        case r'warn_break_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.warnBreakMin = valueDes;
          break;
        case r'warn_cycle_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.warnCycleMin = valueDes;
          break;
        case r'warn_drive_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.warnDriveMin = valueDes;
          break;
        case r'warn_shift_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.warnShiftMin = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBuilder();
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


class GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OFF')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum OFF = _$githubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum_OFF;
  @BuiltValueEnumConst(wireName: r'SB')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum SB = _$githubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum_SB;
  @BuiltValueEnumConst(wireName: r'DR')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum DR = _$githubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum_DR;
  @BuiltValueEnumConst(wireName: r'ON')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum ON = _$githubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum_ON;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoHosPolicyBreakQualifyingStatusesEnumValueOf(name);
}

