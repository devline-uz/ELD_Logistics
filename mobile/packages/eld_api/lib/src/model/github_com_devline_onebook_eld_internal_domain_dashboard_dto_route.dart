//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dashboard_dto_route.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute
///
/// Properties:
/// * [completedAt] 
/// * [createdAt] 
/// * [destination] 
/// * [driverId] 
/// * [driverName] 
/// * [id] 
/// * [origin] 
/// * [sequence] 
/// * [startedAt] 
/// * [status] 
/// * [unitId] 
/// * [unitNumber] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute implements Built<GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute, GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder> {
  @BuiltValueField(wireName: r'completed_at')
  DateTime? get completedAt;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'destination')
  String? get destination;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'origin')
  String? get origin;

  @BuiltValueField(wireName: r'sequence')
  int? get sequence;

  @BuiltValueField(wireName: r'started_at')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum? get status;
  // enum statusEnum {  planned,  in_progress,  completed,  not_completed,  cancelled,  };

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute._();

  factory GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute([void updates(GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute> get serializer => _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute, _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.completedAt != null) {
      yield r'completed_at';
      yield serializers.serialize(
        object.completedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.destination != null) {
      yield r'destination';
      yield serializers.serialize(
        object.destination,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.origin != null) {
      yield r'origin';
      yield serializers.serialize(
        object.origin,
        specifiedType: const FullType(String),
      );
    }
    if (object.sequence != null) {
      yield r'sequence';
      yield serializers.serialize(
        object.sequence,
        specifiedType: const FullType(int),
      );
    }
    if (object.startedAt != null) {
      yield r'started_at';
      yield serializers.serialize(
        object.startedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum),
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
    GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'completed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'destination':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.destination = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverName = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.origin = valueDes;
          break;
        case r'sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sequence = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum?;
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
  GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder();
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


class GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'planned')
  static const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum planned = _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_planned;
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum inProgress = _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'completed')
  static const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum completed = _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'not_completed')
  static const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum notCompleted = _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_notCompleted;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum cancelled = _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnumValueOf(name);
}

