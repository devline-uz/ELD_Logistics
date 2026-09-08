//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_eld_device.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_eld_device_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope, GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice? get data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope, _$GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoEldDevice?;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoEldDeviceEnvelopeBuilder();
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


