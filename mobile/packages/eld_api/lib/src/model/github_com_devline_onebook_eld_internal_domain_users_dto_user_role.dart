//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_user_role.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole
///
/// Properties:
/// * [id] 
/// * [isSystem] 
/// * [name] 
/// * [scope] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole, GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'is_system')
  bool? get isSystem;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'scope')
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum? get scope;
  // enum scopeEnum {  company,  branch,  self,  };

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole, _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.scope != null) {
      yield r'scope';
      yield serializers.serialize(
        object.scope,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum?;
          if (valueDes == null) continue;
          result.scope = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleBuilder();
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


class GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'company')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum company = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_company;
  @BuiltValueEnumConst(wireName: r'branch')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum branch = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_branch;
  @BuiltValueEnumConst(wireName: r'self')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum self = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_self;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum> get values => _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainUsersDtoUserRoleScopeEnumValueOf(name);
}

