//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auth_dto_profile.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_login_result.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult
///
/// Properties:
/// * [accessToken] 
/// * [expiresIn] - ExpiresIn is the access token lifetime in seconds.
/// * [refreshExpiresAt] - RefreshExpiresAt is when the refresh window closes.
/// * [refreshToken] - RefreshToken is empty while the session is limited to 2FA enrolment.
/// * [replacedSession] - ReplacedSession reports that another session of the same device type was revoked by this login (TZ A§20).
/// * [requiresTotpSetup] - RequiresTOTPSetup marks a limited token: the account must enrol in two factor authentication before anything else is permitted.
/// * [sessionId] - SessionID identifies the session created by this login.
/// * [subscriptionReadonly] - SubscriptionReadonly reports that the company subscription lapsed and only read operations are accepted.
/// * [tokenType] 
/// * [user] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult, GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder> {
  @BuiltValueField(wireName: r'access_token')
  String? get accessToken;

  /// ExpiresIn is the access token lifetime in seconds.
  @BuiltValueField(wireName: r'expires_in')
  int? get expiresIn;

  /// RefreshExpiresAt is when the refresh window closes.
  @BuiltValueField(wireName: r'refresh_expires_at')
  DateTime? get refreshExpiresAt;

  /// RefreshToken is empty while the session is limited to 2FA enrolment.
  @BuiltValueField(wireName: r'refresh_token')
  String? get refreshToken;

  /// ReplacedSession reports that another session of the same device type was revoked by this login (TZ A§20).
  @BuiltValueField(wireName: r'replaced_session')
  bool? get replacedSession;

  /// RequiresTOTPSetup marks a limited token: the account must enrol in two factor authentication before anything else is permitted.
  @BuiltValueField(wireName: r'requires_totp_setup')
  bool? get requiresTotpSetup;

  /// SessionID identifies the session created by this login.
  @BuiltValueField(wireName: r'session_id')
  String? get sessionId;

  /// SubscriptionReadonly reports that the company subscription lapsed and only read operations are accepted.
  @BuiltValueField(wireName: r'subscription_readonly')
  bool? get subscriptionReadonly;

  @BuiltValueField(wireName: r'token_type')
  String? get tokenType;

  @BuiltValueField(wireName: r'user')
  GithubComDevlineOnebookEldInternalDomainAuthDtoProfile? get user;

  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult, _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.accessToken != null) {
      yield r'access_token';
      yield serializers.serialize(
        object.accessToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.expiresIn != null) {
      yield r'expires_in';
      yield serializers.serialize(
        object.expiresIn,
        specifiedType: const FullType(int),
      );
    }
    if (object.refreshExpiresAt != null) {
      yield r'refresh_expires_at';
      yield serializers.serialize(
        object.refreshExpiresAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.refreshToken != null) {
      yield r'refresh_token';
      yield serializers.serialize(
        object.refreshToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.replacedSession != null) {
      yield r'replaced_session';
      yield serializers.serialize(
        object.replacedSession,
        specifiedType: const FullType(bool),
      );
    }
    if (object.requiresTotpSetup != null) {
      yield r'requires_totp_setup';
      yield serializers.serialize(
        object.requiresTotpSetup,
        specifiedType: const FullType(bool),
      );
    }
    if (object.sessionId != null) {
      yield r'session_id';
      yield serializers.serialize(
        object.sessionId,
        specifiedType: const FullType(String),
      );
    }
    if (object.subscriptionReadonly != null) {
      yield r'subscription_readonly';
      yield serializers.serialize(
        object.subscriptionReadonly,
        specifiedType: const FullType(bool),
      );
    }
    if (object.tokenType != null) {
      yield r'token_type';
      yield serializers.serialize(
        object.tokenType,
        specifiedType: const FullType(String),
      );
    }
    if (object.user != null) {
      yield r'user';
      yield serializers.serialize(
        object.user,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoProfile),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'access_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.accessToken = valueDes;
          break;
        case r'expires_in':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.expiresIn = valueDes;
          break;
        case r'refresh_expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.refreshExpiresAt = valueDes;
          break;
        case r'refresh_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.refreshToken = valueDes;
          break;
        case r'replaced_session':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.replacedSession = valueDes;
          break;
        case r'requires_totp_setup':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.requiresTotpSetup = valueDes;
          break;
        case r'session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sessionId = valueDes;
          break;
        case r'subscription_readonly':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.subscriptionReadonly = valueDes;
          break;
        case r'token_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tokenType = valueDes;
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoProfile),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoProfile?;
          if (valueDes == null) continue;
          result.user.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder();
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


