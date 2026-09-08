//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_reports_dto_export_params.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_export_job.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob
///
/// Properties:
/// * [createdAt] - CreatedAt is when the job was queued.
/// * [downloadUrl] - DownloadURL is a presigned link, valid until ExpiresAt. It is present only while the job is `done` and inside its 24 hour window (Q75).
/// * [error] - Error carries the failure reason on a failed job.
/// * [expiresAt] - ExpiresAt is when the download stops working.
/// * [fileName] - FileName is the suggested download file name.
/// * [fileSizeB] - FileSizeB is the rendered size in bytes.
/// * [finishedAt] - FinishedAt is when the job reached a terminal state.
/// * [format] - Format is the requested output format.
/// * [id] - ID is the job identifier.
/// * [params] - Params echoes the request so the UI can label the download.
/// * [requestedBy] - RequestedBy is the user that asked for the export.
/// * [startedAt] - StartedAt is when a worker picked the job up.
/// * [status] - Status is the job state.
/// * [type] - Type is the report the job renders.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob, GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobBuilder> {
  /// CreatedAt is when the job was queued.
  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  /// DownloadURL is a presigned link, valid until ExpiresAt. It is present only while the job is `done` and inside its 24 hour window (Q75).
  @BuiltValueField(wireName: r'download_url')
  String? get downloadUrl;

  /// Error carries the failure reason on a failed job.
  @BuiltValueField(wireName: r'error')
  String? get error;

  /// ExpiresAt is when the download stops working.
  @BuiltValueField(wireName: r'expires_at')
  DateTime? get expiresAt;

  /// FileName is the suggested download file name.
  @BuiltValueField(wireName: r'file_name')
  String? get fileName;

  /// FileSizeB is the rendered size in bytes.
  @BuiltValueField(wireName: r'file_size_b')
  int? get fileSizeB;

  /// FinishedAt is when the job reached a terminal state.
  @BuiltValueField(wireName: r'finished_at')
  DateTime? get finishedAt;

  /// Format is the requested output format.
  @BuiltValueField(wireName: r'format')
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum? get format;
  // enum formatEnum {  csv,  xlsx,  pdf,  zip,  };

  /// ID is the job identifier.
  @BuiltValueField(wireName: r'id')
  String? get id;

  /// Params echoes the request so the UI can label the download.
  @BuiltValueField(wireName: r'params')
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams? get params;

  /// RequestedBy is the user that asked for the export.
  @BuiltValueField(wireName: r'requested_by')
  String? get requestedBy;

  /// StartedAt is when a worker picked the job up.
  @BuiltValueField(wireName: r'started_at')
  DateTime? get startedAt;

  /// Status is the job state.
  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum? get status;
  // enum statusEnum {  queued,  running,  done,  failed,  };

  /// Type is the report the job renders.
  @BuiltValueField(wireName: r'type')
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum? get type;
  // enum typeEnum {  distance_by_region,  regulator,  activity,  hos,  dvir,  };

  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob, _$GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.downloadUrl != null) {
      yield r'download_url';
      yield serializers.serialize(
        object.downloadUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType(String),
      );
    }
    if (object.expiresAt != null) {
      yield r'expires_at';
      yield serializers.serialize(
        object.expiresAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.fileName != null) {
      yield r'file_name';
      yield serializers.serialize(
        object.fileName,
        specifiedType: const FullType(String),
      );
    }
    if (object.fileSizeB != null) {
      yield r'file_size_b';
      yield serializers.serialize(
        object.fileSizeB,
        specifiedType: const FullType(int),
      );
    }
    if (object.finishedAt != null) {
      yield r'finished_at';
      yield serializers.serialize(
        object.finishedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.format != null) {
      yield r'format';
      yield serializers.serialize(
        object.format,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.params != null) {
      yield r'params';
      yield serializers.serialize(
        object.params,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams),
      );
    }
    if (object.requestedBy != null) {
      yield r'requested_by';
      yield serializers.serialize(
        object.requestedBy,
        specifiedType: const FullType(String),
      );
    }
    if (object.startedAt != null) {
      yield r'started_at';
      yield serializers.serialize(
        object.startedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobBuilder result,
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
        case r'download_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.downloadUrl = valueDes;
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.error = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.expiresAt = valueDes;
          break;
        case r'file_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fileName = valueDes;
          break;
        case r'file_size_b':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.fileSizeB = valueDes;
          break;
        case r'finished_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.finishedAt = valueDes;
          break;
        case r'format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum?;
          if (valueDes == null) continue;
          result.format = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'params':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoExportParams?;
          if (valueDes == null) continue;
          result.params.replace(valueDes);
          break;
        case r'requested_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.requestedBy = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum?;
          if (valueDes == null) continue;
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
  GithubComDevlineOnebookEldInternalDomainReportsDtoExportJob deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobBuilder();
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


/// Format is the requested output format.
class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'csv')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum csv = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum_csv;
  @BuiltValueEnumConst(wireName: r'xlsx')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum xlsx = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum_xlsx;
  @BuiltValueEnumConst(wireName: r'pdf')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum pdf = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum_pdf;
  @BuiltValueEnumConst(wireName: r'zip')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum zip = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum_zip;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum> get values => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnumValues;
  static GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobFormatEnumValueOf(name);
}

/// Status is the job state.
class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'queued')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum queued = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum_queued;
  @BuiltValueEnumConst(wireName: r'running')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum running = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum_running;
  @BuiltValueEnumConst(wireName: r'done')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum done = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum_done;
  @BuiltValueEnumConst(wireName: r'failed')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum failed = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum_failed;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobStatusEnumValueOf(name);
}

/// Type is the report the job renders.
class GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'distance_by_region')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum distanceByRegion = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum_distanceByRegion;
  @BuiltValueEnumConst(wireName: r'regulator')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum regulator = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum_regulator;
  @BuiltValueEnumConst(wireName: r'activity')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum activity = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum_activity;
  @BuiltValueEnumConst(wireName: r'hos')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum hos = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum_hos;
  @BuiltValueEnumConst(wireName: r'dvir')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum dvir = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum_dvir;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainReportsDtoExportJobTypeEnumValueOf(name);
}

