//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_role_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate
///
/// Properties:
/// * [description] 
/// * [name] 
/// * [permissions] - Permissions replaces the whole set when present.
/// * [scope] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate, GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder> {
  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'name')
  String? get name;

  /// Permissions replaces the whole set when present.
  @BuiltValueField(wireName: r'permissions')
  BuiltList<String> get permissions;

  @BuiltValueField(wireName: r'scope')
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum? get scope;
  // enum scopeEnum {  company,  branch,  };

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate, _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    yield r'permissions';
    yield serializers.serialize(
      object.permissions,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.scope != null) {
      yield r'scope';
      yield serializers.serialize(
        object.scope,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum?;
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
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'company')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum company = _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_company;
  @BuiltValueEnumConst(wireName: r'branch')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum branch = _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_branch;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum> get values => _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainUsersDtoRoleUpdateScopeEnumValueOf(name);
}

