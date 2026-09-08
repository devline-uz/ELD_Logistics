//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_region_distance_row.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow
///
/// Properties:
/// * [country] - Country is the ISO 3166-1 alpha-2 country code.
/// * [distanceM] - DistanceM is the distance driven inside the region, in metres.
/// * [regionCode] - RegionCode is the jurisdiction code, e.g. \"US-IL\".
/// * [regionName] - RegionName is the jurisdiction name.
/// * [unitId] - UnitID is set only in `regions_and_units` mode.
/// * [unitNumber] - UnitNumber is set only in `regions_and_units` mode.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow, GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder> {
  /// Country is the ISO 3166-1 alpha-2 country code.
  @BuiltValueField(wireName: r'country')
  String? get country;

  /// DistanceM is the distance driven inside the region, in metres.
  @BuiltValueField(wireName: r'distance_m')
  int? get distanceM;

  /// RegionCode is the jurisdiction code, e.g. \"US-IL\".
  @BuiltValueField(wireName: r'region_code')
  String? get regionCode;

  /// RegionName is the jurisdiction name.
  @BuiltValueField(wireName: r'region_name')
  String? get regionName;

  /// UnitID is set only in `regions_and_units` mode.
  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  /// UnitNumber is set only in `regions_and_units` mode.
  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow, _$GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.country != null) {
      yield r'country';
      yield serializers.serialize(
        object.country,
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
    if (object.regionCode != null) {
      yield r'region_code';
      yield serializers.serialize(
        object.regionCode,
        specifiedType: const FullType(String),
      );
    }
    if (object.regionName != null) {
      yield r'region_name';
      yield serializers.serialize(
        object.regionName,
        specifiedType: const FullType(String),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'country':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.country = valueDes;
          break;
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.distanceM = valueDes;
          break;
        case r'region_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.regionCode = valueDes;
          break;
        case r'region_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.regionName = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRowBuilder();
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


