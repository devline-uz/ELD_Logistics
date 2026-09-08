//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_tracking_dto_trip_detail.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_tracking_dto_trip_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope, GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripDetail? get data;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope, _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoTripDetail),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainTrackingDtoTripDetail),
          ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoTripDetail?;
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
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelopeBuilder();
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


