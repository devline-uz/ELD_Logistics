//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_notifications_dto_read_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_notifications_dto_read_result_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope, GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult? get data;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope, _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult),
          ) as GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult?;
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
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder();
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


