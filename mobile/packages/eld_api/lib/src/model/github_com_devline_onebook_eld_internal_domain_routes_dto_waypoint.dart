//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_routes_dto_waypoint.g.dart';

/// GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint
///
/// Properties:
/// * [lat] - Lat is the WGS84 latitude in degrees.
/// * [lng] - Lng is the WGS84 longitude in degrees.
/// * [text] - Text is the human readable address shown in the planner.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint implements Built<GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint, GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder> {
  /// Lat is the WGS84 latitude in degrees.
  @BuiltValueField(wireName: r'lat')
  num? get lat;

  /// Lng is the WGS84 longitude in degrees.
  @BuiltValueField(wireName: r'lng')
  num? get lng;

  /// Text is the human readable address shown in the planner.
  @BuiltValueField(wireName: r'text')
  String? get text;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint._();

  factory GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint([void updates(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint> get serializer => _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint, _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.lat != null) {
      yield r'lat';
      yield serializers.serialize(
        object.lat,
        specifiedType: const FullType(num),
      );
    }
    if (object.lng != null) {
      yield r'lng';
      yield serializers.serialize(
        object.lng,
        specifiedType: const FullType(num),
      );
    }
    if (object.text != null) {
      yield r'text';
      yield serializers.serialize(
        object.text,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lng = valueDes;
          break;
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.text = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder();
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


