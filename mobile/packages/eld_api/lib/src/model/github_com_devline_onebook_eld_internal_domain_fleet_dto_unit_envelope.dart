//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_unit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnit? get data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnit),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnit),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnit?;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitEnvelopeBuilder();
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


