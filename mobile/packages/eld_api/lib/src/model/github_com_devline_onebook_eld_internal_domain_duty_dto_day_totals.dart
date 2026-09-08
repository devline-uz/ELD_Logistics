//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_duty_dto_day_totals.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals
///
/// Properties:
/// * [driveMin] 
/// * [offMin] 
/// * [onMin] 
/// * [sbMin] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals implements Built<GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals, GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsBuilder> {
  @BuiltValueField(wireName: r'drive_min')
  int? get driveMin;

  @BuiltValueField(wireName: r'off_min')
  int? get offMin;

  @BuiltValueField(wireName: r'on_min')
  int? get onMin;

  @BuiltValueField(wireName: r'sb_min')
  int? get sbMin;

  GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals._();

  factory GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals([void updates(GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals> get serializer => _$GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals, _$GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.driveMin != null) {
      yield r'drive_min';
      yield serializers.serialize(
        object.driveMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.offMin != null) {
      yield r'off_min';
      yield serializers.serialize(
        object.offMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.onMin != null) {
      yield r'on_min';
      yield serializers.serialize(
        object.onMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.sbMin != null) {
      yield r'sb_min';
      yield serializers.serialize(
        object.sbMin,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'drive_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.driveMin = valueDes;
          break;
        case r'off_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.offMin = valueDes;
          break;
        case r'on_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.onMin = valueDes;
          break;
        case r'sb_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sbMin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsBuilder();
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


