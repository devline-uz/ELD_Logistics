//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_role.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoRole
///
/// Properties:
/// * [createdAt] 
/// * [description] 
/// * [id] 
/// * [isSystem] - IsSystem roles (Super Admin, Administrator, ...) cannot be edited.
/// * [name] 
/// * [permissions] 
/// * [scope] - Scope decides how far a holder of the role can see (TZ Q82.1).
/// * [updatedAt] 
/// * [userCount] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoRole implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoRole, GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder> {
  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'id')
  String? get id;

  /// IsSystem roles (Super Admin, Administrator, ...) cannot be edited.
  @BuiltValueField(wireName: r'is_system')
  bool? get isSystem;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'permissions')
  BuiltList<String>? get permissions;

  /// Scope decides how far a holder of the role can see (TZ Q82.1).
  @BuiltValueField(wireName: r'scope')
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum? get scope;
  // enum scopeEnum {  company,  branch,  self,  };

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'user_count')
  int? get userCount;

  GithubComDevlineOnebookEldInternalDomainUsersDtoRole._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoRole([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoRole;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRole> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRole> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoRole, _$GithubComDevlineOnebookEldInternalDomainUsersDtoRole];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoRole';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoRole object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
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
    if (object.isSystem != null) {
      yield r'is_system';
      yield serializers.serialize(
        object.isSystem,
        specifiedType: const FullType(bool),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.permissions != null) {
      yield r'permissions';
      yield serializers.serialize(
        object.permissions,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.scope != null) {
      yield r'scope';
      yield serializers.serialize(
        object.scope,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.userCount != null) {
      yield r'user_count';
      yield serializers.serialize(
        object.userCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoRole object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'is_system':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isSystem = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'permissions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.permissions.replace(valueDes);
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum?;
          if (valueDes == null) continue;
          result.scope = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        case r'user_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.userCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRole deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder();
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


/// Scope decides how far a holder of the role can see (TZ Q82.1).
class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'company')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum company = _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_company;
  @BuiltValueEnumConst(wireName: r'branch')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum branch = _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_branch;
  @BuiltValueEnumConst(wireName: r'self')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum self = _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_self;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum> get values => _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleScopeEnumValueOf(name);
}

