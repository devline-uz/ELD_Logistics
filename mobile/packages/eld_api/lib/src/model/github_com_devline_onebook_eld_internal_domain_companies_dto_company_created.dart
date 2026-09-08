//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_companies_dto_company.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_companies_dto_company_created.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated
///
/// Properties:
/// * [administratorRoleId] - AdministratorRoleID is the company's copy of the Administrator role.
/// * [administratorUserId] - AdministratorUserID is the invited Administrator account.
/// * [company] 
/// * [invitationChannel] - InvitationChannel is how the link was delivered.
/// * [invitationExpiresAt] - InvitationExpiresAt is when the invitation link stops working (72 h).
/// * [rolesCreated] - RolesCreated is the number of system role templates copied.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated implements Built<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated, GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder> {
  /// AdministratorRoleID is the company's copy of the Administrator role.
  @BuiltValueField(wireName: r'administrator_role_id')
  String? get administratorRoleId;

  /// AdministratorUserID is the invited Administrator account.
  @BuiltValueField(wireName: r'administrator_user_id')
  String? get administratorUserId;

  @BuiltValueField(wireName: r'company')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany? get company;

  /// InvitationChannel is how the link was delivered.
  @BuiltValueField(wireName: r'invitation_channel')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum? get invitationChannel;
  // enum invitationChannelEnum {  email,  sms,  telegram,  };

  /// InvitationExpiresAt is when the invitation link stops working (72 h).
  @BuiltValueField(wireName: r'invitation_expires_at')
  DateTime? get invitationExpiresAt;

  /// RolesCreated is the number of system role templates copied.
  @BuiltValueField(wireName: r'roles_created')
  int? get rolesCreated;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated._();

  factory GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated([void updates(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated, _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.administratorRoleId != null) {
      yield r'administrator_role_id';
      yield serializers.serialize(
        object.administratorRoleId,
        specifiedType: const FullType(String),
      );
    }
    if (object.administratorUserId != null) {
      yield r'administrator_user_id';
      yield serializers.serialize(
        object.administratorUserId,
        specifiedType: const FullType(String),
      );
    }
    if (object.company != null) {
      yield r'company';
      yield serializers.serialize(
        object.company,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany),
      );
    }
    if (object.invitationChannel != null) {
      yield r'invitation_channel';
      yield serializers.serialize(
        object.invitationChannel,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum),
      );
    }
    if (object.invitationExpiresAt != null) {
      yield r'invitation_expires_at';
      yield serializers.serialize(
        object.invitationExpiresAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.rolesCreated != null) {
      yield r'roles_created';
      yield serializers.serialize(
        object.rolesCreated,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'administrator_role_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.administratorRoleId = valueDes;
          break;
        case r'administrator_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.administratorUserId = valueDes;
          break;
        case r'company':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompany?;
          if (valueDes == null) continue;
          result.company.replace(valueDes);
          break;
        case r'invitation_channel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum?;
          if (valueDes == null) continue;
          result.invitationChannel = valueDes;
          break;
        case r'invitation_expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.invitationExpiresAt = valueDes;
          break;
        case r'roles_created':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.rolesCreated = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreated deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedBuilder();
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


/// InvitationChannel is how the link was delivered.
class GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum email = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum sms = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_sms;
  @BuiltValueEnumConst(wireName: r'telegram')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum telegram = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_telegram;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoCompanyCreatedInvitationChannelEnumValueOf(name);
}

