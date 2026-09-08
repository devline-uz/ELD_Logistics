//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_event.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent
///
/// Properties:
/// * [edited] - Edited marks the ✎ badge: the row came from an edit (Q17.2).
/// * [engineHours] 
/// * [eventTime] 
/// * [eventType] 
/// * [id] 
/// * [lat] 
/// * [lng] 
/// * [locationText] 
/// * [locked] - Locked is true once the day has been certified (Q26.1).
/// * [notes] 
/// * [odometerM] 
/// * [origin] - Origin says who produced the row; `auto` is the ELD itself (Q13.1).
/// * [receivedAt] 
/// * [special] 
/// * [status] 
/// * [supersededBy] - SupersededBy points at the row that replaced this one. The original is never deleted (Q17).
/// * [timeSource] 
/// * [unitId] 
/// * [unitNumber] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent, GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventBuilder> {
  /// Edited marks the ✎ badge: the row came from an edit (Q17.2).
  @BuiltValueField(wireName: r'edited')
  bool? get edited;

  @BuiltValueField(wireName: r'engine_hours')
  num? get engineHours;

  @BuiltValueField(wireName: r'event_time')
  DateTime? get eventTime;

  @BuiltValueField(wireName: r'event_type')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum? get eventType;
  // enum eventTypeEnum {  duty_status,  intermediate,  login,  logout,  power_on,  power_off,  engine_on,  engine_off,  malfunction,  diagnostic,  certification,  yard_moves,  personal_use,  };

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'location_text')
  String? get locationText;

  /// Locked is true once the day has been certified (Q26.1).
  @BuiltValueField(wireName: r'locked')
  bool? get locked;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'odometer_m')
  int? get odometerM;

  /// Origin says who produced the row; `auto` is the ELD itself (Q13.1).
  @BuiltValueField(wireName: r'origin')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum? get origin;
  // enum originEnum {  auto,  driver,  driver_edit,  admin_edit,  assigned,  };

  @BuiltValueField(wireName: r'received_at')
  DateTime? get receivedAt;

  @BuiltValueField(wireName: r'special')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum? get special;
  // enum specialEnum {  none,  pc,  ym,  };

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum? get status;
  // enum statusEnum {  OFF,  SB,  DR,  ON,  };

  /// SupersededBy points at the row that replaced this one. The original is never deleted (Q17).
  @BuiltValueField(wireName: r'superseded_by')
  String? get supersededBy;

  @BuiltValueField(wireName: r'time_source')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum? get timeSource;
  // enum timeSourceEnum {  eld_rtc,  server,  phone,  };

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent, _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.edited != null) {
      yield r'edited';
      yield serializers.serialize(
        object.edited,
        specifiedType: const FullType(bool),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum),
      );
    }
    if (object.receivedAt != null) {
      yield r'received_at';
      yield serializers.serialize(
        object.receivedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.special != null) {
      yield r'special';
      yield serializers.serialize(
        object.special,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum),
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
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'edited':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.edited = valueDes;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum?;
          if (valueDes == null) continue;
          result.eventType = valueDes;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum?;
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
        case r'special':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum?;
          if (valueDes == null) continue;
          result.special = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum?;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum?;
          if (valueDes == null) continue;
          result.timeSource = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventBuilder();
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


class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'duty_status')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum dutyStatus = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_dutyStatus;
  @BuiltValueEnumConst(wireName: r'intermediate')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum intermediate = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_intermediate;
  @BuiltValueEnumConst(wireName: r'login')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum login = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_login;
  @BuiltValueEnumConst(wireName: r'logout')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum logout = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_logout;
  @BuiltValueEnumConst(wireName: r'power_on')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum powerOn = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_powerOn;
  @BuiltValueEnumConst(wireName: r'power_off')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum powerOff = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_powerOff;
  @BuiltValueEnumConst(wireName: r'engine_on')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum engineOn = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_engineOn;
  @BuiltValueEnumConst(wireName: r'engine_off')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum engineOff = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_engineOff;
  @BuiltValueEnumConst(wireName: r'malfunction')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum malfunction = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_malfunction;
  @BuiltValueEnumConst(wireName: r'diagnostic')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum diagnostic = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_diagnostic;
  @BuiltValueEnumConst(wireName: r'certification')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum certification = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_certification;
  @BuiltValueEnumConst(wireName: r'yard_moves')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum yardMoves = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_yardMoves;
  @BuiltValueEnumConst(wireName: r'personal_use')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum personalUse = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_personalUse;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventEventTypeEnumValueOf(name);
}

/// Origin says who produced the row; `auto` is the ELD itself (Q13.1).
class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'auto')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum auto = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum_auto;
  @BuiltValueEnumConst(wireName: r'driver')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum driver = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum_driver;
  @BuiltValueEnumConst(wireName: r'driver_edit')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum driverEdit = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum_driverEdit;
  @BuiltValueEnumConst(wireName: r'admin_edit')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum adminEdit = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum_adminEdit;
  @BuiltValueEnumConst(wireName: r'assigned')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum assigned = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum_assigned;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventOriginEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'none')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum none = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum_none;
  @BuiltValueEnumConst(wireName: r'pc')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum pc = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum_pc;
  @BuiltValueEnumConst(wireName: r'ym')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum ym = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum_ym;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventSpecialEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OFF')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum OFF = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum_OFF;
  @BuiltValueEnumConst(wireName: r'SB')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum SB = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum_SB;
  @BuiltValueEnumConst(wireName: r'DR')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum DR = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum_DR;
  @BuiltValueEnumConst(wireName: r'ON')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum ON = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum_ON;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventStatusEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'eld_rtc')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum eldRtc = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum_eldRtc;
  @BuiltValueEnumConst(wireName: r'server')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum server = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum_server;
  @BuiltValueEnumConst(wireName: r'phone')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum phone = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum_phone;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventTimeSourceEnumValueOf(name);
}

