//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_reports_dto_distance_by_region_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_reports_dto_region_distance_row.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_distance_by_region_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope
///
/// Properties:
/// * [data] - Data is the report body.
/// * [meta] - Meta describes the period the report covers.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope, GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder> {
  /// Data is the report body.
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow>? get data;

  /// Meta describes the period the report covers.
  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope, _$GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainReportsDtoRegionDistanceRow>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta),
          ) as GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionMeta?;
          if (valueDes == null) continue;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoDistanceByRegionEnvelopeBuilder();
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


