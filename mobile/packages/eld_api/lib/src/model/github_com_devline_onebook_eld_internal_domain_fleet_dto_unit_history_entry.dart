//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_history_entry.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry
///
/// Properties:
/// * [action] 
/// * [actorId] 
/// * [actorName] 
/// * [at] 
/// * [field] 
/// * [id] 
/// * [kind] - Kind separates the two sources merged into one timeline.
/// * [newValue] 
/// * [oldValue] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryBuilder> {
  @BuiltValueField(wireName: r'action')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum? get action;
  // enum actionEnum {  create,  update,  delete,  restore,  assign,  };

  @BuiltValueField(wireName: r'actor_id')
  String? get actorId;

  @BuiltValueField(wireName: r'actor_name')
  String? get actorName;

  @BuiltValueField(wireName: r'at')
  DateTime? get at;

  @BuiltValueField(wireName: r'field')
  String? get field;

  @BuiltValueField(wireName: r'id')
  String? get id;

  /// Kind separates the two sources merged into one timeline.
  @BuiltValueField(wireName: r'kind')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum? get kind;
  // enum kindEnum {  audit,  assignment,  };

  @BuiltValueField(wireName: r'new_value')
  String? get newValue;

  @BuiltValueField(wireName: r'old_value')
  String? get oldValue;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntrySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntrySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum),
      );
    }
    if (object.actorId != null) {
      yield r'actor_id';
      yield serializers.serialize(
        object.actorId,
        specifiedType: const FullType(String),
      );
    }
    if (object.actorName != null) {
      yield r'actor_name';
      yield serializers.serialize(
        object.actorName,
        specifiedType: const FullType(String),
      );
    }
    if (object.at != null) {
      yield r'at';
      yield serializers.serialize(
        object.at,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.field != null) {
      yield r'field';
      yield serializers.serialize(
        object.field,
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
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum),
      );
    }
    if (object.newValue != null) {
      yield r'new_value';
      yield serializers.serialize(
        object.newValue,
        specifiedType: const FullType(String),
      );
    }
    if (object.oldValue != null) {
      yield r'old_value';
      yield serializers.serialize(
        object.oldValue,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum?;
          if (valueDes == null) continue;
          result.action = valueDes;
          break;
        case r'actor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.actorId = valueDes;
          break;
        case r'actor_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.actorName = valueDes;
          break;
        case r'at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.at = valueDes;
          break;
        case r'field':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.field = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'new_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.newValue = valueDes;
          break;
        case r'old_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.oldValue = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryBuilder();
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


class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'create')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum create = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum_create;
  @BuiltValueEnumConst(wireName: r'update')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum update = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum_update;
  @BuiltValueEnumConst(wireName: r'delete')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum delete = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum_delete;
  @BuiltValueEnumConst(wireName: r'restore')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum restore = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum_restore;
  @BuiltValueEnumConst(wireName: r'assign')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum assign = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum_assign;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryActionEnumValueOf(name);
}

/// Kind separates the two sources merged into one timeline.
class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'audit')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum audit = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum_audit;
  @BuiltValueEnumConst(wireName: r'assignment')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum assignment = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum_assignment;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitHistoryEntryKindEnumValueOf(name);
}

