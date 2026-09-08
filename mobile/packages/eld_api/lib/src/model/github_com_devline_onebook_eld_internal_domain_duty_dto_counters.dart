//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_duty_dto_counters.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDutyDtoCounters
///
/// Properties:
/// * [breakLeftMin] 
/// * [cycleLeftMin] 
/// * [driveLeftMin] 
/// * [drivingTimeLeftMin] 
/// * [shiftLeftMin] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDutyDtoCounters implements Built<GithubComDevlineOnebookEldInternalDomainDutyDtoCounters, GithubComDevlineOnebookEldInternalDomainDutyDtoCountersBuilder> {
  @BuiltValueField(wireName: r'break_left_min')
  int? get breakLeftMin;

  @BuiltValueField(wireName: r'cycle_left_min')
  int? get cycleLeftMin;

  @BuiltValueField(wireName: r'drive_left_min')
  int? get driveLeftMin;

  @BuiltValueField(wireName: r'driving_time_left_min')
  int? get drivingTimeLeftMin;

  @BuiltValueField(wireName: r'shift_left_min')
  int? get shiftLeftMin;

  GithubComDevlineOnebookEldInternalDomainDutyDtoCounters._();

  factory GithubComDevlineOnebookEldInternalDomainDutyDtoCounters([void updates(GithubComDevlineOnebookEldInternalDomainDutyDtoCountersBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDutyDtoCounters;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDutyDtoCountersBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoCounters> get serializer => _$GithubComDevlineOnebookEldInternalDomainDutyDtoCountersSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoCountersSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDutyDtoCounters> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDutyDtoCounters, _$GithubComDevlineOnebookEldInternalDomainDutyDtoCounters];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDutyDtoCounters';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoCounters object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.breakLeftMin != null) {
      yield r'break_left_min';
      yield serializers.serialize(
        object.breakLeftMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.cycleLeftMin != null) {
      yield r'cycle_left_min';
      yield serializers.serialize(
        object.cycleLeftMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.driveLeftMin != null) {
      yield r'drive_left_min';
      yield serializers.serialize(
        object.driveLeftMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.drivingTimeLeftMin != null) {
      yield r'driving_time_left_min';
      yield serializers.serialize(
        object.drivingTimeLeftMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.shiftLeftMin != null) {
      yield r'shift_left_min';
      yield serializers.serialize(
        object.shiftLeftMin,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoCounters object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDutyDtoCountersBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'break_left_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.breakLeftMin = valueDes;
          break;
        case r'cycle_left_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.cycleLeftMin = valueDes;
          break;
        case r'drive_left_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.driveLeftMin = valueDes;
          break;
        case r'driving_time_left_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.drivingTimeLeftMin = valueDes;
          break;
        case r'shift_left_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.shiftLeftMin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoCounters deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDutyDtoCountersBuilder();
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


