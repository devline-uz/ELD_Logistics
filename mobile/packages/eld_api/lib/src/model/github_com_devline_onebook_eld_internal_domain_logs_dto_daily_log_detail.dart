//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_violation.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_event.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_day_totals.dart';
import 'package:eld_api/src/model/date.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_form.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_daily_log_detail.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail
///
/// Properties:
/// * [certificationStatus] - CertificationStatus is the Q19 tri-state.
/// * [coDriverName] - CoDriverName is the second seat of the day, null when driving alone.
/// * [distanceM] 
/// * [driverId] 
/// * [driverName] - DriverName is \"First Last\" of the log owner.
/// * [events] 
/// * [form] 
/// * [id] 
/// * [logDate] - LogDate is the home terminal calendar day (Q10.2).
/// * [ready] - Ready is false while the day still misses its signature (Q25).
/// * [signedAt] 
/// * [timezone] 
/// * [totals] 
/// * [unitIds] 
/// * [updatedAt] 
/// * [violations] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail, GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder> {
  /// CertificationStatus is the Q19 tri-state.
  @BuiltValueField(wireName: r'certification_status')
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum? get certificationStatus;
  // enum certificationStatusEnum {  uncertified,  certified,  needs_recertify,  };

  /// CoDriverName is the second seat of the day, null when driving alone.
  @BuiltValueField(wireName: r'co_driver_name')
  String? get coDriverName;

  @BuiltValueField(wireName: r'distance_m')
  int? get distanceM;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  /// DriverName is \"First Last\" of the log owner.
  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'events')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent>? get events;

  @BuiltValueField(wireName: r'form')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm? get form;

  @BuiltValueField(wireName: r'id')
  String? get id;

  /// LogDate is the home terminal calendar day (Q10.2).
  @BuiltValueField(wireName: r'log_date')
  Date? get logDate;

  /// Ready is false while the day still misses its signature (Q25).
  @BuiltValueField(wireName: r'ready')
  bool? get ready;

  @BuiltValueField(wireName: r'signed_at')
  DateTime? get signedAt;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'totals')
  GithubComDevlineOnebookEldInternalDomainLogsDtoDayTotals? get totals;

  @BuiltValueField(wireName: r'unit_ids')
  BuiltList<String>? get unitIds;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'violations')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>? get violations;

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail, _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.certificationStatus != null) {
      yield r'certification_status';
      yield serializers.serialize(
        object.certificationStatus,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum),
      );
    }
    if (object.coDriverName != null) {
      yield r'co_driver_name';
      yield serializers.serialize(
        object.coDriverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.distanceM != null) {
      yield r'distance_m';
      yield serializers.serialize(
        object.distanceM,
        specifiedType: const FullType(int),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.events != null) {
      yield r'events';
      yield serializers.serialize(
        object.events,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent)]),
      );
    }
    if (object.form != null) {
      yield r'form';
      yield serializers.serialize(
        object.form,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm),
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
    if (object.ready != null) {
      yield r'ready';
      yield serializers.serialize(
        object.ready,
        specifiedType: const FullType(bool),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoDayTotals),
      );
    }
    if (object.unitIds != null) {
      yield r'unit_ids';
      yield serializers.serialize(
        object.unitIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.violations != null) {
      yield r'violations';
      yield serializers.serialize(
        object.violations,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoViolation)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'certification_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum?;
          if (valueDes == null) continue;
          result.certificationStatus = valueDes;
          break;
        case r'co_driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.coDriverName = valueDes;
          break;
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.distanceM = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverName = valueDes;
          break;
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent>?;
          if (valueDes == null) continue;
          result.events.replace(valueDes);
          break;
        case r'form':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm?;
          if (valueDes == null) continue;
          result.form.replace(valueDes);
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
        case r'ready':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.ready = valueDes;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoDayTotals),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoDayTotals?;
          if (valueDes == null) continue;
          result.totals.replace(valueDes);
          break;
        case r'unit_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.unitIds.replace(valueDes);
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        case r'violations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoViolation)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>?;
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
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder();
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


/// CertificationStatus is the Q19 tri-state.
class GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'uncertified')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum uncertified = _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_uncertified;
  @BuiltValueEnumConst(wireName: r'certified')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum certified = _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_certified;
  @BuiltValueEnumConst(wireName: r'needs_recertify')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum needsRecertify = _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_needsRecertify;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnumValueOf(name);
}

