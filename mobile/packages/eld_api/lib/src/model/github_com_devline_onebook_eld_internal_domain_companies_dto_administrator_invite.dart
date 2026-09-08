//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_companies_dto_administrator_invite.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite
///
/// Properties:
/// * [channel] - Channel selects how the invitation link is delivered.
/// * [email] 
/// * [firstName] 
/// * [lastName] 
/// * [phone] 
/// * [username] - Username defaults to the local part of the email address.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite implements Built<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite, GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder> {
  /// Channel selects how the invitation link is delivered.
  @BuiltValueField(wireName: r'channel')
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum? get channel;
  // enum channelEnum {  email,  sms,  telegram,  };

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'first_name')
  String get firstName;

  @BuiltValueField(wireName: r'last_name')
  String get lastName;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  /// Username defaults to the local part of the email address.
  @BuiltValueField(wireName: r'username')
  String? get username;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite._();

  factory GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite([void updates(GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite, _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.channel != null) {
      yield r'channel';
      yield serializers.serialize(
        object.channel,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum),
      );
    }
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
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
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'channel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum?;
          if (valueDes == null) continue;
          result.channel = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInvite deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteBuilder();
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


/// Channel selects how the invitation link is delivered.
class GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum email = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum sms = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_sms;
  @BuiltValueEnumConst(wireName: r'telegram')
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum telegram = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_telegram;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompaniesDtoAdministratorInviteChannelEnumValueOf(name);
}

