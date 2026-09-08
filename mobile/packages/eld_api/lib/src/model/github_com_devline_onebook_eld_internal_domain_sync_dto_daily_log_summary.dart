//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_duty_dto_day_totals.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_daily_log_summary.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary
///
/// Properties:
/// * [certificationStatus] 
/// * [distanceM] 
/// * [id] 
/// * [logDate] 
/// * [signedAt] 
/// * [timezone] 
/// * [totals] - Totals are the four duty-line minutes of the day.
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary, GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder> {
  @BuiltValueField(wireName: r'certification_status')
  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum? get certificationStatus;
  // enum certificationStatusEnum {  uncertified,  certified,  needs_recertify,  };

  @BuiltValueField(wireName: r'distance_m')
  int? get distanceM;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'log_date')
  Date? get logDate;

  @BuiltValueField(wireName: r'signed_at')
  DateTime? get signedAt;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  /// Totals are the four duty-line minutes of the day.
  @BuiltValueField(wireName: r'totals')
  GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals? get totals;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummarySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummarySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary, _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.certificationStatus != null) {
      yield r'certification_status';
      yield serializers.serialize(
        object.certificationStatus,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum),
      );
    }
    if (object.distanceM != null) {
      yield r'distance_m';
      yield serializers.serialize(
        object.distanceM,
        specifiedType: const FullType(int),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.logDate != null) {
      yield r'log_date';
      yield serializers.serialize(
        object.logDate,
        specifiedType: const FullType(Date),
      );
    }
    if (object.signedAt != null) {
      yield r'signed_at';
      yield serializers.serialize(
        object.signedAt,
        specifiedType: const FullType(DateTime),
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
    GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'certification_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum?;
          if (valueDes == null) continue;
          result.certificationStatus = valueDes;
          break;
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.distanceM = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'log_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.logDate = valueDes;
          break;
        case r'signed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.signedAt = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder();
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


class GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'uncertified')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum uncertified = _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_uncertified;
  @BuiltValueEnumConst(wireName: r'certified')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum certified = _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_certified;
  @BuiltValueEnumConst(wireName: r'needs_recertify')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum needsRecertify = _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_needsRecertify;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnumValueOf(name);
}

