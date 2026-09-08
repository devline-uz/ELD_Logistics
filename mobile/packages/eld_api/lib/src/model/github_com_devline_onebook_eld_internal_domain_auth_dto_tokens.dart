//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_tokens.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoTokens
///
/// Properties:
/// * [accessToken] 
/// * [expiresIn] - ExpiresIn is the access token lifetime in seconds.
/// * [refreshExpiresAt] - RefreshExpiresAt is when the refresh window closes.
/// * [refreshToken] - RefreshToken is empty while the session is limited to 2FA enrolment.
/// * [tokenType] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoTokens implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoTokens, GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder> {
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

  @BuiltValueField(wireName: r'token_type')
  String? get tokenType;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTokens._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoTokens([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokens;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTokens> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTokens> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoTokens, _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokens];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoTokens';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTokens object, {
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
    if (object.tokenType != null) {
      yield r'token_type';
      yield serializers.serialize(
        object.tokenType,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTokens object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder result,
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
        case r'token_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tokenType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokens deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder();
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


