//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule
///
/// Properties:
/// * [alertType] 
/// * [createdAt] 
/// * [deliveryMethods] 
/// * [id] 
/// * [intervalUnit] 
/// * [intervalValue] 
/// * [name] 
/// * [notes] 
/// * [notifyCoDriver] 
/// * [reminderBeforeValue] 
/// * [status] 
/// * [type] 
/// * [unitCount] - UnitCount is the number of units currently attached.
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleBuilder> {
  @BuiltValueField(wireName: r'alert_type')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum? get alertType;
  // enum alertTypeEnum {  notification,  email,  sms,  none,  };

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'delivery_methods')
  BuiltList<String>? get deliveryMethods;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'interval_unit')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum? get intervalUnit;
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
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum? get status;
  // enum statusEnum {  active,  inactive,  };

  @BuiltValueField(wireName: r'type')
  String? get type;

  /// UnitCount is the number of units currently attached.
  @BuiltValueField(wireName: r'unit_count')
  int? get unitCount;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.alertType != null) {
      yield r'alert_type';
      yield serializers.serialize(
        object.alertType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.deliveryMethods != null) {
      yield r'delivery_methods';
      yield serializers.serialize(
        object.deliveryMethods,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(String),
      );
    }
    if (object.unitCount != null) {
      yield r'unit_count';
      yield serializers.serialize(
        object.unitCount,
        specifiedType: const FullType(int),
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
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'alert_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum?;
          if (valueDes == null) continue;
          result.alertType = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'delivery_methods':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.deliveryMethods.replace(valueDes);
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum?;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum?;
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
        case r'unit_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.unitCount = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoSchedule deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleBuilder();
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


class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'notification')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum notification = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum_notification;
  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum email = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum sms = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum_sms;
  @BuiltValueEnumConst(wireName: r'none')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum none = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum_none;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleAlertTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'km')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum km = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum_km;
  @BuiltValueEnumConst(wireName: r'mi')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum mi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum_mi;
  @BuiltValueEnumConst(wireName: r'days')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum days = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum_days;
  @BuiltValueEnumConst(wireName: r'engine_hours')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum engineHours = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum_engineHours;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleIntervalUnitEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum active = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleStatusEnumValueOf(name);
}

