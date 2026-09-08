//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_notifications_dto_push_token.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_notifications_dto_push_token_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope, GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken? get data;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope, _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken),
          ) as GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushToken?;
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
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainNotificationsDtoPushTokenEnvelopeBuilder();
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


