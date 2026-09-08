//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_user_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate
///
/// Properties:
/// * [branchId] - BranchID is required for a branch scoped role.
/// * [channel] - Channel selects how the invitation is delivered; empty picks email when an address is present, otherwise sms.
/// * [email] - Email or Phone is required: it is the channel the invitation is sent on.
/// * [firstName] 
/// * [lastName] 
/// * [phone] 
/// * [roleId] 
/// * [username] - Username must be unique inside the company.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate, GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder> {
  /// BranchID is required for a branch scoped role.
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  /// Channel selects how the invitation is delivered; empty picks email when an address is present, otherwise sms.
  @BuiltValueField(wireName: r'channel')
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum? get channel;
  // enum channelEnum {  email,  sms,  telegram,  };

  /// Email or Phone is required: it is the channel the invitation is sent on.
  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'first_name')
  String get firstName;

  @BuiltValueField(wireName: r'last_name')
  String get lastName;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'role_id')
  String get roleId;

  /// Username must be unique inside the company.
  @BuiltValueField(wireName: r'username')
  String get username;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate, _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.channel != null) {
      yield r'channel';
      yield serializers.serialize(
        object.channel,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    yield r'first_name';
    yield serializers.serialize(
      object.firstName,
      specifiedType: const FullType(String),
    );
    yield r'last_name';
    yield serializers.serialize(
      object.lastName,
      specifiedType: const FullType(String),
    );
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType(String),
      );
    }
    yield r'role_id';
    yield serializers.serialize(
      object.roleId,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder result,
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
        case r'channel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum?;
          if (valueDes == null) continue;
          result.channel = valueDes;
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
            specifiedType: const FullType(String),
          ) as String;
          result.firstName = valueDes;
          break;
        case r'last_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
        case r'role_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.roleId = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateBuilder();
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


/// Channel selects how the invitation is delivered; empty picks email when an address is present, otherwise sms.
class GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum email = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum sms = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_sms;
  @BuiltValueEnumConst(wireName: r'telegram')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum telegram = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_telegram;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum> get values => _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnumValues;
  static GithubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainUsersDtoUserCreateChannelEnumValueOf(name);
}

