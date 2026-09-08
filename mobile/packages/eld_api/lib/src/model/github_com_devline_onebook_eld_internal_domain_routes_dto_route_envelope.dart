//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_routes_dto_route.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_routes_dto_route_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope
///
/// Properties:
/// * [data] - Data is the route.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope, GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder> {
  /// Data is the route.
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute? get data;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope, _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute?;
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
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder();
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


