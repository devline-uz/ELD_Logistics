//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_users_dto_user_role.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_user.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoUser
///
/// Properties:
/// * [activatedAt] 
/// * [branchId] 
/// * [branchName] 
/// * [createdAt] 
/// * [email] 
/// * [firstName] 
/// * [fullName] 
/// * [id] 
/// * [invitedAt] 
/// * [lastLoginAt] 
/// * [lastName] 
/// * [phone] 
/// * [role] 
/// * [status] - Status follows TZ Q1: invited -> active, active <-> inactive.
/// * [totpEnabled] 
/// * [updatedAt] 
/// * [username] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoUser implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoUser, GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder> {
  @BuiltValueField(wireName: r'activated_at')
  DateTime? get activatedAt;

  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'branch_name')
  String? get branchName;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'first_name')
  String? get firstName;

  @BuiltValueField(wireName: r'full_name')
  String? get fullName;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'invited_at')
  DateTime? get invitedAt;

  @BuiltValueField(wireName: r'last_login_at')
  DateTime? get lastLoginAt;

  @BuiltValueField(wireName: r'last_name')
  String? get lastName;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'role')
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole? get role;

  /// Status follows TZ Q1: invited -> active, active <-> inactive.
  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum? get status;
  // enum statusEnum {  invited,  active,  inactive,  };

  @BuiltValueField(wireName: r'totp_enabled')
  bool? get totpEnabled;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'username')
  String? get username;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUser._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoUser([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUser> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUser> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoUser, _$GithubComDevlineOnebookEldInternalDomainUsersDtoUser];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoUser object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.activatedAt != null) {
      yield r'activated_at';
      yield serializers.serialize(
        object.activatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.branchName != null) {
      yield r'branch_name';
      yield serializers.serialize(
        object.branchName,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
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
    if (object.fullName != null) {
      yield r'full_name';
      yield serializers.serialize(
        object.fullName,
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
    if (object.invitedAt != null) {
      yield r'invited_at';
      yield serializers.serialize(
        object.invitedAt,
        specifiedType: const FullType(DateTime),
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
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType(String),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum),
      );
    }
    if (object.totpEnabled != null) {
      yield r'totp_enabled';
      yield serializers.serialize(
        object.totpEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
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
    GithubComDevlineOnebookEldInternalDomainUsersDtoUser object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'activated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.activatedAt = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'branch_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchName = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
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
        case r'full_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fullName = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'invited_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.invitedAt = valueDes;
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
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoUserRole?;
          if (valueDes == null) continue;
          result.role.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum?;
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
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainUsersDtoUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder();
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


/// Status follows TZ Q1: invited -> active, active <-> inactive.
class GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'invited')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum invited = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_invited;
  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum active = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainUsersDtoUserStatusEnumValueOf(name);
}

