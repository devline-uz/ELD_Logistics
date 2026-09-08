//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_routes_dto_waypoint.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_routes_dto_directions.g.dart';

/// GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections
///
/// Properties:
/// * [destination] - Destination is the end coordinate the geometry was requested for.
/// * [distanceM] - DistanceM is the driving distance in metres.
/// * [durationS] - DurationS is the estimated driving time in seconds.
/// * [origin] - Origin is the start coordinate the geometry was requested for.
/// * [polyline] - Polyline is the geometry in encoded polyline format (precision 5).
/// * [provider] - Provider names the map provider that answered.
/// * [routeId] - RouteID is the route the geometry belongs to.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections implements Built<GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections, GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder> {
  /// Destination is the end coordinate the geometry was requested for.
  @BuiltValueField(wireName: r'destination')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint? get destination;

  /// DistanceM is the driving distance in metres.
  @BuiltValueField(wireName: r'distance_m')
  int? get distanceM;

  /// DurationS is the estimated driving time in seconds.
  @BuiltValueField(wireName: r'duration_s')
  int? get durationS;

  /// Origin is the start coordinate the geometry was requested for.
  @BuiltValueField(wireName: r'origin')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint? get origin;

  /// Polyline is the geometry in encoded polyline format (precision 5).
  @BuiltValueField(wireName: r'polyline')
  String? get polyline;

  /// Provider names the map provider that answered.
  @BuiltValueField(wireName: r'provider')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum? get provider;
  // enum providerEnum {  nominatim,  photon,  google,  nop,  };

  /// RouteID is the route the geometry belongs to.
  @BuiltValueField(wireName: r'route_id')
  String? get routeId;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections._();

  factory GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections([void updates(GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections> get serializer => _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections, _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.destination != null) {
      yield r'destination';
      yield serializers.serialize(
        object.destination,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint),
      );
    }
    if (object.distanceM != null) {
      yield r'distance_m';
      yield serializers.serialize(
        object.distanceM,
        specifiedType: const FullType(int),
      );
    }
    if (object.durationS != null) {
      yield r'duration_s';
      yield serializers.serialize(
        object.durationS,
        specifiedType: const FullType(int),
      );
    }
    if (object.origin != null) {
      yield r'origin';
      yield serializers.serialize(
        object.origin,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint),
      );
    }
    if (object.polyline != null) {
      yield r'polyline';
      yield serializers.serialize(
        object.polyline,
        specifiedType: const FullType(String),
      );
    }
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum),
      );
    }
    if (object.routeId != null) {
      yield r'route_id';
      yield serializers.serialize(
        object.routeId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'destination':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint?;
          if (valueDes == null) continue;
          result.destination.replace(valueDes);
          break;
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.distanceM = valueDes;
          break;
        case r'duration_s':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.durationS = valueDes;
          break;
        case r'origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint?;
          if (valueDes == null) continue;
          result.origin.replace(valueDes);
          break;
        case r'polyline':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.polyline = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum?;
          if (valueDes == null) continue;
          result.provider = valueDes;
          break;
        case r'route_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.routeId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder();
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


/// Provider names the map provider that answered.
class GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'nominatim')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum nominatim = _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_nominatim;
  @BuiltValueEnumConst(wireName: r'photon')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum photon = _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_photon;
  @BuiltValueEnumConst(wireName: r'google')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum google = _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_google;
  @BuiltValueEnumConst(wireName: r'nop')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum nop = _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_nop;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum> get values => _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnumValues;
  static GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnumValueOf(name);
}

