//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_record.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord
///
/// Properties:
/// * [cancelledReason] 
/// * [cost] 
/// * [createdAt] 
/// * [currency] 
/// * [engineHours] 
/// * [id] 
/// * [invoiceKey] 
/// * [invoiceNo] 
/// * [notes] 
/// * [odometerM] 
/// * [performedAt] 
/// * [scheduleUnitId] 
/// * [status] 
/// * [unitId] 
/// * [unitNumber] 
/// * [vendor] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder> {
  @BuiltValueField(wireName: r'cancelled_reason')
  String? get cancelledReason;

  @BuiltValueField(wireName: r'cost')
  num? get cost;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'currency')
  String? get currency;

  @BuiltValueField(wireName: r'engine_hours')
  num? get engineHours;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'invoice_key')
  String? get invoiceKey;

  @BuiltValueField(wireName: r'invoice_no')
  String? get invoiceNo;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'odometer_m')
  int? get odometerM;

  @BuiltValueField(wireName: r'performed_at')
  DateTime? get performedAt;

  @BuiltValueField(wireName: r'schedule_unit_id')
  String? get scheduleUnitId;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum? get status;
  // enum statusEnum {  completed,  cancelled,  };

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  @BuiltValueField(wireName: r'vendor')
  String? get vendor;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cancelledReason != null) {
      yield r'cancelled_reason';
      yield serializers.serialize(
        object.cancelledReason,
        specifiedType: const FullType(String),
      );
    }
    if (object.cost != null) {
      yield r'cost';
      yield serializers.serialize(
        object.cost,
        specifiedType: const FullType(num),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
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
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.invoiceKey != null) {
      yield r'invoice_key';
      yield serializers.serialize(
        object.invoiceKey,
        specifiedType: const FullType(String),
      );
    }
    if (object.invoiceNo != null) {
      yield r'invoice_no';
      yield serializers.serialize(
        object.invoiceNo,
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
    if (object.performedAt != null) {
      yield r'performed_at';
      yield serializers.serialize(
        object.performedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.scheduleUnitId != null) {
      yield r'schedule_unit_id';
      yield serializers.serialize(
        object.scheduleUnitId,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum),
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
    if (object.vendor != null) {
      yield r'vendor';
      yield serializers.serialize(
        object.vendor,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder result,
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
        case r'cost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.cost = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currency = valueDes;
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
        case r'invoice_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.invoiceKey = valueDes;
          break;
        case r'invoice_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.invoiceNo = valueDes;
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
        case r'performed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.performedAt = valueDes;
          break;
        case r'schedule_unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.scheduleUnitId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum?;
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
        case r'vendor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vendor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder();
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


class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'completed')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum completed = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum cancelled = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnumValueOf(name);
}

