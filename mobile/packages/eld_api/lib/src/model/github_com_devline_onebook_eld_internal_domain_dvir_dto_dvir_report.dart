//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_defect.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_driver_brief.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_report.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport
///
/// Properties:
/// * [certificationSignatureKey] 
/// * [certifiedAt] 
/// * [certifiedByDriverId] 
/// * [closedAt] 
/// * [closedReason] 
/// * [createdAt] 
/// * [defects] 
/// * [driver] 
/// * [driverSignatureKey] 
/// * [engineHours] 
/// * [hasCriticalDefect] - HasCriticalDefect is true when at least one defect is `is_critical`.
/// * [id] 
/// * [kind] - Kind is the derived mobile label of TZ §7.3.
/// * [lat] 
/// * [lng] 
/// * [locationText] 
/// * [mechanicId] 
/// * [mechanicNote] 
/// * [mechanicSignatureKey] 
/// * [odometerM] 
/// * [outOfService] - OutOfService mirrors units.out_of_service after the Q27.2 evaluation.
/// * [performedAt] 
/// * [repairedAt] 
/// * [source_] 
/// * [status] 
/// * [trailerIds] 
/// * [type] 
/// * [unitId] 
/// * [unitNumber] 
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport, GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportBuilder> {
  @BuiltValueField(wireName: r'certification_signature_key')
  String? get certificationSignatureKey;

  @BuiltValueField(wireName: r'certified_at')
  DateTime? get certifiedAt;

  @BuiltValueField(wireName: r'certified_by_driver_id')
  String? get certifiedByDriverId;

  @BuiltValueField(wireName: r'closed_at')
  DateTime? get closedAt;

  @BuiltValueField(wireName: r'closed_reason')
  String? get closedReason;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'defects')
  BuiltList<GithubComDevlineOnebookEldInternalDomainDvirDtoDefect>? get defects;

  @BuiltValueField(wireName: r'driver')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief? get driver;

  @BuiltValueField(wireName: r'driver_signature_key')
  String? get driverSignatureKey;

  @BuiltValueField(wireName: r'engine_hours')
  num? get engineHours;

  /// HasCriticalDefect is true when at least one defect is `is_critical`.
  @BuiltValueField(wireName: r'has_critical_defect')
  bool? get hasCriticalDefect;

  @BuiltValueField(wireName: r'id')
  String? get id;

  /// Kind is the derived mobile label of TZ §7.3.
  @BuiltValueField(wireName: r'kind')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum? get kind;
  // enum kindEnum {  no_defects,  defects_not_fixed,  defects_fixed,  defects_uncertified,  };

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'location_text')
  String? get locationText;

  @BuiltValueField(wireName: r'mechanic_id')
  String? get mechanicId;

  @BuiltValueField(wireName: r'mechanic_note')
  String? get mechanicNote;

  @BuiltValueField(wireName: r'mechanic_signature_key')
  String? get mechanicSignatureKey;

  @BuiltValueField(wireName: r'odometer_m')
  int? get odometerM;

  /// OutOfService mirrors units.out_of_service after the Q27.2 evaluation.
  @BuiltValueField(wireName: r'out_of_service')
  bool? get outOfService;

  @BuiltValueField(wireName: r'performed_at')
  DateTime? get performedAt;

  @BuiltValueField(wireName: r'repaired_at')
  DateTime? get repairedAt;

  @BuiltValueField(wireName: r'source')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum? get source_;
  // enum source_Enum {  app,  paper_import,  };

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum? get status;
  // enum statusEnum {  draft,  submitted_no_defects,  submitted_defects_found,  repaired,  certified,  closed_no_certification,  };

  @BuiltValueField(wireName: r'trailer_ids')
  BuiltList<String>? get trailerIds;

  @BuiltValueField(wireName: r'type')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum? get type;
  // enum typeEnum {  pre_trip,  post_trip,  };

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.certificationSignatureKey != null) {
      yield r'certification_signature_key';
      yield serializers.serialize(
        object.certificationSignatureKey,
        specifiedType: const FullType(String),
      );
    }
    if (object.certifiedAt != null) {
      yield r'certified_at';
      yield serializers.serialize(
        object.certifiedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.certifiedByDriverId != null) {
      yield r'certified_by_driver_id';
      yield serializers.serialize(
        object.certifiedByDriverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.closedAt != null) {
      yield r'closed_at';
      yield serializers.serialize(
        object.closedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.closedReason != null) {
      yield r'closed_reason';
      yield serializers.serialize(
        object.closedReason,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.defects != null) {
      yield r'defects';
      yield serializers.serialize(
        object.defects,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefect)]),
      );
    }
    if (object.driver != null) {
      yield r'driver';
      yield serializers.serialize(
        object.driver,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief),
      );
    }
    if (object.driverSignatureKey != null) {
      yield r'driver_signature_key';
      yield serializers.serialize(
        object.driverSignatureKey,
        specifiedType: const FullType(String),
      );
    }
    if (object.engineHours != null) {
      yield r'engine_hours';
      yield serializers.serialize(
        object.engineHours,
        specifiedType: const FullType(num),
      );
    }
    if (object.hasCriticalDefect != null) {
      yield r'has_critical_defect';
      yield serializers.serialize(
        object.hasCriticalDefect,
        specifiedType: const FullType(bool),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum),
      );
    }
    if (object.lat != null) {
      yield r'lat';
      yield serializers.serialize(
        object.lat,
        specifiedType: const FullType(num),
      );
    }
    if (object.lng != null) {
      yield r'lng';
      yield serializers.serialize(
        object.lng,
        specifiedType: const FullType(num),
      );
    }
    if (object.locationText != null) {
      yield r'location_text';
      yield serializers.serialize(
        object.locationText,
        specifiedType: const FullType(String),
      );
    }
    if (object.mechanicId != null) {
      yield r'mechanic_id';
      yield serializers.serialize(
        object.mechanicId,
        specifiedType: const FullType(String),
      );
    }
    if (object.mechanicNote != null) {
      yield r'mechanic_note';
      yield serializers.serialize(
        object.mechanicNote,
        specifiedType: const FullType(String),
      );
    }
    if (object.mechanicSignatureKey != null) {
      yield r'mechanic_signature_key';
      yield serializers.serialize(
        object.mechanicSignatureKey,
        specifiedType: const FullType(String),
      );
    }
    if (object.odometerM != null) {
      yield r'odometer_m';
      yield serializers.serialize(
        object.odometerM,
        specifiedType: const FullType(int),
      );
    }
    if (object.outOfService != null) {
      yield r'out_of_service';
      yield serializers.serialize(
        object.outOfService,
        specifiedType: const FullType(bool),
      );
    }
    if (object.performedAt != null) {
      yield r'performed_at';
      yield serializers.serialize(
        object.performedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.repairedAt != null) {
      yield r'repaired_at';
      yield serializers.serialize(
        object.repairedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum),
      );
    }
    if (object.trailerIds != null) {
      yield r'trailer_ids';
      yield serializers.serialize(
        object.trailerIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum),
      );
    }
    if (object.unitId != null) {
      yield r'unit_id';
      yield serializers.serialize(
        object.unitId,
        specifiedType: const FullType(String),
      );
    }
    if (object.unitNumber != null) {
      yield r'unit_number';
      yield serializers.serialize(
        object.unitNumber,
        specifiedType: const FullType(String),
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
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'certification_signature_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.certificationSignatureKey = valueDes;
          break;
        case r'certified_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.certifiedAt = valueDes;
          break;
        case r'certified_by_driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.certifiedByDriverId = valueDes;
          break;
        case r'closed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.closedAt = valueDes;
          break;
        case r'closed_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.closedReason = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'defects':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefect)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainDvirDtoDefect>?;
          if (valueDes == null) continue;
          result.defects.replace(valueDes);
          break;
        case r'driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief?;
          if (valueDes == null) continue;
          result.driver.replace(valueDes);
          break;
        case r'driver_signature_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverSignatureKey = valueDes;
          break;
        case r'engine_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.engineHours = valueDes;
          break;
        case r'has_critical_defect':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.hasCriticalDefect = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lng = valueDes;
          break;
        case r'location_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.locationText = valueDes;
          break;
        case r'mechanic_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mechanicId = valueDes;
          break;
        case r'mechanic_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mechanicNote = valueDes;
          break;
        case r'mechanic_signature_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mechanicSignatureKey = valueDes;
          break;
        case r'odometer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.odometerM = valueDes;
          break;
        case r'out_of_service':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.outOfService = valueDes;
          break;
        case r'performed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.performedAt = valueDes;
          break;
        case r'repaired_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.repairedAt = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum?;
          if (valueDes == null) continue;
          result.source_ = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'trailer_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.trailerIds.replace(valueDes);
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum?;
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
        case r'unit_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitNumber = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReport deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportBuilder();
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


/// Kind is the derived mobile label of TZ §7.3.
class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'no_defects')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum noDefects = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum_noDefects;
  @BuiltValueEnumConst(wireName: r'defects_not_fixed')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum defectsNotFixed = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum_defectsNotFixed;
  @BuiltValueEnumConst(wireName: r'defects_fixed')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum defectsFixed = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum_defectsFixed;
  @BuiltValueEnumConst(wireName: r'defects_uncertified')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum defectsUncertified = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum_defectsUncertified;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum> get values => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportKindEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'app')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum app = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSourceEnum_app;
  @BuiltValueEnumConst(wireName: r'paper_import')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum paperImport = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSourceEnum_paperImport;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSourceEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum> get serializer => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSourceEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum> get values => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSourceEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSource_Enum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportSourceEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'draft')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum draft = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum_draft;
  @BuiltValueEnumConst(wireName: r'submitted_no_defects')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum submittedNoDefects = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum_submittedNoDefects;
  @BuiltValueEnumConst(wireName: r'submitted_defects_found')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum submittedDefectsFound = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum_submittedDefectsFound;
  @BuiltValueEnumConst(wireName: r'repaired')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum repaired = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum_repaired;
  @BuiltValueEnumConst(wireName: r'certified')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum certified = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum_certified;
  @BuiltValueEnumConst(wireName: r'closed_no_certification')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum closedNoCertification = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum_closedNoCertification;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportStatusEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pre_trip')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum preTrip = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum_preTrip;
  @BuiltValueEnumConst(wireName: r'post_trip')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum postTrip = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum_postTrip;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirReportTypeEnumValueOf(name);
}

