//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_event_push.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush
///
/// Properties:
/// * [clientEventId] - ClientEventID is the device generated idempotency key. Re-uploading it answers `duplicate`, never an error.
/// * [deviceSeq] - DeviceSeq is the monotonic device counter; retries preserve its order and it breaks a conflict tie between two devices (rule 1).
/// * [eldDeviceId] 
/// * [engineHours] 
/// * [eventTime] 
/// * [eventType] 
/// * [gpsAccuracyM] 
/// * [lat] 
/// * [lng] 
/// * [locationText] 
/// * [notes] 
/// * [odometerM] 
/// * [origin] - Origin records how the event came to be. `manual_no_eld` marks a status entered with the ELD disconnected (Q7.1). `driver_edit`, `admin_edit` and `assigned` are server side origins (log edit approval, §10.4 hand over) and are refused here with `rejected(invalid_payload)`.
/// * [shippingDocIds] 
/// * [special] 
/// * [speedKmh] - SpeedKmh at event_time drives the server side auto-DR and yard-move exit checks (Q5, Q4.2).
/// * [status] 
/// * [timeSource] - TimeSource is the clock event_time came from (Q-B1.2).
/// * [trailerIds] 
/// * [unitId] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush, GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushBuilder> {
  /// ClientEventID is the device generated idempotency key. Re-uploading it answers `duplicate`, never an error.
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  /// DeviceSeq is the monotonic device counter; retries preserve its order and it breaks a conflict tie between two devices (rule 1).
  @BuiltValueField(wireName: r'device_seq')
  int? get deviceSeq;

  @BuiltValueField(wireName: r'eld_device_id')
  String? get eldDeviceId;

  @BuiltValueField(wireName: r'engine_hours')
  num? get engineHours;

  @BuiltValueField(wireName: r'event_time')
  DateTime get eventTime;

  @BuiltValueField(wireName: r'event_type')
  GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum get eventType;
  // enum eventTypeEnum {  status_change,  duty_status,  intermediate,  login,  logout,  power_on,  power_off,  engine_on,  engine_off,  malfunction,  diagnostic,  certification,  yard_moves,  personal_use,  };

  @BuiltValueField(wireName: r'gps_accuracy_m')
  int? get gpsAccuracyM;

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'location_text')
  String? get locationText;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'odometer_m')
  int? get odometerM;

  /// Origin records how the event came to be. `manual_no_eld` marks a status entered with the ELD disconnected (Q7.1). `driver_edit`, `admin_edit` and `assigned` are server side origins (log edit approval, §10.4 hand over) and are refused here with `rejected(invalid_payload)`.
  @BuiltValueField(wireName: r'origin')
  GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum? get origin;
  // enum originEnum {  auto,  driver,  manual_no_eld,  };

  @BuiltValueField(wireName: r'shipping_doc_ids')
  BuiltList<String>? get shippingDocIds;

  @BuiltValueField(wireName: r'special')
  GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum? get special;
  // enum specialEnum {  none,  pc,  ym,  };

  /// SpeedKmh at event_time drives the server side auto-DR and yard-move exit checks (Q5, Q4.2).
  @BuiltValueField(wireName: r'speed_kmh')
  num? get speedKmh;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum? get status;
  // enum statusEnum {  OFF,  SB,  DR,  ON,  };

  /// TimeSource is the clock event_time came from (Q-B1.2).
  @BuiltValueField(wireName: r'time_source')
  GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum? get timeSource;
  // enum timeSourceEnum {  eld_rtc,  server,  phone,  };

  @BuiltValueField(wireName: r'trailer_ids')
  BuiltList<String>? get trailerIds;

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush, _$GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    if (object.deviceSeq != null) {
      yield r'device_seq';
      yield serializers.serialize(
        object.deviceSeq,
        specifiedType: const FullType(int),
      );
    }
    if (object.eldDeviceId != null) {
      yield r'eld_device_id';
      yield serializers.serialize(
        object.eldDeviceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.engineHours != null) {
      yield r'engine_hours';
      yield serializers.serialize(
        object.engineHours,
        specifiedType: const FullType(num),
      );
    }
    yield r'event_time';
    yield serializers.serialize(
      object.eventTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'event_type';
    yield serializers.serialize(
      object.eventType,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum),
    );
    if (object.gpsAccuracyM != null) {
      yield r'gps_accuracy_m';
      yield serializers.serialize(
        object.gpsAccuracyM,
        specifiedType: const FullType(int),
      );
    }
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
    if (object.locationText != null) {
      yield r'location_text';
      yield serializers.serialize(
        object.locationText,
        specifiedType: const FullType(String),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.odometerM != null) {
      yield r'odometer_m';
      yield serializers.serialize(
        object.odometerM,
        specifiedType: const FullType(int),
      );
    }
    if (object.origin != null) {
      yield r'origin';
      yield serializers.serialize(
        object.origin,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum),
      );
    }
    if (object.shippingDocIds != null) {
      yield r'shipping_doc_ids';
      yield serializers.serialize(
        object.shippingDocIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.special != null) {
      yield r'special';
      yield serializers.serialize(
        object.special,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum),
      );
    }
    if (object.speedKmh != null) {
      yield r'speed_kmh';
      yield serializers.serialize(
        object.speedKmh,
        specifiedType: const FullType(num),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum),
      );
    }
    if (object.timeSource != null) {
      yield r'time_source';
      yield serializers.serialize(
        object.timeSource,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum),
      );
    }
    if (object.trailerIds != null) {
      yield r'trailer_ids';
      yield serializers.serialize(
        object.trailerIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
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
    GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientEventId = valueDes;
          break;
        case r'device_seq':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.deviceSeq = valueDes;
          break;
        case r'eld_device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.eldDeviceId = valueDes;
          break;
        case r'engine_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.engineHours = valueDes;
          break;
        case r'event_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.eventTime = valueDes;
          break;
        case r'event_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum;
          result.eventType = valueDes;
          break;
        case r'gps_accuracy_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.gpsAccuracyM = valueDes;
          break;
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
        case r'location_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.locationText = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'odometer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.odometerM = valueDes;
          break;
        case r'origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum?;
          if (valueDes == null) continue;
          result.origin = valueDes;
          break;
        case r'shipping_doc_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.shippingDocIds.replace(valueDes);
          break;
        case r'special':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum?;
          if (valueDes == null) continue;
          result.special = valueDes;
          break;
        case r'speed_kmh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.speedKmh = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'time_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum?;
          if (valueDes == null) continue;
          result.timeSource = valueDes;
          break;
        case r'trailer_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.trailerIds.replace(valueDes);
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
  GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushBuilder();
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


class GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'status_change')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum statusChange = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_statusChange;
  @BuiltValueEnumConst(wireName: r'duty_status')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum dutyStatus = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_dutyStatus;
  @BuiltValueEnumConst(wireName: r'intermediate')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum intermediate = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_intermediate;
  @BuiltValueEnumConst(wireName: r'login')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum login = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_login;
  @BuiltValueEnumConst(wireName: r'logout')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum logout = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_logout;
  @BuiltValueEnumConst(wireName: r'power_on')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum powerOn = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_powerOn;
  @BuiltValueEnumConst(wireName: r'power_off')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum powerOff = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_powerOff;
  @BuiltValueEnumConst(wireName: r'engine_on')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum engineOn = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_engineOn;
  @BuiltValueEnumConst(wireName: r'engine_off')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum engineOff = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_engineOff;
  @BuiltValueEnumConst(wireName: r'malfunction')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum malfunction = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_malfunction;
  @BuiltValueEnumConst(wireName: r'diagnostic')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum diagnostic = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_diagnostic;
  @BuiltValueEnumConst(wireName: r'certification')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum certification = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_certification;
  @BuiltValueEnumConst(wireName: r'yard_moves')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum yardMoves = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_yardMoves;
  @BuiltValueEnumConst(wireName: r'personal_use')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum personalUse = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_personalUse;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushEventTypeEnumValueOf(name);
}

