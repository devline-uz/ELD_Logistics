//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_maintenance_dto_meta.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleListEnvelopeBuilder();
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


