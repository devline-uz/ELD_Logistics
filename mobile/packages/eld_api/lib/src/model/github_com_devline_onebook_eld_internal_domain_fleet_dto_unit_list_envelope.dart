//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_unit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoUnit>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainFleetDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnit)]),
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
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnit)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoUnit>?;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitListEnvelopeBuilder();
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


