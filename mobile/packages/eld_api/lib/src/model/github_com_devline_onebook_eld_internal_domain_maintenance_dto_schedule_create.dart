//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_unit_input.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate
///
/// Properties:
/// * [alertType] 
/// * [deliveryMethods] - DeliveryMethods are the channels the reminder is fanned out to.
/// * [intervalUnit] 
/// * [intervalValue] 
/// * [name] 
/// * [notes] 
/// * [notifyCoDriver] - NotifyCoDriver also reminds the co-driver of the unit (Q38).
/// * [reminderBeforeValue] - ReminderBeforeValue fires the Q37 reminder this far ahead of the due point, in the same unit as the interval.
/// * [status] 
/// * [type] - Type is the free form service category shown in the UI.
/// * [units] - Units attaches the fleet covered by this schedule.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateBuilder> {
  @BuiltValueField(wireName: r'alert_type')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum? get alertType;
  // enum alertTypeEnum {  notification,  email,  sms,  none,  };

  /// DeliveryMethods are the channels the reminder is fanned out to.
  @BuiltValueField(wireName: r'delivery_methods')
  BuiltList<String>? get deliveryMethods;

  @BuiltValueField(wireName: r'interval_unit')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum get intervalUnit;
  // enum intervalUnitEnum {  km,  mi,  days,  engine_hours,  };

  @BuiltValueField(wireName: r'interval_value')
  num get intervalValue;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// NotifyCoDriver also reminds the co-driver of the unit (Q38).
  @BuiltValueField(wireName: r'notify_co_driver')
  bool? get notifyCoDriver;

  /// ReminderBeforeValue fires the Q37 reminder this far ahead of the due point, in the same unit as the interval.
  @BuiltValueField(wireName: r'reminder_before_value')
  num? get reminderBeforeValue;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum? get status;
  // enum statusEnum {  active,  inactive,  };

  /// Type is the free form service category shown in the UI.
  @BuiltValueField(wireName: r'type')
  String? get type;

  /// Units attaches the fleet covered by this schedule.
  @BuiltValueField(wireName: r'units')
  BuiltList<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput>? get units;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.alertType != null) {
      yield r'alert_type';
      yield serializers.serialize(
        object.alertType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum),
      );
    }
    if (object.deliveryMethods != null) {
      yield r'delivery_methods';
      yield serializers.serialize(
        object.deliveryMethods,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    yield r'interval_unit';
    yield serializers.serialize(
      object.intervalUnit,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum),
    );
    yield r'interval_value';
    yield serializers.serialize(
      object.intervalValue,
      specifiedType: const FullType(num),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.notifyCoDriver != null) {
      yield r'notify_co_driver';
      yield serializers.serialize(
        object.notifyCoDriver,
        specifiedType: const FullType(bool),
      );
    }
    if (object.reminderBeforeValue != null) {
      yield r'reminder_before_value';
      yield serializers.serialize(
        object.reminderBeforeValue,
        specifiedType: const FullType(num),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(String),
      );
    }
    if (object.units != null) {
      yield r'units';
      yield serializers.serialize(
        object.units,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'alert_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum?;
          if (valueDes == null) continue;
          result.alertType = valueDes;
          break;
        case r'delivery_methods':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.deliveryMethods.replace(valueDes);
          break;
        case r'interval_unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum;
          result.intervalUnit = valueDes;
          break;
        case r'interval_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.intervalValue = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'notify_co_driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.notifyCoDriver = valueDes;
          break;
        case r'reminder_before_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.reminderBeforeValue = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.type = valueDes;
          break;
        case r'units':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput>?;
          if (valueDes == null) continue;
          result.units.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'notification')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum notification = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum_notification;
  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum email = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum sms = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum_sms;
  @BuiltValueEnumConst(wireName: r'none')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum none = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum_none;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateAlertTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'km')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum km = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum_km;
  @BuiltValueEnumConst(wireName: r'mi')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum mi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum_mi;
  @BuiltValueEnumConst(wireName: r'days')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum days = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum_days;
  @BuiltValueEnumConst(wireName: r'engine_hours')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum engineHours = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum_engineHours;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateIntervalUnitEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum active = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleCreateStatusEnumValueOf(name);
}

