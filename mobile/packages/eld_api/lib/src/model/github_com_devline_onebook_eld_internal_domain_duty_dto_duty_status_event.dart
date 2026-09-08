//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_duty_dto_duty_status_event.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent
///
/// Properties:
/// * [clientEventId] 
/// * [clockSkewSec] - ClockSkewSec is phone minus reference clock, in seconds.
/// * [dailyLogId] 
/// * [deviceSeq] 
/// * [engineHours] 
/// * [eventTime] 
/// * [eventType] 
/// * [gpsAccuracyM] 
/// * [id] 
/// * [lat] 
/// * [lng] 
/// * [locationText] 
/// * [locked] 
/// * [notes] 
/// * [odometerM] 
/// * [origin] 
/// * [receivedAt] 
/// * [shippingDocIds] 
/// * [special] 
/// * [status] 
/// * [supersededBy] - SupersededBy points at the event that won conflict rule 1; a superseded event stays in the log and never disappears.
/// * [timeSource] - TimeSource is the clock the event_time came from (Q-B1.2).
/// * [timeUnverified] - TimeUnverified marks an event stamped from the phone only; the admin log shows it with a yellow marker (Q7.1).
/// * [trailerIds] 
/// * [unitId] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent implements Built<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent, GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String? get clientEventId;

  /// ClockSkewSec is phone minus reference clock, in seconds.
  @BuiltValueField(wireName: r'clock_skew_sec')
  int? get clockSkewSec;

  @BuiltValueField(wireName: r'daily_log_id')
  String? get dailyLogId;

  @BuiltValueField(wireName: r'device_seq')
  int? get deviceSeq;

  @BuiltValueField(wireName: r'engine_hours')
  num? get engineHours;

  @BuiltValueField(wireName: r'event_time')
  DateTime? get eventTime;

  @BuiltValueField(wireName: r'event_type')
  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum? get eventType;
  // enum eventTypeEnum {  duty_status,  intermediate,  login,  logout,  power_on,  power_off,  engine_on,  engine_off,  malfunction,  diagnostic,  certification,  yard_moves,  personal_use,  };

  @BuiltValueField(wireName: r'gps_accuracy_m')
  int? get gpsAccuracyM;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'location_text')
  String? get locationText;

  @BuiltValueField(wireName: r'locked')
  bool? get locked;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'odometer_m')
  int? get odometerM;

  @BuiltValueField(wireName: r'origin')
  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum? get origin;
  // enum originEnum {  auto,  driver,  driver_edit,  admin_edit,  assigned,  manual_no_eld,  };

  @BuiltValueField(wireName: r'received_at')
  DateTime? get receivedAt;

  @BuiltValueField(wireName: r'shipping_doc_ids')
  BuiltList<String>? get shippingDocIds;

  @BuiltValueField(wireName: r'special')
  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum? get special;
  // enum specialEnum {  none,  pc,  ym,  };

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum? get status;
  // enum statusEnum {  OFF,  SB,  DR,  ON,  };

  /// SupersededBy points at the event that won conflict rule 1; a superseded event stays in the log and never disappears.
  @BuiltValueField(wireName: r'superseded_by')
  String? get supersededBy;

  /// TimeSource is the clock the event_time came from (Q-B1.2).
  @BuiltValueField(wireName: r'time_source')
  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum? get timeSource;
  // enum timeSourceEnum {  eld_rtc,  server,  phone,  };

  /// TimeUnverified marks an event stamped from the phone only; the admin log shows it with a yellow marker (Q7.1).
  @BuiltValueField(wireName: r'time_unverified')
  bool? get timeUnverified;

  @BuiltValueField(wireName: r'trailer_ids')
  BuiltList<String>? get trailerIds;

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent._();

  factory GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent([void updates(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent> get serializer => _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent, _$GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.clientEventId != null) {
      yield r'client_event_id';
      yield serializers.serialize(
        object.clientEventId,
        specifiedType: const FullType(String),
      );
    }
    if (object.clockSkewSec != null) {
      yield r'clock_skew_sec';
      yield serializers.serialize(
        object.clockSkewSec,
        specifiedType: const FullType(int),
      );
    }
    if (object.dailyLogId != null) {
      yield r'daily_log_id';
      yield serializers.serialize(
        object.dailyLogId,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceSeq != null) {
      yield r'device_seq';
      yield serializers.serialize(
        object.deviceSeq,
        specifiedType: const FullType(int),
      );
    }
    if (object.engineHours != null) {
      yield r'engine_hours';
      yield serializers.serialize(
        object.engineHours,
        specifiedType: const FullType(num),
      );
    }
    if (object.eventTime != null) {
      yield r'event_time';
      yield serializers.serialize(
        object.eventTime,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.eventType != null) {
      yield r'event_type';
      yield serializers.serialize(
        object.eventType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum),
      );
    }
    if (object.gpsAccuracyM != null) {
      yield r'gps_accuracy_m';
      yield serializers.serialize(
        object.gpsAccuracyM,
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
    if (object.locked != null) {
      yield r'locked';
      yield serializers.serialize(
        object.locked,
        specifiedType: const FullType(bool),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum),
      );
    }
    if (object.receivedAt != null) {
      yield r'received_at';
      yield serializers.serialize(
        object.receivedAt,
        specifiedType: const FullType(DateTime),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum),
      );
    }
    if (object.supersededBy != null) {
      yield r'superseded_by';
      yield serializers.serialize(
        object.supersededBy,
        specifiedType: const FullType(String),
      );
    }
    if (object.timeSource != null) {
      yield r'time_source';
      yield serializers.serialize(
        object.timeSource,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum),
      );
    }
    if (object.timeUnverified != null) {
      yield r'time_unverified';
      yield serializers.serialize(
        object.timeUnverified,
        specifiedType: const FullType(bool),
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
    GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.clientEventId = valueDes;
          break;
        case r'clock_skew_sec':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.clockSkewSec = valueDes;
          break;
        case r'daily_log_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.dailyLogId = valueDes;
          break;
        case r'device_seq':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.deviceSeq = valueDes;
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
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.eventTime = valueDes;
          break;
        case r'event_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum?;
          if (valueDes == null) continue;
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
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
        case r'locked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.locked = valueDes;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum?;
          if (valueDes == null) continue;
          result.origin = valueDes;
          break;
        case r'received_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.receivedAt = valueDes;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum?;
          if (valueDes == null) continue;
          result.special = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'superseded_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.supersededBy = valueDes;
          break;
        case r'time_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum?;
          if (valueDes == null) continue;
          result.timeSource = valueDes;
          break;
        case r'time_unverified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.timeUnverified = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventBuilder();
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


class GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'duty_status')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum dutyStatus = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_dutyStatus;
  @BuiltValueEnumConst(wireName: r'intermediate')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum intermediate = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_intermediate;
  @BuiltValueEnumConst(wireName: r'login')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum login = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_login;
  @BuiltValueEnumConst(wireName: r'logout')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum logout = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_logout;
  @BuiltValueEnumConst(wireName: r'power_on')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum powerOn = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_powerOn;
  @BuiltValueEnumConst(wireName: r'power_off')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum powerOff = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_powerOff;
  @BuiltValueEnumConst(wireName: r'engine_on')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum engineOn = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_engineOn;
  @BuiltValueEnumConst(wireName: r'engine_off')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum engineOff = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_engineOff;
  @BuiltValueEnumConst(wireName: r'malfunction')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum malfunction = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_malfunction;
  @BuiltValueEnumConst(wireName: r'diagnostic')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum diagnostic = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_diagnostic;
  @BuiltValueEnumConst(wireName: r'certification')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum certification = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_certification;
  @BuiltValueEnumConst(wireName: r'yard_moves')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum yardMoves = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_yardMoves;
  @BuiltValueEnumConst(wireName: r'personal_use')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum personalUse = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_personalUse;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventEventTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'auto')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum auto = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum_auto;
  @BuiltValueEnumConst(wireName: r'driver')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum driver = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum_driver;
  @BuiltValueEnumConst(wireName: r'driver_edit')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum driverEdit = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum_driverEdit;
  @BuiltValueEnumConst(wireName: r'admin_edit')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum adminEdit = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum_adminEdit;
  @BuiltValueEnumConst(wireName: r'assigned')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum assigned = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum_assigned;
  @BuiltValueEnumConst(wireName: r'manual_no_eld')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum manualNoEld = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum_manualNoEld;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum> get values => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventOriginEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'none')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum none = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum_none;
  @BuiltValueEnumConst(wireName: r'pc')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum pc = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum_pc;
  @BuiltValueEnumConst(wireName: r'ym')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum ym = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum_ym;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum> get values => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventSpecialEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OFF')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum OFF = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum_OFF;
  @BuiltValueEnumConst(wireName: r'SB')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum SB = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum_SB;
  @BuiltValueEnumConst(wireName: r'DR')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum DR = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum_DR;
  @BuiltValueEnumConst(wireName: r'ON')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum ON = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum_ON;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventStatusEnumValueOf(name);
}

/// TimeSource is the clock the event_time came from (Q-B1.2).
class GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'eld_rtc')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum eldRtc = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum_eldRtc;
  @BuiltValueEnumConst(wireName: r'server')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum server = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum_server;
  @BuiltValueEnumConst(wireName: r'phone')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum phone = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum_phone;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum> get values => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDutyDtoDutyStatusEventTimeSourceEnumValueOf(name);
}

