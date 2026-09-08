//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_role_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate
///
/// Properties:
/// * [description] 
/// * [name] 
/// * [permissions] - Permissions must be keys of GET /permissions; unknown keys are rejected.
/// * [scope] - Scope is company or branch; `self` is reserved for the built in Driver role.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate, GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder> {
  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'name')
  String get name;

  /// Permissions must be keys of GET /permissions; unknown keys are rejected.
  @BuiltValueField(wireName: r'permissions')
  BuiltList<String> get permissions;

  /// Scope is company or branch; `self` is reserved for the built in Driver role.
  @BuiltValueField(wireName: r'scope')
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum get scope;
  // enum scopeEnum {  company,  branch,  };

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate, _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'permissions';
    yield serializers.serialize(
      object.permissions,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'permissions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.permissions.replace(valueDes);
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum;
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
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateBuilder();
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


/// Scope is company or branch; `self` is reserved for the built in Driver role.
class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'company')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum company = _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_company;
  @BuiltValueEnumConst(wireName: r'branch')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum branch = _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_branch;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum> get values => _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleCreateScopeEnumValueOf(name);
}

