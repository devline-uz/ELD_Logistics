//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auth_dto_totp_setup.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_totp_setup_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope, GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup? get data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope, _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup?;
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
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder();
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


