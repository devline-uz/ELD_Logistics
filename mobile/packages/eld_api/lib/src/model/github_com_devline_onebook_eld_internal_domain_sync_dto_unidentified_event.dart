//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_unidentified_event.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent
///
/// Properties:
/// * [distanceM] 
/// * [endAt] 
/// * [id] 
/// * [startAt] 
/// * [status] 
/// * [unitId] 
/// * [unitNumber] 
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent, GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder> {
  @BuiltValueField(wireName: r'distance_m')
  int? get distanceM;

  @BuiltValueField(wireName: r'end_at')
  DateTime? get endAt;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'start_at')
  DateTime? get startAt;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum? get status;
  // enum statusEnum {  pending,  assigned,  annotated,  };

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent, _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.distanceM != null) {
      yield r'distance_m';
      yield serializers.serialize(
        object.distanceM,
        specifiedType: const FullType(int),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum),
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
    GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.distanceM = valueDes;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum?;
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
  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder();
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


class GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum pending = _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'assigned')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum assigned = _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_assigned;
  @BuiltValueEnumConst(wireName: r'annotated')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum annotated = _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_annotated;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnumValueOf(name);
}