/// Origin records how the event came to be. `manual_no_eld` marks a status entered with the ELD disconnected (Q7.1). `driver_edit`, `admin_edit` and `assigned` are server side origins (log edit approval, §10.4 hand over) and are refused here with `rejected(invalid_payload)`.
class GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'auto')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum auto = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum_auto;
  @BuiltValueEnumConst(wireName: r'driver')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum driver = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum_driver;
  @BuiltValueEnumConst(wireName: r'manual_no_eld')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum manualNoEld = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum_manualNoEld;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushOriginEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'none')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum none = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum_none;
  @BuiltValueEnumConst(wireName: r'pc')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum pc = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum_pc;
  @BuiltValueEnumConst(wireName: r'ym')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum ym = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum_ym;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushSpecialEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OFF')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum OFF = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum_OFF;
  @BuiltValueEnumConst(wireName: r'SB')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum SB = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum_SB;
  @BuiltValueEnumConst(wireName: r'DR')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum DR = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum_DR;
  @BuiltValueEnumConst(wireName: r'ON')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum ON = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum_ON;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushStatusEnumValueOf(name);
}

/// TimeSource is the clock event_time came from (Q-B1.2).
class GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'eld_rtc')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum eldRtc = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum_eldRtc;
  @BuiltValueEnumConst(wireName: r'server')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum server = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum_server;
  @BuiltValueEnumConst(wireName: r'phone')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum phone = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum_phone;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoEventPushTimeSourceEnumValueOf(name);
}

