//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_routes_dto_waypoint.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_routes_dto_route.g.dart';

/// GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute
///
/// Properties:
/// * [completedAt] - CompletedAt is when the route reached a terminal state.
/// * [createdAt] - CreatedAt is the creation timestamp.
/// * [destination] - Destination is the end of the leg; its geofence completes the route.
/// * [driverId] - DriverID is the assigned driver.
/// * [driverName] - DriverName is the driver's display name.
/// * [geofenceEnteredAt] - GeofenceEnteredAt is when the unit was first seen inside the destination geofence; it is cleared whenever the unit leaves again.
/// * [geofenceM] - GeofenceM is the destination geofence radius in metres.
/// * [id] - ID is the route identifier.
/// * [notCompletedNote] - NotCompletedNote is the admin's explanation.
/// * [notCompletedReason] - NotCompletedReason is set only on a not_completed route.
/// * [note] - Note is the dispatcher's free text.
/// * [origin] - Origin is the start of the leg.
/// * [sequence] - Sequence orders the routes of one unit; the lowest ongoing sequence is the current one (Q68).
/// * [startedAt] - StartedAt is when the unit first moved on this route.
/// * [status] - Status is the route state.
/// * [unitId] - UnitID is the assigned unit.
/// * [unitNumber] - UnitNumber is the fleet number of the assigned unit.
/// * [updatedAt] - UpdatedAt is the last modification timestamp.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute implements Built<GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute, GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteBuilder> {
  /// CompletedAt is when the route reached a terminal state.
  @BuiltValueField(wireName: r'completed_at')
  DateTime? get completedAt;

  /// CreatedAt is the creation timestamp.
  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  /// Destination is the end of the leg; its geofence completes the route.
  @BuiltValueField(wireName: r'destination')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint? get destination;

  /// DriverID is the assigned driver.
  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  /// DriverName is the driver's display name.
  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  /// GeofenceEnteredAt is when the unit was first seen inside the destination geofence; it is cleared whenever the unit leaves again.
  @BuiltValueField(wireName: r'geofence_entered_at')
  DateTime? get geofenceEnteredAt;

  /// GeofenceM is the destination geofence radius in metres.
  @BuiltValueField(wireName: r'geofence_m')
  int? get geofenceM;

  /// ID is the route identifier.
  @BuiltValueField(wireName: r'id')
  String? get id;

  /// NotCompletedNote is the admin's explanation.
  @BuiltValueField(wireName: r'not_completed_note')
  String? get notCompletedNote;

  /// NotCompletedReason is set only on a not_completed route.
  @BuiltValueField(wireName: r'not_completed_reason')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum? get notCompletedReason;
  // enum notCompletedReasonEnum {  breakdown,  cancelled,  load_rejected,  road_closed,  driver_change,  other,  };

  /// Note is the dispatcher's free text.
  @BuiltValueField(wireName: r'note')
  String? get note;

  /// Origin is the start of the leg.
  @BuiltValueField(wireName: r'origin')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint? get origin;

  /// Sequence orders the routes of one unit; the lowest ongoing sequence is the current one (Q68).
  @BuiltValueField(wireName: r'sequence')
  int? get sequence;

  /// StartedAt is when the unit first moved on this route.
  @BuiltValueField(wireName: r'started_at')
  DateTime? get startedAt;

  /// Status is the route state.
  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum? get status;
  // enum statusEnum {  ongoing,  completed,  not_completed,  cancelled,  };

  /// UnitID is the assigned unit.
  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  /// UnitNumber is the fleet number of the assigned unit.
  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  /// UpdatedAt is the last modification timestamp.
  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute._();

  factory GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute([void updates(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute> get serializer => _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute, _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.completedAt != null) {
      yield r'completed_at';
      yield serializers.serialize(
        object.completedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.destination != null) {
      yield r'destination';
      yield serializers.serialize(
        object.destination,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.geofenceEnteredAt != null) {
      yield r'geofence_entered_at';
      yield serializers.serialize(
        object.geofenceEnteredAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.geofenceM != null) {
      yield r'geofence_m';
      yield serializers.serialize(
        object.geofenceM,
        specifiedType: const FullType(int),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.notCompletedNote != null) {
      yield r'not_completed_note';
      yield serializers.serialize(
        object.notCompletedNote,
        specifiedType: const FullType(String),
      );
    }
    if (object.notCompletedReason != null) {
      yield r'not_completed_reason';
      yield serializers.serialize(
        object.notCompletedReason,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint),
      );
    }
    if (object.sequence != null) {
      yield r'sequence';
      yield serializers.serialize(
        object.sequence,
        specifiedType: const FullType(int),
      );
    }
    if (object.startedAt != null) {
      yield r'started_at';
      yield serializers.serialize(
        object.startedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum),
      );
    }
    if (object.unitId != null) {
      yield r'unit_id';
      yield serializers.serialize(
        object.unitId,
        specifiedType: const FullType(String),
      );
    }
    if (object.unitNumber != null) {
      yield r'unit_number';
      yield serializers.serialize(
        object.unitNumber,
        specifiedType: const FullType(String),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'completed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'destination':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint?;
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
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverName = valueDes;
          break;
        case r'geofence_entered_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.geofenceEnteredAt = valueDes;
          break;
        case r'geofence_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.geofenceM = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'not_completed_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notCompletedNote = valueDes;
          break;
        case r'not_completed_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum?;
          if (valueDes == null) continue;
          result.notCompletedReason = valueDes;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint?;
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
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitId = valueDes;
          break;
        case r'unit_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitNumber = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteBuilder();
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


/// NotCompletedReason is set only on a not_completed route.
class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'breakdown')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum breakdown = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_breakdown;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum cancelled = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'load_rejected')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum loadRejected = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_loadRejected;
  @BuiltValueEnumConst(wireName: r'road_closed')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum roadClosed = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_roadClosed;
  @BuiltValueEnumConst(wireName: r'driver_change')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum driverChange = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_driverChange;
  @BuiltValueEnumConst(wireName: r'other')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum other = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum> get values => _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnumValues;
  static GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnumValueOf(name);
}

/// Status is the route state.
class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ongoing')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum ongoing = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum_ongoing;
  @BuiltValueEnumConst(wireName: r'completed')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum completed = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'not_completed')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum notCompleted = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum_notCompleted;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum cancelled = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteStatusEnumValueOf(name);
}

