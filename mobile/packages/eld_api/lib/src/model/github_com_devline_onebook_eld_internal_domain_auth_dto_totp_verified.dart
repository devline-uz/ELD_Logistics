//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auth_dto_tokens.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_totp_verified.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified
///
/// Properties:
/// * [enabled] 
/// * [recoveryCodes] - RecoveryCodes are shown exactly once, at enrolment. Only their hashes are stored and each code works a single time.
/// * [tokens] - Tokens is filled when the verification upgraded a limited session.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified, GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  /// RecoveryCodes are shown exactly once, at enrolment. Only their hashes are stored and each code works a single time.
  @BuiltValueField(wireName: r'recovery_codes')
  BuiltList<String>? get recoveryCodes;

  /// Tokens is filled when the verification upgraded a limited session.
  @BuiltValueField(wireName: r'tokens')
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokens? get tokens;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified, _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.recoveryCodes != null) {
      yield r'recovery_codes';
      yield serializers.serialize(
        object.recoveryCodes,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.tokens != null) {
      yield r'tokens';
      yield serializers.serialize(
        object.tokens,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoTokens),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.enabled = valueDes;
          break;
        case r'recovery_codes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.recoveryCodes.replace(valueDes);
          break;
        case r'tokens':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoTokens),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoTokens?;
          if (valueDes == null) continue;
          result.tokens.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder();
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


