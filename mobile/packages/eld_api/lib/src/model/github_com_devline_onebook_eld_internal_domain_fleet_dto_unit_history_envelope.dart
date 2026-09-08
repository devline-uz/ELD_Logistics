//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_meta.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_history_entry.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_history_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainFleetDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEnvelopeBuilder();
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


