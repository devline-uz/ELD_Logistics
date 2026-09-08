//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule? get data;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleEnvelopeBuilder();
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


