//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_totp_verify_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest
///
/// Properties:
/// * [code] 
/// * [recoveryCode] - RecoveryCode is accepted instead of Code when the device is lost.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest, GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder> {
  @BuiltValueField(wireName: r'code')
  String? get code;

  /// RecoveryCode is accepted instead of Code when the device is lost.
  @BuiltValueField(wireName: r'recovery_code')
  String? get recoveryCode;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest, _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(String),
      );
    }
    if (object.recoveryCode != null) {
      yield r'recovery_code';
      yield serializers.serialize(
        object.recoveryCode,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        case r'recovery_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.recoveryCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifyRequestBuilder();
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


