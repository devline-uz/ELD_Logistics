//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_routes_dto_waypoint_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_routes_dto_route_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate
///
/// Properties:
/// * [destination] - Destination is the end of the leg.
/// * [driverId] - DriverID is the driver that will be notified.
/// * [geofenceM] - GeofenceM is the destination geofence radius in metres; defaults to 300.
/// * [note] - Note is the dispatcher's free text.
/// * [origin] - Origin is the start of the leg.
/// * [sequence] - Sequence orders several routes of the same unit (Q68); defaults to the next free slot when omitted.
/// * [unitId] - UnitID is the unit that will drive the leg.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate implements Built<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate, GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreateBuilder> {
  /// Destination is the end of the leg.
  @BuiltValueField(wireName: r'destination')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput get destination;

  /// DriverID is the driver that will be notified.
  @BuiltValueField(wireName: r'driver_id')
  String get driverId;

  /// GeofenceM is the destination geofence radius in metres; defaults to 300.
  @BuiltValueField(wireName: r'geofence_m')
  int? get geofenceM;

  /// Note is the dispatcher's free text.
  @BuiltValueField(wireName: r'note')
  String? get note;

  /// Origin is the start of the leg.
  @BuiltValueField(wireName: r'origin')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput get origin;

  /// Sequence orders several routes of the same unit (Q68); defaults to the next free slot when omitted.
  @BuiltValueField(wireName: r'sequence')
  int? get sequence;

  /// UnitID is the unit that will drive the leg.
  @BuiltValueField(wireName: r'unit_id')
  String get unitId;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate._();

  factory GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate([void updates(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate, _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'destination';
    yield serializers.serialize(
      object.destination,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput),
    );
    yield r'driver_id';
    yield serializers.serialize(
      object.driverId,
      specifiedType: const FullType(String),
    );
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
    yield r'origin';
    yield serializers.serialize(
      object.origin,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput),
    );
    if (object.sequence != null) {
      yield r'sequence';
      yield serializers.serialize(
        object.sequence,
        specifiedType: const FullType(int),
      );
    }
    yield r'unit_id';
    yield serializers.serialize(
      object.unitId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'destination':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput;
          result.destination.replace(valueDes);
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput;
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
            specifiedType: const FullType(String),
          ) as String;
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
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteCreateBuilder();
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


