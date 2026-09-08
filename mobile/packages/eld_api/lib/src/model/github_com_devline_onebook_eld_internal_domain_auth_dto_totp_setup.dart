//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_totp_setup.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup
///
/// Properties:
/// * [digits] - Digits and Period describe the expected authenticator configuration.
/// * [issuer] 
/// * [otpauthUrl] - OtpauthURL is rendered as a QR code by the client.
/// * [period] 
/// * [secret] - Secret is the base32 value for manual entry. It is shown once and is stored AES-256-GCM encrypted.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup, GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder> {
  /// Digits and Period describe the expected authenticator configuration.
  @BuiltValueField(wireName: r'digits')
  int? get digits;

  @BuiltValueField(wireName: r'issuer')
  String? get issuer;

  /// OtpauthURL is rendered as a QR code by the client.
  @BuiltValueField(wireName: r'otpauth_url')
  String? get otpauthUrl;

  @BuiltValueField(wireName: r'period')
  int? get period;

  /// Secret is the base32 value for manual entry. It is shown once and is stored AES-256-GCM encrypted.
  @BuiltValueField(wireName: r'secret')
  String? get secret;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup, _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.digits != null) {
      yield r'digits';
      yield serializers.serialize(
        object.digits,
        specifiedType: const FullType(int),
      );
    }
    if (object.issuer != null) {
      yield r'issuer';
      yield serializers.serialize(
        object.issuer,
        specifiedType: const FullType(String),
      );
    }
    if (object.otpauthUrl != null) {
      yield r'otpauth_url';
      yield serializers.serialize(
        object.otpauthUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.period != null) {
      yield r'period';
      yield serializers.serialize(
        object.period,
        specifiedType: const FullType(int),
      );
    }
    if (object.secret != null) {
      yield r'secret';
      yield serializers.serialize(
        object.secret,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'digits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.digits = valueDes;
          break;
        case r'issuer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.issuer = valueDes;
          break;
        case r'otpauth_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.otpauthUrl = valueDes;
          break;
        case r'period':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.period = valueDes;
          break;
        case r'secret':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.secret = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder();
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


