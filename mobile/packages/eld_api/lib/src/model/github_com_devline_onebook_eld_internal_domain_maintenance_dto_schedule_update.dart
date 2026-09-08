//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_unit_input.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate
///
/// Properties:
/// * [alertType] 
/// * [deliveryMethods] 
/// * [intervalUnit] 
/// * [intervalValue] 
/// * [name] 
/// * [notes] 
/// * [notifyCoDriver] 
/// * [reminderBeforeValue] 
/// * [status] 
/// * [type] 
/// * [units] - Units replaces the attached fleet when present; omit to keep it as is.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateBuilder> {
  @BuiltValueField(wireName: r'alert_type')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum? get alertType;
  // enum alertTypeEnum {  notification,  email,  sms,  none,  };

  @BuiltValueField(wireName: r'delivery_methods')
  BuiltList<String>? get deliveryMethods;

  @BuiltValueField(wireName: r'interval_unit')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum? get intervalUnit;
  // enum intervalUnitEnum {  km,  mi,  days,  engine_hours,  };

  @BuiltValueField(wireName: r'interval_value')
  num? get intervalValue;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'notify_co_driver')
  bool? get notifyCoDriver;

  @BuiltValueField(wireName: r'reminder_before_value')
  num? get reminderBeforeValue;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum? get status;
  // enum statusEnum {  active,  inactive,  };

  @BuiltValueField(wireName: r'type')
  String? get type;

  /// Units replaces the attached fleet when present; omit to keep it as is.
  @BuiltValueField(wireName: r'units')
  BuiltList<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput>? get units;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.alertType != null) {
      yield r'alert_type';
      yield serializers.serialize(
        object.alertType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum),
      );
    }
    if (object.deliveryMethods != null) {
      yield r'delivery_methods';
      yield serializers.serialize(
        object.deliveryMethods,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.intervalUnit != null) {
      yield r'interval_unit';
      yield serializers.serialize(
        object.intervalUnit,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum),
      );
    }
    if (object.intervalValue != null) {
      yield r'interval_value';
      yield serializers.serialize(
        object.intervalValue,
        specifiedType: const FullType(num),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum),
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
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'alert_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum?;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum?;
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum?;
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
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'notification')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum notification = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum_notification;
  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum email = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum sms = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum_sms;
  @BuiltValueEnumConst(wireName: r'none')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum none = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum_none;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateAlertTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'km')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum km = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum_km;
  @BuiltValueEnumConst(wireName: r'mi')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum mi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum_mi;
  @BuiltValueEnumConst(wireName: r'days')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum days = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum_days;
  @BuiltValueEnumConst(wireName: r'engine_hours')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum engineHours = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum_engineHours;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateIntervalUnitEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum active = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUpdateStatusEnumValueOf(name);
}

