//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_activity_row.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow
///
/// Properties:
/// * [endOdometerM] - EndOdometerM is the last odometer reading in the window, in metres.
/// * [hasData] - HasData is false when the subject reported nothing in the window, which is why its odometer columns are zero.
/// * [name] - Name is the unit number or the driver's display name.
/// * [odometerChangeM] - OdometerChangeM is Q75: End − Start. It is zero when the window holds no telemetry at all.
/// * [startOdometerM] - StartOdometerM is the first odometer reading in the window, in metres.
/// * [subjectId] - SubjectID is the driver or unit the row describes.
/// * [subjectType] - SubjectType tells which of the two the row describes.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow, GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder> {
  /// EndOdometerM is the last odometer reading in the window, in metres.
  @BuiltValueField(wireName: r'end_odometer_m')
  int? get endOdometerM;

  /// HasData is false when the subject reported nothing in the window, which is why its odometer columns are zero.
  @BuiltValueField(wireName: r'has_data')
  bool? get hasData;

  /// Name is the unit number or the driver's display name.
  @BuiltValueField(wireName: r'name')
  String? get name;

  /// OdometerChangeM is Q75: End − Start. It is zero when the window holds no telemetry at all.
  @BuiltValueField(wireName: r'odometer_change_m')
  int? get odometerChangeM;

  /// StartOdometerM is the first odometer reading in the window, in metres.
  @BuiltValueField(wireName: r'start_odometer_m')
  int? get startOdometerM;

  /// SubjectID is the driver or unit the row describes.
  @BuiltValueField(wireName: r'subject_id')
  String? get subjectId;

  /// SubjectType tells which of the two the row describes.
  @BuiltValueField(wireName: r'subject_type')
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum? get subjectType;
  // enum subjectTypeEnum {  drivers,  units,  };

  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow, _$GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.endOdometerM != null) {
      yield r'end_odometer_m';
      yield serializers.serialize(
        object.endOdometerM,
        specifiedType: const FullType(int),
      );
    }
    if (object.hasData != null) {
      yield r'has_data';
      yield serializers.serialize(
        object.hasData,
        specifiedType: const FullType(bool),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.odometerChangeM != null) {
      yield r'odometer_change_m';
      yield serializers.serialize(
        object.odometerChangeM,
        specifiedType: const FullType(int),
      );
    }
    if (object.startOdometerM != null) {
      yield r'start_odometer_m';
      yield serializers.serialize(
        object.startOdometerM,
        specifiedType: const FullType(int),
      );
    }
    if (object.subjectId != null) {
      yield r'subject_id';
      yield serializers.serialize(
        object.subjectId,
        specifiedType: const FullType(String),
      );
    }
    if (object.subjectType != null) {
      yield r'subject_type';
      yield serializers.serialize(
        object.subjectType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'end_odometer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.endOdometerM = valueDes;
          break;
        case r'has_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.hasData = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'odometer_change_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.odometerChangeM = valueDes;
          break;
        case r'start_odometer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.startOdometerM = valueDes;
          break;
        case r'subject_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.subjectId = valueDes;
          break;
        case r'subject_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum?;
          if (valueDes == null) continue;
          result.subjectType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowBuilder();
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


/// SubjectType tells which of the two the row describes.
class GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'drivers')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum drivers = _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_drivers;
  @BuiltValueEnumConst(wireName: r'units')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum units = _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_units;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainReportsDtoActivityRowSubjectTypeEnumValueOf(name);
}

