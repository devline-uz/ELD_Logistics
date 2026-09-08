//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_users_dto_permission.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_permission_module.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule
///
/// Properties:
/// * [label] 
/// * [module] 
/// * [permissions] - Permissions are ordered exactly like the catalogue.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule, GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder> {
  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'module')
  String? get module;

  /// Permissions are ordered exactly like the catalogue.
  @BuiltValueField(wireName: r'permissions')
  BuiltList<GithubComDevlineOnebookEldInternalDomainUsersDtoPermission>? get permissions;

  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule, _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType(String),
      );
    }
    if (object.module != null) {
      yield r'module';
      yield serializers.serialize(
        object.module,
        specifiedType: const FullType(String),
      );
    }
    if (object.permissions != null) {
      yield r'permissions';
      yield serializers.serialize(
        object.permissions,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoPermission)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'module':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.module = valueDes;
          break;
        case r'permissions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoPermission)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainUsersDtoPermission>?;
          if (valueDes == null) continue;
          result.permissions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder();
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


