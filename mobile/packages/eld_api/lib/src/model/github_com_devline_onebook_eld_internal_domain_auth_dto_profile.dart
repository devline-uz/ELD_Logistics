//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_profile.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoProfile
///
/// Properties:
/// * [branchId] 
/// * [companyId] - CompanyID is empty for platform (super admin) accounts.
/// * [email] - Email is masked for anyone but the account owner.
/// * [firstName] 
/// * [id] 
/// * [isSuperAdmin] 
/// * [lastLoginAt] 
/// * [lastName] 
/// * [permissions] 
/// * [pinSet] 
/// * [roleId] 
/// * [roleName] 
/// * [scope] 
/// * [status] 
/// * [totpEnabled] 
/// * [username] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoProfile implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoProfile, GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  /// CompanyID is empty for platform (super admin) accounts.
  @BuiltValueField(wireName: r'company_id')
  String? get companyId;

  /// Email is masked for anyone but the account owner.
  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'first_name')
  String? get firstName;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'is_super_admin')
  bool? get isSuperAdmin;

  @BuiltValueField(wireName: r'last_login_at')
  DateTime? get lastLoginAt;

  @BuiltValueField(wireName: r'last_name')
  String? get lastName;

  @BuiltValueField(wireName: r'permissions')
  BuiltList<String>? get permissions;

  @BuiltValueField(wireName: r'pin_set')
  bool? get pinSet;

  @BuiltValueField(wireName: r'role_id')
  String? get roleId;

  @BuiltValueField(wireName: r'role_name')
  String? get roleName;

  @BuiltValueField(wireName: r'scope')
  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum? get scope;
  // enum scopeEnum {  company,  branch,  self,  };

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum? get status;
  // enum statusEnum {  invited,  active,  inactive,  };

  @BuiltValueField(wireName: r'totp_enabled')
  bool? get totpEnabled;

  @BuiltValueField(wireName: r'username')
  String? get username;

  GithubComDevlineOnebookEldInternalDomainAuthDtoProfile._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoProfile([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfile;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoProfile> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfileSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfileSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoProfile> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoProfile, _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfile];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoProfile';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.companyId != null) {
      yield r'company_id';
      yield serializers.serialize(
        object.companyId,
        specifiedType: const FullType(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    if (object.firstName != null) {
      yield r'first_name';
      yield serializers.serialize(
        object.firstName,
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
    if (object.isSuperAdmin != null) {
      yield r'is_super_admin';
      yield serializers.serialize(
        object.isSuperAdmin,
        specifiedType: const FullType(bool),
      );
    }
    if (object.lastLoginAt != null) {
      yield r'last_login_at';
      yield serializers.serialize(
        object.lastLoginAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.lastName != null) {
      yield r'last_name';
      yield serializers.serialize(
        object.lastName,
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
    if (object.pinSet != null) {
      yield r'pin_set';
      yield serializers.serialize(
        object.pinSet,
        specifiedType: const FullType(bool),
      );
    }
    if (object.roleId != null) {
      yield r'role_id';
      yield serializers.serialize(
        object.roleId,
        specifiedType: const FullType(String),
      );
    }
    if (object.roleName != null) {
      yield r'role_name';
      yield serializers.serialize(
        object.roleName,
        specifiedType: const FullType(String),
      );
    }
    if (object.scope != null) {
      yield r'scope';
      yield serializers.serialize(
        object.scope,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum),
      );
    }
    if (object.totpEnabled != null) {
      yield r'totp_enabled';
      yield serializers.serialize(
        object.totpEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.username != null) {
      yield r'username';
      yield serializers.serialize(
        object.username,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'company_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.companyId = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'first_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.firstName = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'is_super_admin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isSuperAdmin = valueDes;
          break;
        case r'last_login_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastLoginAt = valueDes;
          break;
        case r'last_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastName = valueDes;
          break;
        case r'permissions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.permissions.replace(valueDes);
          break;
        case r'pin_set':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.pinSet = valueDes;
          break;
        case r'role_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.roleId = valueDes;
          break;
        case r'role_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.roleName = valueDes;
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum?;
          if (valueDes == null) continue;
          result.scope = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'totp_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.totpEnabled = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.username = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoProfile deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder();
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


class GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'company')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum company = _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum_company;
  @BuiltValueEnumConst(wireName: r'branch')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum branch = _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum_branch;
  @BuiltValueEnumConst(wireName: r'self')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum self = _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum_self;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum> get values => _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileScopeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'invited')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum invited = _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum_invited;
  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum active = _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainAuthDtoProfileStatusEnumValueOf(name);
}

