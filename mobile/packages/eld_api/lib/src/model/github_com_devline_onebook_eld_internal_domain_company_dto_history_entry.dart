//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_history_entry.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry
///
/// Properties:
/// * [action] 
/// * [editedBy] 
/// * [editedByName] 
/// * [field] 
/// * [id] 
/// * [newValue] 
/// * [oldValue] 
/// * [recordId] 
/// * [tableName] 
/// * [ts] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry, GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder> {
  @BuiltValueField(wireName: r'action')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum? get action;
  // enum actionEnum {  create,  update,  delete,  soft_delete,  hos_policy_change,  subscription_change,  };

  @BuiltValueField(wireName: r'edited_by')
  String? get editedBy;

  @BuiltValueField(wireName: r'edited_by_name')
  String? get editedByName;

  @BuiltValueField(wireName: r'field')
  String? get field;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'new_value')
  String? get newValue;

  @BuiltValueField(wireName: r'old_value')
  String? get oldValue;

  @BuiltValueField(wireName: r'record_id')
  String? get recordId;

  @BuiltValueField(wireName: r'table_name')
  String? get tableName;

  @BuiltValueField(wireName: r'ts')
  DateTime? get ts;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntrySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntrySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum),
      );
    }
    if (object.editedBy != null) {
      yield r'edited_by';
      yield serializers.serialize(
        object.editedBy,
        specifiedType: const FullType(String),
      );
    }
    if (object.editedByName != null) {
      yield r'edited_by_name';
      yield serializers.serialize(
        object.editedByName,
        specifiedType: const FullType(String),
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
    if (object.recordId != null) {
      yield r'record_id';
      yield serializers.serialize(
        object.recordId,
        specifiedType: const FullType(String),
      );
    }
    if (object.tableName != null) {
      yield r'table_name';
      yield serializers.serialize(
        object.tableName,
        specifiedType: const FullType(String),
      );
    }
    if (object.ts != null) {
      yield r'ts';
      yield serializers.serialize(
        object.ts,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum?;
          if (valueDes == null) continue;
          result.action = valueDes;
          break;
        case r'edited_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.editedBy = valueDes;
          break;
        case r'edited_by_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.editedByName = valueDes;
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
        case r'record_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.recordId = valueDes;
          break;
        case r'table_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tableName = valueDes;
          break;
        case r'ts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.ts = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryBuilder();
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


class GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'create')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum create = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_create;
  @BuiltValueEnumConst(wireName: r'update')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum update = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_update;
  @BuiltValueEnumConst(wireName: r'delete')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum delete = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_delete;
  @BuiltValueEnumConst(wireName: r'soft_delete')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum softDelete = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_softDelete;
  @BuiltValueEnumConst(wireName: r'hos_policy_change')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum hosPolicyChange = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_hosPolicyChange;
  @BuiltValueEnumConst(wireName: r'subscription_change')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum subscriptionChange = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_subscriptionChange;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntryActionEnumValueOf(name);
}

