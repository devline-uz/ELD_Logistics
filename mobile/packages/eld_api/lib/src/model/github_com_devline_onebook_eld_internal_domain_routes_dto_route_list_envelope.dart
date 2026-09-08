//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_routes_dto_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_routes_dto_route.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_routes_dto_route_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope
///
/// Properties:
/// * [data] - Data is the page of routes.
/// * [meta] - Meta carries the pagination counters.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope, GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder> {
  /// Data is the page of routes.
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute>? get data;

  /// Meta carries the pagination counters.
  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope, _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteListEnvelopeBuilder();
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


