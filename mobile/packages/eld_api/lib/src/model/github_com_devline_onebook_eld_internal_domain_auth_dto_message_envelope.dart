//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auth_dto_message_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_message_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope, GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse? get data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope, _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse?;
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
  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder();
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


