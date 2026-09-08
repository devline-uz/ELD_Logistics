//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_violation_details.dart';
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_violation.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoViolation
///
/// Properties:
/// * [createdAt] 
/// * [dailyLogId] 
/// * [details] 
/// * [driverId] - DriverID is null for `unidentified_driving`, which has no driver yet.
/// * [driverName] 
/// * [id] 
/// * [logDate] 
/// * [occurredAt] - OccurredAt is the instant the engine placed the breach.
/// * [policyVersionId] - PolicyVersionID is the hos_policy_versions row the day was judged under (Q10.1); null means the built-in FMCSA defaults.
/// * [resolvedAt] - ResolvedAt closes the violation; the row itself stays forever (Q58).
/// * [resolvedReason] 
/// * [severity] 
/// * [type] - Type is the canonical HOS violation catalogue (Q57).
/// * [unitId] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoViolation implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation, GithubComDevlineOnebookEldInternalDomainLogsDtoViolationBuilder> {
  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'daily_log_id')
  String? get dailyLogId;

  @BuiltValueField(wireName: r'details')
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails? get details;

  /// DriverID is null for `unidentified_driving`, which has no driver yet.
  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'log_date')
  Date? get logDate;

  /// OccurredAt is the instant the engine placed the breach.
  @BuiltValueField(wireName: r'occurred_at')
  DateTime? get occurredAt;

  /// PolicyVersionID is the hos_policy_versions row the day was judged under (Q10.1); null means the built-in FMCSA defaults.
  @BuiltValueField(wireName: r'policy_version_id')
  String? get policyVersionId;

  /// ResolvedAt closes the violation; the row itself stays forever (Q58).
  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  @BuiltValueField(wireName: r'resolved_reason')
  String? get resolvedReason;

  @BuiltValueField(wireName: r'severity')
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum? get severity;
  // enum severityEnum {  warning,  violation,  };

  /// Type is the canonical HOS violation catalogue (Q57).
  @BuiltValueField(wireName: r'type')
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum? get type;
  // enum typeEnum {  form_manner_trailer,  form_manner_doc,  drive_limit,  shift_limit,  break_required,  cycle_limit,  uncertified_log,  unidentified_driving,  eld_malfunction,  missing_dvir,  };

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  GithubComDevlineOnebookEldInternalDomainLogsDtoViolation._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoViolation([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoViolationBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoViolationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoViolation, _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolation];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoViolation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoViolation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.dailyLogId != null) {
      yield r'daily_log_id';
      yield serializers.serialize(
        object.dailyLogId,
        specifiedType: const FullType(String),
      );
    }
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails),
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
    if (object.occurredAt != null) {
      yield r'occurred_at';
      yield serializers.serialize(
        object.occurredAt,
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
    if (object.resolvedAt != null) {
      yield r'resolved_at';
      yield serializers.serialize(
        object.resolvedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.resolvedReason != null) {
      yield r'resolved_reason';
      yield serializers.serialize(
        object.resolvedReason,
        specifiedType: const FullType(String),
      );
    }
    if (object.severity != null) {
      yield r'severity';
      yield serializers.serialize(
        object.severity,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum),
      );
    }
    if (object.unitId != null) {
      yield r'unit_id';
      yield serializers.serialize(
        object.unitId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoViolation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoViolationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'daily_log_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.dailyLogId = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails?;
          if (valueDes == null) continue;
          result.details.replace(valueDes);
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
        case r'occurred_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.occurredAt = valueDes;
          break;
        case r'policy_version_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.policyVersionId = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        case r'resolved_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resolvedReason = valueDes;
          break;
        case r'severity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum?;
          if (valueDes == null) continue;
          result.severity = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum?;
          if (valueDes == null) continue;
          result.type = valueDes;
          break;
        case r'unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoViolationBuilder();
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


class GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'warning')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum warning = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum_warning;
  @BuiltValueEnumConst(wireName: r'violation')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum violation = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum_violation;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationSeverityEnumValueOf(name);
}

/// Type is the canonical HOS violation catalogue (Q57).
class GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'form_manner_trailer')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum formMannerTrailer = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_formMannerTrailer;
  @BuiltValueEnumConst(wireName: r'form_manner_doc')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum formMannerDoc = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_formMannerDoc;
  @BuiltValueEnumConst(wireName: r'drive_limit')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum driveLimit = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_driveLimit;
  @BuiltValueEnumConst(wireName: r'shift_limit')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum shiftLimit = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_shiftLimit;
  @BuiltValueEnumConst(wireName: r'break_required')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum breakRequired = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_breakRequired;
  @BuiltValueEnumConst(wireName: r'cycle_limit')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum cycleLimit = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_cycleLimit;
  @BuiltValueEnumConst(wireName: r'uncertified_log')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum uncertifiedLog = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_uncertifiedLog;
  @BuiltValueEnumConst(wireName: r'unidentified_driving')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum unidentifiedDriving = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_unidentifiedDriving;
  @BuiltValueEnumConst(wireName: r'eld_malfunction')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum eldMalfunction = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_eldMalfunction;
  @BuiltValueEnumConst(wireName: r'missing_dvir')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum missingDvir = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_missingDvir;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoViolationTypeEnumValueOf(name);
}

