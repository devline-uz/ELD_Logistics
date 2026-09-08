//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_tracking_dto_unidentified_event.g.dart';

/// GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent
///
/// Properties:
/// * [annotation] 
/// * [assignedDriverId] - AssignedDriverID is set once an admin assignment or a driver claim resolved the event.
/// * [createdAt] 
/// * [distanceM] - DistanceM is metres driven without an identified driver.
/// * [endAt] 
/// * [id] 
/// * [pendingDays] - PendingDays is how long the event has been unresolved; beyond 8 days it raises an admin alert (TZ A§10.4).
/// * [resolvedAt] 
/// * [startAt] 
/// * [status] 
/// * [trackKey] - TrackKey is the object storage key of the recorded track.
/// * [unitId] 
/// * [unitNumber] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent implements Built<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent, GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder> {
  @BuiltValueField(wireName: r'annotation')
  String? get annotation;

  /// AssignedDriverID is set once an admin assignment or a driver claim resolved the event.
  @BuiltValueField(wireName: r'assigned_driver_id')
  String? get assignedDriverId;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  /// DistanceM is metres driven without an identified driver.
  @BuiltValueField(wireName: r'distance_m')
  int? get distanceM;

  @BuiltValueField(wireName: r'end_at')
  DateTime? get endAt;

  @BuiltValueField(wireName: r'id')
  String? get id;

  /// PendingDays is how long the event has been unresolved; beyond 8 days it raises an admin alert (TZ A§10.4).
  @BuiltValueField(wireName: r'pending_days')
  int? get pendingDays;

  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  @BuiltValueField(wireName: r'start_at')
  DateTime? get startAt;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum? get status;
  // enum statusEnum {  pending,  assigned,  annotated,  };

  /// TrackKey is the object storage key of the recorded track.
  @BuiltValueField(wireName: r'track_key')
  String? get trackKey;

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent._();

  factory GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent([void updates(GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent> get serializer => _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent, _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.annotation != null) {
      yield r'annotation';
      yield serializers.serialize(
        object.annotation,
        specifiedType: const FullType(String),
      );
    }
    if (object.assignedDriverId != null) {
      yield r'assigned_driver_id';
      yield serializers.serialize(
        object.assignedDriverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.distanceM != null) {
      yield r'distance_m';
      yield serializers.serialize(
        object.distanceM,
        specifiedType: const FullType(int),
      );
    }
    if (object.endAt != null) {
      yield r'end_at';
      yield serializers.serialize(
        object.endAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.pendingDays != null) {
      yield r'pending_days';
      yield serializers.serialize(
        object.pendingDays,
        specifiedType: const FullType(int),
      );
    }
    if (object.resolvedAt != null) {
      yield r'resolved_at';
      yield serializers.serialize(
        object.resolvedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.startAt != null) {
      yield r'start_at';
      yield serializers.serialize(
        object.startAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum),
      );
    }
    if (object.trackKey != null) {
      yield r'track_key';
      yield serializers.serialize(
        object.trackKey,
        specifiedType: const FullType(String),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'annotation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.annotation = valueDes;
          break;
        case r'assigned_driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assignedDriverId = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.distanceM = valueDes;
          break;
        case r'end_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'pending_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.pendingDays = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        case r'start_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'track_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.trackKey = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder();
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


class GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum pending = _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'assigned')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum assigned = _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_assigned;
  @BuiltValueEnumConst(wireName: r'annotated')
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum annotated = _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_annotated;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnumValueOf(name);
}

