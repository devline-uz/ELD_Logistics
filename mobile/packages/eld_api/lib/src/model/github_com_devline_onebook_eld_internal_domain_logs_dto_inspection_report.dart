//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_daily_log_detail.dart';
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_report.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport
///
/// Properties:
/// * [carrierName] 
/// * [days] 
/// * [driverId] 
/// * [driverName] 
/// * [from] 
/// * [generatedAt] 
/// * [homeTerminalAddress] 
/// * [regulationProfile] - RegulationProfile decides the transfer format (Q56).
/// * [timezone] 
/// * [to] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport, GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportBuilder> {
  @BuiltValueField(wireName: r'carrier_name')
  String? get carrierName;

  @BuiltValueField(wireName: r'days')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail>? get days;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'from')
  Date? get from;

  @BuiltValueField(wireName: r'generated_at')
  DateTime? get generatedAt;

  @BuiltValueField(wireName: r'home_terminal_address')
  String? get homeTerminalAddress;

  /// RegulationProfile decides the transfer format (Q56).
  @BuiltValueField(wireName: r'regulation_profile')
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum? get regulationProfile;
  // enum regulationProfileEnum {  us_fmcsa,  generic,  canada,  texas,  california,  alaska,  hawaii,  };

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'to')
  Date? get to;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport, _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.carrierName != null) {
      yield r'carrier_name';
      yield serializers.serialize(
        object.carrierName,
        specifiedType: const FullType(String),
      );
    }
    if (object.days != null) {
      yield r'days';
      yield serializers.serialize(
        object.days,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail)]),
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
    if (object.from != null) {
      yield r'from';
      yield serializers.serialize(
        object.from,
        specifiedType: const FullType(Date),
      );
    }
    if (object.generatedAt != null) {
      yield r'generated_at';
      yield serializers.serialize(
        object.generatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.homeTerminalAddress != null) {
      yield r'home_terminal_address';
      yield serializers.serialize(
        object.homeTerminalAddress,
        specifiedType: const FullType(String),
      );
    }
    if (object.regulationProfile != null) {
      yield r'regulation_profile';
      yield serializers.serialize(
        object.regulationProfile,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
    if (object.to != null) {
      yield r'to';
      yield serializers.serialize(
        object.to,
        specifiedType: const FullType(Date),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'carrier_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.carrierName = valueDes;
          break;
        case r'days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail>?;
          if (valueDes == null) continue;
          result.days.replace(valueDes);
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
        case r'from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.from = valueDes;
          break;
        case r'generated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.generatedAt = valueDes;
          break;
        case r'home_terminal_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.homeTerminalAddress = valueDes;
          break;
        case r'regulation_profile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum?;
          if (valueDes == null) continue;
          result.regulationProfile = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.timezone = valueDes;
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.to = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReport deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportBuilder();
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


/// RegulationProfile decides the transfer format (Q56).
class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'us_fmcsa')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum usFmcsa = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum_usFmcsa;
  @BuiltValueEnumConst(wireName: r'generic')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum generic = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum_generic;
  @BuiltValueEnumConst(wireName: r'canada')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum canada = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum_canada;
  @BuiltValueEnumConst(wireName: r'texas')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum texas = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum_texas;
  @BuiltValueEnumConst(wireName: r'california')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum california = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum_california;
  @BuiltValueEnumConst(wireName: r'alaska')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum alaska = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum_alaska;
  @BuiltValueEnumConst(wireName: r'hawaii')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum hawaii = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum_hawaii;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionReportRegulationProfileEnumValueOf(name);
}

