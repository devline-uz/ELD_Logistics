//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_transfer_result.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult
///
/// Properties:
/// * [fileKey] - FileKey is the object storage key of the produced archive.
/// * [format] 
/// * [generatedAt] 
/// * [regulationProfile] - RegulationProfile is the company profile that selected the format.
/// * [sizeBytes] - SizeBytes is the archive size.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult, GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultBuilder> {
  /// FileKey is the object storage key of the produced archive.
  @BuiltValueField(wireName: r'file_key')
  String? get fileKey;

  @BuiltValueField(wireName: r'format')
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum? get format;
  // enum formatEnum {  csv_pdf_zip,  fmcsa_eld_output,  };

  @BuiltValueField(wireName: r'generated_at')
  DateTime? get generatedAt;

  /// RegulationProfile is the company profile that selected the format.
  @BuiltValueField(wireName: r'regulation_profile')
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum? get regulationProfile;
  // enum regulationProfileEnum {  us_fmcsa,  generic,  canada,  texas,  california,  alaska,  hawaii,  };

  /// SizeBytes is the archive size.
  @BuiltValueField(wireName: r'size_bytes')
  int? get sizeBytes;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult, _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.fileKey != null) {
      yield r'file_key';
      yield serializers.serialize(
        object.fileKey,
        specifiedType: const FullType(String),
      );
    }
    if (object.format != null) {
      yield r'format';
      yield serializers.serialize(
        object.format,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum),
      );
    }
    if (object.generatedAt != null) {
      yield r'generated_at';
      yield serializers.serialize(
        object.generatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.regulationProfile != null) {
      yield r'regulation_profile';
      yield serializers.serialize(
        object.regulationProfile,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum),
      );
    }
    if (object.sizeBytes != null) {
      yield r'size_bytes';
      yield serializers.serialize(
        object.sizeBytes,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'file_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fileKey = valueDes;
          break;
        case r'format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum?;
          if (valueDes == null) continue;
          result.format = valueDes;
          break;
        case r'generated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.generatedAt = valueDes;
          break;
        case r'regulation_profile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum?;
          if (valueDes == null) continue;
          result.regulationProfile = valueDes;
          break;
        case r'size_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sizeBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultBuilder();
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


class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'csv_pdf_zip')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum csvPdfZip = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum_csvPdfZip;
  @BuiltValueEnumConst(wireName: r'fmcsa_eld_output')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum fmcsaEldOutput = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum_fmcsaEldOutput;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultFormatEnumValueOf(name);
}

/// RegulationProfile is the company profile that selected the format.
class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'us_fmcsa')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum usFmcsa = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum_usFmcsa;
  @BuiltValueEnumConst(wireName: r'generic')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum generic = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum_generic;
  @BuiltValueEnumConst(wireName: r'canada')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum canada = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum_canada;
  @BuiltValueEnumConst(wireName: r'texas')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum texas = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum_texas;
  @BuiltValueEnumConst(wireName: r'california')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum california = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum_california;
  @BuiltValueEnumConst(wireName: r'alaska')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum alaska = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum_alaska;
  @BuiltValueEnumConst(wireName: r'hawaii')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum hawaii = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum_hawaii;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResultRegulationProfileEnumValueOf(name);
}

