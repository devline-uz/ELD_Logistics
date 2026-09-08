//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_invitation_sent.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent
///
/// Properties:
/// * [channel] 
/// * [expiresAt] 
/// * [purpose] 
/// * [userId] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent, GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentBuilder> {
  @BuiltValueField(wireName: r'channel')
  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum? get channel;
  // enum channelEnum {  email,  sms,  telegram,  };

  @BuiltValueField(wireName: r'expires_at')
  DateTime? get expiresAt;

  @BuiltValueField(wireName: r'purpose')
  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum? get purpose;
  // enum purposeEnum {  invitation,  password_reset,  };

  @BuiltValueField(wireName: r'user_id')
  String? get userId;

  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent, _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.channel != null) {
      yield r'channel';
      yield serializers.serialize(
        object.channel,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum),
      );
    }
    if (object.expiresAt != null) {
      yield r'expires_at';
      yield serializers.serialize(
        object.expiresAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.purpose != null) {
      yield r'purpose';
      yield serializers.serialize(
        object.purpose,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum),
      );
    }
    if (object.userId != null) {
      yield r'user_id';
      yield serializers.serialize(
        object.userId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'channel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum?;
          if (valueDes == null) continue;
          result.channel = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.expiresAt = valueDes;
          break;
        case r'purpose':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum?;
          if (valueDes == null) continue;
          result.purpose = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentBuilder();
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


class GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum email = _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum sms = _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum_sms;
  @BuiltValueEnumConst(wireName: r'telegram')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum telegram = _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum_telegram;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum> get values => _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnumValues;
  static GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentChannelEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'invitation')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum invitation = _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum_invitation;
  @BuiltValueEnumConst(wireName: r'password_reset')
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum passwordReset = _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum_passwordReset;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum> get values => _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentPurposeEnumValueOf(name);
}

