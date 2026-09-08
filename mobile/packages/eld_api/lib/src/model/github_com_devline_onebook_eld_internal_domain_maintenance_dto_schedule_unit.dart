//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_unit.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit
///
/// Properties:
/// * [cancelledReason] 
/// * [createdAt] 
/// * [currentValue] - CurrentValue is the live reading: telemetry for km/mi/engine hours, elapsed days for a day interval. Null when the unit never reported.
/// * [engineHours] 
/// * [id] 
/// * [intervalUnit] 
/// * [intervalValue] 
/// * [lastServiceAt] 
/// * [lastServiceValue] - LastServiceValue is the reading at the last completed service.
/// * [nextDueAt] 
/// * [nextDueValue] - NextDueValue is last_service_value + interval_value.
/// * [odometerM] - OdometerM is the raw telemetry odometer in metres, for clients that do their own unit conversion.
/// * [overdue] - Overdue is Remaining < 0 (Q34 — shown red in the UI).
/// * [remaining] - Remaining is next_due_value - current_value; negative means overdue.
/// * [reminderDue] - ReminderDue is true once Remaining fell to reminder_before_value.
/// * [reminderSentAt] 
/// * [scheduleId] 
/// * [scheduleName] 
/// * [scheduleType] 
/// * [status] 
/// * [unitId] 
/// * [unitNumber] 
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitBuilder> {
  @BuiltValueField(wireName: r'cancelled_reason')
  String? get cancelledReason;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  /// CurrentValue is the live reading: telemetry for km/mi/engine hours, elapsed days for a day interval. Null when the unit never reported.
  @BuiltValueField(wireName: r'current_value')
  num? get currentValue;

  @BuiltValueField(wireName: r'engine_hours')
  num? get engineHours;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'interval_unit')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum? get intervalUnit;
  // enum intervalUnitEnum {  km,  mi,  days,  engine_hours,  };

  @BuiltValueField(wireName: r'interval_value')
  num? get intervalValue;

  @BuiltValueField(wireName: r'last_service_at')
  DateTime? get lastServiceAt;

  /// LastServiceValue is the reading at the last completed service.
  @BuiltValueField(wireName: r'last_service_value')
  num? get lastServiceValue;

  @BuiltValueField(wireName: r'next_due_at')
  DateTime? get nextDueAt;

  /// NextDueValue is last_service_value + interval_value.
  @BuiltValueField(wireName: r'next_due_value')
  num? get nextDueValue;

  /// OdometerM is the raw telemetry odometer in metres, for clients that do their own unit conversion.
  @BuiltValueField(wireName: r'odometer_m')
  int? get odometerM;

  /// Overdue is Remaining < 0 (Q34 — shown red in the UI).
  @BuiltValueField(wireName: r'overdue')
  bool? get overdue;

  /// Remaining is next_due_value - current_value; negative means overdue.
  @BuiltValueField(wireName: r'remaining')
  num? get remaining;

  /// ReminderDue is true once Remaining fell to reminder_before_value.
  @BuiltValueField(wireName: r'reminder_due')
  bool? get reminderDue;

  @BuiltValueField(wireName: r'reminder_sent_at')
  DateTime? get reminderSentAt;

  @BuiltValueField(wireName: r'schedule_id')
  String? get scheduleId;

  @BuiltValueField(wireName: r'schedule_name')
  String? get scheduleName;

  @BuiltValueField(wireName: r'schedule_type')
  String? get scheduleType;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum? get status;
  // enum statusEnum {  scheduled,  due,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cancelledReason != null) {
      yield r'cancelled_reason';
      yield serializers.serialize(
        object.cancelledReason,
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
    if (object.currentValue != null) {
      yield r'current_value';
      yield serializers.serialize(
        object.currentValue,
        specifiedType: const FullType(num),
      );
    }
    if (object.engineHours != null) {
      yield r'engine_hours';
      yield serializers.serialize(
        object.engineHours,
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
    if (object.intervalUnit != null) {
      yield r'interval_unit';
      yield serializers.serialize(
        object.intervalUnit,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum),
      );
    }
    if (object.intervalValue != null) {
      yield r'interval_value';
      yield serializers.serialize(
        object.intervalValue,
        specifiedType: const FullType(num),
      );
    }
    if (object.lastServiceAt != null) {
      yield r'last_service_at';
      yield serializers.serialize(
        object.lastServiceAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.lastServiceValue != null) {
      yield r'last_service_value';
      yield serializers.serialize(
        object.lastServiceValue,
        specifiedType: const FullType(num),
      );
    }
    if (object.nextDueAt != null) {
      yield r'next_due_at';
      yield serializers.serialize(
        object.nextDueAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.nextDueValue != null) {
      yield r'next_due_value';
      yield serializers.serialize(
        object.nextDueValue,
        specifiedType: const FullType(num),
      );
    }
    if (object.odometerM != null) {
      yield r'odometer_m';
      yield serializers.serialize(
        object.odometerM,
        specifiedType: const FullType(int),
      );
    }
    if (object.overdue != null) {
      yield r'overdue';
      yield serializers.serialize(
        object.overdue,
        specifiedType: const FullType(bool),
      );
    }
    if (object.remaining != null) {
      yield r'remaining';
      yield serializers.serialize(
        object.remaining,
        specifiedType: const FullType(num),
      );
    }
    if (object.reminderDue != null) {
      yield r'reminder_due';
      yield serializers.serialize(
        object.reminderDue,
        specifiedType: const FullType(bool),
      );
    }
    if (object.reminderSentAt != null) {
      yield r'reminder_sent_at';
      yield serializers.serialize(
        object.reminderSentAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.scheduleId != null) {
      yield r'schedule_id';
      yield serializers.serialize(
        object.scheduleId,
        specifiedType: const FullType(String),
      );
    }
    if (object.scheduleName != null) {
      yield r'schedule_name';
      yield serializers.serialize(
        object.scheduleName,
        specifiedType: const FullType(String),
      );
    }
    if (object.scheduleType != null) {
      yield r'schedule_type';
      yield serializers.serialize(
        object.scheduleType,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum),
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
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cancelled_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cancelledReason = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'current_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.currentValue = valueDes;
          break;
        case r'engine_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.engineHours = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'interval_unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum?;
          if (valueDes == null) continue;
          result.intervalUnit = valueDes;
          break;
        case r'interval_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.intervalValue = valueDes;
          break;
        case r'last_service_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastServiceAt = valueDes;
          break;
        case r'last_service_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lastServiceValue = valueDes;
          break;
        case r'next_due_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.nextDueAt = valueDes;
          break;
        case r'next_due_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.nextDueValue = valueDes;
          break;
        case r'odometer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.odometerM = valueDes;
          break;
        case r'overdue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.overdue = valueDes;
          break;
        case r'remaining':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.remaining = valueDes;
          break;
        case r'reminder_due':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.reminderDue = valueDes;
          break;
        case r'reminder_sent_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.reminderSentAt = valueDes;
          break;
        case r'schedule_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.scheduleId = valueDes;
          break;
        case r'schedule_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.scheduleName = valueDes;
          break;
        case r'schedule_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.scheduleType = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum?;
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
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitBuilder();
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


class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'km')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum km = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum_km;
  @BuiltValueEnumConst(wireName: r'mi')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum mi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum_mi;
  @BuiltValueEnumConst(wireName: r'days')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum days = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum_days;
  @BuiltValueEnumConst(wireName: r'engine_hours')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum engineHours = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum_engineHours;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitIntervalUnitEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum scheduled = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'due')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum due = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum_due;
  @BuiltValueEnumConst(wireName: r'completed')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum completed = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum cancelled = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitStatusEnumValueOf(name);
}

