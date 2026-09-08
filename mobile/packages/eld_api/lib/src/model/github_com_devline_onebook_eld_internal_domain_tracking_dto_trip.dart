//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_tracking_dto_driver_brief.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_tracking_dto_trip.g.dart';

/// GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip
///
/// Properties:
/// * [distanceM] - DistanceM is metres; DurationSec is seconds; MaxSpeedKmh is km/h.
/// * [driver] 
/// * [durationSec] 
/// * [endAt] 
/// * [endLat] 
/// * [endLng] 
/// * [id] 
/// * [maxSpeedKmh] 
/// * [open] - Open is true while the trip has no end yet.
/// * [startAt] 
/// * [startLat] 
/// * [startLng] 
/// * [unitId] 
/// * [unitNumber] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip implements Built<GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip, GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder> {
  /// DistanceM is metres; DurationSec is seconds; MaxSpeedKmh is km/h.
  @BuiltValueField(wireName: r'distance_m')
  int? get distanceM;

  @BuiltValueField(wireName: r'driver')
  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief? get driver;

  @BuiltValueField(wireName: r'duration_sec')
  int? get durationSec;

  @BuiltValueField(wireName: r'end_at')
  DateTime? get endAt;

  @BuiltValueField(wireName: r'end_lat')
  num? get endLat;

  @BuiltValueField(wireName: r'end_lng')
  num? get endLng;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'max_speed_kmh')
  num? get maxSpeedKmh;

  /// Open is true while the trip has no end yet.
  @BuiltValueField(wireName: r'open')
  bool? get open;

  @BuiltValueField(wireName: r'start_at')
  DateTime? get startAt;

  @BuiltValueField(wireName: r'start_lat')
  num? get startLat;

  @BuiltValueField(wireName: r'start_lng')
  num? get startLng;

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip._();

  factory GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip([void updates(GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip> get serializer => _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTripSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip, _$GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.distanceM != null) {
      yield r'distance_m';
      yield serializers.serialize(
        object.distanceM,
        specifiedType: const FullType(int),
      );
    }
    if (object.driver != null) {
      yield r'driver';
      yield serializers.serialize(
        object.driver,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief),
      );
    }
    if (object.durationSec != null) {
      yield r'duration_sec';
      yield serializers.serialize(
        object.durationSec,
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
    if (object.endLat != null) {
      yield r'end_lat';
      yield serializers.serialize(
        object.endLat,
        specifiedType: const FullType(num),
      );
    }
    if (object.endLng != null) {
      yield r'end_lng';
      yield serializers.serialize(
        object.endLng,
        specifiedType: const FullType(num),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.maxSpeedKmh != null) {
      yield r'max_speed_kmh';
      yield serializers.serialize(
        object.maxSpeedKmh,
        specifiedType: const FullType(num),
      );
    }
    if (object.open != null) {
      yield r'open';
      yield serializers.serialize(
        object.open,
        specifiedType: const FullType(bool),
      );
    }
    if (object.startAt != null) {
      yield r'start_at';
      yield serializers.serialize(
        object.startAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.startLat != null) {
      yield r'start_lat';
      yield serializers.serialize(
        object.startLat,
        specifiedType: const FullType(num),
      );
    }
    if (object.startLng != null) {
      yield r'start_lng';
      yield serializers.serialize(
        object.startLng,
        specifiedType: const FullType(num),
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
    GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.distanceM = valueDes;
          break;
        case r'driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief),
          ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief?;
          if (valueDes == null) continue;
          result.driver.replace(valueDes);
          break;
        case r'duration_sec':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.durationSec = valueDes;
          break;
        case r'end_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endAt = valueDes;
          break;
        case r'end_lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.endLat = valueDes;
          break;
        case r'end_lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.endLng = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'max_speed_kmh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.maxSpeedKmh = valueDes;
          break;
        case r'open':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.open = valueDes;
          break;
        case r'start_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startAt = valueDes;
          break;
        case r'start_lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.startLat = valueDes;
          break;
        case r'start_lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.startLng = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainTrackingDtoTrip deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainTrackingDtoTripBuilder();
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


