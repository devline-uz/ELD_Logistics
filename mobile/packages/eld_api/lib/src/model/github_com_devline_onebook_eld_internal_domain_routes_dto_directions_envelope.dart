//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_routes_dto_directions.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_routes_dto_directions_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope
///
/// Properties:
/// * [data] - Data is the route geometry.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope, GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder> {
  /// Data is the route geometry.
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections? get data;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope, _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections?;
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
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder();
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


