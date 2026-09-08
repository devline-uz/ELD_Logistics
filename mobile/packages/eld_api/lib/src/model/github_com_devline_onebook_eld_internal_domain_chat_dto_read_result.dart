//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_chat_dto_read_result.g.dart';

/// GithubComDevlineOnebookEldInternalDomainChatDtoReadResult
///
/// Properties:
/// * [unread] 
/// * [updated] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainChatDtoReadResult implements Built<GithubComDevlineOnebookEldInternalDomainChatDtoReadResult, GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder> {
  @BuiltValueField(wireName: r'unread')
  int? get unread;

  @BuiltValueField(wireName: r'updated')
  int? get updated;

  GithubComDevlineOnebookEldInternalDomainChatDtoReadResult._();

  factory GithubComDevlineOnebookEldInternalDomainChatDtoReadResult([void updates(GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoReadResult> get serializer => _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResultSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResultSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainChatDtoReadResult> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainChatDtoReadResult, _$GithubComDevlineOnebookEldInternalDomainChatDtoReadResult];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainChatDtoReadResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoReadResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.unread != null) {
      yield r'unread';
      yield serializers.serialize(
        object.unread,
        specifiedType: const FullType(int),
      );
    }
    if (object.updated != null) {
      yield r'updated';
      yield serializers.serialize(
        object.updated,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoReadResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'unread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.unread = valueDes;
          break;
        case r'updated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.updated = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoReadResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainChatDtoReadResultBuilder();
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


