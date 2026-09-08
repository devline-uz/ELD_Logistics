//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_duty_dto_recap_day.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay
///
/// Properties:
/// * [availableMin] 
/// * [date] 
/// * [gainedNextMin] 
/// * [onDutyMin] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay implements Built<GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay, GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder> {
  @BuiltValueField(wireName: r'available_min')
  int? get availableMin;

  @BuiltValueField(wireName: r'date')
  Date? get date;

  @BuiltValueField(wireName: r'gained_next_min')
  int? get gainedNextMin;

  @BuiltValueField(wireName: r'on_duty_min')
  int? get onDutyMin;

  GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay._();

  factory GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay([void updates(GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay> get serializer => _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDaySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDaySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay, _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.availableMin != null) {
      yield r'available_min';
      yield serializers.serialize(
        object.availableMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType(Date),
      );
    }
    if (object.gainedNextMin != null) {
      yield r'gained_next_min';
      yield serializers.serialize(
        object.gainedNextMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.onDutyMin != null) {
      yield r'on_duty_min';
      yield serializers.serialize(
        object.onDutyMin,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'available_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.availableMin = valueDes;
          break;
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.date = valueDes;
          break;
        case r'gained_next_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.gainedNextMin = valueDes;
          break;
        case r'on_duty_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.onDutyMin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder();
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


