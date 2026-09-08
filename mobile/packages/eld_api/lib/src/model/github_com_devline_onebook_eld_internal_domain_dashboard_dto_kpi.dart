//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dashboard_dto_kpi.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI
///
/// Properties:
/// * [activeDrivers] - ActiveDrivers is the denominator of the status block.
/// * [activeUnits] - ActiveUnits counts the units that reported telemetry today.
/// * [disconnectedEld] - DisconnectedELD counts the units whose ELD reported losing the link.
/// * [driversOnDuty] - DriversOnDuty counts the drivers currently in ON or DR.
/// * [malfunctionEld] - MalfunctionELD counts the devices carrying an active FMCSA code.
/// * [pendingLogEdits] - PendingLogEdits counts the log edit requests waiting for a decision.
/// * [unassignedDriving] - UnassignedDriving counts the unidentified driving events still pending.
/// * [uncertifiedLogs] - UncertifiedLogs counts the logs uncertified for two days or more.
/// * [violations] - Violations counts the violations of the current ISO week.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI implements Built<GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI, GithubComDevlineOnebookEldInternalDomainDashboardDtoKPIBuilder> {
  /// ActiveDrivers is the denominator of the status block.
  @BuiltValueField(wireName: r'active_drivers')
  int? get activeDrivers;

  /// ActiveUnits counts the units that reported telemetry today.
  @BuiltValueField(wireName: r'active_units')
  int? get activeUnits;

  /// DisconnectedELD counts the units whose ELD reported losing the link.
  @BuiltValueField(wireName: r'disconnected_eld')
  int? get disconnectedEld;

  /// DriversOnDuty counts the drivers currently in ON or DR.
  @BuiltValueField(wireName: r'drivers_on_duty')
  int? get driversOnDuty;

  /// MalfunctionELD counts the devices carrying an active FMCSA code.
  @BuiltValueField(wireName: r'malfunction_eld')
  int? get malfunctionEld;

  /// PendingLogEdits counts the log edit requests waiting for a decision.
  @BuiltValueField(wireName: r'pending_log_edits')
  int? get pendingLogEdits;

  /// UnassignedDriving counts the unidentified driving events still pending.
  @BuiltValueField(wireName: r'unassigned_driving')
  int? get unassignedDriving;

  /// UncertifiedLogs counts the logs uncertified for two days or more.
  @BuiltValueField(wireName: r'uncertified_logs')
  int? get uncertifiedLogs;

  /// Violations counts the violations of the current ISO week.
  @BuiltValueField(wireName: r'violations')
  int? get violations;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI._();

  factory GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI([void updates(GithubComDevlineOnebookEldInternalDomainDashboardDtoKPIBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDashboardDtoKPIBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI> get serializer => _$GithubComDevlineOnebookEldInternalDomainDashboardDtoKPISerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDashboardDtoKPISerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI, _$GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.activeDrivers != null) {
      yield r'active_drivers';
      yield serializers.serialize(
        object.activeDrivers,
        specifiedType: const FullType(int),
      );
    }
    if (object.activeUnits != null) {
      yield r'active_units';
      yield serializers.serialize(
        object.activeUnits,
        specifiedType: const FullType(int),
      );
    }
    if (object.disconnectedEld != null) {
      yield r'disconnected_eld';
      yield serializers.serialize(
        object.disconnectedEld,
        specifiedType: const FullType(int),
      );
    }
    if (object.driversOnDuty != null) {
      yield r'drivers_on_duty';
      yield serializers.serialize(
        object.driversOnDuty,
        specifiedType: const FullType(int),
      );
    }
    if (object.malfunctionEld != null) {
      yield r'malfunction_eld';
      yield serializers.serialize(
        object.malfunctionEld,
        specifiedType: const FullType(int),
      );
    }
    if (object.pendingLogEdits != null) {
      yield r'pending_log_edits';
      yield serializers.serialize(
        object.pendingLogEdits,
        specifiedType: const FullType(int),
      );
    }
    if (object.unassignedDriving != null) {
      yield r'unassigned_driving';
      yield serializers.serialize(
        object.unassignedDriving,
        specifiedType: const FullType(int),
      );
    }
    if (object.uncertifiedLogs != null) {
      yield r'uncertified_logs';
      yield serializers.serialize(
        object.uncertifiedLogs,
        specifiedType: const FullType(int),
      );
    }
    if (object.violations != null) {
      yield r'violations';
      yield serializers.serialize(
        object.violations,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDashboardDtoKPIBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'active_drivers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.activeDrivers = valueDes;
          break;
        case r'active_units':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.activeUnits = valueDes;
          break;
        case r'disconnected_eld':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.disconnectedEld = valueDes;
          break;
        case r'drivers_on_duty':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.driversOnDuty = valueDes;
          break;
        case r'malfunction_eld':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.malfunctionEld = valueDes;
          break;
        case r'pending_log_edits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.pendingLogEdits = valueDes;
          break;
        case r'unassigned_driving':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.unassignedDriving = valueDes;
          break;
        case r'uncertified_logs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.uncertifiedLogs = valueDes;
          break;
        case r'violations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.violations = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoKPI deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDashboardDtoKPIBuilder();
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


