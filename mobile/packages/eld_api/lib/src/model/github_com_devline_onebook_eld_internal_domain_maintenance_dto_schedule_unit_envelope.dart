//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_unit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_unit_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit? get data;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit?;
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
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitEnvelopeBuilder();
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


