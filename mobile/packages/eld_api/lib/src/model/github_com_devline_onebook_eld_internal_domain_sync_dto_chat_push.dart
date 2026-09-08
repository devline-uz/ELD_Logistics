//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_chat_push.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush
///
/// Properties:
/// * [clientId] - ClientID is the device generated idempotency key of the message.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush, GithubComDevlineOnebookEldInternalDomainSyncDtoChatPushBuilder> {
  /// ClientID is the device generated idempotency key of the message.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoChatPushBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoChatPushBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatPushSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatPushSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush, _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoChatPushBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoChatPushBuilder();
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


