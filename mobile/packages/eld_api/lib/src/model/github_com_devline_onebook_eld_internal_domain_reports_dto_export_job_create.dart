//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_reports_dto_export_params.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_export_job_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate
///
/// Properties:
/// * [format] - Format is the output format; it defaults per type when omitted.
/// * [params] - Params carries the report specific window and filters.
/// * [type] - Type is the report to render.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate, GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateBuilder> {
  /// Format is the output format; it defaults per type when omitted.
  @BuiltValueField(wireName: r'format')
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum? get format;
  // enum formatEnum {  csv,  xlsx,  pdf,  zip,  };

  /// Params carries the report specific window and filters.
  @BuiltValueField(wireName: r'params')
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams? get params;

  /// Type is the report to render.
  @BuiltValueField(wireName: r'type')
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum get type;
  // enum typeEnum {  distance_by_region,  regulator,  activity,  hos,  dvir,  };

  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate, _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.format != null) {
      yield r'format';
      yield serializers.serialize(
        object.format,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum),
      );
    }
    if (object.params != null) {
      yield r'params';
      yield serializers.serialize(
        object.params,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams),
      );
    }
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum?;
          if (valueDes == null) continue;
          result.format = valueDes;
          break;
        case r'params':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams?;
          if (valueDes == null) continue;
          result.params.replace(valueDes);
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateBuilder();
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


/// Format is the output format; it defaults per type when omitted.
class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'csv')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum csv = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum_csv;
  @BuiltValueEnumConst(wireName: r'xlsx')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum xlsx = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum_xlsx;
  @BuiltValueEnumConst(wireName: r'pdf')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum pdf = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum_pdf;
  @BuiltValueEnumConst(wireName: r'zip')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum zip = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum_zip;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum> get values => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnumValues;
  static GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateFormatEnumValueOf(name);
}

/// Type is the report to render.
class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'distance_by_region')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum distanceByRegion = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum_distanceByRegion;
  @BuiltValueEnumConst(wireName: r'regulator')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum regulator = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum_regulator;
  @BuiltValueEnumConst(wireName: r'activity')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum activity = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum_activity;
  @BuiltValueEnumConst(wireName: r'hos')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum hos = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum_hos;
  @BuiltValueEnumConst(wireName: r'dvir')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum dvir = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum_dvir;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobCreateTypeEnumValueOf(name);
}

