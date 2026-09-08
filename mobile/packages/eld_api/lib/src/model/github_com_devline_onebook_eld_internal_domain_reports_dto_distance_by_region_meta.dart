//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_distance_by_region_meta.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta
///
/// Properties:
/// * [from] - From is the first day of the quarter.
/// * [mode] - Mode is the breakdown that was requested.
/// * [quarter] - Quarter is the calendar quarter, 1 to 4.
/// * [to] - To is the last day of the quarter.
/// * [totalDistanceM] - TotalDistanceM is the sum of every row, in metres.
/// * [year] - Year is the calendar year.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta, GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder> {
  /// From is the first day of the quarter.
  @BuiltValueField(wireName: r'from')
  Date? get from;

  /// Mode is the breakdown that was requested.
  @BuiltValueField(wireName: r'mode')
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum? get mode;
  // enum modeEnum {  regions_and_units,  regions_only,  };

  /// Quarter is the calendar quarter, 1 to 4.
  @BuiltValueField(wireName: r'quarter')
  int? get quarter;

  /// To is the last day of the quarter.
  @BuiltValueField(wireName: r'to')
  Date? get to;

  /// TotalDistanceM is the sum of every row, in metres.
  @BuiltValueField(wireName: r'total_distance_m')
  int? get totalDistanceM;

  /// Year is the calendar year.
  @BuiltValueField(wireName: r'year')
  int? get year;

  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta, _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum),
      );
    }
    if (object.quarter != null) {
      yield r'quarter';
      yield serializers.serialize(
        object.quarter,
        specifiedType: const FullType(int),
      );
    }
    if (object.to != null) {
      yield r'to';
      yield serializers.serialize(
        object.to,
        specifiedType: const FullType(Date),
      );
    }
    if (object.totalDistanceM != null) {
      yield r'total_distance_m';
      yield serializers.serialize(
        object.totalDistanceM,
        specifiedType: const FullType(int),
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
    GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum?;
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
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.to = valueDes;
          break;
        case r'total_distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.totalDistanceM = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaBuilder();
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


/// Mode is the breakdown that was requested.
class GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'regions_and_units')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum regionsAndUnits = _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_regionsAndUnits;
  @BuiltValueEnumConst(wireName: r'regions_only')
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum regionsOnly = _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_regionsOnly;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum> get values => _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMetaModeEnumValueOf(name);
}

