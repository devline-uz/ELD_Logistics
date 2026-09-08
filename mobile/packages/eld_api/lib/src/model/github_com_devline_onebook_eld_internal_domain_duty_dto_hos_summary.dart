//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_duty_dto_recap_day.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_duty_dto_day_totals.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/date.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_duty_dto_counters.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_duty_dto_violation.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_duty_dto_hos_summary.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary
///
/// Properties:
/// * [counters] 
/// * [date] - Date is the log day in the home terminal timezone (Q10.2).
/// * [driverId] 
/// * [evaluatedAt] - EvaluatedAt is the instant the counters describe: `now` for today, the end of the log day for a past date.
/// * [policyVersionId] - PolicyVersionID is the hos_policy_versions row in force on that day (Q10.1); null means the built-in FMCSA 70/8 defaults were used.
/// * [recap] 
/// * [timezone] - Timezone is the home terminal timezone the day boundary was taken in.
/// * [totals] 
/// * [violations] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary implements Built<GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary, GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder> {
  @BuiltValueField(wireName: r'counters')
  GithubComDevlineOnebookEldInternalDomainDutyDtoCounters? get counters;

  /// Date is the log day in the home terminal timezone (Q10.2).
  @BuiltValueField(wireName: r'date')
  Date? get date;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  /// EvaluatedAt is the instant the counters describe: `now` for today, the end of the log day for a past date.
  @BuiltValueField(wireName: r'evaluated_at')
  DateTime? get evaluatedAt;

  /// PolicyVersionID is the hos_policy_versions row in force on that day (Q10.1); null means the built-in FMCSA 70/8 defaults were used.
  @BuiltValueField(wireName: r'policy_version_id')
  String? get policyVersionId;

  @BuiltValueField(wireName: r'recap')
  BuiltList<GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay>? get recap;

  /// Timezone is the home terminal timezone the day boundary was taken in.
  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'totals')
  GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals? get totals;

  @BuiltValueField(wireName: r'violations')
  BuiltList<GithubComDevlineOnebookEldInternalDomainDutyDtoViolation>? get violations;

  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary._();

  factory GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary([void updates(GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary> get serializer => _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummarySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummarySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary, _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.counters != null) {
      yield r'counters';
      yield serializers.serialize(
        object.counters,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoCounters),
      );
    }
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType(Date),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.evaluatedAt != null) {
      yield r'evaluated_at';
      yield serializers.serialize(
        object.evaluatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.policyVersionId != null) {
      yield r'policy_version_id';
      yield serializers.serialize(
        object.policyVersionId,
        specifiedType: const FullType(String),
      );
    }
    if (object.recap != null) {
      yield r'recap';
      yield serializers.serialize(
        object.recap,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay)]),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
    if (object.totals != null) {
      yield r'totals';
      yield serializers.serialize(
        object.totals,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals),
      );
    }
    if (object.violations != null) {
      yield r'violations';
      yield serializers.serialize(
        object.violations,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoViolation)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'counters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoCounters),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoCounters?;
          if (valueDes == null) continue;
          result.counters.replace(valueDes);
          break;
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.date = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'evaluated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.evaluatedAt = valueDes;
          break;
        case r'policy_version_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.policyVersionId = valueDes;
          break;
        case r'recap':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay>?;
          if (valueDes == null) continue;
          result.recap.replace(valueDes);
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.timezone = valueDes;
          break;
        case r'totals':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals?;
          if (valueDes == null) continue;
          result.totals.replace(valueDes);
          break;
        case r'violations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoViolation)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainDutyDtoViolation>?;
          if (valueDes == null) continue;
          result.violations.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder();
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


