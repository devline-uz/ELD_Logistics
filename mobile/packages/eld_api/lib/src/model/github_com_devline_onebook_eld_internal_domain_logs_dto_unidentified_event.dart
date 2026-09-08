//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_unidentified_event.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent
///
/// Properties:
/// * [annotation] 
/// * [assignedDriverId] 
/// * [assignedDriverName] 
/// * [createdAt] 
/// * [distanceM] 
/// * [editRequestId] 
/// * [endAt] 
/// * [id] 
/// * [startAt] 
/// * [status] - Status is `proposed` while an admin assignment waits for the driver.
/// * [unitId] 
/// * [unitNumber] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent, GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder> {
  @BuiltValueField(wireName: r'annotation')
  String? get annotation;

  @BuiltValueField(wireName: r'assigned_driver_id')
  String? get assignedDriverId;

  @BuiltValueField(wireName: r'assigned_driver_name')
  String? get assignedDriverName;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'distance_m')
  int? get distanceM;

  @BuiltValueField(wireName: r'edit_request_id')
  String? get editRequestId;

  @BuiltValueField(wireName: r'end_at')
  DateTime? get endAt;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'start_at')
  DateTime? get startAt;

  /// Status is `proposed` while an admin assignment waits for the driver.
  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum? get status;
  // enum statusEnum {  pending,  proposed,  assigned,  annotated,  };

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent, _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent object, {
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
    if (object.assignedDriverName != null) {
      yield r'assigned_driver_name';
      yield serializers.serialize(
        object.assignedDriverName,
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
    if (object.editRequestId != null) {
      yield r'edit_request_id';
      yield serializers.serialize(
        object.editRequestId,
        specifiedType: const FullType(String),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum),
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
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder result,
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
        case r'assigned_driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assignedDriverName = valueDes;
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
        case r'edit_request_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.editRequestId = valueDes;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum?;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder();
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


/// Status is `proposed` while an admin assignment waits for the driver.
class GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum pending = _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'proposed')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum proposed = _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_proposed;
  @BuiltValueEnumConst(wireName: r'assigned')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum assigned = _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_assigned;
  @BuiltValueEnumConst(wireName: r'annotated')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum annotated = _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_annotated;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnumValueOf(name);
}

