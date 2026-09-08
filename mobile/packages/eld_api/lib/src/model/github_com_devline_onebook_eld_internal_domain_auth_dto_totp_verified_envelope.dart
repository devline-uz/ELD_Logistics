//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auth_dto_totp_verified.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_totp_verified_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope, GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified? get data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope, _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder();
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


