//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_routes_dto_waypoint_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_routes_dto_route_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate
///
/// Properties:
/// * [destination] - Destination replaces the end of the leg.
/// * [driverId] - DriverID reassigns the driver; the new driver is notified.
/// * [geofenceM] - GeofenceM replaces the destination geofence radius in metres.
/// * [note] - Note replaces the dispatcher's free text.
/// * [origin] - Origin replaces the start of the leg.
/// * [sequence] - Sequence reorders the route inside its unit's queue.
/// * [unitId] - UnitID reassigns the unit.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate implements Built<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate, GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder> {
  /// Destination replaces the end of the leg.
  @BuiltValueField(wireName: r'destination')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput? get destination;

  /// DriverID reassigns the driver; the new driver is notified.
  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  /// GeofenceM replaces the destination geofence radius in metres.
  @BuiltValueField(wireName: r'geofence_m')
  int? get geofenceM;

  /// Note replaces the dispatcher's free text.
  @BuiltValueField(wireName: r'note')
  String? get note;

  /// Origin replaces the start of the leg.
  @BuiltValueField(wireName: r'origin')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput? get origin;

  /// Sequence reorders the route inside its unit's queue.
  @BuiltValueField(wireName: r'sequence')
  int? get sequence;

  /// UnitID reassigns the unit.
  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate([void updates(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate, _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.destination != null) {
      yield r'destination';
      yield serializers.serialize(
        object.destination,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.geofenceM != null) {
      yield r'geofence_m';
      yield serializers.serialize(
        object.geofenceM,
        specifiedType: const FullType(int),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.origin != null) {
      yield r'origin';
      yield serializers.serialize(
        object.origin,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput),
      );
    }
    if (object.sequence != null) {
      yield r'sequence';
      yield serializers.serialize(
        object.sequence,
        specifiedType: const FullType(int),
      );
    }
    if (object.unitId != null) {
      yield r'unit_id';
      yield serializers.serialize(
        object.unitId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'destination':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput?;
          if (valueDes == null) continue;
          result.destination.replace(valueDes);
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'geofence_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.geofenceM = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput?;
          if (valueDes == null) continue;
          result.origin.replace(valueDes);
          break;
        case r'sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sequence = valueDes;
          break;
        case r'unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteUpdateBuilder();
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


