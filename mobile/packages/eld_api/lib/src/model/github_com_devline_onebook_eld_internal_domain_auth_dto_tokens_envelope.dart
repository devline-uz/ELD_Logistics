//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auth_dto_tokens.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_tokens_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope, GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokens? get data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope, _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoTokens),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoTokens),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoTokens?;
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
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder();
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


