//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_export_params.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams
///
/// Properties:
/// * [branchId] - BranchID narrows the export to one branch. A `branch` scoped requester never controls it: the server overwrites the field with the caller's own branch before the job is stored (TZ A§16).
/// * [comment] - Comment is the free text the regulator export carries on its cover page.
/// * [driverIds] - DriverIDs filters the export to these drivers.
/// * [from] - From is the first day of the window (inclusive).
/// * [mode] - Mode is the Distance by Region breakdown.
/// * [quarter] - Quarter selects the Distance by Region period.
/// * [subject] - Subject is the activity report axis.
/// * [to] - To is the last day of the window (inclusive).
/// * [unitIds] - UnitIDs filters the export to these units.
/// * [year] - Year selects the Distance by Region period.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams, GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsBuilder> {
  /// BranchID narrows the export to one branch. A `branch` scoped requester never controls it: the server overwrites the field with the caller's own branch before the job is stored (TZ A§16).
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  /// Comment is the free text the regulator export carries on its cover page.
  @BuiltValueField(wireName: r'comment')
  String? get comment;

  /// DriverIDs filters the export to these drivers.
  @BuiltValueField(wireName: r'driver_ids')
  BuiltList<String>? get driverIds;

  /// From is the first day of the window (inclusive).
  @BuiltValueField(wireName: r'from')
  Date? get from;

  /// Mode is the Distance by Region breakdown.
  @BuiltValueField(wireName: r'mode')
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum? get mode;
  // enum modeEnum {  regions_and_units,  regions_only,  };

  /// Quarter selects the Distance by Region period.
  @BuiltValueField(wireName: r'quarter')
  int? get quarter;

  /// Subject is the activity report axis.
  @BuiltValueField(wireName: r'subject')
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum? get subject;
  // enum subjectEnum {  drivers,  units,  };

  /// To is the last day of the window (inclusive).
  @BuiltValueField(wireName: r'to')
  Date? get to;

  /// UnitIDs filters the export to these units.
  @BuiltValueField(wireName: r'unit_ids')
  BuiltList<String>? get unitIds;

  /// Year selects the Distance by Region period.
  @BuiltValueField(wireName: r'year')
  int? get year;

  GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams, _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverIds != null) {
      yield r'driver_ids';
      yield serializers.serialize(
        object.driverIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.from != null) {
      yield r'from';
      yield serializers.serialize(
        object.from,
        specifiedType: const FullType(Date),
      );
    }
    if (object.mode != null) {
      yield r'mode';
      yield serializers.serialize(
        object.mode,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum),
      );
    }
    if (object.quarter != null) {
      yield r'quarter';
      yield serializers.serialize(
        object.quarter,
        specifiedType: const FullType(int),
      );
    }
    if (object.subject != null) {
      yield r'subject';
      yield serializers.serialize(
        object.subject,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum),
      );
    }
    if (object.to != null) {
      yield r'to';
      yield serializers.serialize(
        object.to,
        specifiedType: const FullType(Date),
      );
    }
    if (object.unitIds != null) {
      yield r'unit_ids';
      yield serializers.serialize(
        object.unitIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.year != null) {
      yield r'year';
      yield serializers.serialize(
        object.year,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'comment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        case r'driver_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.driverIds.replace(valueDes);
          break;
        case r'from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.from = valueDes;
          break;
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum?;
          if (valueDes == null) continue;
          result.mode = valueDes;
          break;
        case r'quarter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.quarter = valueDes;
          break;
        case r'subject':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum?;
          if (valueDes == null) continue;
          result.subject = valueDes;
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.to = valueDes;
          break;
        case r'unit_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.unitIds.replace(valueDes);
          break;
        case r'year':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.year = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsBuilder();
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


/// Mode is the Distance by Region breakdown.
class GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'regions_and_units')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum regionsAndUnits = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum_regionsAndUnits;
  @BuiltValueEnumConst(wireName: r'regions_only')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum regionsOnly = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum_regionsOnly;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum> get values => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsModeEnumValueOf(name);
}

/// Subject is the activity report axis.
class GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'drivers')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum drivers = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum_drivers;
  @BuiltValueEnumConst(wireName: r'units')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum units = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum_units;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum> get values => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnumValues;
  static GithubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportParamsSubjectEnumValueOf(name);
}

